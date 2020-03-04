component {

    function commandboxModules() {
        var required_modules = {
            'commandbox-cfconfig': 'commandbox-cfconfig',
            'commandbox-lex': 'jcberquist/commandbox-lex'
        };

        print.line( 'Checking system modules...' ).toConsole();

        try {
            var output = print.unANSI( command( 'package list --system --JSON' ).run( returnOutput = true ) ).trim();
            var modules = deserializeJSON( output ).dependencies.keyArray();
        } catch ( any e ) {
            var modules = [ ];
        }

        var modules_installed = true;
        for ( var m in required_modules ) {
            if ( !modules.find( m ) ) {
                modules_installed = false;
                command( 'install #required_modules[ m ]#' ).run();
            }
        }

        return modules_installed;
    }

    function dockerWarmup() {
        command( 'mkdir /serverHome/' ).run();

        print.line( 'Starting server...' );
        command( 'server start openbrowser=false saveSettings=false' ).run();

        while ( true ) {
            print.line( 'Waiting for server...' ).toConsole();
            var logs = command( 'server log' ).run( returnOutput = true );
            if ( logs.contains( 'Server is up' ) ) {
                print.line( 'Server is up.' ).toConsole();
                break;
            }
            sleep( 1000 );
        }

        print.line( 'Installing extensions.' ).toConsole();
        command( 'lex install --wait' ).run();

        print.line( 'Stopping server...' ).toConsole();
        command( 'server stop' ).run();

        print.line( 'Generating start script...' ).toConsole();
        command( 'server start --dryrun --console openbrowser=false saveSettings=false startScript=bash' ).run();
        command( '!chmod +x ./server-start.sh' ).run();

        print.line( 'Cleaning up start script...' ).toConsole();
        var startScriptFile = resolvePath( './server-start.sh' );
        var startScript = fileRead( startScriptFile );
        // use exec so Java gets to be PID 1
        startScript = startScript.reReplace( '(\n)([^\n]+/java)', '\1exec \2' );
        // remove uneeded tray config items
        startScript = startScript.reReplace( '\n[\t ]+''--tray-(icon|config)[^\n]+', '', 'all' );
        // update runwar location
        startScript = startScript.replace( '/root/.CommandBox/lib/runwar-', '/serverHome/runwar-' );
        fileWrite( startScriptFile, startScript );
    }

}
