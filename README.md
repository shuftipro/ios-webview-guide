# iOS Webview Guide
Guide to implement webview with permissions to camera and select file option using basic permissions. 

## Permissions

Application Info.plist must contain an Privacy - Camera Usage Description , Privacy - Microphone Usage Description key and  Privacy - Microphone Usage Description with a explanation to end-user about how the app uses this data.

Add these lines in app Indo.plist.

```
<key>NSMicrophoneUsageDescription</key>
<string>We need your microphone access to record your voice.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need your gallary asccess to select photos. </string>
<key>NSCameraUsageDescription</key>
<string>We need your camera acccess to capture your photo.</string>
```

</br>

Attached [file](WebViewController.swift) contains the sample code to implement webview. 


