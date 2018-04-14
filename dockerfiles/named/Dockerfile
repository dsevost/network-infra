FROM dsevosty/network-infra:latest

#
# 
#
MAINTAINER dmitry sevostyanov <dmitry.sevostyanov@gmail.com>

ENV \
    BIND_USER=named \
    NAMED_ETC=/etc/named \
    NAMED_DATA=/var/named

EXPOSE 8053/tcp 8053/udp

COPY resources/*.sh /usr/local/bin/

RUN \
    [ -d "$NAMED_ETC" ] && rm -rf ${NAMED_ETC}{,_ro} ; \
    mkdir -p ${NAMED_ETC}{,_ro} ; \
    cp /var/named/named.ca ${NAMED_ETC}_ro ; \
    cp /etc/named.rfc1912.zones ${NAMED_ETC}_ro ; \
    /usr/sbin/rndc-confgen -a -u named -r /dev/urandom -c ${NAMED_ETC}_ro/rndc.key ; \
    chown -R $BIND_USER ${NAMED_ETC}{,_ro} ; \
    chmod 644 ${NAMED_ETC}_ro/* ; \
    chmod 777 /var/run/named ; \
    chmod 755 /usr/local/bin/*.sh

COPY resources/*.template ${NAMED_ETC}_ro/

#ENTRYPOINT /usr/sbin/named-checkconf $NAMED_ETC/named.conf && /usr/sbin/named -g -u $BIND_USER -c $NAMED_ETC/named.conf
CMD /usr/sbin/named -g -c $NAMED_ETC/named.conf
