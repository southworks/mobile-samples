import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FcmSendResult {
  const FcmSendResult.success(this.messageName)
    : isSuccess = true,
      errorMessage = null;

  const FcmSendResult.failure(this.errorMessage)
    : isSuccess = false,
      messageName = null;

  final bool isSuccess;
  final String? messageName;
  final String? errorMessage;
}

class FcmTopicSender {
  FcmTopicSender({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<FcmSendResult> send({
    required String serviceAccountPath,
    required String topic,
    required String title,
    required String body,
  }) async {
    final serviceAccountFile = File(serviceAccountPath);
    if (!serviceAccountFile.existsSync()) {
      return FcmSendResult.failure(
        'Service account file not found: $serviceAccountPath',
      );
    }

    final serviceAccountJson =
        jsonDecode(serviceAccountFile.readAsStringSync()) as Map<String, dynamic>;
    final projectId = serviceAccountJson['project_id'] as String?;
    if (projectId == null || projectId.isEmpty) {
      return FcmSendResult.failure(
        'Service account JSON is missing project_id.',
      );
    }

    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final authClient = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    try {
      final uri = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );
      final payload = {
        'message': {
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'title': title,
            'body': body,
          },
        },
      };

      final response = await authClient.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody =
            jsonDecode(response.body) as Map<String, dynamic>? ?? {};
        final messageName = responseBody['name'] as String? ?? '(no id returned)';
        return FcmSendResult.success(messageName);
      }

      return FcmSendResult.failure(
        'FCM request failed (${response.statusCode}): ${response.body}',
      );
    } on Object catch (error) {
      return FcmSendResult.failure(error.toString());
    } finally {
      authClient.close();
    }
  }

  void close() {
    _httpClient.close();
  }
}
