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
