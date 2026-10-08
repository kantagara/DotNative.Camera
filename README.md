# DotNative.Camera

Capture a photo through the platform camera UI:

```csharp
builder.Services.AddCamera();
byte[]? jpeg = await services.Camera.CapturePhotoAsync();
```

Android uses the installed camera app and returns its JPEG thumbnail; iOS uses
the system camera picker and returns a resized JPEG (up to 512 px on the long
edge). Cancellation returns `null`. This first release does not expose a live
preview, video capture, flash/focus controls or camera switching. A live inline
preview needs native-view support in DotNative's renderer. iOS apps must include
`NSCameraUsageDescription`. The Android implementation relies on an installed
camera app. Windows/macOS/Linux are not implemented.

## Service access

Import `DotNative.Camera` to access the plugin through `IServiceProvider`:

```csharp
using DotNative.Camera;

var plugin = services.Camera;
```

The getter calls `GetRequiredService<ICamera>()` on every access, preserving
DI lifetimes and the usual missing-registration error. Register the plugin with
`AddCamera(...)` before building the provider.

A `net10.0` application uses the property syntax with C# 14 or later. A
`net9.0` application uses only the method equivalent:

```csharp
var plugin = services.Camera();
```

The package contains separate `net9.0` and `net10.0` assemblies. NuGet selects
the assembly matching the application target framework. `NET10_0_OR_GREATER`
selects the property; the `#else` branch selects the method.

Build and pack both targets with .NET 10 SDK. A source build using .NET 9 SDK
builds only `net9.0`; it does not produce the .NET 10 assembly.
