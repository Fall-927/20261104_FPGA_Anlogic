# Ex4：OSD 显示参数调节

安路 EG4S20BG256 图片轮播工程，当前分支为 `Ex4_osd-parameter-adjust`。
本版本包含基础图片显示、HDMI 测试音及拓展4，不包含拓展2转场。

工程目录：[EG4S20_EX4_OSD](EG4S20_EX4_OSD/)。

## 使用入口

1. 使用 Anlogic TD 4.6 打开 `EG4S20_EX4_OSD/HDMI_EX4_OSD.al`。
2. 顶层保持为 `hdmi_slideshow_top`，不要选择 OSD 子模块。
3. 在工程目录执行 `source build_ex4.tcl`，检查时序后执行 `source generate_ex4_bit.tcl`。
4. 输出 `HDMI_EX4_OSD.bit`，通过下载器加载到开发板。

SD 卡格式、BMP 规格和绝对 LBA 配置见工程内 `SLIDESHOW_README.md`。
复制/更换 SD 卡文件后必须重新定位地址和构建，默认地址不能通用于其他卡。

## 按键

| 按键 | 功能 |
| --- | --- |
| KEY12 / KEY13 | 上一张 / 下一张 |
| KEY14 | 自动 / 手动轮播 |
| KEY8 / KEY9 | 亮度减 / 加 |
| KEY4 / KEY5 | 对比度减 / 加 |
| KEY0 | 恢复默认参数 |
| KEY1 | 显示 / 隐藏 OSD |

参数范围 00～16，默认 08；参数和图片在垂直消隐提交。
完整功能及测试说明见 `EG4S20_EX4_OSD/DISPLAY_SETTINGS_README.md`。
本次整理不更改 RTL 功能，不代表新增板级验证。

不包含 TD 数据库、日志、比特流、测试二进制或个人媒体。第三方授权说明保留在工程内。
