# EG4S20 SD 视频与原声音轨播放

> 更新：下文是首版 AV15 的历史说明。当前代码已经升级到 AV10 v2，
> 请以 `VIDEO_HQ_README.md` 为准。旧 VIDEO0.AV / HDMI_VIDEO.bit 不能用于新版。

独立工程：`HDMI_VIDEO.al`；顶层：`rtl/hdmi_video_top.v`。
原 `EG4S20_BMP_SLIDESHOW` 目录未修改。这里复制保留了原参考代码及版权声明；
原 SLIDESHOW / AUDIO README 只描述旧图片工程，不适用于视频播放。

## 当前状态与限制

- 实现 AV15 专用格式，不直接读取 MP4/H.264/AAC，也不读取普通 BMP。
- 160×120、RGB565LE、15 fps、正向行序；像素及行均重复四次，输出 640×480/60 HDMI。
- 原声为 48 kHz、16 位、双声道 LPCM，支持左右不同信号，不是内置测试音。
- SDRAM 四槽循环缓冲，写入未发布、显示及声音均完成后才回收。
- 每个素材帧对应 3200 组立体声样本与四个 HDMI 帧；暂停不消耗声音数据。
- KEY12 上一个、KEY13 下一个（最多三项，循环选择），KEY14 暂停/继续。
  暂停在素材帧边界提交，最大约 67 ms，加约 84 ms 按键消抖。
  KEY12/13 切换会黑屏静音、重新初始化读卡并从片头开始，不是无缝切换。
- 同一视频片尾自动从头重新加载循环，有短暂黑屏/静音，不自动跳到下一段。
- 未设置的 VIDEO1/2 地址为 0，选择它们会重新播放 VIDEO0。
- 错误或音画欠载会关闭图像、静音并熄灭 LED，需要复位或切换重试。
- SDHC/SDXC、SPI 模式，要求文件物理扇区连续；不支持 FPGA FAT 跟链、exFAT、碎片文件。
- 12.5 MHz SPI 原始上限 1.56 MB/s，素材 768000 B/s；CMD17 与卡内部延迟降低余量。
  慢卡不能保证持续播放，仿真不代表所有卡兼容。CRC 字节被读取但尚未验证 CRC16。
- HDMI 沿用原固定时序和管脚，不实现 EDID、HPD、HDCP。接收器需支持 HDMI 音频。

**没有实板验证。不能将仿真和时序通过等同于已经成功显示/发声。**

## 1. 素材与打包

已经将用户的素材打包为 `D:\Users\yushe\Videos\VIDEO0.AV`：
76 帧，5.0667 秒，7601 扇区，3891712 字节。
声音源 965120 字节，按视频长度补到 972800 字节，尾部补静音。

再次打包（输出文件必须尚不存在，避免覆盖素材）：

```powershell
python tools/pack_video.py --video 'D:\Users\yushe\Videos\video.rgb565' --audio 'D:\Users\yushe\Videos\audio.pcm' --output 'D:\Users\yushe\Videos\VIDEO1.AV'
```

其他视频先用 FFmpeg 转换为相同格式，再打包为 VIDEO1.AV / VIDEO2.AV。
不要只是把同一视频改名假装是不同素材。
视频长度为准；音轨不足补静音，超过视频长度截断。
复杂编辑列表或不同流起始时间的 MP4 应先在电脑确认转换后的音画对齐。

## 2. SD 卡准备（仍需用户操作）

1. 备份卡上重要文件；本工程工具不格式化、不写物理磁盘、不自动复制文件。
2. 将 VIDEO0.AV（可加 VIDEO1/2.AV）复制到现有 FAT16/FAT32 卡根目录。
3. **必须验证连续性并获取实际 LBA，不能按文件名、盘符或文件大小猜地址。**
4. 用只读的完整 SD 镜像，或管理员 PowerShell 中已核对为该 SD 的物理磁盘运行：

```powershell
# N 必须替换成通过 Windows 磁盘管理核实的 SD 卡磁盘号。
# 此命令以 rb 只读打开，不会写卡；不能把示例中的 N 直接执行。
python tools/locate_video.py '\\.\PhysicalDriveN' --files VIDEO0.AV
# 三个文件：--files VIDEO0.AV VIDEO1.AV VIDEO2.AV
# 镜像文件也可：python tools/locate_video.py 'D:\sd-backup.img' --files VIDEO0.AV
```

定位器支持 MBR 单 FAT 分区或 FAT superfloppy，FAT32 根目录跟链和活动 FAT。
多个分区时显式传 `--partition-lba`。碎片、损坏链、格式或长度不匹配会拒绝。
文件复制、移动、替换后必须重新定位并重新编译。

## 3. 填地址、编译、生成 bit

**当前 `VIDEO0_LBA=251744` 已匹配本次 SD 卡上的 VIDEO0.AV。**
只读访问卷 `\\.\F:` 验证 FAT 连续链，卷内相对扇区为 5984；
加分区起点 245760 得绝对扇区 251744。文件 SHA256 与电脑素材一致：
`05AA00985CF45F32AE267628DB7DEF0EE233B21408B6BAFD9764A75FAFFAF6E3`。
文件移动、替换、重新复制或换卡后需要重新定位并编译，不能复用旧地址。

把定位结果填进 `rtl/hdmi_video_top.v` 的 VIDEO0_LBA、VIDEO1_LBA、VIDEO2_LBA。
然后在本工程目录执行：

```powershell
'source build_video.tcl' | & 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021\bin\td.exe' -nogui
```

检查当前生成的 `HDMI_VIDEO_timing.rpt` 和全部告警，再运行：

```powershell
'source generate_video_bit.tcl' | & 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021\bin\td.exe' -nogui
```

输出为本目录 `HDMI_VIDEO.bit`；不能误用复制保留的 HDMI_SLIDESHOW 工程。
不自动连接开发板或烧写。先降低接收端音量，断电插卡，再下载并验证。

## 4. 验证与覆盖范围

本次结果（2026-10-29）：

- TD 4.6 使用实际 VIDEO0_LBA=251744 重新综合、布局布线完成，
  五时钟 0 setup / 0 hold，最小裕量 2.169 / 0.104 ns。
- 使用 3837 LUT、1662 寄存器、6 BRAM9K、3 DSP、2 PLL。
- 8 包 / 32 显示帧，9830400 像素及 25600 双声道样本逐个匹配。
- 暂停恢复测试逐像素匹配 13516800 像素，音频仍恰好 25600 样本，无重复/遗漏。
- 按键切换重启后重新核对全片通过。
- 外部 PCM HDMI 测试 49600 采样，49599 反向解码正确，末尾一个仍在发送队列。
- 打包/FAT16定位 Python 三项测试通过，头/小端/背压 RTL 测试通过。
- SD 文件实际 LBA 已确认 251744，已据此重新编译并成功生成 `HDMI_VIDEO.bit`，629600 字节。
  bitgen 成功日志为 `td_20261029_140930.log`。未下载开发板，仍需实板验证。

只读检查发现当前 USB 卡磁盘号为 1：F: 是 FAT 分区（原 IMAGE0/1/2.BMP），
起始扇区 245760；G: 是 exFAT，不用于本版本。
**盘符/磁盘号重新插卡后可能变化，执行定位前重新核实。**
若用户将 VIDEO0.AV 复制进当前 F:，定位示例为：

```powershell
python tools/locate_video.py '\\.\PhysicalDrive1' --partition-lba 245760 --files VIDEO0.AV
```

这是文件所在分区起点，不是 VIDEO0_LBA，不能混用。

`sim/test_pack_video.py`：打包、补静音、拒绝覆盖、头格式、FAT16 连续链/碎片拒绝。
`sim/run_video_tests.ps1`：AV15 头与小端字节、背压、端到端像素、双声道样本、缓存回绕、片尾、暂停恢复、按键切换。
端到端采用真实 FIFO RTL，加事务级 SDRAM、统一仿真时钟和节流的读卡替身，
因此不覆盖真实 SD 命令交互、异步时钟相位、SDRAM 电气时序或接收器兼容性。
`sim/test_hdmi_pcm.cpp`：外部不同左右声道样本反向解码、BCH、IEC60958、元数据、N/CTS、可见区 RGB。
原 `sim/run_audio_test.ps1` 继续测试默认内建音模式。

STA 沿用异步分组与 CDC 假路径；通过不代表跨域、SPI 外部时序和 HDMI 电气认证。
实板需逐项检查画面方向、比例、连续播放、多轮回绕、原声左右声道、口型同步、
暂停/继续、长按不连跳、三视频切换、复位、慢卡欠载与错误恢复。

## AV15 v1 格式

头 512 字节，其余保留字节全零，所有整数 little-endian：

| 偏移 | 长度 | 内容 |
| --- | --- | --- |
| 0 | 4 | ASCII AV15 |
| 4 | 4 | 版本 1 |
| 8/10 | 各2 | 宽160 / 高120 |
| 12/14 | 各2 | 帧率15 / 声道2 |
| 16 | 4 | 采样率48000 |
| 20 | 4 | 视频帧数 |
| 24/28 | 各4 | 每帧图像38400 / 声音12800字节 |

每个包恰好 100 个扇区：先图像 RGB565LE 38400 字节，再 L/R 交错 S16LE 12800 字节。
总文件长度必须为 `512 + 帧数 × 51200`，当前硬件最多接受 83886 帧。
