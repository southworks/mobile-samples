namespace ServerNet;

public sealed class NotificationInputValidator
{
    public const int MaxTitleLength = 30;
    public const int MaxBodyLength = 100;

    public void ValidateTitle(string title)
    {
        var trimmed = title.Trim();
        if (trimmed.Length == 0)
        {
            throw new InputValidationException("Title cannot be empty.");
        }

        if (trimmed.Length > MaxTitleLength)
        {
            throw new InputValidationException(
                $"Title must be at most {MaxTitleLength} characters.");
        }
    }

    public void ValidateBody(string body)
    {
        var trimmed = body.Trim();
        if (trimmed.Length == 0)
        {
            throw new InputValidationException("Body cannot be empty.");
        }

        if (trimmed.Length > MaxBodyLength)
        {
            throw new InputValidationException(
                $"Body must be at most {MaxBodyLength} characters.");
        }
    }
}
