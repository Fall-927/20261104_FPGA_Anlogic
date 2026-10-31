# EG4S20 SD 照片 / 视频 HDMI 播放器

当前主工程为 `HDMI_MEDIA.al`，顶层 `rtl/hdmi_media_top.v`。
集成三张照片的手动/自动轮播、视频原声播放与暂停、照片/视频模式切换。
详细操作、卡地址及验证边界见 [MEDIA_README.md](MEDIA_README.md)，
提交与发布检查见 [GITHUB_UPLOAD.md](GITHUB_UPLOAD.md)。

## 融合版快速开始

1. 使用Anlogic TD 4.6，目标EG4S20BG256，在仓库根目录打开工程。
2. SDHC/SDXC卡使用FAT16/FAT32，三个BMP及AV文件必须连续存储。
   图片为640×480/24bit BMP；视频为AV10 v2（320×240/10fps + 48k双声道PCM），
   不支持直接播放MP4/H.264/AAC。转换工具为 `tools/convert_video_hq.ps1`。
3. 只读定位四个文件的绝对LBA，更新 `rtl/hdmi_media_top.v`。
   当前地址和 `MEDIA_LBA_VERIFIED=1` 只对应开发卡，换卡或文件位置改变必须重新定位。
4. TD Tcl Console执行 `source build_media.tcl`；检查本轮时序及告警后，
   执行 `source generate_media_bit.tcl`，生成 `HDMI_MEDIA.bit`。
5. 开发板断电插卡，再下载；脚本不自动烧板。

矩阵第4行col0/1/2/3（参考映射KEY0/1/2/3）分别为上一张、下一张、
照片自动/手动或视频暂停/继续、照片/视频切换。旧文档KEY12～15标注与
实际扫描行有冲突，以 [行列和管脚表](MEDIA_README.md) 为准。
默认照片手动模式；自动约5秒一张；返回视频从片头播放；返回照片需重新装载三图。

验证状态：按键、照片缓存、视频回归及SD安全停止仿真通过；最新布局布线
五时钟0 setup/0 hold错误。视频不能返回照片的反馈已增加扇区收尾握手修订，
**修订版仍待实板确认**。仿真/STA通过不等于板级验证通过。

## 工程入口

| 工程 | 顶层 | 用途 |
| --- | --- | --- |
| HDMI_MEDIA.al | hdmi_media_top | 当前融合版 |
| HDMI_VIDEO.al | hdmi_video_top | 独立视频兼容工程 |
| HDMI_SLIDESHOW.al | hdmi_slideshow_top | 原照片和测试音参考 |

`rtl/`为逻辑，`al_ip/`为安路IP包装，`constraints/`为约束，
`tools/`为转换和只读定位，`sim/`为测试和仿真替身。
构建产物和用户素材不上传；保留 [第三方声明](THIRD_PARTY_NOTICES.md) 与 `LICENSES/`。
第三方IP/参考设计的公开再分发权限需上传者确认，不添加覆盖全项目的统一许可证。

## 历史照片工程说明

以下仅描述旧 `HDMI_SLIDESHOW.al`，不能套用到融合版按键、音频或构建流程。

新增 HDMI 48kHz 双声道、1kHz 正弦测试音输出；与视频共用时钟，图片和轮播功能保留。
编译、下载及听音验证见 [HDMI_AUDIO_README.md](HDMI_AUDIO_README.md)。
新版音频功能已完成符号级仿真，实际接收端播放效果仍需上板确认。

基于安路 EG4S20BG256 的纯 FPGA 图片显示工程。通过 SPI 读取 TF/SD 卡上的
三张 BMP，转换为 RGB565 后预载到 SDRAM，再以 640×480 @ 60Hz 输出至显示器。
无需 CPU；支持按键上一张、下一张和约 5 秒自动轮播。

## 功能与限制

- 输入：640×480、24-bit、BI_RGB 非压缩、正高度、54 字节头 BMP。
- 显示：25.2MHz 像素时钟，126MHz DDR 串行时钟，HDMI TMDS，含音频数据岛。
- 内存：三帧 RGB565，使用 SDRAM 每个 32 位字地址的低 16 位。
- 切图：在垂直消隐期间切换缓存基址，不在可见画面中途切换。
- 默认手动模式；矩阵 KEY12 上一张、KEY13 下一张、KEY14 自动/手动。
- 开机读完三张图后才显示，加载期间黑屏，加载完后无需再次读卡切图。
- 固定物理扇区读取，不实现 FPGA 端 FAT 文件名查找；只支持 SDHC/SDXC 块寻址卡。
- RGB565 有色深损失；新版竖线修复已通过仿真，仍待上板确认显示效果。

## 快速开始

1. 使用 TD 4.6 打开根目录 `HDMI_SLIDESHOW.al`，顶层为 `hdmi_slideshow_top`。
2. 准备三张符合规格的 BMP，文件占用扇区必须连续。
3. 用 `tools/find_bmp_lba.py` 定位各文件的绝对 LBA，更新
   `rtl/hdmi_slideshow_top.v` 中 `IMAGE0_LBA`、`IMAGE1_LBA`、`IMAGE2_LBA`。
4. 综合、布局布线、检查时序，再生成 bit。断电插卡，连接 HDMI，JTAG 下载后复位。
5. 等待加载完成；按键按下超过 100ms，长按不会连续切换。

默认地址仅对应开发时的卡，不能直接套用到其他卡：

| 文件 | 绝对 LBA |
| --- | ---: |
| IMAGE0.BMP | 248032 |
| IMAGE1.BMP | 246112 |
| IMAGE2.BMP | 249888 |

重新复制、覆盖或移动文件都可能改变 LBA。工具对物理磁盘只读，但运行前仍须
核对磁盘编号；必要时使用管理员终端。不需要格式化或写入裸磁盘。
当前定位工具仅有 FAT16 回归覆盖，FAT32 功能不应视为已验证。

在 TD Tcl Console 中，工作目录设为仓库根目录后运行：

```tcl
source build_slideshow.tcl
# 检查最新 HDMI_SLIDESHOW_timing.rpt 后执行：
source generate_slideshow_bit.tcl
```

生成 `HDMI_SLIDESHOW.bit`。脚本不自动烧写硬件，bit 和构建产物不纳入源码仓库。
PLL 和 SDRAM 包装模块依赖 TD 自带 EG4 原语，不适合直接移植到其他 FPGA。

## 源码结构

```text
rtl/hdmi_slideshow_top.v       顶层、三图加载和视频连接
rtl/slideshow_controls.v       矩阵扫描、消抖及轮播控制
rtl/sd_bmp/                    SPI 读卡与 BMP 解析
rtl/sdram/                     三帧缓存与参考 SDRAM 控制器
rtl/tmds_*.v                   TMDS 编码和 DDR 串行输出
al_ip/                         厂商 PLL、FIFO、SDRAM 包装模块
constraints/                   管脚与时钟约束
sim/                           回归测试及测试专用模型
tools/                         只读 BMP 扇区定位工具
```

## 测试

需要 Python 3；RTL 回归还需要 Verilator 及 MSVC x64。
PowerShell 测试脚本的 `VerilatorRoot` 指向含 `bin/verilator_bin.exe` 的目录，
`VsDevCmd` 可覆盖为本机 Visual Studio 的 `VsDevCmd.bat` 路径。

```powershell
python sim/test_locator.py
./sim/run_bmp_test.ps1 -VerilatorRoot 'C:/tools/verilator' -VsDevCmd 'C:/path/to/VsDevCmd.bat'
./sim/run_controls_test.ps1 -VerilatorRoot 'C:/tools/verilator' -VsDevCmd 'C:/path/to/VsDevCmd.bat'
./sim/run_framebuffer_test.ps1 -VerilatorRoot 'C:/tools/verilator' -VsDevCmd 'C:/path/to/VsDevCmd.bat'
./sim/run_sdram_write_test.ps1 -VerilatorRoot 'C:/tools/verilator' -VsDevCmd 'C:/path/to/VsDevCmd.bat'
./sim/run_audio_test.ps1 -VerilatorRoot 'C:/tools/verilator' -VsDevCmd 'C:/path/to/VsDevCmd.bat'
```

已通过按键、三帧缓存及真实控制器写入数据回归。
真实控制器测试覆盖连续 8 个 128 像素 burst，逐像素检查物理 WRITE 数据；
旧 `NOREG` 写 FIFO 首像素测试失败，修正为 `OUTREG` 后通过。
读 FIFO 仍为 `NOREG`，不要一并修改。
本次构建 TT 1.10V 85°C 的时序报告五个时钟均为 0 setup / 0 hold 错误。
仿真与 STA 不等同于板上验证或所有工况保证；CDC 例外和外部接口仍需审查。

更多管脚、使用和验证说明见 [SLIDESHOW_README.md](SLIDESHOW_README.md)。
上传步骤见 [GITHUB_UPLOAD.md](GITHUB_UPLOAD.md)。

## 第三方版权

本包包含厂商生成 IP 和教学板参考控制器，保留其原始声明，
未对整个工程授予 MIT/Apache 等统一开源许可。
公开上传前请先阅读 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) 并确认再分发权限。
权限未确认时请先使用私有仓库保存，不要宣称全部代码均为原创。
