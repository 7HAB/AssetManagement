using System.Security.Claims;

using AssetManagement.Application.Abstractions;
using AssetManagement.Domain.Enums;

namespace AssetManagement.API.Services;

public sealed class HttpContextCurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
{
    private const string UserIdClaimType = "sub";

    private ClaimsPrincipal? User => httpContextAccessor.HttpContext?.User;

    public int? UserId
    {
        get
        {
            var userIdClaim = User?.FindFirstValue(UserIdClaimType) ?? User?.FindFirstValue(ClaimTypes.NameIdentifier); 
           
            return int.TryParse(userIdClaim, out var userId) ? userId : null;
        }
    }

    public bool IsAuthenticated => User?.Identity?.IsAuthenticated == true;
    public bool IsAdmin => User?.IsInRole(nameof(RoleId.Admin)) == true;
}
