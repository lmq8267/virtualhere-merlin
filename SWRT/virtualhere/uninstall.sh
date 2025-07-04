#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export vhusbd_`
alias echo_date='echo 【$(date -R +%Y年%m月%d日\ %X)】:'

vh_enable=`dbus get vhusbd_enable`

if [ "${vh_enable}"x = "1"x ] ; then
    sh /jffs/softcenter/scripts/vhusbd_config.sh stop
fi

echo_date "删除VirtualHere插件相关文件！"

confs=`dbus list vhusbd|cut -d "=" -f1`
for conf in $confs
do
	dbus remove $conf
done

sleep 1
find /jffs/softcenter/init.d/ -name "*vhusbd*" | xargs rm -rf
rm -rf /jffs/softcenter/scripts/vhusbd*
rm -rf /jffs/softcenter/init.d/*vhusbd.sh
rm -rf /jffs/softcenter/bin/vhusbd*
rm -rf /jffs/softcenter/webs/Module_virtualhere.asp
rm -rf /jffs/softcenter/res/icon-virtualhere.png

echo_date "VirtualHere插件卸载完成，江湖有缘再见~"
echo_date "-------------------------------------------"
echo_date "此次卸载保留了vhusbd配置文件夹: /jffs/softcenter/etc/vhusbd"
echo_date "如果您希望重装vhusbd插件后，初始化配置和许可证"
echo_date "请重装插件前手动删除文件夹/jffs/softcenter/etc/vhusbd"
echo_date "-------------------------------------------"
rm -rf /jffs/softcenter/scripts/uninstall_virtualhere.sh
