using System;
using Microsoft.Extensions.DependencyInjection;

namespace DotNative.Camera;

public static class CameraServiceProviderExtensions
{
#if NET10_0_OR_GREATER
    extension(IServiceProvider services)
    {
        /// <summary>Resolves the registered plugin using the provider's DI lifetime.</summary>
        public ICamera Camera => services.GetRequiredService<ICamera>();
    }
#else
    /// <summary>Resolves the registered plugin using the provider's DI lifetime.</summary>
    public static ICamera Camera(this IServiceProvider services) =>
        services.GetRequiredService<ICamera>();
#endif
}
