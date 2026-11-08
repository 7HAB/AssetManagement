using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Infrastructure.Persistence;

using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AssetManagement.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
        {
            // 1. Read the connection string (comes from user-secrets on your machine).
            var connectionString = configuration.GetConnectionString("AssetManagement");

            // 2. Fail at startup with a clear message, not on the first request.
            if (string.IsNullOrWhiteSpace(connectionString))
            {
                throw new InvalidOperationException(
                    "Connection string 'AssetManagement' is missing. Set it with dotnet user-secrets (see README).");
            }

            // 3. Register the DbContext: "whenever someone needs the database, create it like this".
            services.AddDbContext<AssetManagementDbContext>(options =>
            {
                options.UseSqlServer(connectionString);
            });

            // 4. Register the health check that tries to reach the database.
            services.AddHealthChecks()
                .AddDbContextCheck<AssetManagementDbContext>("database");

            return services;
        }
    }
}
