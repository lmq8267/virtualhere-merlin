#!/bin/sh

source /koolshare/scripts/base.sh

mkdir -p /tmp/upload
mkdir -p /koolshare/configs/vhusbd

vh_enable=`dbus get vhusbd_enable`
vh_wan=`dbus get vhusbd_wan`
vh_ipv6=`dbus get vhusbd_ipv6`
vh_cron_type=`dbus get vhusbd_cron_type`
vh_cron_time=`dbus get vhusbd_cron_time`
vh_cron_hour_min=`dbus get vhusbd_cron_hour_min`
vh_password=`dbus get vhusbd_password`

logg () {
   #logger -t "【VirtualHere】" "$1"
   echo -e "\033[36;1m【$(date -R +%Y年%m月%d日\ %X)】: \033[0m\033[35;1m$1 \033[0m"
   echo "$(date +'%a %b %d %H:%M:%S %Y') LOG_INFO    $1 " >>/tmp/upload/vhusbd.log
   
}

# 自启
fun_nat_start(){
    if [ "${vh_enable}"x = "1"x ] ;then
	    [ ! -L "/koolshare/init.d/S49vhusbd.sh" ] && ln -sf /koolshare/scripts/vhusbd_config.sh /koolshare/init.d/S49vhusbd.sh
            #[ ! -L "/koolshare/init.d/N49vhusbd.sh" ] && ln -sf /koolshare/scripts/vhusbd_config.sh /koolshare/init.d/N49vhusbd.sh
	    #如果开机自启失败，试着去掉上方代码前的 # 号
    fi
}

# 定时任务
fun_crontab(){
    if [ "${vh_enable}" != "1" ] || [ "${vh_cron_time}"x = "0"x ] ;then
        [ -n "$(cru l | grep vhusbd_monitor)" ] && cru d vhusbd_monitor
    fi
    
     if [ "${vh_cron_hour_min}" == "min" ] && [ "${vh_cron_time}"x != "0"x ] ; then
        if [ "${vh_cron_type}" == "watch" ]; then
        	logg "开启定时，每${vh_cron_time}分钟检查一次vhusbd 进程是否正常运行"
        	cru a vhusbd_monitor "*/"${vh_cron_time}" * * * * /bin/sh /koolshare/scripts/vhusbd_config.sh watch"
        elif [ "${vh_cron_type}" == "start" ]; then
        	logg "开启定时，每${vh_cron_time}分钟重新启动一次vhusbd程序"
                cru a vhusbd_monitor "*/"${vh_cron_time}" * * * * /bin/sh /koolshare/scripts/vhusbd_config.sh restart"
    	fi
    elif [ "${vh_cron_hour_min}" == "hour" ] && [ "${vh_cron_time}"x != "0"x ] ; then
        if [ "${vh_cron_type}" == "watch" ]; then
            logg "开启定时，每${vh_cron_time}小时检查一次vhusbd 进程是否正常运行"
            cru a vhusbd_monitor "0 */"${vh_cron_time}" * * * /bin/sh /koolshare/scripts/vhusbd_config.sh watch"
        elif [ "${vh_cron_type}" == "start" ]; then
            logg "开启定时，每${vh_cron_time}小时重新启动一次vhusbd程序"
            cru a vhusbd_monitor "0 */"${vh_cron_time}" * * * /bin/sh /koolshare/scripts/vhusbd_config.sh restart"
        fi
    fi
}

# 停止并清理
onstop(){
    PID=$(pidof vhusbd)
    [ -n "$(cru l | grep vhusbd_monitor)" ] && cru d vhusbd_monitor
    if [ -n "${PID}" ];then
		kill -9 "${PID}" >/dev/null 2>&1
                killall vhusbd >/dev/null 2>&1
    fi
    [ -n "$(cru l | grep vhusbd_rules)" ] && cru d vhusbd_rules
    iptables -D INPUT -p tcp --dport 7575 -j ACCEPT 2>/dev/null
    ip6tables -D INPUT -p tcp --dport 7575 -j ACCEPT 2>/dev/null
    iptables -D INPUT -p udp --dport 7575 -j ACCEPT 2>/dev/null
    ip6tables -D INPUT -p udp --dport 7575 -j ACCEPT 2>/dev/null
    logg "程序已关闭"
}


fun_start_stop(){
if [ "${vh_enable}" = "1" ] ; then
	logg "-------------------------------------------"
	logg "开始启动 /koolshare/bin/vhusbd"
	if [ ! -s /koolshare/configs/vhusbd/vhusbd.ini ]; then
		echo 'ServerName=$HOSTNAME$' >>/koolshare/configs/vhusbd/vhusbd.ini
		echo 'AutoAttachToKernel=1' >>/koolshare/configs/vhusbd/vhusbd.ini
	fi
	newbase="$(dbus get vhusbd_config)"
	oldbase="$(cat /koolshare/configs/vhusbd/vhusbd.ini 2>/dev/null | base64 | tr -d '\n')"
	if [ "$newbase" != "$oldbase" ] && [ -n "$newbase" ] ; then
		echo "$newbase" | base64 -d > /koolshare/configs/vhusbd/vhusbd.ini
	fi 
	#if ! grep -q "^ServerName=" /koolshare/configs/vhusbd/vhusbd.ini ; then
		#echo 'ServerName=$HOSTNAME$' >>/koolshare/configs/vhusbd/vhusbd.ini
	#fi
	#if ! grep -q "^AutoAttachToKernel=" /koolshare/configs/vhusbd/vhusbd.ini ; then
		#echo 'AutoAttachToKernel=1' >>/koolshare/configs/vhusbd/vhusbd.ini
	#fi
	[ -x /koolshare/bin/vhusbd ] || chmod +x /koolshare/bin/vhusbd
	[ -f /koolshare/bin/vhusbd ] || logg "/koolshare/bin/vhusbd 程序不存在！"
	[ $(($(/koolshare/bin/vhusbd -h 2>&1 | wc -l))) -gt 3 ] || logg "/koolshare/bin/vhusbd 不完整或不匹配当前架构！"
	ver="$(/koolshare/bin/vhusbd -h 2>&1 | head -n 1 | grep -oE 'v[0-9]+(\.[0-9]+)*')"
	[ -z "$ver" ] && ver="未知版本"
	dbus set vhusbd_version="$ver"
	killall vhusbd >/dev/null 2>&1
	killall -9 vhusbd >/dev/null 2>&1
	cmd=""
	[ "$vh_ipv6" = "1" ] && cmd="-i " && logg "增加对 ipv6 的监听"
	auth=$(grep -E "^clientAuthorization=" /koolshare/configs/vhusbd/vhusbd.ini)
	auth_script="/tmp/vhusbd_auth.sh"
	if [ -n "$vh_password" ] ; then
		logg "增加密码验证"
    		if [ -z "$auth" ] ; then
        		echo 'clientAuthorization=/tmp/vhusbd_auth.sh "$VENDOR_ID$" "$PRODUCT_ID$" "$CLIENT_ID$" "$CLIENT_IP$" "$PRODUCT_SERIAL$" "$PASSWORD$" "$DEVPATH$" "$NICKNAME$" "$NUM_BINDINGS$"' >> /koolshare/configs/vhusbd/vhusbd.ini
    		fi
    		md5=$(echo -n "$vh_password" | md5sum | awk '{print $1}')
    		cat > "$auth_script" <<EOF
#!/bin/sh
PASS_MD5="\$6"
CORRECT="$md5"
echo "\$(date '+%a %b %e %T %Y') LOG_INFO    供应商ID=【\$1】  产品ID=【\$2】  客户端账户=【\$3】  客户端IP=【\$4】  序列号=【\$5】  密码MD5=【\$6】  设备路径=【\$7】  客户端名称=【\$8】  当前连接数量=【\$9】" >>/tmp/upload/vhusbd.log
if [ "\$PASS_MD5" = "\$CORRECT" ]; then
    echo "\$(date '+%a %b %e %T %Y') LOG_INFO    密码验证通过" >> /tmp/upload/vhusbd.log
    exit 1  # 密码正确
else
    echo "\$(date '+%a %b %e %T %Y') LOG_ERR    密码验证错误" >> /tmp/upload/vhusbd.log
    exit 2  # 密码错误
fi
EOF

    		chmod +x "$auth_script"
	else
    		if [ -n "$auth" ]; then
        		sed -i '/^clientAuthorization=/d' /koolshare/configs/vhusbd/vhusbd.ini
    		fi
	fi
	TZ=UTC-8 /koolshare/bin/vhusbd -c /koolshare/configs/vhusbd/vhusbd.ini -b ${cmd}-r /tmp/upload/vhusbd.log &
	sleep 5
	if [ ! -z "$(pidof vhusbd)" ] ; then
		logg "vhusbd-$ver 启动成功！"
		dbus set vhusbd_config="$(cat /koolshare/configs/vhusbd/vhusbd.ini | base64 | tr -d '\n')"
		 if [ "$vh_wan" = 1 ] ; then
		 	logg "开启防火墙放行端口 7575 外网访问"
       		iptables -I INPUT -p tcp --dport 7575 -j ACCEPT 2>/dev/null
   			iptables -I INPUT -p udp --dport 7575 -j ACCEPT 2>/dev/null
   			ip6tables -I INPUT -p tcp --dport 7575 -j ACCEPT 2>/dev/null
   			ip6tables -I INPUT -p udp --dport 7575 -j ACCEPT 2>/dev/null
   			iptables -I OUTPUT -p tcp --dport 7575 -j ACCEPT 2>/dev/null
   			iptables -I OUTPUT -p udp --dport 7575 -j ACCEPT 2>/dev/null
   			ip6tables -I OUTPUT -p tcp --dport 7575 -j ACCEPT 2>/dev/null
   			ip6tables -I OUTPUT -p udp --dport 7575 -j ACCEPT 2>/dev/null
   			if [ -z "$(cru l | grep vhusbd_rules)" ] ; then
      				cru a vhusbd_rules "*/2 * * * * iptables -C INPUT -p tcp --dport 7575 -j ACCEPT || iptables -I INPUT -p tcp --dport 7575 -j ACCEPT ; iptables -C INPUT -p udp --dport 7575 -j ACCEPT || iptables -I INPUT -p udp --dport 7575 -j ACCEPT ; ip6tables -C INPUT -p tcp --dport 7575 -j ACCEPT || ip6tables -I INPUT -p tcp --dport 7575 -j ACCEPT ; ip6tables -C INPUT -p udp --dport 7575 -j ACCEPT || ip6tables -I INPUT -p udp --dport 7575 -j ACCEPT"
   			fi
    		fi
	else
		logg "vhusbd-$ver 启动失败！"
	fi
else
	onstop
fi
}



case $ACTION in
start)
    	logger "【软件中心】：启动 VirtualHere "
	fun_start_stop
	fun_nat_start
	fun_crontab
	;;
stop)
	onstop
	;;
restart)
	logger "【软件中心】定时任务：重新启动 VirtualHere"
        onstop
        fun_start_stop
	fun_nat_start
	fun_crontab
	;;
watch)
	[ -n "$(pidof vhusbd)" ] && exit 0
	logger "【软件中心】定时任务：进程掉线，重新启动 VirtualHere"
	fun_nat_start
	fun_start_stop
	;;
clearlog)
        true >/tmp/upload/vhusbd.log
	http_response "$1"
    ;;
esac

# for web submit
case $2 in
1)
	fun_start_stop
	fun_nat_start
	fun_crontab
	http_response "$1"
    ;;
clearlog)
        true >/tmp/upload/vhusbd.log
	http_response "$1"
    ;;
esac
