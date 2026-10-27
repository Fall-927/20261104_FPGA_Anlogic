# 480p 构建验证

- 工具：TD 4.6.96021，器件 EG4S20BG256，顶层 hdmi_color_top。
- 输入 50 MHz；TD 生成的 PLL 模块为 PLL，文件 al_ip/PLL.v。
- 完成综合、place、route、最终静态时序分析及 bitgen。
- 分析条件：TT、1.10 V、85 C；三个时钟检查均为 0 setup / 0 hold 违例。不代表所有 PVT 条件均已验证。
- 时钟报告确认 pixel_clk=25.200 MHz、serial_clk=126.000 MHz。
- 资源：576 LUT、110 寄存器、1 PLL；DSP、BRAM 均为 0。
- 输出文件 HDMI_480P.bit，629600 字节。
- 存在器件数据库 adc_vref 重复 IO 警告；本工程未使用该信号。无构建 ERROR。
- 未进行 JTAG 下载、Flash 写入、显示器验证或完整链路动态仿真。

源代码压缩包仅含所需源码和配置，不含占位 PLL、PLL_sim.v、日志、数据库、报告或 bit。下载文件单独保留。
