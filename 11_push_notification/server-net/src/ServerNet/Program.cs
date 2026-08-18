using ServerNet;

var validator = new NotificationInputValidator();
using var sender = new FcmTopicSender(new HttpClient());
var app = new CliApp(validator, sender);

var exitCode = await app.RunAsync(args);
Environment.Exit(exitCode);
