using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Domain.Entities;

namespace AssetManagement.Application.Abstractions.Persistence;

public interface IAssetHistoryRepository
{
    /// <summary>Stages a new history row. Written by IUnitOfWork.SaveChangesAsync.</summary>
    void Add(AssetHistory entry);

    /// <summary>All events for one asset, oldest first, read-only (not tracked).</summary>
    Task<IReadOnlyList<AssetHistory>> ListByAssetAsync(int assetId, CancellationToken cancellationToken = default);
}
