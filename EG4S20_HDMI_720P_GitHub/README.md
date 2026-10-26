# EG4S20 HDMI 720p Color Bars

安路 EG4S20BG256 + 硬木课堂综合底板，输出 1280x720 @ 60 Hz 八色竖条。
开发工具：Anlogic TD 4.6.96021。纯视频/DVI 兼容信号，无音频、HDCP、EDID。

## 使用

1. TD 打开根目录 `HDMI_720P.al`，顶层 `hdmi_color_top`。
2. 综合、布局布线、查看时序后生成 bitstream，通过 JTAG 下载。
3. 连接底板 HDMI 至支持 720p60 的显示器，按下并释放用户 RSTn 按键。
4. LED0 亮表示两级 PLL 锁定；屏幕应显示白黄青绿紫红蓝黑八条竖带。

本目录不依赖原 SWLED 目录。不要额外添加旧开关灯 SWLED.v，
`al_ip/SWLED.v` 在这里是 PLL，而不是 LED 顶层。

## 文件

| 文件 | 用途 |
|---|---|
| rtl/hdmi_color_top.v | 顶层、复位、RGB/TMDS/串行模块连接 |
| rtl/hdmi_pll_720p.v | 两级 PLL 级联和锁定处理 |
| rtl/video_720p_bars.v | 行场计数、同步信号、彩条 |
| rtl/tmds_encoder.v | 单颜色通道 8bit -> 10bit TMDS 编码 |
| rtl/tmds_serializer_eg4.v | 10bit -> DDR 串行输出 |
| al_ip/*.v, *.ipc | TD 生成的 PLL 源码及可重生成配置 |
| constraints/hdmi_720p.adc | 引脚与 I/O 电气标准 |
| constraints/hdmi_720p.sdc | 输入及派生时钟 |
| sim/tb_video_720p.v | 一帧视频时序和彩条断言；非完整链路仿真 |
| docs/CODE_GUIDE.md | 中文逐语句讲解及修改方法 |
| build_720p.tcl | TD 命令行综合、布局布线和报告脚本 |

## 硬件与时钟

- clk_50m: R7，rst_n: E3（低有效），led: B14（高亮）。请核对实物版本。
- HDMI 时钟 P1/R1，D0 N1/M1，D1 P4/N4，D2 J3/J4；ADC 只约束 P 端，LVDS33 自动配置 N 端。
- 电气配置依据随板资料 M0_Borad.zip 中 10_VGA_hdmi_tx_display_MB 的 hdmi.adc。
- 50 -> 55 -> 74.25/371.25 MHz，两级 PLL；串行速率 742.5 Mb/s/通道。
- 1650x750 总时序，1280x720 有效区，正极性 HS/VS。

早期原目录版本已通过本机 TD 综合、布局布线及当前约束下的 setup/hold 检查，
但尚未上板验证。检查条件为 TT 1.10V 85C，不等于全工艺角、板级信号完整性或 HDMI 合规认证。
仿真测试平台尚未动态运行。整理版重新验证结果见 docs/VALIDATION.md。

## GitHub 备份

本目录可整体作为仓库根目录。未自动 git init、提交、推送或创建远端仓库。
推荐新建**私有仓库**备份；公开前确认板厂/安路生成 IP 和资料的分发权限。
保留 al_ip 文件中的版权信息，不擅自给第三方文件套用 MIT 等许可证。

在本目录打开终端，安装 Git 并配置身份后可执行：

```powershell
git init
git add .
git status
git commit -m "Add EG4S20 HDMI 720p color bars"
git branch -M main
git remote add origin <你的仓库URL>
git push -u origin main
```

提交前确认没有 license、个人凭据、日志与编译缓存。
`.bit` 可重新生成，默认不入库；需要保存实测固件时可单独放 GitHub Release。
