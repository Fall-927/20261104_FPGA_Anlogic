# 20261104_FPGA_Anlogic
2026嵌赛安路赛题一

## Ex3 图片缩放：六张照片 + 基础视频播放

分支Ex3_image-scaling，基于v2.0，仅加入Ex3，不包含其他扩展。
当前工程：[Ex3_IMAGE_SCALING/HDMI_MEDIA.al](Ex3_IMAGE_SCALING/HDMI_MEDIA.al)。
原三张IMAGE0/1/2和三张不同分辨率图片共同轮播，保留视频原声、暂停及模式切换。

- [当前六张版操作、素材地址和构建](Ex3_IMAGE_SCALING/README.md)
- [Ex3缩放原理及首版记录](Ex3_IMAGE_SCALING/EX3_README.md)
- [第三方声明](Ex3_IMAGE_SCALING/THIRD_PARTY_NOTICES.md)

缩放由FPGA逐行读取完成，最近邻等比例居中、补黑边，HDMI输出640×480。
用户已反馈三张缩放版正常播放；六张版通过按键、缓存及视频回归，仍待实板确认。
源码不包含用户媒体、bit或编译报告，需按实际SD卡LBA重新构建。
main、Ex5及v2.0保持不变。
