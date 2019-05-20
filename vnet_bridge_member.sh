#!/bin/sh -x
jail_prestart_exec() {
  jailname=$1
  if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
  then \
    epairif0=`/sbin/ifconfig epair create`
    epairif1=`/sbin/ifconfig epair create`
    cat /dev/null > /tmp/"epair_${jailname}.txt"
    echo "${epairif0}" >> /tmp/"epair_${jailname}.txt"
    echo "${epairif1}" >> /tmp/"epair_${jailname}.txt"
    /sbin/ifconfig "${epairif0}" up
    /sbin/ifconfig "${epairif1}" up
    /sbin/ifconfig bridge0 addm "${epairif0}"
    /sbin/ifconfig bridge2 addm "${epairif1}"
  fi
}

jail_created_exec() {
  jailname=$1
  if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
  then \
    bridge0memberlist="`ifconfig bridge0 | grep 'member: ' | awk '{ print $2}'`"
    bridge2memberlist="`ifconfig bridge2 | grep 'member: ' | awk '{ print $2}'`"
    shortjailname=`echo $jailname | cut -c1-3`
    for i in `cat /tmp/"epair_${jailname}.txt"`
    do \
      if echo "$bridge0memberlist" | grep "$i" >/dev/null
      then \
        jailnet=`/sbin/ifconfig "${i%a}b" name "wakan${shortjailname}"`
        /sbin/ifconfig "${jailnet}" vnet "${jailname}"
	continue
      fi
      if echo "$bridge2memberlist" | grep "$i" >/dev/null
      then \
        jailnet=`/sbin/ifconfig "${i%a}b" name "agile${shortjailname}"`
        /sbin/ifconfig "${jailnet}" vnet "${jailname}"
	continue
      fi
    done
  fi
}

jail_poststop_exec() {
  jailname=$1
  if [ -n "$jailname" ] && [ -d "/jail/$jailname" ]
  then \
    for i in `cat /tmp/"epair_${jailname}.txt"`
    do \
      /sbin/ifconfig "${i}" destroy;
    done
  fi
}

case $1 in
  "prestart") jail_prestart_exec $2 ;;
  "created")  jail_created_exec  $2 ;;
  "poststop") jail_poststop_exec $2 ;;
esac
