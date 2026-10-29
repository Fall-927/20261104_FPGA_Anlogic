# 20261104_FPGA_Anlogic-Ex_layer-subtitle-overlay

2026 嵌赛安路赛题一：EG4S20 SD 卡 BMP 轮播、HDMI 音频与动态图层/滚动字幕叠加。

## 工程入口

使用 Anlogic TD 4.6 打开
`EG4S20_BMP_SLIDESHOW/HDMI_SLIDESHOW.al`。
运行构建与测试脚本时，请先进入 `EG4S20_BMP_SLIDESHOW` 目录。

- [工程说明与构建步骤](EG4S20_BMP_SLIDESHOW/README.md)
- [动态图层与滚动字幕说明](EG4S20_BMP_SLIDESHOW/OSD_README.md)
- [HDMI 音频说明](EG4S20_BMP_SLIDESHOW/HDMI_AUDIO_README.md)
- [仓库上传说明](EG4S20_BMP_SLIDESHOW/GITHUB_UPLOAD.md)
- [第三方来源与发布限制](EG4S20_BMP_SLIDESHOW/THIRD_PARTY_NOTICES.md)

## 仓库内容

保留 RTL、厂商 IP 包装模块、工程文件、约束、构建脚本、仿真测试和文档。
日志、编译数据库、时序/面积报告、bit 文件和仿真生成物不纳入源码仓库，
可按工程说明重新生成；`.gitignore` 已包含对应规则。

本次整理未修改 RTL 功能，也不代表已完成重新综合、时序检查或上板验证。
第三方再分发权限未确认前，请使用私有仓库；不要给整个工程擅自添加统一开源许可。
