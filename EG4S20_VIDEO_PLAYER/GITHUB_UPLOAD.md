# 上传 GitHub

## 当前融合版（优先阅读）

本目录已有Git仓库及origin，无需再次git init或重建远端。
主工程为HDMI_MEDIA.al，主说明为README.md和MEDIA_README.md。
本次仅整理工作区，不暂存、提交、推送或创建Release。

应上传根目录工程/构建脚本、rtl/、al_ip/、constraints/、tools/源码，
sim/中的Verilog、C++、Python、PowerShell测试，以及说明文档、
.gitignore、THIRD_PARTY_NOTICES.md和LICENSES/。
不上传TD数据库、日志、报告、bit、仿真二进制、SD镜像、视频、照片、音频。
本地bit和报告保留不删除；忽略规则不会自动取消已跟踪文件。

检查命令（Python 3、RTL测试需Verilator及MSVC x64；路径按本机配置）：

```powershell
python -m unittest discover -s sim -p 'test_*.py'
.\sim\run_media_controls.ps1
.\sim\run_media_memory.ps1
.\sim\run_sd_safe_stop.ps1
.\sim\run_video_tests.ps1
git status --short
git diff --check
git diff --stat
git remote -v
```

确认工作区没有不相关修改后，再手动暂存、检查、提交：

```powershell
git add .
git diff --cached --stat
git diff --cached --check
git commit -m "Integrate photo and video playback with safe SD mode switching"
```

随后确认远端、分支和同步状态再手动push，不使用force。
TD自动更新的工程时间戳也应检查，不能误认成功能修改。
视频返回照片修订仍待实板确认，不能发布为全部上板验证成功。
公开前核实第三方IP和参考代码再分发权限；未确认前建议私有仓库。
不添加覆盖全项目的统一MIT/Apache/GPL许可证。

## 历史首次建仓说明

以下命令仅适用于新建空仓库，不用于当前已有origin的目录。

音频版本还应上传 `rtl/hdmi_audio_tx.v`、`HDMI_AUDIO_README.md`、
`LICENSES/hdl-util-hdmi-MIT.txt` 和 `sim` 下新增音频测试，
并保留更新后的工程文件与第三方声明。

## 网页方式

1. 确认第三方文件的再分发权限；未确认时先创建 Private 仓库。
2. 推荐仓库名：`eg4s20-sd-bmp-slideshow`。
3. 解压上传包，将 README、rtl、al_ip、constraints、sim、tools 等内容
   放在仓库根目录，不要只上传 zip，也不要再嵌套一层同名文件夹。
4. 网页拖拽可能遗漏 `.gitignore`、`.gitattributes`，请单独检查。

## Git 命令方式

在解压后的目录打开终端，替换仓库地址：

```powershell
git init
git add .
git status
git commit -m "Add EG4S20 SD BMP slideshow with FIFO alignment fix"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/eg4s20-sd-bmp-slideshow.git
git push -u origin main
```

上述命令适用于新建空仓库。已有仓库时先拉取并合并，不要强制推送覆盖远端。
本包不含 bit；需要发布 bit 时可在板上验证后作为 GitHub Release 附件单独上传，
写清硬件型号、LBA 参数和验证状态。不要上传 TD 安装目录、许可证或个人图片。
