internal sealed record CallOptions(string OperationId, Guid DatasetId, string? InputPath)
{
    public static CallOptions Parse(string[] args)
    {
        if (args.Length < 2 || !string.Equals(args[0], "call", StringComparison.Ordinal))
        {
            throw new RequestValidationException("Usage: relewise-agent call <operation-id> --dataset <dataset-id> [--input <path>]");
        }

        var operationId = args[1];
        string? datasetIdValue = null;
        string? inputPath = null;

        for (var index = 2; index < args.Length; index++)
        {
            if (args[index] is "--dataset" or "--input")
            {
                if (index + 1 >= args.Length)
                {
                    throw new RequestValidationException($"Option '{args[index]}' requires a value.", operationId);
                }

                var option = args[index];
                var value = args[++index];
                if (option == "--dataset")
                {
                    if (datasetIdValue is not null)
                    {
                        throw new RequestValidationException("Option '--dataset' can only be specified once.", operationId);
                    }

                    datasetIdValue = value;
                }
                else
                {
                    if (inputPath is not null)
                    {
                        throw new RequestValidationException("Option '--input' can only be specified once.", operationId);
                    }

                    inputPath = value;
                }

                continue;
            }

            throw new RequestValidationException($"Unknown option '{args[index]}'.", operationId);
        }

        if (!Guid.TryParse(datasetIdValue, out var datasetId))
        {
            throw new RequestValidationException("Option '--dataset' must contain a valid UUID.", operationId);
        }

        return new CallOptions(operationId, datasetId, inputPath);
    }
}

internal sealed class RequestValidationException : Exception
{
    public RequestValidationException(string message, string? operationId = null)
        : base(message)
    {
        OperationId = operationId;
    }

    public string? OperationId { get; }
}
