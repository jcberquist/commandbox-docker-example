# syntax=docker/dockerfile:1.0.0-experimental
FROM adoptopenjdk/openjdk11:slim as lucee

COPY ./artifacts/box-5.0.0 /usr/bin/box
RUN chmod 755 /usr/bin/box && \
    echo "$(box version) successfully installed"
COPY ./artifacts/lucee-light /root/.CommandBox/artifacts/lucee-light
COPY ./artifacts/esapi-extension-2.1.0.17.lex /root/lucee-extensions/

WORKDIR /app/

COPY ./config/ /app/
RUN box task run task.cfc commandboxModules
RUN box task run task.cfc dockerWarmup


FROM adoptopenjdk/openjdk11:slim as app

COPY --from=lucee /serverHome/ /serverHome/
COPY --from=lucee /root/.CommandBox/lib/runwar-4.0.2.jar /serverHome/
COPY --from=lucee /app/server-start.sh /usr/bin/

COPY ./app/ /app/

CMD server-start.sh
