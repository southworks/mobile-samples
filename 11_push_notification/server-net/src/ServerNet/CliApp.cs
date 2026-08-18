namespace ServerNet;

public sealed class CliApp(
    NotificationInputValidator validator,
    FcmTopicSender sender)
{
    public async Task<int> RunAsync(string[] arguments, CancellationToken cancellationToken = default)
    {
        CliOptions options;
        try
        {
            options = CliOptionsParser.Parse(arguments);
        }
        catch (FormatException ex)
        {
            Console.Error.WriteLine($"Error: {ex.Message}");
            CliOptionsParser.PrintHelp();
            return 1;
        }

        if (options.ShowHelp)
        {
            CliOptionsParser.PrintHelp();
            return 0;
        }

        if (options.ServiceAccountPath is null)
        {
            Console.Error.WriteLine(
                "Error: Provide --service-account or set GOOGLE_APPLICATION_CREDENTIALS.");
            CliOptionsParser.PrintHelp();
            return 1;
        }

        var title = await PromptValidatedAsync(
            $"Notification title (max {NotificationInputValidator.MaxTitleLength} chars)",
            validator.ValidateTitle,
            cancellationToken);
        var body = await PromptValidatedAsync(
            $"Notification body (max {NotificationInputValidator.MaxBodyLength} chars)",
            validator.ValidateBody,
            cancellationToken);

        Console.WriteLine();
        Console.WriteLine($"Sending to topic \"{options.Topic}\"...");
        Console.WriteLine(
            "Reminder: devices must be subscribed to this topic in the Flutter app.");

        var result = await sender.SendAsync(
            options.ServiceAccountPath,
            options.Topic,
            title,
            body,
            cancellationToken);

        if (result.IsSuccess)
        {
            Console.WriteLine($"Success: {result.MessageName}");
            return 0;
        }

        Console.Error.WriteLine($"Failed: {result.ErrorMessage}");
        return 1;
    }

    private static async Task<string> PromptValidatedAsync(
        string label,
        Action<string> validate,
        CancellationToken cancellationToken)
    {
        while (true)
        {
            Console.Write($"{label}: ");
            cancellationToken.ThrowIfCancellationRequested();

            var input = Console.ReadLine();
            if (input is null)
            {
                Console.Error.WriteLine("Input cancelled.");
                Environment.Exit(1);
            }

            try
            {
                validate(input);
                return input.Trim();
            }
            catch (InputValidationException ex)
            {
                Console.Error.WriteLine(ex.Message);
            }
        }
    }
}
