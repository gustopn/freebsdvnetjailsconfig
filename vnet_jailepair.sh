#!/bin/sh -x
jail_prestart_exec() {
  /sbin/ifconfig "`/sbin/ifconfig "epair${1}" create`" up
}

jail_created_exec() {
  /sbin/ifconfig "epair${1}b" vnet "${2}"
}

jail_poststop_exec() {
  /sbin/ifconfig "epair${1}a" destroy
}

jailname="$2"
if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
then \
  namemd5=`md5 -s "$jailname" | awk '{print $NF}'`
  namemd5short=`echo $namemd5 | cut -c 30-32`
  namemd5addr=`echo $namemd5 | cut -c 1-16`
  epairifnum=`printf '%d' "0x${namemd5short}"`
  case "$1" in
    "prestart") jail_prestart_exec "${epairifnum}";;
    "created")  jail_created_exec  "${epairifnum}" "$jailname";;
    "poststop") jail_poststop_exec "${epairifnum}";;
  esac
fi
