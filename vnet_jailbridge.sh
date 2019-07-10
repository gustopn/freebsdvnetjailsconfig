#!/bin/sh -x
jail_prestart_exec() {
  jailname=$1
  if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
  then \
    epairif0=`/sbin/ifconfig epair create`
    echo "${epairif0}" > /tmp/"epair_${jailname}.txt"
    /sbin/ifconfig "${epairif0}" up
    /sbin/ifconfig bridge0 addm "${epairif0}"
  fi
}

jail_created_exec() {
  jailname=$1
  if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
  then \
    shortjailname=`echo $jailname | cut -c1-3`
    for i in `cat /tmp/"epair_${jailname}.txt"`
    do \
      jailnet=`/sbin/ifconfig "${i%a}b" name "jailnet${shortjailname}"`
      /sbin/ifconfig "${jailnet}" vnet "${jailname}"
    done
  fi
}

jail_poststop_exec() {
  jailname=$1
  if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
  then \
    for i in `cat /tmp/"epair_${jailname}.txt"`
    do \
      /sbin/ifconfig "${i}" destroy
    done
  fi
}

case $1 in
  "prestart") jail_prestart_exec $2 ;;
  "created")  jail_created_exec  $2 ;;
  "poststop") jail_poststop_exec $2 ;;
esac
