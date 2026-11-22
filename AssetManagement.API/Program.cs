using AssetManagement.API.ErrorHandling;
using AssetManagement.API.Services;
using AssetManagement.Application;
using AssetManagement.Application.Abstractions;
using AssetManagement.Infrastructure;


var builder = WebApplication.CreateBuilder(args);

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

var app = builder.Build();

// ---------- 2. PIPELINE (middleware, AFTER Build) ----------
// Error handling first, so it wraps everything below it.
app.UseApiErrorHandling();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();