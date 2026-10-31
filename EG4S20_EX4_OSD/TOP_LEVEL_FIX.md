# 工程顶层

请关闭旧 TD 会话后重新打开本目录的 `HDMI_EX4_OSD.al`。
顶层应为 `hdmi_slideshow_top`，不能将调色或OSD子模块设为顶层。
如设计树选择错误，对 `hdmi_slideshow_top` 执行 Set as Top，再从综合开始运行。

当前版本仅含基础功能和拓展4，原 `slideshow_fade` 文件已移除。
显式指定顶层的编译入口为 `build_ex4.tcl`。
