# EG4S20 HDMI 640x480 彩条测试

状态：已接入 TD 生成的 `al_ip/PLL.v`，完整工程已通过 TD 4.6.96021 综合、布局布线和静态时序检查。尚未进行硬件下载、显示器实测或完整链路动态仿真。原 720p 工程保持不变。

## 视频参数

| 项目 | 数值 |
| --- | --- |
| 有效画面 | 640 x 480 |
| 像素时钟 | 25.2 MHz |
| 5 倍串行时钟 | 126 MHz |
| 每路 TMDS 数据率 | 252 Mbit/s（DDR） |
| 水平：有效/前肩/同步/后肩 | 640 / 16 / 96 / 48 |
| 垂直：有效/前肩/同步/后肩 | 480 / 10 / 2 / 33 |
| 总计 / 刷新率 | 800 x 525 / 60 Hz |
| HS / VS 极性 | 均为负 |

采用 25.2 MHz 的 60.000 Hz 变体，并非传统 25.175 MHz 的约 59.94 Hz。接收设备兼容性需实测。纯视频 TMDS（DVI 兼容）输出，不含音频、HDCP 或 HDMI 数据岛。

## PLL 与编译

1. TD 打开 `HDMI_480P.al`，顶层必须为 `hdmi_color_top`，不是 `PLL`。当前已包含生成好的 PLL，无须重新生成。
2. 如需修改时钟，进入 Tools -> IP Generator，编辑 `al_ip/PLL.ipc`；模块名保持 `PLL`，输出到 `al_ip/PLL.v`。
3. 输入 50 MHz，无补偿（No compensation），启用 Reset 和 Lock，带宽默认 Medium。
4. 启用 C0=25.2 MHz、C1=126 MHz，两路相位均为 0。预期参考分频 5、反馈倍频 63、VCO=630 MHz、输出分频 25 和 5；模拟环路参数由 TD 计算，不手填。
5. 生成后确认端口为 refclk/reset/extlock/clk0_out/clk1_out；核对包装模块中的 `u_core.pll_inst` 层级与生成文件一致。
6. 工程仅添加新 PLL，不添加旧 SWLED.v 或 720p 的 pll.v。顶层设为 `hdmi_color_top`。测试平台仅用于仿真，不参与综合。
7. 执行综合、Place、Route，检查两个时钟频率及 setup/hold 均无违例，再生成 bit，用 JTAG 下载。`PLL_sim.v` 不加入综合文件列表，旧 `pll_480p.v` 占位文件也不使用。

命令行可执行 `source build_480p.tcl`。完成时序检查后，可执行 `bitgen -bit HDMI_480P.bit`。不会自动进行 JTAG 下载或 Flash 写入。

## 管脚

沿用已核对的底板约束：clk_50m=R7、rst_n=E3、led=B14，均 LVCMOS33；HDMI 时钟 P1、数据 B/G/R=N1/P4/J3，均 LVDS33。负端由 TD 配对，不单独增加 N 输出。复位低有效，LED 显示 PLL 锁定，不代表视频一定正确。

## 如何修改代码

- `rtl/video_480p_bars.v`：x/y 是横纵坐标；799/524 是一行/一帧计数终点。hsync/vsync 用区间取反形成低有效脉冲。de 只在有效区为高；颜色比较阈值每 80 像素变化一次。
- `rtl/hdmi_pll_480p.v`：把 TD 生成的 PLL 端口映射为像素时钟、串行时钟和锁定信号；SDC 显式描述同源时钟。
- `rtl/hdmi_color_top.v`：连接时钟、复位同步、彩条、三路 TMDS 编码和 DDR 串行器。蓝色通道消隐时携带 HS/VS。
- `rtl/tmds_encoder.v`：RGB 每字节转换为 10 位 TMDS 码，并控制直流平衡。
- `rtl/tmds_serializer_eg4.v`：每个像素使用 5 个串行时钟周期、每周期双沿输出 2 位，低位先发。只适用于本工程同 PLL、固定相位的 5:1 时钟。
- `constraints/hdmi_480p.sdc`：20ns 输入时钟；输出倍率分别为 0.504 和 2.52。修改分辨率必须同时检查 PLL、时序、SDC、彩条边界和测试平台。

## GitHub 备份

保留 rtl、al_ip、constraints、sim、工程文件、脚本、README 和点文件。构建日志、数据库、报告和 bit 不提交。不要上传 TD 安装目录、许可证、厂商 PDF。生成 IP 的公开再分发权限应另行确认；备份可先使用私有仓库。
