# 图层叠加与动态字幕

已接入原 `HDMI_SLIDESHOW.al` 工程，无需增加管脚、外设或修改 SD 卡图片。
保持原 SD 卡地址、三帧缓存、KEY12/13 切图、KEY14 轮播和 HDMI 测试音。

## 显示效果

- 顶部半透明深蓝状态条：`ANLOGIC IMG 1/3 MANUAL UP 00:00:00`。
  图片编号跟随实际提交的缓存选择，模式显示 AUTO 或 MANUAL。
- 计时为图片播放启用后的累计运行时长，60 个视频帧计一秒，格式 `HH:MM:SS`。
  范围 00:00:00 至 99:59:59，随后回零。复位清零，切图不清零。
  **这是运行时长，不是联网时间或 RTC 日期时间。**
- 底部黄色标语从右向左循环滚动，默认每帧 1 像素，即 60 像素/秒。
  标语带 2 像素黑色阴影，在显示窗口边缘裁切。文字放大 2 倍，每字符 16×16。
- 三个标语片段循环显示：WELCOME TO ANLOGIC FPGA、HDMI MULTIMEDIA SHOW、LAYER OSD DEMO。
- 深蓝面板与图片作 50% 混合，青色装饰与面板作 50% 混合，黄色字幕作约 75% 混合，
  白色状态字为不透明前景。图片主体未覆盖区域逐像素直通。
- 位置、图片/模式和时间信息只在垂直消隐期更新，避免帧内撕裂。
  加载或错误状态隐藏 OSD，不掩盖原工程的黑屏与错误指示。

当前字库含大写英文字母、数字、空格和 `: / -`，不含中文或小写字形。
未支持字符显示为空格。

## 改动位置

`rtl/slideshow_osd.v`：字库、计时、状态文字、滚动与逐通道混合。

`rtl/hdmi_slideshow_top.v`：在 RGB565 展开为 RGB888 后、HDMI 编码前接入 OSD。
`HDMI_SLIDESHOW.al`：加入新模块源文件。

OSD 含两级流水线，RGB、x/y、HS/VS、DE 和音频 play 同步延迟两个像素时钟。
HDMI 发送器仍收到正确的 800×525 时序；音频采样分频和 N/CTS 不变。
帧缓存的读使能、切图逻辑和串行器不做修改。
字库为组合常量，不使用磁盘字库、SDRAM 帧写回或额外 CPU。

## 修改标语和速度

在 `rtl/slideshow_osd.v` 修改 `MESSAGE`。
它是 **恰好 64 个 ASCII 字符**、512 位的循环消息，空格也占字符。
少于 64 字符时在末尾补空格；多于 64 字符会截掉开头，不能直接超长填写。
改好后重新综合，不需要重新准备 SD 卡。

`SCROLL_FRAME_DIV` 为正整数，1=60 像素/秒，2=30 像素/秒，3=20 像素/秒。
`FRAMES_PER_SECOND` 默认 60，与现有 25.2 MHz、800×525 视频模式一致。
改变视频刷新率时必须同步调整。

## 验证与重新编译

OSD 自检：

```powershell
./sim/run_osd_test.ps1 -Iverilog 'C:/tools/iverilog/bin/iverilog.exe' -Vvp 'C:/tools/iverilog/bin/vvp.exe' -Preview
```

默认构建文件放在系统临时目录 `eg4s20-osd-test`，可用 `-OutputDirectory` 指定。
`-Preview` 输出从 RTL 仿真逐像素捕获的 PPM 图片，不是真实上板截图。
测试覆盖字体与阴影、逐通道透明混合、完整帧时序、滚动回绕、BCD 进位、状态帧边界更新、
禁用时旁路，以及 OSD 到 HDMI 音视频发送器的连接。

TD 打开原 `HDMI_SLIDESHOW.al`，执行原流程：

```tcl
source build_slideshow.tcl
# 检查本次新生成的时序报告，再执行：
source generate_slideshow_bit.tcl
```

必须重新综合/布局布线，不能复用改动前的 `HDMI_SLIDESHOW_pr.db` 直接生成 bit。
本次环境未找到可用安路 TD 编译器，未完成厂商综合、资源与 STA 检查，
**未生成新 bit，也未烧写或声称通过实板验证**。
通用 Verilog 工具的顶层展开检查忽略了安路厂商原语，不能替代 TD 检查。

2026-10-27 验证结果：OSD 像素自检通过；OSD→HDMI 集成仿真通过 1,680,004 周期，
核对全部三路视频/控制/音频符号、启用/禁用及 FIFO 无溢出。
原 HDMI 音频回归通过 62 帧、49,600 个生成样本（49,599 个已解码，末尾一个待发送），
检查 BCH、IEC 奇偶校验、InfoFrame、N/CTS、保护带和 RGB 编码。
OSD Verilator 检查无宽度错误或锁存器警告，余下未使用位警告对应 2 倍字形缩放和取整。

上板验收：三张图切换时顶部编号正确；AUTO/MANUAL 对应按键状态；计时每秒更新；
字幕连续左移且循环无突跳；半透明区域仍可看到原图；切图无新增白线、花屏或撕裂；
HDMI 测试音持续；复位重载后字幕与计时重新开始。
