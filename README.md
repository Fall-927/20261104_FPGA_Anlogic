# 20261104_FPGA_Anlogic
2026嵌赛安路赛题一

## Ex5 音频可视化（基于2.0）

当前分支：`Ex5_audio-visualization`。main及v2.0保持不变。

当前工程：[Ex5_AUDIO_VISUALIZATION/HDMI_MEDIA.al](Ex5_AUDIO_VISUALIZATION/HDMI_MEDIA.al)。
支持三张照片手动/自动轮播、视频原声播放及暂停、照片/视频模式切换。

- [融合版操作、按键和SD卡准备](Ex5_AUDIO_VISUALIZATION/MEDIA_README.md)
- [工程入口与构建说明](Ex5_AUDIO_VISUALIZATION/README.md)
- [上传和第三方许可提醒](Ex5_AUDIO_VISUALIZATION/GITHUB_UPLOAD.md)

原照片工程保留在EG4S20_BMP_SLIDESHOW。源码不包含用户媒体和编译产物。
视频返回照片修订已通过仿真及STA，仍待实板复测，不作为板级验证成功保证。

音频扩展说明：[AUDIO_VIS_README.md](Ex5_AUDIO_VISUALIZATION/AUDIO_VIS_README.md)。
视频底部叠加真实双声道PCM波形，暂停冻结并变黄，照片模式旁路；不是FFT频谱。
