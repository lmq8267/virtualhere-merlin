#!/bin/sh

source /jffs/softcenter/scripts/base.sh

vh_pid=`pidof vhusbd`
if [ -n "$vh_pid" ];then
        vhver=`dbus get vhusbd_version`
        [ ! -z "$vhver" ] && vhver="vhusbd $vhver "
	vhusbd_log="$vhver <span style='color:  #7FFF00'>运行中<img src='https://www.right.com.cn/forum/data/attachment/album/202401/30/081238k459q2d5klacs8rk.gif' width='30px' alt=''> PID：$vh_pid </span>"
else
	vhusbd_log="<span style='color:  #FF0000'>未运行</span>"
fi
newbase="$(dbus get vhusbd_config)"
oldbase="$(cat /jffs/softcenter/etc/vhusbd/vhusbd.ini 2>/dev/null | base64 | tr -d '\n')"
if [ "$newbase" != "$oldbase" ] && [ -n "$oldbase" ] ; then
	dbus set vhusbd_config="$oldbase"
fi
http_response "$vhusbd_log"
