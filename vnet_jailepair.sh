#!/bin/sh -x
jail_prestart_exec() {
  /sbin/ifconfig "`/sbin/ifconfig "epair${1}" create`" up
}

jail_created_exec() {
  /sbin/ifconfig "epair${1}b" vnet "${2}"
}

jail_poststart_exec() {
  jailnetlinklocala=`/sbin/ifconfig "epair${1}a" | grep "fe80::" | awk '{print substr($2, 0, index($2, "%") - 1 )}'`
  jailnetlinklocalb=`echo "${jailnetlinklocala%a}b"`
  /sbin/ifconfig "epair${1}a" inet "${3}.${4}" netmask 255.255.255.252
  /usr/sbin/jexec "${2}" /sbin/ifconfig "epair${1}b" inet "${3}.${5}" netmask 255.255.255.252 up
  /usr/sbin/jexec "${2}" /sbin/ifconfig "epair${1}b" inet6 "${6}${7}" prefixlen 128
  /usr/sbin/jexec "${2}" /sbin/route add -inet default "${3}.${4}"
  /usr/sbin/jexec "${2}" /sbin/route add -inet6 default "${jailnetlinklocala}"
  /sbin/route add -inet6 "${6}${7}" "${jailnetlinklocalb}"
}

jail_prestop_exec() {

}

jail_poststop_exec() {
  /sbin/ifconfig "epair${1}a" destroy
}

jailname="$2"
if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
then \
  namemd5=`md5 -s "$jailname" | awk '{print $NF}'`
  namemd5short=`echo $namemd5 | cut -c 30-32`
  epairifnum=`printf '%d' "0x${namemd5short}"`
  if [ "$1" == "poststart" ]
  then \
    jailaddr4=`echo $namemd5 | cut -c 31-32`
    jailaddr4=`printf '%d' "0x${jailaddr4}" | awk '{print $1 - ($1 % 4) }'`
    jailaddr4a=`expr $jailaddr4 + 1`
    jailaddr4b=`expr $jailaddr4 + 2`
    jailaddr6=`echo $namemd5 | cut -c 1-16 | awk '{ i=0; while (i<4) { outstr = outstr ":" substr($0, 1 + (i*4), 4); i=i+1 } print outstr}'`
  fi
  case "$1" in
    "prestart") jail_prestart_exec  "${epairifnum}";;
    "created")  jail_created_exec   "${epairifnum}" "$jailname";;
    "poststart") jail_poststart_exec "${epairifnum}" "$jailname" "$3" "$jailaddr4a" "$jailaddr4b" "$4" "$jailaddr6";;
    "prestop")  jail_prestop_exec   "${epairifnum}";;
    "poststop") jail_poststop_exec  "${epairifnum}";;
  esac
fi
