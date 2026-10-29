# 上传 GitHub

音频版本还应上传 `rtl/hdmi_audio_tx.v`、`HDMI_AUDIO_README.md`、
`LICENSES/hdl-util-hdmi-MIT.txt` 和 `sim` 下新增音频测试，
并保留更新后的工程文件与第三方声明。

## 网页方式

1. 确认第三方文件的再分发权限；未确认时先创建 Private 仓库。
2. 推荐仓库名：`20261104_FPGA_Anlogic-Ex2_image-transition`。
3. 将外层 `20261104_FPGA_Anlogic-Ex2_image-transition` 目录中的
   `README.md`、`.gitignore`、`.gitattributes` 和整个 `EG4S20_BMP_SLIDESHOW`
   目录上传到仓库根目录。不要上传旁边的清理备份目录或旧工程 zip。
4. 网页拖拽可能遗漏 `.gitignore`、`.gitattributes`，请单独检查。

## Git 命令方式

在外层 `20261104_FPGA_Anlogic-Ex2_image-transition` 目录打开终端，替换仓库地址：

```powershell
git init
git add .
git status
git commit -m "Add EG4S20 image transition project"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/20261104_FPGA_Anlogic-Ex2_image-transition.git
git push -u origin main
```

上述命令适用于新建空仓库。已有仓库时先拉取并合并，不要强制推送覆盖远端。
本包不含 bit；需要发布 bit 时可在板上验证后作为 GitHub Release 附件单独上传，
写清硬件型号、LBA 参数和验证状态。不要上传 TD 安装目录、许可证或个人图片。
