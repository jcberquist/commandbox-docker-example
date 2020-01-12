FROM amazoncorretto:8

RUN yum install -y which && yum clean -y all

COPY box-4.8.0 /usr/bin/box
RUN chmod 755 /usr/bin/box && \
    echo "$(box version) successfully installed"

COPY ./ServerService.cfc /root/.CommandBox/cfml/system/services/
COPY ./task.cfc /app/

WORKDIR /app/

RUN box task run

COPY ./index.cfm /app/

CMD $(box server start --console --command openbrowser=false savesettings=false host=0.0.0.0 port=80 | tail -n 1)
