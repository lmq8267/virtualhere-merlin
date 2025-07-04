#! /bin/sh

source /koolshare/scripts/base.sh
eval `dbus export vhusbd_`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

DIR=$(cd $(dirname $0); pwd)

vh_enable=`dbus get vhusbd_enable`

if [ ! -d "/koolshare" ] ; then
  echo_date "本插件仅适用于【koolshare 梅林改/官改 384/386/388软件中心】固件平台！"
  echo_date "你的固件无法安装此插件包，请正确选择插件包！！！"
  rm -rf /tmp/virtualhere* >/dev/null 2>&1
  exit 1
fi
if [ "${vh_enable}"x = "1"x ] ; then
    sh /koolshare/scripts/vhusbd_config.sh stop
fi
find /koolshare/init.d/ -name "*vhusbd.sh*"|xargs rm -rf
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
cp -rf /tmp/virtualhere/bin/vhusbd${cpucore} /koolshare/bin/vhusbd
cp -rf /tmp/virtualhere/scripts/* /koolshare/scripts/
cp -rf /tmp/virtualhere/webs/* /koolshare/webs/
cp -rf /tmp/virtualhere/res/* /koolshare/res/
cp /tmp/virtualhere/uninstall.sh /koolshare/scripts/uninstall_virtualhere.sh
ln -sf /koolshare/scripts/vhusbd_config.sh /koolshare/init.d/S49vhusbd.sh

chmod +x /koolshare/bin/vhusbd
chmod +x /koolshare/scripts/vhusbd_*
chmod +x /koolshare/scripts/uninstall_virtualhere.sh
chmod +x /koolshare/init.d/S49vhusbd.sh
dbus set softcenter_module_virtualhere_description="VirtualHere 允许通过网络远程使用 USB 设备，就像本地连接一样！"
dbus set softcenter_module_virtualhere_install=1
dbus set softcenter_module_virtualhere_name=virtualhere
dbus set softcenter_module_virtualhere_title=VirtualHere
dbus set softcenter_module_virtualhere_version="$(cat $DIR/version)"

sleep 1
echo_date "VirtualHere 插件安装完毕！"
rm -rf /tmp/virtualhere* >/dev/null 2>&1

if [ "${vh_enable}"x = "1"x ] ; then
    sh /koolshare/scripts/vhusbd_config.sh restart
fi
exit 0
