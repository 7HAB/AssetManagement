using AssetManagement.API.ErrorHandling;
using AssetManagement.API.Middleware;
using AssetManagement.API.Services;
using AssetManagement.Application;
using AssetManagement.Application.Abstractions;
using AssetManagement.Infrastructure;

using Serilog;
using Serilog.Events;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSerilog((services, loggerConfiguration) => loggerConfiguration
    .ReadFrom.Configuration(builder.Configuration)
    .ReadFrom.Services(services)
    .Enrich.FromLogContext());
// ---------- 1. SERVICES (everything on builder.Services, BEFORE Build) ----------
builder.Services.AddApplication(builder.Configuration)
                .AddInfrastructure(builder.Configuration);
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUser, HttpContextCurrentUser>();

builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Error handling: the specific handler MUST be registered before the catch-all.
builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<ValidationExceptionHandler>();
builder.Services.AddApiErrorHandling();   // registers GlobalExceptionHandler (see note below)
try
{
    var app = builder.Build();

// ---------- 2. PIPELINE (middleware, AFTER Build) ----------
// Error handling first, so it wraps everything below it.
app.UseMiddleware<CorrelationIdMiddleware>();

app.UseSerilogRequestLogging(options =>
{
    options.GetLevel = (httpContext, _, ex) =>
    {
        if (httpContext.Request.Path.StartsWithSegments("/health"))
            return LogEventLevel.Verbose;                 // hidden at Information minimum

        if (ex is not null || httpContext.Response.StatusCode >= 500)
            return LogEventLevel.Error;

        return LogEventLevel.Information;
    };

    // Runs when the request finishes, so authentication has already happened.
    options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
    {
        var userId = httpContext.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        diagnosticContext.Set("UserId", userId ?? "anonymous");
    };
});
app.UseApiErrorHandling();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run(); ;
}
catch (Exception ex) when (ex is not HostAbortedException)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}

