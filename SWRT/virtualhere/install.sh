#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export vhusbd_`
alias echo_date='echo 【$(date -R +%Y年%m月%d日\ %X)】:'

DIR=$(cd $(dirname $0); pwd)

vh_enable=`dbus get vhusbd_enable`

if [ "${vh_enable}"x = "1"x ] ; then
    sh /jffs/softcenter/scripts/vhusbd_config.sh stop
fi
find /jffs/softcenter/init.d/ -name "*vhusbd.sh*"|xargs rm -rf
cd /tmp

cputype=$(uname -ms | tr ' ' '_' | tr '[A-Z]' '[a-z]')
[ -n "$(echo $cputype | grep -E "linux.*armv.*")" ] && cpucore="arm"
[ -n "$(echo $cputype | grep -E "linux.*armv7.*")" ] && [ -n "$(cat /proc/cpuinfo | grep vfp)" ] && cpucore="arm"
[ -n "$(echo $cputype | grep -E "linux.*aarch64.*|linux.*armv8.*")" ] && cpucore="arm64"
if [ -n "$(echo $cputype | grep -E "linux.*mips.*")" ] ; then
      mipstype=$(echo -n I | hexdump -o 2>/dev/null | awk '{ print substr($2,6,1); exit}') 
      [ "$mipstype" = "0" ] && cpucore="mips" || cpucore="mipsel" 
fi
if [ -z "$cpucore" ] ; then
  echo_date "你的设备CPU架构未知，无法安装本插件！"
  rm -rf /tmp/virtualhere* >/dev/null 2>&1
  exit 1
fi
cp -rf /tmp/virtualhere/bin/vhusbd${cpucore} /jffs/softcenter/bin/vhusbd
cp -rf /tmp/virtualhere/scripts/* /jffs/softcenter/scripts/
cp -rf /tmp/virtualhere/webs/* /jffs/softcenter/webs/
cp -rf /tmp/virtualhere/res/* /jffs/softcenter/res/
cp /tmp/virtualhere/uninstall.sh /jffs/softcenter/scripts/uninstall_virtualhere.sh
ln -sf /jffs/softcenter/scripts/vhusbd_config.sh /jffs/softcenter/init.d/S49vhusbd.sh

chmod +x /jffs/softcenter/bin/vhusbd
chmod +x /jffs/softcenter/scripts/vhusbd_*
chmod +x /jffs/softcenter/scripts/uninstall_virtualhere.sh
chmod +x /jffs/softcenter/init.d/S49vhusbd.sh
dbus set softcenter_module_virtualhere_description="VirtualHere 允许通过网络远程使用 USB 设备，就像本地连接一样！"
dbus set softcenter_module_virtualhere_install=1
dbus set softcenter_module_virtualhere_name=virtualhere
dbus set softcenter_module_virtualhere_title=VirtualHere
dbus set softcenter_module_virtualhere_version="$(cat $DIR/version)"

sleep 1
echo_date "VirtualHere 插件安装完毕！"
rm -rf /tmp/virtualhere* >/dev/null 2>&1

if [ "${vh_enable}"x = "1"x ] ; then
    sh /jffs/softcenter/scripts/vhusbd_config.sh restart
fi
exit 0
