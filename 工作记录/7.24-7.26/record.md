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
* [x] fix
* [x] 提示以及题目完善

## 提示
* 提供源码——浏览器自动下载，模仿 system.lua 的 action_backup 函数
  * upload.lua
  * ```lua
        -- 设置HTTP响应头，指定为下载文件
            local reader = ltn12_popen("cat /www/upload.lua>/dev/null")

            luci.http.header(
                'Content-Disposition', 'attachment; filename="upload-%s-%s.lua"' %{
                    luci.sys.hostname(),
                    os.date("%Y-%m-%d")
                })

            luci.http.prepare_content("application/x-targz")
            luci.ltn12.pump.all(reader, luci.http.write)

            function ltn12_popen(command)

            local fdi, fdo = nixio.pipe()
            local pid = nixio.fork()

            if pid > 0 then
                fdo:close()
                local close
                return function()
                    local buffer = fdi:read(2048)
                    local wpid, stat = nixio.waitpid(pid, "nohang")
                    if not close and wpid and stat == "exited" then
                        close = true
                    end

                    if buffer and #buffer > 0 then
                        return buffer
                    elseif close then
                        fdi:close()
                        return nil
                    end
                end
            elseif pid == 0 then
                nixio.dup(fdo, nixio.stdout)
                fdi:close()
                fdo:close()
                nixio.exec("/bin/sh", "-c", command)
            end
        end
    ```
* 实现页面刷新渲染和自动下载
  ```html
            <% if flag_4 then%>
            <script>
                setTimeout(function() {
                    window.location.href = "<%=url('admin/upload/upload/sendfiles2')%>"; // 设置重定向的目标URL
                }, 3000); // 3000毫秒即3秒钟
            </script>
        <% end %>
    ```
    ```lua
        function action_sendfiles2()
        local reader = ltn12_popen("cat /www/level4.zip")
        local http = require "luci.http"
        http.header(
            'Content-Disposition', 'attachment; filename="level4-%s-%s.zip"' %{
                luci.sys.hostname(),
                os.date("%Y-%m-%d")
            })

        http.prepare_content("application/x-targz")
        luci.ltn12.pump.all(reader, http.write)
        http.redirect(luci.dispatcher.build_url('admin/upload/upload'))
        end
    ```
* xss 弹窗提示
  * 修改 showM.js 文件
## attack
* untar
* serialize
## fix
* 使用 diff 生成 patch
* commandinject
* untar
* serialize
  * action_date 函数中输入的不能为数组，table
## 修改的文件
* rule-details.lua
* status.lua 