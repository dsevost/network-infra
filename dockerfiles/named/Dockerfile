FROM dsevosty/network-infra:latest

#
# 
#
MAINTAINER dmitry sevostyanov <dmitry.sevostyanov@gmail.com>

ENV \
    BIND_USER=named \
    NAMED_ETC=/etc/named \
    NAMED_DATA=/var/named

EXPOSE 53/tcp 53/udp

RUN \
    [ -d "$NAMED_ETC" ] && rm -rf ${NAMED_ETC}{,_ro} ; \
    mkdir -p ${NAMED_ETC}{,_ro} ; \
    cp /var/named/named.ca ${NAMED_ETC}_ro ; \
    /usr/sbin/rndc-confgen -a -u named -r /dev/urandom -c ${NAMED_ETC}_ro/rndc.key ; \
    chown -R $BIND_USER ${NAMED_ETC}{,_ro} 
#    ; \
#    chmod 644 -R ${NAMED_ETC}{,_ro}

COPY resources/*.template ${NAMED_ETC}_ro/
COPY resources/init-named.sh /usr/local/sbin/

#VOLUME ["$NAMED_ETC", "$NAMED_DATA"]

#ENTRYPOINT /usr/sbin/named-checkconf $NAMED_ETC/named.conf && /usr/sbin/named -g -u $BIND_USER -c $NAMED_ETC/named.conf
CMD /usr/sbin/named -g -u $BIND_USER -c $NAMED_ETC/named.conf
