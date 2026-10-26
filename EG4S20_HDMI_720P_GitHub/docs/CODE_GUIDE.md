# 代码怎么写、每条语句做什么

按硬件数据流理解：时钟 -> 像素坐标 -> RGB -> TMDS 码字 -> 串行差分输出。
同类重复语句合并讲解，例如红绿蓝三个实例、四路 ODDR 的规则完全一致。
这是文件中的实际代码说明；不是把 Verilog 当作顺序执行的 C 程序。

## 0. 先认识通用语法

| 写法 | 意思 |
|---|---|
| `module name (...)` / `endmodule` | 定义一个硬件模块及边界 |
| `input wire` / `output wire` | 输入/输出连线 |
| `reg` | 可在过程块赋值的变量；是否成为寄存器取决于 always 写法 |
| `[7:0]` | 8 位，总位数为 7-0+1；不是 7 位 |
| `wire [9:0]` | 一根 10 位并行总线 |
| `assign a = b` | 持续连接组合逻辑，b 变化会反映到 a |
| `always @*` | 组合逻辑块，读取的输入变化就重新计算 |
| `always @(posedge clk ...)` | 时钟上升沿触发的时序逻辑 |
| `or posedge reset` | reset 拉高即可触发异步复位，不必等待时钟 |
| `=` | 阻塞赋值，这个过程内后续语句看见更新后的值；用于组合计算 |
| `<=` | 非阻塞赋值，各语句先取旧值，再统一更新；用于寄存器 |
| `~` / `!` | 逐位取反 / 逻辑非；一位信号时效果相似，多位时不同 |
| `&` / `\|` / `^` | 逐位与 / 或 / 异或 |
| `&&` / `\|\|` | 逻辑且 / 或，结果是一位条件 |
| `{a,b}` | 拼接，a 放高位，b 放低位 |
| `a ? b : c` | 条件选择：a 真选 b，否则 c |
| `1'b0` / `3'b111` | 1 位二进制 0 / 3 位二进制 111 |
| `24'hff0000` | 24 位十六进制，RGB 为红 FF、绿 00、蓝 00 |
| `.port(signal)` | 模块的 port 接当前作用域的 signal |
| `#(.PARAM(value))` | 配置被实例化模块的参数 |
| `` `timescale 1ns/1ps `` | 仿真时间单位和精度，不设置真实时钟频率 |

顶层中的 `u_pll`、`u_video` 等是实例名字，不是函数调用。所有模块一直并行工作。

## 1. hdmi_color_top.v：把硬件模块接起来

### 端口和时钟

- `clk_50m`：外部 50MHz 晶振输入；约束映射到 R7。
- `rst_n`：外部低有效复位，名字后缀 n 只是命名约定；实际极性由逻辑决定。
- `led`：PLL 锁定指示。
- `hdmi_data_p[2:0]`：三条视频串行数据通道，0 蓝、1 绿、2 红。
- `hdmi_clk_p`：发送给显示器的差分时钟 P 端。
- `wire pixel_clk, serial_clk, locked`：声明内部连线，没有生成时钟。
- `hdmi_pll_720p u_pll (...)`：连接两级 PLL 包装。
- `.refclk(clk_50m)`：50MHz 接参考输入。
- `.reset(~rst_n)`：把低有效外部复位翻成 PLL 的高有效复位。
- `.pixel_clk(...) / .serial_clk(...) / .locked(...)`：引出两个频率和锁定状态。

### 复位

`wire reset_async = ~rst_n | ~locked`：按键按下或 PLL 未锁定，任意条件成立就复位。

`pixel_reset_pipe`、`serial_reset_pipe` 各是三位寄存器链，分别属于两个时钟域。

```verilog
if (reset_async) pixel_reset_pipe <= 3'b111;
else pixel_reset_pipe <= {pixel_reset_pipe[1:0], 1'b0};
```

复位立即写 111；释放后每个像素时钟移入一个 0：111 -> 110 -> 100 -> 000。
最高位到第三拍才清零，因此复位“异步拉起、同步释放”。串行域代码同理。
`wire pixel_reset = pixel_reset_pipe[2]` 取最高位作为该域复位。
不要直接拿未同步的按键去释放高速域复位。

### 像素和编码连接

- `hs, vs, de`：行同步、场同步、像素有效标志。
- `red/green/blue[7:0]`：三个 8 位颜色，总共 RGB888。
- `video_720p_bars u_video`：每个像素周期根据坐标生成颜色与同步。
- `symbol_b/g/r[9:0]`：三个通道各一个 10 位 TMDS 码字。
- 蓝色编码器 `.c0(hs), .c1(vs)`：消隐期间在蓝通道传行场同步。
- 红绿编码器 `.c0(1'b0), .c1(1'b0)`：这两个通道的控制位固定 0。
- 三个 `.data(...)`：接不同颜色；三个 `.symbol(...)`：接各自码字。

### 新像素通知和输出

`pixel_toggle <= ~pixel_toggle`：每来一拍像素时钟翻转一次，用变化事件表示新码字已更新。
虽然 toggle 自身波形为半像素频率，但它的每一次边沿都代表一个新像素。

`tmds_serializer_eg4 u_tx`：把三个 10 位码字和 toggle 接到串行域。
`assign hdmi_data_p = serial_data`：数据连到顶层 P 端。
`assign hdmi_clk_p = serial_clock`：发送时钟连到顶层 P 端。
`assign led = locked`：两级锁定时 LED 高电平点亮。LED 亮不能证明画面正确。

N 端没有写 assign；由 ADC 中的 LVDS33 让 TD 自动占用配对球位。

## 2. hdmi_pll_720p.v：产生正确频率

- `refclk/reset`：50MHz 输入、高有效复位。
- `pixel_clk/serial_clk/locked`：74.25MHz、371.25MHz 和总锁定。
- `clk_55m`：两级之间的中间时钟。
- `lock_stage1/lock_stage2`：分别保存两个 PLL 的锁定输出连线。
- `SWLED u_stage1`：这里 SWLED 是 al_ip 中的第一级 PLL，50 -> 55MHz。
- `.clk0_out(clk_55m)`：把第一级输出接到中间时钟。
- `reset_stage2_async = reset | ~lock_stage1`：外部复位或第一级未锁定时，保持第二级复位。
- `reset_stage2_pipe`：在 55MHz 域移入 0，三拍后释放第二级。
- `pll u_stage2`：以稳定的 55MHz 为输入，输出像素和串行时钟。
- 两条 `defparam ... DERIVE_PLL_CLOCKS = "DISABLE"`：仅关闭 TD 的自动时钟约束派生。
  它们不关闭 PLL，也不改变硬件频率；正式 SDC 提供显式时钟关系。
- `locked = lock_stage1 & lock_stage2 & ~reset`：只有两级均锁定且没有复位才输出 1。

`al_ip/SWLED.v` 与 `al_ip/pll.v` 是安路向导生成文件，保留版权和参数信息。
端口声明定义接口；`EG_PHY_PLL #(参数) pll_inst(端口)` 实例化芯片 PLL 硬核。
`FIN` 描述输入频率，`REFCLK_DIV` 是参考分频，`FBCLK_DIV` 是反馈倍率，
`CLKC*_DIV` 是输出分频；本例 VCO_PHASE_0/NOCOMP 配置下：

```text
第一级：50 / 1 * 22 = 1100MHz VCO；1100 / 20 = 55MHz
第二级：55 / 2 * 27 = 742.5MHz VCO
输出0：742.5 / 10 = 74.25MHz
输出1：742.5 / 2  = 371.25MHz
```

`CLKC*_ENABLE` 启用输出；`CPHASE/FPHASE` 配置相位；模拟环路参数由向导计算。
其余动态配置输入绑 0 表示本例不做运行时重配置；未使用输出无需连接。
`open` 是向导写出的未用输出网络名，不是 Verilog 关键字。
修改频率优先重跑 TD IP Generator，并同步修改 SDC，不手改模拟环路参数。
`.ipc` 保存可重新打开向导的配置，不参与 RTL 运算。

## 3. video_720p_bars.v：最适合你先改的文件

`x[10:0]` 是横向计数器，11 位能表示 0~2047；本例用 0~1649。
`y[9:0]` 是纵向计数器，10 位能表示 0~1023；本例用 0~749。

时序块逐句：

```verilog
if (reset) begin x <= 0; y <= 0; end
```

复位回到第一行第一个像素。

```verilog
else if (x == 1649) begin
    x <= 0;
    if (y == 749) y <= 0;
    else y <= y + 1'b1;
end else x <= x + 1'b1;
```

每拍 x+1；到一行末尾 x 清零、y+1；到一帧末尾两者回到起点。
普通像素拍没有给 y 赋值，时序寄存器自然保持 y 不变，不是组合锁存器。

- `hsync = (x >= 1390 && x < 1430)`：1280 有效像素 +110 前肩后开始同步，持续40拍。
- `vsync = (y >= 725 && y < 730)`：720 有效行 +5 前肩后开始同步，持续5行。
- `de = !reset && (x < 1280 && y < 720)`：仅左上1280x720范围发送有效颜色。
- 总长不是分辨率：一行还有前肩/同步/后肩；一帧还有消隐行。
- 刷新率 = 74250000 /1650 /750 = 60Hz。

颜色组合块先执行 `{red,green,blue}=24'h000000`，保证所有路径有赋值，不产生锁存器。
`if (de)` 内根据 x 所在区间选颜色；每160像素换一条，总计8条。

### 怎么改成纯红

保持默认消隐黑色，把原 `if (de) begin ... end` 整段颜色选择改为：

```verilog
if (de) {red, green, blue} = 24'hff0000;
```

`00ff00` 是纯绿，`0000ff` 是纯蓝，`ffffff` 是白，`000000` 是黑。

### 怎么改成左右双色或上下双色

在 `if (de)` 内：

```verilog
if (x < 640) {red,green,blue} = 24'hff0000;
else         {red,green,blue} = 24'h0000ff;
```

上下双色改为 `if (y < 360)`。彩条改横条则按 y 划分，每条 720/8=90 行。
只改颜色或图案不必改 PLL；改分辨率/刷新率则必须连同总时序、位宽、PLL、SDC、仿真一起改。

## 4. tmds_encoder.v：8 位颜色为什么变成 10 位

TMDS 先减少跳变，再平衡长期 0/1 数量。不是在 RGB 后随便加两位。

- `integer i`：for 循环索引；固定次数循环会综合展开为组合逻辑，不是 CPU 执行8拍。
- `ones_data[3:0] / ones_q[3:0]`：统计8位中1的个数，范围0~8，用4位足够。
- `balance signed[5:0]`：本码字8位部分的“1数量减0数量”，范围-8~8。
- `q_m[8:0]`：8位减少跳变后的数据，另加1位标志。
- `use_xnor`：本字选择 XNOR 还是 XOR 链。
- `next_symbol`：下一拍要输出的10位结果；不是寄存器输出端。
- `disparity / next_disparity`：当前和下一拍的累计直流偏差，必须有符号。
  6位足以覆盖此算法的正常状态，别扩大为32位 integer，以免增加加法链。

组合块逐句：

1. `ones_data=0` 后 for 循环累加 `data[i]`；`{3'b000,data[i]}` 把一位扩成4位。
2. `use_xnor=(ones_data>4)||((ones_data==4)&&!data[0])`：TMDS规定的选择条件。
3. `q_m[0]=data[0]`：第一位原样保留。
4. 从 i=1~7：每位用上一位 q_m 与当前 data 做 XOR；若选择 XNOR 则再取反。
5. `q_m[8]=!use_xnor`：记录使用哪一种变换，供接收端还原。
6. 第二个统计循环数出 q_m 低8位有多少个1。
7. `$signed({1'b0,ones_q,1'b0})-6'sd8`：先乘2再减8，即 N1-N0。
   `$signed` 指定符号解释，不改变比特序列。
8. 先给 `next_symbol` 默认控制码、`next_disparity=0`，让组合块所有路径确定。

`if (!de)`：当前是消隐期，不编码颜色；根据 `{c1,c0}` 四种同步组合选固定控制码。
控制期把累计 disparity 清零。

`else if ((disparity==0)||(balance==0))`：累计或当前平衡时，按 q_m[8] 决定低8位是否取反，
拼接两位标志，并更新累计偏差。

第二个 else-if 判断累计偏差与当前偏差是否同号。同号就反转低8位抵消偏差，
`{1'b1,q_m[8],~q_m[7:0]}` 同时记录反转标志；后续加减计入标志位的偏差。

最后 else 保留低8位，`{1'b0,q_m[8],q_m[7:0]}`，并更新累计偏差。
不要只改拼接码字而不改对应 disparity 公式。

末尾时序块：复位输出控制码并清偏差；正常时 `symbol<=next_symbol`、
`disparity<=next_disparity`，同一像素上升沿一起更新。
这一级让 RGB 到码字有一拍延迟；hs/vs/de 和颜色都在同一次编码选择中使用。

初学阶段改图案无需动本文件；若要优化这里，应先建立全256输入、控制码与连续像素参考模型测试。

## 5. tmds_serializer_eg4.v：10位怎么从一根线出去

一拍像素有10位，每拍串行时钟发2位，所以串行时钟必须为像素的5倍。

- `toggle_pipe[2:0]`：采样像素域的翻转通知。
- `load_symbol = toggle_pipe[2] ^ toggle_pipe[1]`：相邻两拍不同，表示检测到新像素事件。
- `shift_b/g/r`：保存还没发送的码字位。
- `shift_c`：保存待发时钟图样。
- `pair_b/g/r/c[1:0]`：下一组要送 ODDR 的两位。

复位分支将通知链、移位寄存器和两位暂存全部清零。
正常分支先 `toggle_pipe <= {toggle_pipe[1:0],pixel_toggle}`，把新通知向后移动。
由于非阻塞赋值，当前 if 使用的是本拍更新前的 load_symbol，不能按 C 的顺序误解。

新码字到来时：

```verilog
pair_b <= symbol_b[1:0];
shift_b <= {2'b00, symbol_b[9:2]};
```

先取最低两位，剩余8位右移两位并在高位补0。红绿两路相同。
`pair_c<=2'b00; shift_c<={2'b00,8'b11111000}` 表示完整10位时钟字1111100000，
LSB先发即0000011111，五低五高形成像素时钟；与数据使用同样的串行流水线。

没有新码字时：`pair_b<=shift_b[1:0]` 取下一对，`shift_b<={2'b00,shift_b[9:2]}` 再移两位。
五个串行周期依次发送 b0/b1、b2/b3、b4/b5、b6/b7、b8/b9。

四个 `EG_LOGIC_ODDR` 是安路 IO 双沿输出原语：

- `ASYNCRST("ENABLE")`：启用异步复位。
- `.clk(clk_5x)`：串行时钟。
- `.rst(reset)`：串行域复位。
- `.d0(pair_b[0])`：在上升沿输出最低位。
- `.d1(pair_b[1])`：在下降沿输出另一位。
- `.q(serial_data[0])`：蓝色串行线；绿色、红色、时钟线同理。

pair 和 ODDR 都有寄存行为，所以 ODDR 采样上一拍 pair，增加一级延迟，
但四路延迟一致。不要只给时钟线改成 assign pixel_clk，否则可能破坏与数据的对齐。

这里不是通用异步 FIFO：多位码字用“稳定总线+翻转通知”传送，依赖同源固定5:1时钟及正确时序。
不能换成独立晶振，也不能靠全局 false_path 掩盖跨域问题；上板还需观察图像稳定性。

## 6. 约束与工程文件

ADC 每行 `set_pin_assignment {端口} { LOCATION=球位; IOSTANDARD=标准; }`：
把 RTL 逻辑端口对应到物理引脚并设置电气标准。
R7/E3/B14 用 LVCMOS33；HDMI 四个 P 端用板厂示例的 LVDS33。
不得单独驱动或另约束 N 端；报告中会出现自动生成的 `(n)` 管脚。

SDC 第一行 `create_clock`：20ns输入周期、0ns上升10ns下降。
三个 `create_generated_clock` 声明相对输入的倍率1.1、1.485、7.425。
`get_ports` 取顶层端口；`get_nets` 取网线；`-master_clock` 说明同源关系。
SDC只告诉工具该如何检查时间，不会真正产生时钟；真实频率由 PLL 决定。

HDMI_720P.al 是 TD XML 工程清单：器件、源码、ADC、SDC、顶层和 bitgen 设置。
所有路径相对当前目录，整个仓库移动后依然能打开。

build_720p.tcl 顺序：

1. open_project：打开工程并加载器件/源文件。
2. elaborate：建立顶层层次。
3. read_adc / optimize_rtl：读引脚约束、RTL优化。
4. read_sdc / optimize_gate：读时序约束、门级映射。
5. export_db：保存中间数据库，可以不提交Git。
6. place / route：布局与实际布线，不是只检查语法。
7. report_area：列出资源与 IO 映射；start_timer：建立时序分析。
8. report_timing / report_clock_summary：生成时序和时钟报告。

脚本默认不下载、不写 Flash，也不自动忽略时序失败；看完报告再生成 bit。

## 7. tb_video_720p.v：仿真不是综合

- `reg clk=0; always #6.7340067 clk=~clk`：仿真中制造近似74.25MHz时钟；`#` 延时不是可综合时钟发生器。
- `reset=1` 后等4个下降沿再拉低，让计数器可靠复位并避免在上升沿改复位。
- 两层 for 循环遍历750行、每行1650拍。
- `#1`：等待组合逻辑稳定再检查。
- `!==`：严格比较，包括X/Z，不是普通 `!=`。
- `$fatal`：发现 DE/HS/VS/颜色不符合预期就结束并报错。
- `expected`：按x/160计算参考颜色，与RGB输出逐像素对比。
- active_count=921600：1280x720有效像素数。
- hs_count=30000：40拍x750行；vs_count=8250：5行x1650拍。
- `$display` 输出通过提示，`$finish` 结束仿真。

它只覆盖时序/彩条发生器，不验证 PLL、TMDS 编码、串行位序、模拟电气或实际屏幕。

## 8. 推荐修改顺序

1. 先改颜色常量，熟悉RGB888，不改时钟和串行器。
2. 再改分区条件，实现左右/上下/棋盘格。
3. 加帧计数器，每个帧末递增一次，用计数器控制颜色或方块移动。
   计数器始终使用 pixel_clk，别把普通计数器输出当新时钟。
4. 修改后先跑视频仿真，再TD综合、布局布线、查看时序。
5. 最后再改分辨率：统一核对时钟、行场参数、计数器位宽、DE区域和测试平台。

Git 保存一次小改动一个提交，提交说明写清“改了什么、为什么、是否实测”。
