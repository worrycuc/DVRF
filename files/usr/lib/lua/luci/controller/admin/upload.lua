module("luci.controller.admin.upload", package.seeall)

function index()
	local fs = require "nixio.fs"

	entry({"admin", "upload"}, alias("admin", "upload", "upload"), _("Upload"), 30).index = true

	entry({"admin", "upload", "upload"}, call("action_upload"), _("Upload"), 1)

	-- call() instead of post() due to upload handling!
    entry({"admin", "upload", "upload", "untar"}, call("action_untar"))
	entry({"admin", "upload", "upload", "uploadflag"}, call("action_uploadflag"))
    entry({"admin", "upload", "upload", "date"}, call("action_date")).leaf = true
end

local function image_supported(image)
    return (0==0)
	-- return (os.execute("sysupgrade -T %q >/dev/null" % image) == 0)
end

local function image_checksum(image)
	return (luci.sys.exec("md5sum %q" % image):match("^([^%s]+)"))
end

local function image_sha256_checksum(image)
	return (luci.sys.exec("sha256sum %q" % image):match("^([^%s]+)"))
end

local function supports_sysupgrade()
	return nixio.fs.access("/lib/upgrade/platform.sh")
end

local function supports_reset()
	return (os.execute([[grep -sq "^overlayfs:/overlay / overlay " /proc/mounts]]) == 0)
end

local function storage_size()
	local size = 0
	if nixio.fs.access("/proc/mtd") then
		for l in io.lines("/proc/mtd") do
			local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
			if n == "linux" or n == "firmware" then
				size = tonumber(s, 16)
				break
			end
		end
	elseif nixio.fs.access("/proc/partitions") then
		for l in io.lines("/proc/partitions") do
			local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
			if b and n and not n:match('[0-9]') then
				size = tonumber(b) * 1024
				break
			end
		end
	end
	return size
end


function action_upload()
	--
	-- Overview
	--
	luci.template.render("admin_upload/upload", {
		reset_avail   = supports_reset(),
		upgrade_avail = supports_sysupgrade()
	})
end

function action_uploadflag()
	local fs = require "nixio.fs"
	local http = require "luci.http"

    local c=http.formvalue("flag") 
    local file = io.open("/etc/config/samba", "r")

    -- 读取文件内容并逐行匹配
    local lineNum = 0
    local nextLine = ""
    local lastLine = false
    for line in file:lines() do
        lineNum = lineNum + 1
        if line == c then
            lastLine = lineNum
        end
    end

    -- 关闭文件
    file:close()

    -- 输出结果
    if lastLine then
        if lastLine==1 then
            hint='some URL can be used,want know more please using xss attack in port forwards'
        end
        if lastLine==2 then
            hint='Incredible! Now untar seems to be a good tool'
        end
        if lastLine==3 then
            hint='serialize is fun! learn the code to get flag'
        end
        if lastLine==4 then
            hint='you successfully find all flag in web,see if you can crack the pwn'
        end
        if lastLine==lineNum then
            os.execute('echo "flag{$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | head -c 16)}" >> /etc/config/samba')
            if lastLine==1 or lastLine==2 then
                os.execute('tail -n 1 /etc/config/samba >/flag')
            end
            if lastLine==3 then
                os.execute('tail -n 1 /etc/config/samba >/www/flag')
            end
        end
        luci.template.render("admin_upload/upload", {
            flag_success = true,
            flag_hint=hint
    })
    else
        luci.template.render("admin_upload/upload", {
            flag_failed = true
    })
    end
    http.redirect(luci.dispatcher.build_url('admin/upload/upload'))
end

function action_uploadtar()
	local fs = require "nixio.fs"
	local http = require "luci.http"
	local archive_tmp = "/tmp/restore.tar"

	local fp
	http.setfilehandler(
		function(meta, chunk, eof)
			if not fp and meta and meta.name == "archive" then
				fp = io.open(archive_tmp, "w")
			end
			if fp and chunk then
				fp:write(chunk)
			end
			if fp and eof then
				fp:close()
			end
		end
	)

	if not luci.dispatcher.test_post_security() then
		fs.unlink(archive_tmp)
		return
	end

	local upload = http.formvalue("archive")
	if upload and #upload > 0 then
		if os.execute("tar -C / -xzf %q >/dev/null 2>&1" % archive_tmp) == 0 then
			luci.template.render("admin_upload/upload", {
				reset_avail   = supports_reset(),
				upgrade_avail = supports_sysupgrade(),
				backup_invalid = true
			})
		end
		return http.redirect(luci.dispatcher.build_url('admin/upload/upload'))
	end

	http.redirect(luci.dispatcher.build_url('admin/upload/upload'))
end

function action_reset()
	if supports_reset() then
		luci.template.render("admin_system/applyreboot", {
			title = luci.i18n.translate("Erasing..."),
			msg   = luci.i18n.translate("The system is erasing the configuration partition now and will reboot itself when finished."),
			addr  = "192.168.1.1"
		})

		fork_exec("sleep 1; killall dropbear uhttpd; sleep 1; jffs2reset -y && reboot")
		return
	end

	http.redirect(luci.dispatcher.build_url('admin/upload/flashops'))
end

function action_untar()
    local fs = require "nixio.fs"
	local http = require "luci.http"
    local c=http.formvalue("fileName") 
	local tarfile_tmp = string.format("/tmp/upload/%s", c)
	local fp
	http.setfilehandler(
		function(meta, chunk, eof)
			if not fp and meta then
				fp = io.open(tarfile_tmp, "w")
			end
			if fp and chunk then
				fp:write(chunk)
			end
			if fp and eof then
				fp:close()
			end

		end
	)

	-- if not luci.dispatcher.test_post_security() then
	-- 	fs.unlink(tarfile_tmp)
	-- 	return
	-- end
    c="tar -C /tmp/upload/ -xf %s >/dev/null 2>&1 && rm %s" % {tarfile_tmp, tarfile_tmp}
    os.execute("echo %s>output" % c)
    if os.execute("tar -C /tmp/upload/ -xf %s >/dev/null 2>&1 && rm %s" % {tarfile_tmp, tarfile_tmp}) == 0 then
		luci.template.render("admin_upload/upload", {
			upload_success = true
		})
	else
		luci.template.render("admin_upload/upload", {
			upload_success = false
		})
	end
	return
	http.redirect(luci.dispatcher.build_url('admin/upload/upload'))
end

function action_date(code)
    local http = require("luci.http")
    local util = require("luci.util")
    local md5 = require ("luci.md5")
    -- 定义一个名为date的类
    local date = {
        a = nil,
        b = nil,
        file = nil
    }

    -- 定义date类的__wakeup方法
    function date:__wakeup()
        -- if type(self.a) == "table" or type(self.b) == "table" then
        --     http.status(400, "Bad Request")
        --     http.write("no array")
        --     return
        -- end
        -- json = require "luci.json"
        -- local base64 = require"luci.base64"
        -- local date = {
        --     a = {},
        --     b = {},
        --     file = "\\f\\l\\a\\g"
        -- }
        
        -- -- 创建一个函数来模拟PHP中的Error类
        -- local function Error(message, code)
        --     return {
        --         message = message,
        --         code = code
        --     }
        -- end
        
        -- -- 创建一个date对象，并设置a和b字段为Error对象
        -- date.a = Error("payload", 1)
        -- date.b = Error("payload", 2)
        -- -- 序列化date对象为字符串
        -- local serialized_str = json.encode(date)
        -- local encoded = base64.encode( serialized_str )


        if self.a ~= self.b and md5.sum(self.a) == md5.sum(self.b) then
            local content = self.file
            local uuid = util.exec("echo $RANDOM"):gsub("\n", "") .. ".txt"
            util.exec("echo '" .. content .. "' > " .. uuid)
            local data = util.exec("cat " .. uuid):gsub("%s+", "")
            -- http.write(encoded)
            http.write(util.exec("cat " .. data))
        else
            http.status(400, "Bad Request")
            http.write("")
        end
    end
    -- 解析传递的GET参数并调用date类的__wakeup方法
    http.prepare_content("application/json")
    json = require "luci.json"
    local base64 = require"luci.base64"
    if code then
        local decoded_code = base64.decode(code)
        local success, obj = pcall(json.decode, decoded_code)
        if success and type(obj) == "table" then
            setmetatable(obj, { __index = date })
            obj:__wakeup()
        else
            http.status(400, "Bad Request")
            http.write(decoded_code)
        end
    else
        http.status(400, "Bad Request")
        http.write("")
    end
end