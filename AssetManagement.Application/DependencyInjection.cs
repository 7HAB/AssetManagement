using Microsoft.Extensions.DependencyInjection;

namespace AssetManagement.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        return services;
    }
}