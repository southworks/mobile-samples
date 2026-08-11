import 'package:server/notification_input_validator.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationInputValidator', () {
    final validator = NotificationInputValidator();

    test('accepts valid title and body lengths', () {
      expect(() => validator.validateTitle('Hello'), returnsNormally);
      expect(() => validator.validateBody('Short body'), returnsNormally);
    });

    test('rejects empty title', () {
      expect(
        () => validator.validateTitle('   '),
        throwsA(isA<InputValidationException>()),
      );
    });

    test('rejects title longer than 30 characters', () {
      expect(
        () => validator.validateTitle('a' * 31),
        throwsA(isA<InputValidationException>()),
      );
    });

    test('rejects body longer than 100 characters', () {
      expect(
        () => validator.validateBody('b' * 101),
        throwsA(isA<InputValidationException>()),
      );
    });
  });
}
