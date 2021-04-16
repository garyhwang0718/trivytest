FROM alpine:3.12

RUN echo 'hosts: files dns' >> /etc/nsswitch.conf
RUN apk add --update --no-cache tzdata bash apk-cron curl jq logrotate ca-certificates && \
    update-ca-certificates

ENV INFLUXDB_VERSION 1.8.3
ENV KAPACITOR_VERSION 1.5.7

RUN set -ex && \
    mkdir ~/.gnupg; \
    echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
    apk add --no-cache --virtual .build-deps wget gnupg tar && \
    chmod 600 ~/.gnupg/* && \
    chmod 700 ~/.gnupg && \
    for key in \
        05CE15085FC09D18E99EFB22684A14CF2582E0C5 ; \
    do \
        gpg --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --keyserver hkp://pgp.mit.edu --recv-keys:80 "$key" || \
        gpg --keyserver hkp://keyserver.pgp.com:80 --recv-keys "$key" ; \
    done && \
    wget --no-verbose https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz.asc && \
    wget --no-verbose https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz && \
    gpg --batch --verify influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz.asc influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz && \
    mkdir -p /usr/src && \
    tar -C /usr/src -xzf influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz && \
    rm -f /usr/src/influxdb-*/influxdb.conf && \
    chmod +x /usr/src/influxdb-*/* && \
    cp -a /usr/src/influxdb-*/* /usr/bin/ && \
    wget --no-verbose https://dl.influxdata.com/kapacitor/releases/kapacitor-${KAPACITOR_VERSION}-static_linux_amd64.tar.gz.asc && \
    wget --no-verbose https://dl.influxdata.com/kapacitor/releases/kapacitor-${KAPACITOR_VERSION}-static_linux_amd64.tar.gz && \
    gpg --batch --verify kapacitor-${KAPACITOR_VERSION}-static_linux_amd64.tar.gz.asc kapacitor-${KAPACITOR_VERSION}-static_linux_amd64.tar.gz && \
    mkdir -p /usr/src && \
    tar -C /usr/src -xzf kapacitor-${KAPACITOR_VERSION}-static_linux_amd64.tar.gz && \
    rm -f /usr/src/kapacitor-*/kapacitor.conf && \
    chmod +x /usr/src/kapacitor-*/* && \
    cp -a /usr/src/kapacitor-*/* /usr/bin/ && \
    rm -rf /etc/periodic/daily/apk && \
    mv /etc/periodic/daily/logrotate /etc/periodic/hourly && \
    gpgconf --kill all && \
    rm -rf *.tar.gz* /usr/src /root/.gnupg && \
    apk del .build-deps
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf

EXPOSE 8086

VOLUME /var/lib/influxdb

COPY entrypoint.sh /entrypoint.sh
COPY influxdb/init-influxdb.sh /init-influxdb.sh
COPY influxdb/migrate.sh /usr/bin/migrate.sh

RUN chmod a+x /entrypoint.sh && chmod a+x /init-influxdb.sh && mkdir -p /var/log/influxdb/ && chmod a+x /usr/bin/migrate.sh

COPY kapacitor/kapacitor.conf /etc/kapacitor/kapacitor.conf
COPY logrotate/influx /etc/logrotate.d/
COPY logrotate/kapacitor /etc/logrotate.d/
RUN chmod 644 /etc/logrotate.d/influx && chmod 644 /etc/logrotate.d/kapacitor

EXPOSE 9092

VOLUME /var/lib/kapacitor

ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd"]

