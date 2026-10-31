# 2.0 — 照片 / 视频融合播放器

## 新功能

- 增加HDMI_MEDIA工程，共用SD、SDRAM和HDMI通路。
- 三张BMP手动切换或约5秒自动轮播；AV10 v2视频原声播放和暂停/继续。
- 矩阵第4行KEY3切换照片/视频，KEY2控制视频暂停或照片自动/手动，KEY0/1上一张/下一张。
- 返回视频从片头装载，返回照片重新读取三图；切模式保持HDMI时序。
- 视频退出增加SD扇区收尾握手，背压下继续消费当前扇区、CRC及尾部时钟后切换。

## 构建与卡配置

使用Anlogic TD4.6、EG4S20BG256，在EG4S20_VIDEO_PLAYER目录执行
source build_media.tcl，检查时序及告警后执行source generate_media_bit.tcl。
卡上文件必须连续，支持FAT16/FAT32和SDHC/SDXC，不直接解码MP4，不支持exFAT。
hdmi_media_top.v中地址仅对应开发卡，换卡或移动素材必须重新定位并构建。

## 验证与限制

Python 7项测试、按键/照片缓存/视频回归及SD安全停止测试通过。
最新五时钟0 setup/0 hold错误，最小裕量1.382/0.104ns。
用户反馈视频不能返回照片后已修订，尚未收到修订版实板复测结果。
仿真不覆盖完整SD卡交互、电气时序及所有HDMI接收器兼容性。
本次仅发布源码，不附带卡地址绑定的bit和用户媒体；GitHub自动提供源码压缩包。
保留第三方版权与许可声明，详见各工程THIRD_PARTY_NOTICES.md及LICENSES/。
