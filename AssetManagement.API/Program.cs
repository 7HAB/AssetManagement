using AssetManagement.API.ErrorHandling;
using AssetManagement.API.Services;
using AssetManagement.Application;
using AssetManagement.Application.Abstractions;
using AssetManagement.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddApplication(builder.Configuration)
                .AddInfrastructure(builder.Configuration);
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUser, HttpContextCurrentUser>();

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddApiErrorHandling();
var app = builder.Build();
// Configure the HTTP request pipeline. ERROR HANDLING MUST BE FIRST, before any other middleware that can throw exceptions.
app.UseApiErrorHandling();
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}


app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
