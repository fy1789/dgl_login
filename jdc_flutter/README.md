# jdc_flutter


### 开始


* [flutter部署环境](https://flutterchina.club/get-started/install/)
* [原文档查看](https://www.cnblogs.com/azhe35/p/12309434.html)

### 修改请求后台地址
*  lib/main 文件
```dart
configDio(
  //adb kill-server && adb server && adb shell
  baseUrl: inProduction ? '线上部署地址' : 'http://192.168.1.109:9997',
  interceptors: interceptors,
);
```

### 修改应用名称
* android
  在项目下找到android目录，依次app》src》main》AndroidManifest.xml，打开AndroidManifest.xml文件，找到application节点，修改label参数即可
```xml
 <application
        android:name="io.flutter.app.FlutterApplication"
        android:icon="@mipmap/ic_logo"  <- 应用logo
        android:label="玩安卓"> <- 应用名字
        ...
    </application>
```
* ios
  在项目下找到ios目录，依次Runner》Info.plist，打开Info.plist文件，参数都是key-string的形式，找到CFBundleName，修改参数即可
```xml
<dict>
    ...
    <key>CFBundleName</key>
    <string>玩安卓</string> <- 应用名字
    ...
</dict>
```

### 修改应用图标
* android
  在项目下找到android目录，依次app》src》main》res，然后会有一组mipmap开头的目录，即不同目录存放不同的图标大小，把我们不同大小的图标分别放在对应的目录中。
打开AndroidManifest.xml文件，找到application节点，修改icon参数即可
```xml
<application
    android:name="io.flutter.app.FlutterApplication"
    android:icon="@mipmap/ic_logo"  <- 应用logo
    android:label="玩安卓">
    ...
</application>

mipmap-hdpi - 72*72
mipmap-mdpi - 48*48
mipmap-xhdpi - 96*96
mipmap-xxhdpi - 144*144
mipmap-xxxhdpi - 192*192
```
* ios
  在项目下找到ios目录，依次Runner》Assets.xcassets》AppIcon.appiconset，然后会有一组后缀为1x、2x、3x的图标，根据尺寸存放即可。
在同级目录的Contents.json文件中修改自己的配置
```json
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    ...
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
ios的图标尺寸较多，可以根据Contents.json文件中的配置挨个去修改，或者只修改通用的即可。

```


