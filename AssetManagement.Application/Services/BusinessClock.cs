using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Application.Abstractions;
using AssetManagement.Application.Options;

using Microsoft.Extensions.Options;

namespace AssetManagement.Application.Services;

public sealed class BusinessClock : IBusinessClock
{
    private readonly TimeProvider _timeProvider;
    private readonly TimeZoneInfo _businessTimeZone;

    public BusinessClock(TimeProvider timeProvider, IOptions<BusinessOptions> options)
    {
        _timeProvider = timeProvider;
        _businessTimeZone = TimeZoneInfo.FindSystemTimeZoneById(options.Value.TimeZoneId);
    }

    public DateTime UtcNow => _timeProvider.GetUtcNow().UtcDateTime;

    public DateOnly Today => DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(UtcNow, _businessTimeZone));
}

