using AssetManagement.Application.Options;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AssetManagement.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<BusinessOptions>()
            .BindConfiguration(BusinessOptions.SectionName)
            .ValidateDataAnnotations()
            .Validate(o => TimeZoneInfo.TryFindSystemTimeZoneById(o.TimeZoneId, out _), 
                           $"{BusinessOptions.SectionName}: TimeZoneId is not a time zone known to this machine.")
            .ValidateOnStart();
        return services;
    }
}