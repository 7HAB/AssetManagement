using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Application.Abstractions.Persistence;
using AssetManagement.Domain.Entities;

using Microsoft.EntityFrameworkCore;

namespace AssetManagement.Infrastructure.Persistence.Repositories;

internal sealed class AssetHistoryRepository(AssetManagementDbContext dbContext): IAssetHistoryRepository
{
    public void Add(AssetHistory entity)
    {
        ArgumentNullException.ThrowIfNull(entity);
        dbContext.AssetHistories.Add(entity);
    }
    public async Task<IReadOnlyList<AssetHistory>> ListByAssetAsync(int assetId, CancellationToken cancellationToken = default)
    {
        return await dbContext.AssetHistories
            .AsNoTracking()
            .Where(h => h.AssetId == assetId)
            .OrderBy(h => h.EffectiveDate)
            .ThenBy(h => h.AssetHistoryId)
            .ToListAsync(cancellationToken);
    }
}
