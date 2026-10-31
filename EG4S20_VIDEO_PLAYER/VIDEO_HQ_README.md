# EG4S20 SD 视频播放器

当前仓库源码对应稳定格式 AV10 v2：320×240 RGB565、10 fps、48 kHz/16 bit 双声道 PCM，HDMI 输出 640×480。MP4 必须先在电脑端转换，FPGA 不包含 H.264/AAC 解码器。

## 工程结构

- `rtl/`：视频顶层、SD SPI 读取、AV 解包、SDRAM 缓存、HDMI 音视频发送。
- `al_ip/`：安路 EG4 原语包装模块。
- `constraints/`：管脚和时钟约束。
- `tools/`：视频转换、AV 打包和只读 FAT 定位工具。
- `sim/`、`simulation/`：仿真和回归测试。
- `HDMI_VIDEO.al`：视频工程；`build_video.tcl` 和 `generate_video_bit.tcl`：构建脚本。

## 构建

使用 Anlogic TD 4.6，在本目录执行：

```tcl
source build_video.tcl
source generate_video_bit.tcl
```

生成的数据库、报告和 `.bit` 文件均为本地构建产物，不提交到仓库。

## 媒体准备

```powershell
.\tools\convert_video_hq.ps1 -InputVideo 'input.mp4' -OutputBase 'VIDEOHQ'
```

将生成的 `VIDEOHQ.AV` 改名为 `VIDEO0.AV` 后复制到 FAT16/FAT32 SD 卡根目录。文件必须连续；复制或移动后使用 `tools/locate_video.py` 重新定位绝对 LBA，并更新 `rtl/hdmi_video_top.v` 的 `VIDEO0_LBA` 后重新构建。不要把视频文件提交到源码仓库。

## 上板使用

下载生成的 `HDMI_VIDEO.bit`，SD 卡插入开发板后上电。KEY12/KEY13 切换视频，KEY14 暂停/继续。HDMI 接收端需支持 LPCM 音频。

## 说明

工程只支持 SDHC/SDXC、SPI 读卡和连续文件，不支持直接读取 MP4、H.264、AAC 或 exFAT。第三方授权见 `THIRD_PARTY_NOTICES.md` 和 `LICENSES/`。

## 修复与边界

1. 旧版片尾触发全流复位，停止 TMDS 并重做 SD 初始化；黑屏是旧代码明确行为。
   现改为 SD 完成末扇区后直接发 CMD17 读取文件第一个 payload 扇区，
   不重读头、不重初始化，四个循环槽提前预取下一轮，首帧编号归零。
2. HDMI 时序、串行器及音频元数据不再随换片复位。
   冷启动先发送 2 秒稳定黑画面/静音，让接收器锁定，再显示首帧；
   预缓冲四包后才启动。避免“FPGA 已播片头、显示器还没锁定”的常见观感。
   2 秒不是对所有接收器锁定时间的保证。
3. 音频 L/R 在启动前预取，Explicit Audio InfoFrame 声明 LPCM / stereo / 48k / 16bit，
   并每帧发 Clear_AVMUTE GCP。原素材并非静音（原声均值约 -13.8 dBFS）。
   这些是兼容性修订，**尚不能确定无声根因或保证特定显示器有声**。
   PCM 输入、N/CTS、数据岛、校验仍需真实 HDMI 接收器验证。
4. 分辨率从 160×120 升为 320×240，像素数四倍，2×放大而不是4×。
   为控制原始数据带宽，帧率从15降为10。输出仍是640×480/60，不是高清解码器。
   动作流畅度会下降，不能等同原1206×664/30视频质量。
5. SPI 数据时钟从12.5提升到25 MHz，仍是逐扇区 CMD17。
   素材约1.731 MB/s，卡延迟/电气质量可能导致欠载，四包只能吸收短时抖动。
   新版不能保证所有SD卡稳定播放；慢卡时fail关闭画面/声音。

原图片工程目录未修改。当前卡未连接电脑，未自动复制/覆盖SD卡文件，也未烧板。

## 新素材与下一步

已核对本次卡上VIDEOHQ.AV：卷F:所在分区起点245760，文件相对LBA13600，
实际绝对LBA259360，FAT链连续；SHA256为
`D8E6549E194B97DB37075878C5EAFDE1A01C1875661CF5530A982C9C008F896C`，
与电脑原文件一致。顶层VIDEO0_LBA已更新259360。
用户反馈旧48kHz测试音输出正常；新版原声仍需实板验证。
已用实际地址259360重新综合、布局布线：0 setup / 0 hold，
最小裕量1.312 / 0.104ns。bitgen成功，`HDMI_VIDEO.bit`为629600字节，
生成于2026-10-29 19:39:27；日志`td_20261029_193921.log`。
本文件名现已更新为HQ新版，不再是旧AV15内容；未自动烧写开发板。

电脑已经生成 `D:\Users\yushe\Videos\VIDEOHQ.AV`：
320×240/10fps，51帧，5.1秒，8826368字节，17239扇区。
请将它复制到原FAT分区根目录，保留旧VIDEO0.AV方便回退，不能放exFAT分区。
重新确认盘符/磁盘号。若仍为F:且分区起点仍为245760：

```powershell
# 对卷只读定位，输出是卷内相对LBA，需要加245760！
python tools/locate_video.py '\\.\F:' --partition-lba 0 --files VIDEOHQ.AV
```

或者对完整卡镜像/物理磁盘定位，指定真实分区起点，输出已经是绝对LBA。
不要把两种结果混用。

把新文件的实际绝对地址填入 `rtl/hdmi_video_top.v` 的 VIDEO0_LBA。
当前地址259360匹配本次复制的VIDEOHQ.AV，不是原VIDEO0.AV。
`generate_video_bit.tcl` 会拒绝占位值。请使用本次新生成的 `HDMI_VIDEO.bit`，
不要误选其他目录备份的旧AV15版。

```powershell
'source build_video.tcl' | & 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021\bin\td.exe' -nogui
# 检查本轮时序及全部告警后：
'source generate_video_bit.tcl' | & 'D:\Anlogic\TD_4.6.8_CPLD_Release_96.021\bin\td.exe' -nogui
```

KEY12/13换片，KEY14暂停继续；未填VIDEO1/2地址的选择会从头重载相同视频。
片尾原地连续循环，不再重载。换片时仍需预缓冲，有黑画面但HDMI链路保持。

## 无声排查

新增 `rtl/hdmi_audio_diagnostic_top.v`，使用同样HDMI协议持续发送低音量1kHz。
该顶层可独立综合为诊断版本，正常 `HDMI_VIDEO.al` 不启用测试音。
若测试音也无声，应确认显示器型号、自带扬声器/耳机输出、HDMI输入音频设置、
HDMI直连（不是DVI转接），并继续查接收器兼容性；不能据此断言接收器坏了。
若测试音有声而原声无声，再查读卡/PCM/SDRAM通路。

## 格式

### 长视频

本次 `input.mp4` 的真实时长是 **5.0667 秒**，因此 `VIDEOHQ.AV` 播放约5.1秒后循环，
这是素材长度，不是播放器提前结束。要播放长视频，换成长的 MP4；不要给 FFmpeg 加 `-t 5`。
可以直接运行：

```powershell
.\tools\convert_video_hq.ps1 -InputVideo 'D:\Users\yushe\Videos\long.mp4' -OutputBase 'D:\Users\yushe\Videos\LONG'
```

脚本会读取完整视频时长，转换为 320×240/10fps 和 48kHz 双声道 PCM，并显示最终 AV 大小。
FPGA 配置支持最多约40分钟（24818帧）的单个 AV 文件；实际 F: 分区只有约500MB，
当前卡扣除原文件后大约只能容纳4–5分钟。超过这个长度需要更大的 FAT32 分区/SD 卡，
并重新定位 LBA、填入 `VIDEO0_LBA`、重新生成 bit。当前读卡器不支持 exFAT（G:），
也不支持把一个长视频拆成多个 AV 后自动顺序播放；超过分区容量需要后续增加分段播放逻辑。

如果长视频转换后仍显示约5秒，先检查脚本打印的 `Input duration` 和 AV 的 `frames`，
再检查复制到 SD 卡的是新文件，不要复用旧 `VIDEOHQ.AV`。

512字节头，little-endian：magic AV10，版本2，320×240，10fps，2声道，
48000Hz，帧数，每帧视频153600字节，声音19200字节，其余头字节0。
每包338扇区：视频153600 + PCM19200 + 零填充256。
硬件删除填充，SDRAM每槽86400个16bit字，四槽345600字。
每帧4800组双声道样本，对应6个HDMI显示帧。
打包脚本 `tools/pack_video_hq.py`，定位脚本现在同时识别AV10和旧AV15。

## 验证

本轮TD4.6综合、布局布线通过：五时钟0 setup / 0 hold，最小裕量1.749 / 0.095ns。
上述裕量是上一轮占位地址的逻辑验证；本次实际地址编译以最新时序报告为准。
外部PCM反向解码测试通过：49600采样，49599已解码，最后一个留在发送队列；
新增Explicit Audio InfoFrame及Clear_AVMUTE GCP均验证校验和/BCH。
Python HQ打包、补静音、sector padding、FAT16定位/头拒绝两项测试通过。

### 2026-10-29 20:25 欠载黑屏修复

板级录像显示“短暂出画面后永久黑屏”。旧代码把一次 `video_empty`、音频 FIFO
空或音频溢出直接写入 `fail`，随后 `show=0`、`play=0`，所以 HDMI 被永久黑掉。
现改为：视频 FIFO 暂时空时保持最后 RGB；音频暂时空时继续发静音；
只有 `card_error`、格式错误或写入溢出才置 fatal。预取槽错过一帧时保持当前槽，
不锁死输出。重新综合布局布线：0 setup / 0 hold，最小裕量1.819 / 0.155ns；
bitgen成功于20:25:02，`HDMI_VIDEO.bit` 629600字节。请用该新版验证；
尚未有真实板级回归录像。

端到端使用真实FIFO和事务级SDRAM/读卡替身，检查两轮循环：
约29491200个2×放大像素和76800组双声道样本，暂停恢复、按键换片通过。
测试覆盖末包到首包样本归零且播放enable不中断，不仅是首次片尾。
真实SPI25MHz、异步时钟、电气时序及显示器声音仍需实板验证。
旧AV15解析回归保留，通过HQ=0/LOOP=0参数运行。
