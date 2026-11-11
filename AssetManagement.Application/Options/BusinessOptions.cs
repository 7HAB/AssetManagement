using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace AssetManagement.Application.Options;

public sealed class BusinessOptions
{
    public const string SectionName = "Business";

    [Required]
    public string TimeZoneId { get; init; } = "";
}
