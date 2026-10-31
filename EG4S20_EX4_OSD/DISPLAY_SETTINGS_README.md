# 基础功能 + 拓展4（无拓展2）

当前工程保留 SD BMP 读取、三图 SDRAM 缓存、640×480 HDMI 显示与原 HDMI 测试音。
切图采用垂直消隐期直接换图，不再执行淡出、淡入、黑场等待或滑动转场。
工程目录统一为 `EG4S20_EX4_OSD`，TD 工程名为 `HDMI_EX4_OSD`。

| 按键 | 功能 |
| --- | --- |
| KEY12 / KEY13 | 上一张 / 下一张，直接切换 |
| KEY14 | 自动 / 手动轮播，自动约5秒一次 |
| KEY8 / KEY9 | 亮度减 / 加 |
| KEY4 / KEY5 | 对比度减 / 加 |
| KEY0 | 恢复亮度、对比度默认值08 |
| KEY1 | 显示 / 隐藏参数面板 |

亮度、对比度范围均为00～16，默认08，左上角显示 BRI、CON 数字与条形刻度。
按键需按下约100ms，长按不连发。新增按键丝印沿用此前映射，仍需实板确认。
电气映射：亮度 row=1011 的col0/1，对比度 row=1101 的col0/1，恢复/面板 row=1110 的col0/1。

图像运算：`clip(((channel-128)*contrast >> 3)+128+(brightness-8)*16, 0, 255)`。
参数及图片选择在垂直消隐提交，信息叠加不写回 SDRAM。
调色与OSD保留两拍流水线，坐标、DE、HS、VS同步延迟，不更改SDRAM读取节拍。
默认参数逐位保留RGB565扩展后的RGB888，复位恢复参数，不写卡保存。

工程入口 `HDMI_EX4_OSD.al`，顶层必须是 `hdmi_slideshow_top`。
`build_ex4.tcl` 执行综合、布局布线和时序分析；`generate_ex4_bit.tcl`生成bit，不自动烧写。
`sim/run_settings_test.ps1`验证参数、矩阵按键及直接切图。
SD卡地址与输入格式沿用 `SLIDESHOW_README.md`。

修改前代码、测试及说明备份：`D:/FPGAqiansai/backups/before-remove-task2-20261028`。
已移除旧转场RTL、转场测试和转场说明，均可从备份恢复。

本次验证：参数运算73984组组合、矩阵按键及直接切图测试全部通过。
TD综合、布局布线完成，现有约束下0 setup / 0 hold违例；最小setup slack 1.298 ns，hold slack 0.127 ns。
已重新生成 `HDMI_EX4_OSD.bit`，未自动上板，实际显示与按键仍需下载验收。
