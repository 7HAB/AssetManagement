using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace AssetManagement.Application.Options;

public sealed class BusinessOptions
{
    public const string SectionName = "Business";

    [Required]
    public string TimeZoneId { get; init; } = string.Empty;

    [Required]
    public string Audience { get; init; } = string.Empty;

    [Required]
    [MinLength(32)]
    public string SigningKey { get; init; } = string.Empty;

    [Range(1, 60)]
    public string AccessTokenExpirationInMinutes { get; init; } = "15";

    [Range(1, 30)]
    public string RefreshTokenExpirationInDays { get; init; } = "7";
}
