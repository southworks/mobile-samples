import 'dart:io';

import 'package:server/cli_options.dart';
import 'package:server/fcm_topic_sender.dart';
import 'package:server/notification_input_validator.dart';

Future<int> runCli(List<String> arguments) async {
  final CliOptions options;
  try {
    options = parseCliOptions(arguments);
  } on FormatException catch (error) {
    stderr.writeln('Error: $error');
    printHelp();
    return 1;
  }

  if (options.showHelp) {
    printHelp();
    return 0;
  }

  if (options.serviceAccountPath == null) {
    stderr.writeln(
      'Error: Provide --service-account or set GOOGLE_APPLICATION_CREDENTIALS.',
    );
    printHelp();
    return 1;
  }

  final validator = NotificationInputValidator();
  final title = await _promptValidated(
    label: 'Notification title (max ${NotificationInputValidator.maxTitleLength} chars)',
    validate: validator.validateTitle,
  );
  final body = await _promptValidated(
    label: 'Notification body (max ${NotificationInputValidator.maxBodyLength} chars)',
    validate: validator.validateBody,
  );

  stdout.writeln('');
  stdout.writeln('Sending to topic "${options.topic}"...');
  stdout.writeln(
    'Reminder: devices must be subscribed to this topic in the Flutter app.',
  );

  final sender = FcmTopicSender();
  try {
    final result = await sender.send(
      serviceAccountPath: options.serviceAccountPath!,
      topic: options.topic,
      title: title,
      body: body,
    );

    if (result.isSuccess) {
      stdout.writeln('Success: ${result.messageName}');
      return 0;
    }

    stderr.writeln('Failed: ${result.errorMessage}');
    return 1;
  } finally {
    sender.close();
  }
}

Future<String> _promptValidated({
  required String label,
  required void Function(String value) validate,
}) async {
  while (true) {
    stdout.write('$label: ');
    final input = stdin.readLineSync();
    if (input == null) {
      stderr.writeln('Input cancelled.');
      exit(1);
    }

    try {
      validate(input);
      return input.trim();
    } on InputValidationException catch (error) {
      stderr.writeln(error.message);
    }
  }
}
