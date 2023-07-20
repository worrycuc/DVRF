# DVRF web 开发记录
## 已完成
* [x] 界面修改，普通用户
* web 漏洞
  * [x] 登录
  * [x] xss
  * [x] 命令注入
* [x] check 和 exp
* [ ] 提示以及题目完善
## 命令注入
### 关于接口权限问题
*  ps 查看进程的权限 `5495 root 864 S /usr/sbin/uhttpd -f -h /www -r OpenWrt -x /cgi-bin -t 6`
* 接口在对输入时对与根目录有关的操作'/'做了限制，直接执行与根目录相关的操作都无法正常执行，查看 systemlog,发现 shell 报语法错误，猜测对输入进行了修改过滤
* 会话的环境变量与系统的环境变量不一致，在服务器段设置 $FLAG 并不会在 web 的会话中出现
### 难度
* 如何回显shell输出
* 命令间的拼接
* 过滤 cat less more，在 [status.lua](https://github.com/worrycuc/DVRF/blob/develop/files/usr/lib/lua/luci/controller/admin/status.lua) 中更改
  * ```lua
        function filterKeywords(str)
            local keywords = {"cat", "less", "more"}
            
            for _, keyword in ipairs(keywords) do
            str = string.gsub(str, keyword, "")
            end
            
            return str
        end
  * 使用 tail 可绕过，具体方式为`http://%s/cgi-bin/luci/admin/status/realtime/bandwidth_status/eth0$(echo cd ..>output.sh;echo tail flag.txt>>output.sh;ash%20output.sh%3Eoutput)`
## 提示
## Exp && Checker
* 登录
  * [login check](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/checker/login.py)
  * [login exp](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/exp/login.py)
* xss
  * [xss check](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/checker/xss.py)
  * [xss exp](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/exp/xss.py)
* 命令注入
  * [ci check](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/checker/commandinjection.py)
  * [ci exp](https://github.com/worrycuc/DVRF/blob/develop/%E5%B7%A5%E4%BD%9C%E8%AE%B0%E5%BD%95/exp/commandinjection.py)