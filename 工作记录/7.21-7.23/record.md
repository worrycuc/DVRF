# DVRF web 开发记录
## 已完成
* [x] 界面修改，普通用户
* web 漏洞
  * [x] 登录
  * [x] xss
  * [x] 命令注入
  * [x] untar一句话木马
  * [x] 序列化
* [x] check 和 exp
* [ ] 提示以及题目完善
## 修改的文件
## 新漏洞——unzip
* 上传 tar 或者 zip 文件
* 文件解压后存放在 /tmp/upload
* 利用软连接将木马放在/www 目录下
* 利用访问文件名来触发木马（muma.lua）
* 利用一句话木马，远程连接会话的shell

### 实现新功能页面增加
* 增加的文件 /tmp/upload
* /admin/upload.lua
* /admin_upload/upload.htm
### 漏洞点
* 将 tar 文件解压后存放在 /tmp/upload 中，不对解压出的文件进行检查
### 木马
* opkg update
* opkg install luasocket

## 新漏洞——反序列化
### 逻辑
* 根据提供的序列化源代码，用户得出构造序列化参数的方法
* 提供 base64加解密，序列化的 lua 文件 供用户使用
* 提供 md5 加密 lua文件，方便读者绕开 md5 检查
* 根据源码的功能，得到获取 flag 的构造参数方法
### 实现
* 写接口 /upload/date，在 upload.lua 中加入新 entry
* luci.util 没有 base64decode
* 提供base64加解密lua /luci/base64.lua
* 提供序列化函数lua   /luci/json.lua
* 提供源代码
* flag 放在 /www 上
* md5绕过 /luci/md5.lua(传数组返回none)
## flag 提交逻辑以及存放新的 flag
### 逻辑
* upload 页面新增提交 flag 功能
  * 提交正确，随机生成新的flag放在某目录下
  * 给出页面提示
  * 给出源码提示，直接浏览器自动下载
* 将两道 pwn 题源码给出
### 实现
* 在 upload.lua 中加入 entry，提交flag后，会触发 action_uploadflag 函数对 post 的flag 进行处理和操作
* upload.htm 加入 flag submit 界面