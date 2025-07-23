<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- version: 2.1.8 -->
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>软件中心 - VirtualHere 虚拟USB服务器</title>
<link rel="stylesheet" type="text/css" href="index_style.css" />
<link rel="stylesheet" type="text/css" href="form_style.css" />
<link rel="stylesheet" type="text/css" href="usp_style.css" />
<link rel="stylesheet" type="text/css" href="ParentalControl.css">
<link rel="stylesheet" type="text/css" href="css/icon.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
<link rel="stylesheet" type="text/css" href="res/softcenter.css">
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<style type="text/css">
.close {
    background: red;
    color: black;
    border-radius: 12px;
    line-height: 18px;
    text-align: center;
    height: 18px;
    width: 18px;
    font-size: 16px;
    padding: 1px;
    top: -10px;
    right: -10px;
    position: absolute;
}
/* use cross as close button */
.close::before {
    content: "\2716";
}
.contentM_qis {
    position: fixed;
    -webkit-border-radius: 5px;
    -moz-border-radius: 5px;
    border-radius:10px;
    z-index: 10;
    background-color:#2B373B;
    /*margin-left: -100px;*/
    top: 100px;
    width:755px;
    return height:auto;
    box-shadow: 3px 3px 10px #000;
    background: rgba(0,0,0,0.85);
    display:none;
}

.user_title{
    text-align:center;
    font-size:18px;
    color:#99FF00;
    padding:10px;
    font-weight:bold;
}
.vhusbd_btn {
    border: 1px solid #222;
    background: linear-gradient(to bottom, #003333  0%, #000000 100%); /* W3C */
	background: linear-gradient(to bottom, #91071f  0%, #700618 100%); /* W3C rogcss*/
    font-size:10pt;
    color: #fff;
    padding: 5px 5px;
    border-radius: 5px 5px 5px 5px;
    width:16%;
}
.vhusbd_btn:hover {
    border: 1px solid #222;
    background: linear-gradient(to bottom, #27c9c9  0%, #279fd9 100%); /* W3C */
	background: linear-gradient(to bottom, #cf0a2c  0%, #91071f 100%); /* W3C rogcss*/
    font-size:10pt;
    color: #fff;
    padding: 5px 5px;
    border-radius: 5px 5px 5px 5px;
    width:16%;
}
#vhusbd_config {
	width:99%;
	font-family:'Lucida Console';
	font-size:12px; background:#475A5F;
	color:#FFFFFF;
	text-transform:none;
	margin-top:5px;
	overflow:scroll;
	background:transparent; /* W3C rogcss*/
	border:1px solid #91071f; /* W3C rogcss*/
}
input[type=button]:focus {
    outline: none;
}
</style>
<script>
var db_vhusbd = {};
var node_max = 0;
var params_input = ["vhusbd_cron_time", "vhusbd_cron_hour_min", "vhusbd_cron_type", "vhusbd_password"]
var params_check = ["vhusbd_enable", "vhusbd_wan", "vhusbd_ipv6"]
var params_base64 = ["vhusbd_config"]

function initial() {
	show_menu(menu_hook);
	get_dbus_data();
	get_status();
	conf2obj();
	buildswitch();
}

function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/vhusbd",
		dataType: "json",
		async: false,
		success: function(data) {
			db_vhusbd = data.result[0];
			conf2obj();
			$("#vhusbd_version_show").html(db_vhusbd["vhusbd_version"]);
		}
	});
}

function conf2obj() {
	//input
	for (var i = 0; i < params_input.length; i++) {
		if(db_vhusbd[params_input[i]]){
			E(params_input[i]).value = db_vhusbd[params_input[i]];
		}
	}
	// checkbox
	for (var i = 0; i < params_check.length; i++) {
		if(db_vhusbd[params_check[i]]){
			E(params_check[i]).checked = db_vhusbd[params_check[i]] == 1 ? true : false
		}
	}
	//base64
	for (var i = 0; i < params_base64.length; i++) {
		if(db_vhusbd[params_base64[i]]){
			E(params_base64[i]).value = Base64.decode(db_vhusbd[params_base64[i]]);
		}
	}
}

function get_status() {
		var postData = {
			"id": parseInt(Math.random() * 100000000),
			"method": "vhusbd_status.sh",
			"params": [],
			"fields": ""
		};
		$.ajax({
			type: "POST",
			cache: false,
			url: "/_api/",
			data: JSON.stringify(postData),
			dataType: "json",
			success: function(response) {
				E("status").innerHTML = response.result;
				setTimeout("get_status();", 10000);
			},
			error: function() {
				setTimeout("get_status();", 5000);
			}
		});
		for (var i = 0; i < params_base64.length; i++) {
			if(db_vhusbd[params_base64[i]]){
				E(params_base64[i]).value = Base64.decode(db_vhusbd[params_base64[i]]);
			}
		}
}

function buildswitch() {
	$("#vhusbd_enable").click(
	function() {
		if (E('vhusbd_enable').checked) {
			document.form.vhusbd_enable.value = 1;
		} else {
			document.form.vhusbd_enable.value = 0;
		}
	});
	$("#vhusbd_wan").click(
	function() {
		if (E('vhusbd_wan').checked) {
			document.form.vhusbd_wan.value = 1;
		} else {
			document.form.vhusbd_wan.value = 0;
		}
	});
	$("#vhusbd_ipv6").click(
	function() {
		if (E('vhusbd_ipv6').checked) {
			document.form.vhusbd_ipv6.value = 1;
		} else {
			document.form.vhusbd_ipv6.value = 0;
		}
	});
}

function save() {
	showLoading(3);
	if(E("vhusbd_cron_time").value == "0"){
		    E("vhusbd_cron_hour_min").value = "";
		    E("vhusbd_cron_type").value = "";
	}
	//input
	for (var i = 0; i < params_input.length; i++) {
		if (E(params_input[i]).value) {
			db_vhusbd[params_input[i]] = E(params_input[i]).value;
		}else{
			db_vhusbd[params_input[i]] = "";
		}
	}
	// checkbox
	for (var i = 0; i < params_check.length; i++) {
		db_vhusbd[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
	}
	//base64
	for (var i = 0; i < params_base64.length; i++) {
		if (!E(params_base64[i]).value) {
			db_vhusbd[params_base64[i]] = "";
		} else {
			if (E(params_base64[i]).value.indexOf("=") != -1) {
				db_vhusbd[params_base64[i]] = Base64.encode(E(params_base64[i]).value);
			} else {
				db_vhusbd[params_base64[i]] = "";
			}
		}
	}
	// post data
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "vhusbd_config.sh", "params": [1], "fields": db_vhusbd };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
				refreshpage();
			}
		}
	});
}

function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "VirtualHere 虚拟USB服务器");
	tablink[tablink.length - 1] = new Array("", "Module_virtualhere.asp");
}

function clear_vhusbdlog() {
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "vhusbd_config.sh", "params": ["clearlog"], "fields": db_vhusbd };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
}
function get_vhusbd_log() {
	$.ajax({
		url: '/_temp/vhusbd.log',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
            if (res.length == 0){
            E("vhusbd_logtxt").value = "日志文件为空或程序未启动"; 
            get_vhusbd_log();
			}else{ $('#vhusbd_logtxt').val(res); 
                      var textarea = document.getElementById('vhusbd_logtxt');
                      textarea.scrollTop = textarea.scrollHeight;
                    }
		}
	});
}
function open_conf(open_conf) {
	if (open_conf == "vhusbd_log") {
		get_vhusbd_log();
	}
	$("#" + open_conf).fadeIn(200);
}
function close_conf(close_conf) {
	$("#" + close_conf).fadeOut(200);
}

</script>
</head>
<body onload="initial();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="POST" name="form" action="/applydb.cgi?p=vhusbd" target="hidden_frame">
<input type="hidden" name="current_page" value="Module_virtualhere.asp"/>
<input type="hidden" name="next_page" value="Module_virtualhere.asp"/>
<input type="hidden" name="group_id" value=""/>
<input type="hidden" name="modified" value="0"/>
<input type="hidden" name="action_mode" value=""/>
<input type="hidden" name="action_script" value=""/>
<input type="hidden" name="action_wait" value="5"/>
<input type="hidden" name="first_time" value=""/>
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
<input type="hidden" name="SystemCmd" onkeydown="onSubmitCtrl(this, ' Refresh ')" value="vhusbd_config.sh"/>
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
<table class="content" align="center" cellpadding="0" cellspacing="0">
    <tr>
        <td width="17">&nbsp;</td>
        <td valign="top" width="202">
            <div id="mainMenu"></div>
            <div id="subMenu"></div>
        </td>
        <td valign="top">
            <div id="tabMenu" class="submenuBlock"></div>
            <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" valign="top">
                        <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3"  class="FormTitle" id="FormTitle">
                            <tr>
                                <td bgcolor="#4D595D" colspan="3" valign="top">
                                    <div>&nbsp;</div>
                                    <div style="float:left;" class="formfonttitle">软件中心 - VirtualHere 虚拟USB服务器</div>
                                    <div style="float:right; width:15px; height:25px;margin-top:10px"><img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img></div>
                                    <div style="margin:30px 0 10px 5px;" class="splitLine"></div>
                                    <div class="formfontdesc">VirtualHere 允许通过网络远程使用 USB 设备，就像本地连接一样！<br> 
                                    服务器文档：<a href="http://www.virtualhere.com/configuration_faq"  target="_blank"><em><u>http://www.virtualhere.com/configuration_faq</u></em></a><br><br></div>
                                    <div id="vhusbd_switch_show">
                                    <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                    <thead>
                                            <tr>
                                            <td colspan="2" title="展示vhusbd的版本号以及运行进程pid">运行状态</a></td>
                                            </tr>
                                        </thead>
                                        <tr id="vhusbd_status">
                                            <th width="20%" >运行状态</th>
                                            <td><span id="status">获取中...</span>
                                            </td>
                                        </tr>
                                        <thead>
                                            <tr>
                                            <td colspan="2">基础配置</a></td>
                                            </tr>
                                        </thead>
                                        <tr>
                                            <th>
                                                <label title="启用virtualhere服务器">开启vhusbd</a></label>
                                            </th>
                                            <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="vhusbd_enable">
                                                        <input id="vhusbd_enable" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                                <div></div>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>
                                                <div>
                                                    <a type="button" class="vhusbd_btn" style="cursor:pointer" href="javascript:void(0);" onclick="open_conf('vhusbd_log');" >查看日志</a>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="20%" title="设置定时检查程序进程是否正常运行或进行定时重新启动程序">定时功能(<i>0为关闭</i>)</th>
                                            <td>
                                                每 <input type="text" oninput="this.value=this.value.replace(/[^\d]/g, '')" id="vhusbd_cron_time" name="vhusbd_cron_time" class="input_3_table" maxlength="2" value="0" placeholder="" />
                                                <select id="vhusbd_cron_hour_min" name="vhusbd_cron_hour_min" style="width:60px;margin:3px 2px 0px 2px;" class="input_option">
                                                    <option value="min">分钟</option>
                                                    <option value="hour">小时</option>
                                                </select> 
                                                <select id="vhusbd_cron_type" name="vhusbd_cron_type" style="width:60px;margin:3px 2px 0px 2px;" class="input_option">
                                                    <option value="watch">检查</option>
                                                    <option value="start">重启</option>
                                                </select> 一次服务
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>
                                                <label title="防火墙放行 7575 端口通行，在外网也能连接7575端口">允许外网连接</label>
                                            </th>
                                            <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="vhusbd_wan">
                                                        <input id="vhusbd_wan" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                                <div></div>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>
                                                <label title="监听 ipv6 端口，客户端可通过ipv6链接此服务器">启用IPV6</label>
                                            </th>
                                            <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="vhusbd_ipv6">
                                                        <input id="vhusbd_ipv6" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                                <div></div>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
    						<th>
        					<label title="客户端连接此服务器时需输入密码">密码验证</label>
    						</th>
    						<td colspan="2">
        					<div style="display:table-cell;float: left;">
            					<input  type="password" name="vhusbd_password" id="vhusbd_password" autocomplete="new-password" class="input_ss_table" autocorrect="off" autocapitalize="off" maxlength="64" value="" onBlur="switchType(this, false);" onFocus="switchType(this, true);" placeholder="留空不需要密码即可连接">
                				<i>此功能仅限激活后高级版才能使用</i>
        					</div>
    						</td>
					</tr>
                                        <thead>
                                            <tr>
                                            <td colspan="2">配置文件</a></td>
                                            </tr>
                                        </thead>
                                        <tr>
                                            <th width="20%" title="服务器的配置文件，不懂请勿修改！">服务器配置</th>
                                            <td>
                                                <div>
                                                	<i>编辑前请务必刷新一两次网页！(因为启动后5秒才会刷新此配置文件)</i>
                                                    <textarea cols="50" rows="6" wrap="off" id="vhusbd_config" name="vhusbd_config" style="width:90%;padding:10px;font-family:monospace;font-size:12px;background:#1a2426;color:#e0e0e0;border:1px solid #374c51;"></textarea>
                                                    <div style="margin-top:10px;font-size:12px;color:#a0a0a0;">
                                                    <i>配置文件保存路径 /koolshare/configs/vhusbd/vhusbd.ini</i>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                    <div style="text-align:center;margin-top:20px;">
                                        <input class="button_gen" id="cmdBtn" onclick="save()" type="button" value="提交"/>
                                    </div>
                                    <div id="vhusbd_log" class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
    <div class="user_title">vhusbd 日志文件 / 标准输出&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('vhusbd_log');" value="关闭"><span class="close"></span></a></div>
    <div id="user_tr" style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
        <textarea cols="50" rows="20" wrap="off" id="vhusbd_logtxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
    </div>
    <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
        <input id="edit_node1" class="button_gen" type="button" onclick="close_conf('vhusbd_log');" value="返回主界面">
        &nbsp;&nbsp;<input class="button_gen" type="button" onclick="close_conf('vhusbd_log');clear_vhusbdlog();" value="清空日志">
    </div>
</div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
        <td width="10" align="center" valign="top"></td>
    </tr>
</table>

</form>
<div id="footer"></div>
</body>

</html>

