# DVRF 开发进度

## 已完成
* [x] 界面修改，普通用户
* web 漏洞
  * [x] 登录
  * [x] xss
  * [] 命令注入
* [] 利用脚本
## 修改的文件
* [index.lua](https://github.com/worrycuc/DVRF/blob/develop/files/usr/lib/lua/luci/controller/admin/index.lua)
* [dispatcher.lua](https://github.com/worrycuc/DVRF/blob/develop/files/usr/lib/lua/luci/dispatcher.lua)
* [status.lua](https://github.com/worrycuc/DVRF/blob/develop/files/usr/lib/lua/luci/controller/admin/status.lua)
* [/etc/passwd]()
* [/etc/group]()
* [/etc/shadow]()
* [/etc/config/rpcd](https://github.com/worrycuc/DVRF/blob/develop/files/etc/config/rpcd)
* [forward-details.lua](https://github.com/worrycuc/DVRF/blob/develop/files/usr/lib/lua/luci/model/cbi/firewall/forward-details.lua)
* [nsection.htm](https://github.com/worrycuc/DVRF/blob/develop/files/usr/lib/lua/luci/view/cbi/nsection.htm)
* [showM.js](https://github.com/worrycuc/DVRF/blob/develop/files/www/luci-static/resource/showMessage.js)
## 更改记录
* 服务器运行是以 root 权限，虽然登录是以 dvrfguest 登录
* /etc/config/rpcd 可以控制能否读写页面
* opkg install shadow-su（不一定要）

## xss
### 逻辑设计
* 用户利用 firewall port-forward 的 name 字段构造 xss
* 答案放在showMessage.js的函数里，执行这个函数(可以被直接看到)，会弹窗给出flag
  * nsection.htm，，<script src="/luci-static/resources/showM.js"></script>
  * 编写js文件，存放在 luci-static/resources
  * flag 在函数里随机生成再，base32加密
* 用户根据藏在界面源码的提示知道需要触发 showMessage函数
### 难度增加
* 对字段进行过滤
  * 在哪里过滤,forward-details.lua
    ```lua
        //对'<xx>'过滤
        function escape(input)
            local stripTagsRE = "</?[^>]+>"
            local filteredInput = string.gsub(input, stripTagsRE, "")
            return filteredInput    
        end
    ```
    * 可以 <svg/onload=showMessage()//
## 命令注入
* 存放在 $FLAG 环境变量中
* 位于 /www 目录中，无法前往根目录或对根目录进行操作
## 藏提示
* F12 scource
## Exp && Checker