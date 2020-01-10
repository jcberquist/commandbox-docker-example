component {

    function run() {
        print.line('Starting server...').toConsole();;
        command( 'server start openbrowser=false saveSettings=false host=0.0.0.0 port=80' ).run();

        while (true) {
            print.line('Waiting for server...').toConsole();
            var logs = command( 'server log' ).run(returnOutput = true);
            if (logs.contains('Server is up')) {
                break;
            }
            sleep(1000);
        }

        print.line('Console output available, and server is up, stopping server...');
        command('server stop').run();
    }

}
