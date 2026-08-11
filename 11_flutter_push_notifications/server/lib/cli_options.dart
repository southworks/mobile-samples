import 'dart:io';

class CliOptions {
  const CliOptions({
    required this.topic,
    required this.serviceAccountPath,
    this.showHelp = false,
  });

  static const defaultTopic = 'sample_push';

  final String topic;
  final String? serviceAccountPath;
  final bool showHelp;
}

CliOptions parseCliOptions(List<String> arguments) {
  var topic = CliOptions.defaultTopic;
  String? serviceAccountPath;
  var showHelp = false;

  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
      continue;
    }
    if (argument == '--topic') {
      if (index + 1 >= arguments.length) {
        throw const FormatException('Missing value for --topic');
      }
      topic = arguments[++index];
      continue;
    }
    if (argument == '--service-account') {
      if (index + 1 >= arguments.length) {
        throw const FormatException('Missing value for --service-account');
      }
      serviceAccountPath = arguments[++index];
      continue;
    }
    if (argument.startsWith('-')) {
      throw FormatException('Unknown option: $argument');
    }
  }

  serviceAccountPath ??= Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  return CliOptions(
    topic: topic,
    serviceAccountPath: serviceAccountPath,
    showHelp: showHelp,
  );
}

void printHelp() {
  stdout.writeln('''
FCM topic notification sender (Sample 11)

Usage:
  dart run [--topic sample_push] [--service-account PATH]

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
''');
}
