namespace ServerNet;

public sealed record FcmSendResult
{
    public bool IsSuccess { get; init; }
    public string? MessageName { get; init; }
    public string? ErrorMessage { get; init; }

    public static FcmSendResult Success(string messageName) =>
        new()
        {
            IsSuccess = true,
            MessageName = messageName,
        };

    public static FcmSendResult Failure(string errorMessage) =>
        new()
        {
            IsSuccess = false,
            ErrorMessage = errorMessage,
        };
}
