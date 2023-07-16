# 7.11-7.13
## 主要任务
* 了解 iotgoat
  * 查看 iotgoat github commit 的源码
* 学习编译 openwrt
  * 了解 luci 语言
* 重点学习修改源码中 /files
* 尝试编译搭建自己的 openwrt 操作系统

## 学习记录
* iotgoat 如何搭建的（查看 commit 记录）
  * 先运行 openwrt系统的虚拟机 [Getting started](https://github.com/OWASP/IoTGoat/commit/cbcd3dc8bbc11b3de34b2d9c5c51343a3b3cc07d)
  * no.1 的实现步骤[IoTgoat 搭建指南](https://github.com/OWASP/IoTGoat/commit/b488ba8e77dd211762240116c66f1e86fc86cfd9)
  * 修改 banner /package/base-files/banner
  * web 类型漏洞在 files/usr/lib/lua/luci/model/cbi/admin_network/wifi.lua

## 尝试修改
* fork openwrt 源码
* 先从最简单的弄起，修改一下 banner 吧
* 在根目录添加 /files 文件夹，模仿 iotgoat

## 参考文献
* [how-to-build-openwrt](https://openwrt.org/zh-cn/doc/howto/build)