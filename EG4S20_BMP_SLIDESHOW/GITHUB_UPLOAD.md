# 上传 GitHub

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
