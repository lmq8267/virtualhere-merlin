# virtualhere-梅林版离线安装包

<p align="center">
  <img alt="GitHub Created At" src="https://img.shields.io/github/created-at/lmq8267/virtualhere-merlin?logo=github&label=%E5%88%9B%E5%BB%BA%E6%97%A5%E6%9C%9F">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Flmq8267%2Fvirtualhere-merlin&count_bg=%2395C10D&title_bg=%23555555&icon=github.svg&icon_color=%238DC409&title=%E8%AE%BF%E9%97%AE%E6%95%B0&edge_flat=false"/></a>
<a href="https://github.com/lmq8267/virtualhere-merlin/releases"><img src="https://img.shields.io/github/downloads/lmq8267/virtualhere-merlin/total?logo=github&label=%E4%B8%8B%E8%BD%BD%E9%87%8F"></a>
<a href="https://github.com/lmq8267/virtualhere-merlin/graphs/contributors"><img src="https://img.shields.io/github/contributors-anon/lmq8267/virtualhere-merlin?logo=github&label=%E8%B4%A1%E7%8C%AE%E8%80%85"></a>
<a href="https://github.com/lmq8267/virtualhere-merlin/releases/"><img src="https://img.shields.io/github/release/lmq8267/virtualhere-merlin?logo=github&label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC"></a>
<a href="https://github.com/lmq8267/virtualhere-merlin/issues"><img src="https://img.shields.io/github/issues-raw/lmq8267/virtualhere-merlin?logo=github&label=%E9%97%AE%E9%A2%98"></a>
<a href="https://github.com/lmq8267/virtualhere-merlin/discussions"><img src="https://img.shields.io/github/discussions/lmq8267/virtualhere-merlin?logo=github&label=%E8%AE%A8%E8%AE%BA"></a>
<a href="GitHub repo size"><img src="https://img.shields.io/github/repo-size/lmq8267/virtualhere-merlin?logo=github&label=%E4%BB%93%E5%BA%93%E5%A4%A7%E5%B0%8F"></a>
<a href="https://github.com/lmq8267/virtualhere-merlin/actions?query=workflow%3ABuild"><img src="https://img.shields.io/github/actions/workflow/status/lmq8267/virtualhere-merlin/CI.yml?branch=master&logo=github&label=%E6%9E%84%E5%BB%BA%E7%8A%B6%E6%80%81" alt="Build status"></a>
</p>

官网：https://www.virtualhere.com

### UI预览

![image](https://github.com/user-attachments/assets/6e34b574-e7ee-42e7-9657-625c08aed1b6)

![image](https://github.com/user-attachments/assets/cc62d249-8a03-4d58-b5c1-6ba3be92cf24)

![image](https://github.com/user-attachments/assets/a6135a9d-ac82-4d1a-87e5-f511588026e8)

-------------------------------------------

##### 客户端如何踢出其他客户端对服务器的连接？
![image](https://github.com/user-attachments/assets/b9134ad6-a762-4b34-9060-6d3d6740e8df)

#
- Liunx端的客户端GUI应该使用sudo命令添加 **`-a`** 参数启动，那么在管理界面就会有 **`断开其他用户连接`** 选项，添加 **`-q ZH-CN`** 参数启动默认中文（为了防止您之前的配置导致无法启动Admin模式，可以输入 **`sudo rm -rf /tmp/vhclient*`** 删除之前的配置缓存再启动即可）
```
sudo vhuit64 -a -q ZH-CN
```
Liunx里也可以使用命令行参数进行踢掉所有连接服务器的客户端 `vhuit64 -t "STOP USING ALL,服务器地址"`    
```
# 成功断开客户端的连接会响应 ok
vhuit64 -t "STOP USING ALL,192.168.2.1:7575"
```
#

- Windows客户端应该使用cmd命令添加 **`-a`** 参数启动，那么在管理界面就会有 **`断开其他用户连接`** 选项，添加 **`-q ZH-CN`** 参数启动默认中文
```
vhui64.exe -a -q ZH-CN
```
1. 在pc里可以写一个bat脚本用来快速启动（和vhui64.exe在同一个文件夹内）
```
@echo off
setlocal

:: 设置客户端程序名称vhui64.exe
set "APP=vhui64.exe"

:: 先尝试关闭已有的 vhui64.exe 进程（静默）
taskkill /f /im %APP% >nul 2>&1

:: 等待 1 秒确保进程已终止
timeout /t 1 >nul

:: 检查当前目录下是否存在可执行文件
if exist "%~dp0%APP%" (
    echo 正在启动 %APP%...
    start "" "%~dp0%APP%" -a -q ZH-CN
) else (
    :: 如果文件不存在，弹出提示框
    mshta "javascript:alert('当前文件夹内没有 %APP% 无法启动！');close();"
    exit /b 1
)

endlocal

```
2. 也可以写一个bat脚本用来踢掉指定服务器的所有客户端连接（需要先运行客户端）
```
@echo off
setlocal enabledelayedexpansion

echo.
:: 提示输入服务器 IP 地址
set /p SERVER_IP=请输入需要停止的服务器IP地址：

:: 提示输入端口号（默认 7575）
set /p SERVER_PORT=请输入端口号（直接回车默认为7575）：
if "%SERVER_PORT%"=="" set SERVER_PORT=7575

:: 构造目标地址
set TARGET=%SERVER_IP%:%SERVER_PORT%

:: 调用 VirtualHere 命令停止所有客户端使用该服务器设备
echo 正在尝试停止服务器 %TARGET% 上的所有客户端使用设备...
vhui64.exe -t "STOP USING ALL,%TARGET%" -r out.txt

:: 读取返回结果
set /p RESULT=<out.txt

:: 判断结果并输出
if "%RESULT:~0,6%"=="FAILED" (
    echo 操作失败：服务器可能未连接或设备已被其他客户端使用。
) else (
    if "%RESULT:~0,5%"=="ERROR" (
        echo 错误：%RESULT%
    ) else (
        echo 成功：%RESULT%
    )
)

pause



