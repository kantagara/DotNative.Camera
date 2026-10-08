# DotNative.Camera

Capture a photo through the platform camera UI:

```csharp
builder.Services.AddCamera();
byte[]? jpeg = await services.GetRequiredService<ICamera>().CapturePhotoAsync();
```

Android uses the installed camera app and returns its JPEG thumbnail; iOS uses
the system camera picker and returns a resized JPEG (up to 512 px on the long
edge). Cancellation returns `null`. This first release does not expose a live
preview, video capture, flash/focus controls or camera switching. A live inline
preview needs native-view support in DotNative's renderer. iOS apps must include
`NSCameraUsageDescription`. The Android implementation relies on an installed
camera app. Windows/macOS/Linux are not implemented.
