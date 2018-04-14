#!/bin/bash

set -xe

tmpl_suffix="template"

function str2list() {
    local VAR=$1
    local ret=

    for v in $(eval echo \$${VAR}) ; do
	ret="$ret ${v};"
    done
    echo $ret
}

named_etc_ro=${NAMED_ETC}_ro
named_etc_ro=${NAMED_ETC}

cat ${named_etc_ro}/acl.conf.${tmpl_suffix} | sed "s|__ACL_LOCAL_NETS__|$(str2list ACL_LOCAL_NETS)|" > ${NAMED_ETC}/acl.conf

cat ${named_etc_ro}/forwarders.conf.${tmpl_suffix} | sed "s|__FORWARDERS__|$(str2list FORWARDERS)|" > ${NAMED_ETC}/forwarders.conf

case ${ALLOW_RECURSION} in
    true|True|TRUE|yes|Yes|YES)
	recursion=yes
	;;
    *)
	recursion=no
	;;
esac

cat ${named_etc_ro}/named.conf.${tmpl_suffix} | sed "s|__ALLOW_RECURSION__|$recursion|" > ${NAMED_ETC}/named.conf

mkdir -p ${NAMED_DATA}/{data,dynamic,forward,reverse}

master_in_addr_arpa=`echo $LOCAL_ZONE_FORWARD_NET | sed 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)/\3.\2.\1/'`
cat ${named_etc_ro}/local-zone.conf.${tmpl_suffix} | sed "\
    s|__MASTER_LOCAL_ZONE_NAME__|$MASTER_LOCAL_ZONE_NAME| ; \
    s|__MASTER_IN_ADDR_ARPA__|$master_in_addr_arpa| ; \
    " > ${NAMED_ETC}/local-zone.conf

cat ${named_etc_ro}/local.db.${tmpl_suffix} | sed "s|__LOCAL_ZONE_FORWARD_NET__|$LOCAL_ZONE_FORWARD_NET|" > ${NAMED_DATA}/forward/${MASTER_LOCAL_ZONE_NAME}.db

cat ${named_etc_ro}/reverse.db.${tmpl_suffix} | sed "s|__MASTER_LOCAL_ZONE_NAME__|$MASTER_LOCAL_ZONE_NAME|" > ${NAMED_DATA}/reverse/$master_in_addr_arpa.db
