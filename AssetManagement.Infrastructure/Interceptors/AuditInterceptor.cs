using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Application.Abstractions;
using AssetManagement.Domain.Common;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace AssetManagement.Infrastructure.Interceptors;

public sealed class AuditInterceptor (ICurrentUser currentUser, TimeProvider timeProvider) : SaveChangesInterceptor
{


    public override InterceptionResult<int> SavingChanges(DbContextEventData eventData, InterceptionResult<int> result)
    {
        StampAuditFields(eventData.Context);
        return base.SavingChanges(eventData, result);
    }

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(DbContextEventData eventData, InterceptionResult<int> result, CancellationToken cancellationToken = default)
    {
        StampAuditFields(eventData.Context);
        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }


    private void StampAuditFields(DbContext? dbContext)
    {
        if (dbContext is null)
        {
            return;
        }
        var now = timeProvider.GetUtcNow().UtcDateTime;
        var userId = currentUser.UserId ?? SystemUser.Id;

        foreach (var entry in dbContext.ChangeTracker.Entries<IModifiable>())
        {
            switch (entry.State)
            {
                case EntityState.Added when entry.Entity is IAuditable auditable:
                    auditable.CreatedBy = userId;
                    auditable.CreatedAt = now;
                    auditable.ModifiedBy = null;
                    auditable.ModifiedAt = null;
                    break;

                case EntityState.Modified:
                    entry.Entity.ModifiedBy = userId;
                    entry.Entity.ModifiedAt = now;
                    if (entry.Entity is IAuditable)
                    {
                        entry.Property(nameof(IAuditable.CreatedAt)).IsModified = false;
                        entry.Property(nameof(IAuditable.CreatedBy)).IsModified = false;
                    }
                    break;

            }
        }
    }
}
