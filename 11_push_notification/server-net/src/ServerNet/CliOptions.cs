namespace ServerNet;

public sealed record CliOptions(
    string Topic,
    string? ServiceAccountPath,
    bool ShowHelp)
{
    public const string DefaultTopic = "sample_push";
}

public static class CliOptionsParser
{
    public static CliOptions Parse(string[] arguments)
    {
        var topic = CliOptions.DefaultTopic;
        string? serviceAccountPath = null;
        var showHelp = false;

        for (var index = 0; index < arguments.Length; index++)
        {
            var argument = arguments[index];
            if (argument is "--help" or "-h")
            {
                showHelp = true;
                continue;
            }

            if (argument == "--topic")
            {
                if (index + 1 >= arguments.Length)
                {
                    throw new FormatException("Missing value for --topic");
                }

                topic = arguments[++index];
                continue;
            }

            if (argument == "--service-account")
            {
                if (index + 1 >= arguments.Length)
                {
                    throw new FormatException("Missing value for --service-account");
                }

                serviceAccountPath = arguments[++index];
                continue;
            }

            if (argument.StartsWith('-'))
            {
                throw new FormatException($"Unknown option: {argument}");
            }
        }

        serviceAccountPath ??= Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS");

        return new CliOptions(topic, serviceAccountPath, showHelp);
    }

    public static void PrintHelp()
    {
        Console.WriteLine(
            """
            FCM topic notification sender (Sample 11)

            Usage:
              dotnet run --project src/ServerNet [--topic sample_push] [--service-account PATH]

            Options:
              --topic               FCM topic to send to (default: sample_push)
              --service-account     Path to Firebase service account JSON
              -h, --help            Show this help

            Environment:
              GOOGLE_APPLICATION_CREDENTIALS   Service account JSON path

            Notes:
              - You will be prompted for notification title (max 30 chars)
                and body (max 100 chars).
              - Devices only receive the message if they subscribed to the
                same topic in the Flutter app.
            """);
    }
}
