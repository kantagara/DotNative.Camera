using DotNative.Plugins;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace DotNative.Camera;

public interface ICamera
{
    Task<byte[]?> CapturePhotoAsync(CancellationToken cancellationToken = default);
}

public static class CameraServices
{
    public static IServiceCollection AddCamera(this IServiceCollection services)
    {
        services.TryAddSingleton<ICamera, NativeCamera>();
        return services;
    }
}

internal sealed class NativeCamera(IPlatformChannels channels) : ICamera
{
    public async Task<byte[]?> CapturePhotoAsync(CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var result = await channels
            .Get("dotnative.camera")
            .InvokeAsync("capturePhoto", cancellationToken: cancellationToken)
            .ConfigureAwait(false);
        return result switch
        {
            null => null,
            byte[] bytes => bytes,
            _ => throw new InvalidDataException("Invalid camera image response."),
        };
    }
}
