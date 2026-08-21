using System.Text.Json;

internal static class DatasetCatalog
{
    public static DatasetSummary[] FromCurrentUser(JsonElement currentUser)
    {
        CurrentUserContract? response;
        try
        {
            response = JsonSerializer.Deserialize(
                currentUser,
                AgentJsonContext.Default.CurrentUserContract);
        }
        catch (JsonException exception)
        {
            throw new AgentGatewayResponseException(exception);
        }

        if (response?.Licenses is null || response.Licenses.Any(license => license.Datasets is null))
        {
            throw new AgentGatewayResponseException();
        }

        return response.Licenses
            .SelectMany(license => license.Datasets!.Select(dataset => new DatasetSummary(
                Id: dataset.Id,
                DisplayName: dataset.DisplayName,
                Type: dataset.Type,
                LicenseId: license.Id,
                LicenseDisplayName: license.DisplayName)))
            .OrderBy(dataset => dataset.LicenseDisplayName, StringComparer.Ordinal)
            .ThenBy(dataset => dataset.DisplayName, StringComparer.Ordinal)
            .ThenBy(dataset => dataset.Id, StringComparer.Ordinal)
            .ToArray();
    }

    public static DatasetPolicy FromDatasetDetails(JsonElement datasetDetails)
    {
        DatasetDetailsContract? response;
        try
        {
            response = JsonSerializer.Deserialize(
                datasetDetails,
                AgentJsonContext.Default.DatasetDetailsContract);
        }
        catch (JsonException exception)
        {
            throw new AgentGatewayResponseException(exception);
        }

        if (response?.AgentGatewayPolicy?.Areas is null)
        {
            throw new AgentGatewayResponseException();
        }

        return new DatasetPolicy(
            response.AgentGatewayPolicy.RestApiEnabled,
            response.AgentGatewayPolicy.Areas);
    }
}

internal sealed record DatasetPolicy(bool RestApiEnabled, string[] Areas)
{
    public bool Allows(string? area)
    {
        return RestApiEnabled &&
            area is not null &&
            Areas.Contains(area, StringComparer.OrdinalIgnoreCase);
    }
}

internal sealed class AgentGatewayResponseException : Exception
{
    public AgentGatewayResponseException()
        : base("The Agent Gateway response did not match the versioned API contract.")
    {
    }

    public AgentGatewayResponseException(Exception innerException)
        : base("The Agent Gateway response did not match the versioned API contract.", innerException)
    {
    }
}
