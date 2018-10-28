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
#named_etc_ro=${NAMED_ETC}

[ -r "${NAMED_ETC}/acl.conf" ] || \
    cat ${named_etc_ro}/acl.conf.${tmpl_suffix} | \
	sed "s|__ACL_LOCAL_NETS__|$(str2list ACL_LOCAL_NETS)|" > ${NAMED_ETC}/acl.conf

[ -r "${NAMED_ETC}/forwarders.conf" ] || \
    cat ${named_etc_ro}/forwarders.conf.${tmpl_suffix} | \
	sed "s|__FORWARDERS__|$(str2list FORWARDERS)|" > ${NAMED_ETC}/forwarders.conf

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

case $LOCAL_ZONE_AUTODETECT in
    true|True|TRUE|yes|Yes|YES)
	autodetect_root_ns=$(dig +short $(echo $MASTER_LOCAL_ZONE_NAME | sed 's/[^\.]\+\.//') ns | head -1)
	autodetect_ns_name=$(dig @$autodetect_root_ns $MASTER_LOCAL_ZONE_NAME ns | awk "/^$MASTER_LOCAL_ZONE_NAME/ { print \$5; }")
	autodetect_ns_ip=$(dig +short @$autodetect_root_ns $autodetect_ns_name a)
	LOCAL_ZONE_FORWARD_NET=`echo $autodetect_ns_ip | sed 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\).*/\1.\2.\3/'`
	NS1=`echo $autodetect_ns_ip | sed 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)/\4/'`
	NS2=NS1
	NS_CACHE1=NS1
	NS_CACHE2=NS1
	;;
    *)
	NS1=251
	NS2=252
	NS_CACHE1=253
	NS_CACHE2=254
	;;
esac

master_in_addr_arpa=`echo $LOCAL_ZONE_FORWARD_NET | sed 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)/\3.\2.\1/'`

[ -r "${NAMED_ETC}/local-zones.conf" ] || \
    cat ${named_etc_ro}/local-zones.conf.${tmpl_suffix} | sed "\
	s|__MASTER_LOCAL_ZONE_NAME__|$MASTER_LOCAL_ZONE_NAME| ; \
	s|__MASTER_IN_ADDR_ARPA__|$master_in_addr_arpa| ; \
	s|__MASTER_SERVERS__|$MASTER_SERVERS| ; \
	" > ${NAMED_ETC}/local-zones.conf

[ -r "${NAMED_DATA}/forward/${MASTER_LOCAL_ZONE_NAME}.db" ] || \
    cat ${named_etc_ro}/local.db.${tmpl_suffix} | \
	sed "\
	    s|__LOCAL_ZONE_FORWARD_NET__|$LOCAL_ZONE_FORWARD_NET| ; \
	    s|__NS1__|$NS1| ; \
	    s|__NS2__|$NS2| ; \
	    s|__NS_CACHE1__|$NS_CACHE1| ; \
	    s|__NS_CACHE2__|$NS_CACHE2| ; \
	" \
	> ${NAMED_DATA}/forward/${MASTER_LOCAL_ZONE_NAME}.db

[ -r "${NAMED_DATA}/reverse/$master_in_addr_arpa.db" } || \
    cat ${named_etc_ro}/reverse.db.${tmpl_suffix} | \
	sed "s|__MASTER_LOCAL_ZONE_NAME__|$MASTER_LOCAL_ZONE_NAME|" > ${NAMED_DATA}/reverse/$master_in_addr_arpa.db
