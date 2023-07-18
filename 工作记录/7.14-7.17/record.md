## 创建相关虚拟机
* 使用 vmware
* 配置 passwd （dvrfhardcode）
## 简单修改
* `uci set luci.ccache.enable=0; uci commit luci` in order to disable the code caching for development purposes.
* 找到登录页面和 controller,`/usr/lib/lua/luci`
  * sysauth.htm
  * controller/admin/index.lua
  * 函数内部通过调用 luci.util.ubus 方法，向ubus发送一个 session.access 的请求，来检查指定会话ID是否具有访问指定对象和方法的权限。
* When testing, if you have edited index files, be sure to remove the folder /tmp/luci-modulecache/* and the file(s) /tmp/luci-indexcache*, then refresh the LUCI page to see your edits.
## ftp 进行 vscode远程连接
* 联网设置 /etc/resolv.conf nameserver 8.8.8.8
* opkg update,opkg install vsftpd
* vscode 下载 ftp-simple
## lua
* 对 openwrt 系统的 luci 架构进行简单梳理
  * template.lua 对 html 页面进行渲染 render
  * http.lua 对 http 报文进行处理和回复
  * sys.lua 与系统有关的行为与服务
  * dispacher.lua 中的 target_to_json 函数生成 /tmp/luci-indexcache*.json,该 json 串对应了访问的路由和行为
## 漏洞
### 登录绕过
* 登录界面对应 html /view/themes/bootstrap/sysauth.htm，主题应用的文件
* sys.lua user.getpasswd user.checkpasswd，对用户名和密码进行检验
* 先找到可以访问系统 cmd 的 api，根据该 api 获得 登录密码（flag？）
### 弱密码？？会不会太简单
改shadow文件
### xss
* 尝试编写网页，使用cbi模块，需要下载。。。。
  ```shell
    opkg update
    opkg install luci luci-base luci-compat
  ```

* 模仿 iotgoat 的 wifi.lua
  * view/ 中的 html 文件中有 html 字段的拼接
### api 接口
* 个人认为最简单，它就当作被遗弃的接口或者是后门
  * 模仿 iotgoat 的 iotgoat.lua，登录后可以访问
    * 注意 iotgoat 中
      ```lua
       entry({"admin", "iotgoat", "cmdinject"}, template("iotgoat/cmd"), "", 1)

       entry({"dvrf", "cmdinject"}, template("dvrf/cmd"), "", 1)
       -- http://192.168.66.128/cgi-bin/luci/dvrf/cmdinject 访问
      ```
  * 思考 webcmd.htm 的合理性，该如何 fix it


## cve
## exploit github
提示，
### 命令注入
## 参考文献
* [HowToDevelopmentEnvironment](https://github.com/openwrt/luci/wiki/DevelopmentEnvironmentHowTo)
* [luci_tutorials](https://github.com/seamustuohy/luci_tutorials/blob/master/02-APIs.md)
* [Luci-of-OpenWrt](https://github.com/featureoverload/Embedded-GUI-Develop/blob/master/Luci-of-OpenWrt/luci%E6%A1%86%E6%9E%B6%E4%BB%A3%E7%A0%81%E2%80%9D%E9%80%BB%E8%BE%91%E2%80%9D%E6%B5%81%E7%A8%8B%E5%9B%BE.pdf)
