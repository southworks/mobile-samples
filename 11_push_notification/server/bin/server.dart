import 'dart:io';

import 'package:server/server.dart' as server;

Future<void> main(List<String> arguments) async {
  final exitCode = await server.runCli(arguments);
  exit(exitCode);
}
