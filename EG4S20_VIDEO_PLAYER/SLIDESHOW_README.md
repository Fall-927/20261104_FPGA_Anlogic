# 三张 BMP 手动切换与自动轮播

当前工程已增加 HDMI 48kHz 测试音，见 [HDMI_AUDIO_README.md](HDMI_AUDIO_README.md)。
以下 SD 卡、按键和图片缓存说明继续适用。

独立工程：`HDMI_SLIDESHOW.al`，顶层：`hdmi_slideshow_top`。
原有 `HDMI_BMP.al` 单图片工程仍保留。

## SD 卡准备

使用已定位的三张文件，不需要重新格式化或修改分区：

| 文件 | 绝对起始 LBA |
| --- | ---: |
| IMAGE0.BMP | 248032 |
| IMAGE1.BMP | 246112 |
| IMAGE2.BMP | 249888 |

每张必须为 640×480、24-bit BGR、BI_RGB 非压缩、正高度（bottom-up）、
54 字节头的 BMP，大小为 921654 字节，文件占用的扇区必须连续。
当前不在 FPGA 中解析 FAT 或按文件名查找；文件移动、覆盖、重新复制或
重新格式化后，必须重新运行 `tools/find_bmp_lba.py`，更新顶层的三个 LBA 参数，
重新编译。不能用文件名顺序推算物理扇区。

## 操作

1. 断电插卡，连接 HDMI，下载本工程 bit；必要时按 RESET。
2. 等待三张图全部预载，启动期间为黑屏，随后显示 IMAGE0。
3. 当前实板按键：KEY12：上一张；KEY13：下一张；KEY14：切换自动/手动模式。
4. 默认手动；自动模式约每 5 秒切换，顺序为 0→1→2→0。
5. 按键消抖约 80–84ms，长按不连发。建议按下超过 100ms。
   多键组合不支持；切换自动模式不会清空当前图。复位重新读卡并回到手动模式。

代码扫描 row3，对应 col0/1/2；用户实板丝印为 KEY12/13/14。
本次图片修复不修改扫描行或管脚映射。
加载未完成时忽略上一张/下一张；KEY14 可预选自动模式。
LED 亮表示已启用显示且未捕获加载/缓存错误，不是自动模式指示灯。

## 数据通路与切图

SDHC/SDXC SPI → BMP 校验和 RGB565 转换 → 双时钟 FIFO → SDRAM 三帧缓存。
每帧 307200 个像素，三帧共 921600 个 SDRAM 字地址；物理 SDRAM 每地址
32 位，仅使用低 16 位，因此占用地址跨度为 3686400 字节。
内部降为 RGB565，HDMI 扩展为 RGB888 输出，精度不是原始 24-bit 无损。

每帧垂直消隐期间停止读请求、等待在途 burst 完成、清空预取 FIFO，
选择帧基址并重新预取。每帧严格读取 307200 个像素，BMP 行倒序输出。
三张图开机全部预载后不再访问 SD，切图无需等待 SD 读卡。
仅在消隐期提交图片选择，不在可见行中途修改帧基址。

## 编译和下载

TD 4.6 打开 `HDMI_SLIDESHOW.al`，检查顶层为 `hdmi_slideshow_top`，
执行综合、布局布线和时序分析，确认无违例后执行 Generate Bitstream。
JTAG 下载生成的 `HDMI_SLIDESHOW.bit`，不要误选原单图或彩条 bit。

也可在工程目录执行：

```powershell
'source build_slideshow.tcl' | & 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021\bin\td.exe' -nogui
```

此脚本生成布局布线数据库和报告，不自动连接或烧写开发板。
检查时序报告后，可执行以下命令生成新的 bit：

```powershell
'source generate_slideshow_bit.tcl' | & 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021\bin\td.exe' -nogui
```

bit 文件位于工程根目录。生成 bit 不会自动烧写开发板。

## 验证范围

### 竖线修复：写 FIFO 与控制器流水线对齐

旧版写 FIFO 使用 `NOREG`，但参考 SDRAM 控制器的 `wr_ack` 是提前一拍的
取数请求，原厂搭配的是 `OUTREG`。实际控制器回归测试已复现旧版在
每段第一个物理写入地址送出下一像素，而不是正确首像素。
本次仅将 `slideshow_framebuffer` 的写 FIFO 改为 `OUTREG`；读 FIFO
继续使用 `NOREG`，HDMI 串行器、按键扫描与轮播策略不变。

新增 `sim/run_sdram_write_test.ps1`：连接真实控制器、命令模块、数据模块和
厂商 FIFO，在 SDRAM 采样相位核对实际 WRITE 数据，连续 8 个 burst、
1024 像素逐个一致。旧配置首像素失败，修复后通过。
先前的事务级缓存替身没有覆盖提前取数协议，已同步修正，
三帧写入、倒序行读出、切换与帧末限制回归通过。
这证明了流水线修复，不等同于板上竖线已消除；需要重新下载后确认。

2026-10-27：按键控制和帧缓存事务级测试通过；TD 4.6 综合、布局布线完成，
TT 1.10V 85°C 下五个时钟报告均为 0 setup / 0 hold 错误。
已生成 `HDMI_SLIDESHOW.bit`，未自动下载，仍需板上验证。

`sim/run_controls_test.ps1` 检查按键消抖、长按、循环、消隐提交及模式切换。
`sim/run_framebuffer_test.ps1` 使用真实 FIFO RTL 与事务级 SDRAM 替身，
检查三帧写入、倒序行读取、帧末停止和切换清空旧数据。
测试替身不参与综合，不能代替 SDRAM 电气时序仿真或板上验证。

布局布线时序报告位于 `HDMI_SLIDESHOW_timing.rpt`；检查适用工况、
CDC 和接口约束。已有异步时钟组例外，STA 通过不等于外部 SPI/HDMI
接口或 CDC 均已获得硬件认证。
需在板上实际验证三张图内容、连续手动切图、自动轮播多轮、复位重载，
观察是否有白条、撕裂、闪烁、黑屏。当前尚未完成新版上板验证。

厂商 IP 和参考控制器保留原版权；公开上传前确认其再分发许可。
