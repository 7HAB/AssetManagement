using AssetManagement.Application.Abstractions;
using AssetManagement.Application.Options;
using AssetManagement.Application.Services;

using FluentValidation;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

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
        services.TryAddSingleton(TimeProvider.System);
        services.AddSingleton<IBusinessClock, BusinessClock>();
        services.AddValidatorsFromAssemblyContaining<ApplicationAssemblyMarker>();
        return services;
    }
}