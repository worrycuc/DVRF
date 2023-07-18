## 下载旧版本
* 下载 openwrt 18.06/lede 1806
* 配置到虚拟机上
## 创建普通用户
*  /etc/passwd,/etc/group, /etc/shadow 需要替换
*  home/user
   *  ```shell
        # 有shell权限
        useradd -r -s /bin/ash dvrfguest
        passwd testuser
        mkdir /dvrfguest
        mkdir /home/dvrfguest
        chown dvrfguest /home/dvrfguest
     ```
* /etc/config/rpcd:
  ```shell
  #add myuser,只能看不能修改
  config login
	option username 'myuser'
	option password '$p$myuser'
	list read '*'
	##list write '*'
  ```
### 普通用户界面
* 将 admin 的用户从 root 换成 dvrfguest
* [](https://stackoverflow.com/questions/18377138/openwrt-luci-how-to-implement-limited-user-access)
* 普通用户没有 root 权限如何增加firewall？
## 依据 cve 漏洞制作靶机环境
* [CVE-list](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/cve/cve_list.md)
* 命令注入(command injection)
  * [CVE-2019-12272](https://www.cvedetails.com/cve/CVE-2019-12272/)
  * [CVE-2021-28961](https://www.cvedetails.com/cve/CVE-2021-28961/)
  * 自己写也可以
* xss
  * [CVE-2019-18993](https://www.cvedetails.com/cve/CVE-2019-18993/)
* csrf
  * [CVE-2019-17367](https://www.cvedetails.com/cve/CVE-2019-17367/)
## 题目设置
### 登录
* 弱密码
* 直接爆破，用 md5 加密提示（密码的前缀），放在请求头中
* flag 在响应报请求头中
### 其他
* CVE-2019-12272
* 找到XSS注入点，绕过csp限制，获取管理员的cookie，使用管理员的cookie登录，sql注入得到flag
  * xss 绕过
  * 获得cookie <iframe onload="alert(document.cookie)"></iframe>
* unsafe redirect
## 提示
* F12 源码中，访问这个 url 试试吧？--》xss利用
* 藏在页面中
* base64 加密，base32
* 某个 flag 拿到后，可以给提示下一个
## Exp 和 Checker 脚本
## 参考文献
* [Create new users and groups for applications or system services](https://openwrt.org/docs/guide-user/additional-software/create-new-users)
