# EG4S20 HDMI 480p

基于安路 EG4S20BG256 的 640×480、60 Hz HDMI 接口彩条输出工程。
使用 Verilog、安路 PLL 和 ODDR 原语，实现 DVI 兼容纯视频输出。
这是显示基础工程，不包含 SD 卡、BMP、SDRAM 帧缓存、HDMI 音频、HDCP 或 EDID。

## 环境与参数

- FPGA：EG4S20BG256，大拇指核心板及配套 HDMI 底板。
- 综合工具：Anlogic Tang Dynasty 4.6.96021。
- 输入时钟：50 MHz；像素时钟：25.2 MHz；DDR 串行时钟：126 MHz。
- 有效画面：640×480；总时序：800×525；HS、VS 均为负极性。
- H 有效/前肩/同步/后肩：640/16/96/48。
- V 有效/前肩/同步/后肩：480/10/2/33。
- 白、黄、青、绿、紫、红、蓝、黑八色条，每条宽 80 像素。

## 文件结构

```text
HDMI_480P.al           TD 工程入口
build_480p.tcl         综合、布局布线和时序报告
rtl/                  5 个可综合 Verilog 模块
constraints/          引脚和时钟约束
ip/hdmi_pll.ipc        PLL 配置记录
sim/                  视频时序及 PLL 测试平台
scripts/simulate.ps1  可配置安装路径的仿真入口
```

工程只引用本目录内文件，无需原 SWLED 或 720p 工程。
PLL 直接实例化于 `rtl/hdmi_pll_480p.v`，综合无需重新生成 IP；
`.ipc` 仅为配置记录，不是额外编译输入。

## 构建和下载

1. 在 TD 打开 `HDMI_480P.al`，顶层为 `hdmi_color_top`。
2. 执行综合、布局布线，检查时序报告后生成 bitstream。
3. 或在本目录的 TD 命令行运行：

```tcl
source build_480p.tcl
# 确认时序报告通过后再执行：
bitgen -bit HDMI_480P.bit -version 0X00 -g ucode:00000000000000000000000000000000
```

4. 用 TD Download 将新生成的 `HDMI_480P.bit` 通过 JTAG 下载到 FPGA。
   首次测试不选择 Program Flash。
5. 按下并释放用户复位键，LED0 常亮表示 PLL 锁定，显示器应显示八色条。

25.2 MHz 相比常见的 25.175 MHz 高约 0.0993%，对应整 60 Hz。
实际显示器兼容性、PLL 模拟锁定和长期稳定性仍需上板验证；LED 亮不等于视频正常。

## 引脚

| 端口 | 球位 | 电平 |
|---|---|---|
| clk_50m | R7 | LVCMOS33 |
| rst_n | E3 | LVCMOS33，低有效 |
| led | B14 | LVCMOS33，高亮 |
| hdmi_clk_p | P1 | LVDS33 |
| hdmi_data_p[0] | N1 | LVDS33 |
| hdmi_data_p[1] | P4 | LVDS33 |
| hdmi_data_p[2] | J3 | LVDS33 |

N 端由 TD 自动配对为 R1、M1、N4、J4，不要另行驱动。
HDMI LVDS33 配置沿用原工程所采用的板厂示例：
`M0_Borad/10_VGA_hdmi_tx_display_MB/source_code/adc_sdc/hdmi.adc`。
上板前核对实际板卡版本。

## 仿真

视频测试检查连续两帧的全部像素、同步、颜色、帧回绕及复位。
PLL 测试使用 TD 安装目录自带的数字模型，不随仓库分发供应商库。
安装 Vivado Simulator 后，从仓库根目录运行（路径替换为本机安装目录）：

```powershell
.\scripts\simulate.ps1 -VivadoBin 'D:\Vivado\2017.4\bin' -TdRoot 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021'
```

如果系统阻止运行脚本，可仅对本次进程使用以下入口，不修改系统策略：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\simulate.ps1 -VivadoBin 'D:\Vivado\2017.4\bin' -TdRoot 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021'
```

Vivado 仅用于仿真，不用于安路器件综合。成功时两项测试分别输出 `PASS:`。

## 验证记录与限制

整理前的 480p 工程已完成 TD 综合、布局布线和 bitgen，无布线违例；
TT、1.10 V、85°C 条件下各时钟域 setup/hold 错误均为 0。
资源：576 LUT、110 寄存器、1 PLL、0 BRAM；两帧时序及 PLL 数字模型仿真通过。
本次整理只删减注释和工程运行状态，不修改 RTL 功能。
尚未上板验证，也未完成完整 HDMI 接收端解码或全工艺角签核。
PLL 模拟环路参数沿用原工程第二级设置；数字仿真不等同于模拟环路验证。

仓库仅包含可重建源码；bitstream、日志、缓存和数据库不纳入版本控制。
当前为无帧缓存彩条，后续同色深 640×480 帧缓存容量为 1280×720 的三分之一，
不代表 bitstream 文件大小也缩小至三分之一。

## 备份与授权

这是本地整理的 GitHub 备份目录，尚未自动上传、初始化提交或设置远程仓库。
未附带原始 PDF、供应商仿真库或工具安装文件，也未擅自指定开源许可证。
公开发布前请自行确认代码及第三方资料的授权；需要开源时再按实际权属选择许可证。
