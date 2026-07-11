import 'package:flutter_test/flutter_test.dart';
import 'package:alu_nexus/core/utils/validators.dart';

void main() {
  group('AppValidators.aluEmail', () {
    test('accepts @alustudent.com addresses', () {
      expect(AppValidators.aluEmail('a.student@alustudent.com'), isNull);
    });

    test('accepts @alueducation.com addresses', () {
      expect(AppValidators.aluEmail('staff@alueducation.com'), isNull);
    });

    test('rejects non-ALU domains', () {
      expect(AppValidators.aluEmail('someone@gmail.com'), isNotNull);
    });

    test('rejects malformed emails', () {
      expect(AppValidators.aluEmail('not-an-email'), isNotNull);
    });

    test('rejects empty input', () {
      expect(AppValidators.aluEmail(''), isNotNull);
      expect(AppValidators.aluEmail(null), isNotNull);
    });
  });

  group('AppValidators.password', () {
    test('accepts a strong password', () {
      expect(AppValidators.password('Secure123'), isNull);
    });

    test('rejects passwords under 8 characters', () {
      expect(AppValidators.password('Ab1'), isNotNull);
    });

    test('rejects passwords without an uppercase letter', () {
      expect(AppValidators.password('nocaps123'), isNotNull);
    });

    test('rejects passwords without a number', () {
      expect(AppValidators.password('NoNumbersHere'), isNotNull);
    });
  });

  group('AppValidators.confirmPassword', () {
    test('accepts matching passwords', () {
      expect(AppValidators.confirmPassword('Secure123', 'Secure123'), isNull);
    });

    test('rejects mismatched passwords', () {
      expect(
        AppValidators.confirmPassword('Secure123', 'Different1'),
        isNotNull,
      );
    });
  });

  group('AppValidators.url', () {
    test('accepts a valid URL', () {
      expect(AppValidators.url('https://alueducation.com'), isNull);
    });

    test('is optional (empty is valid)', () {
      expect(AppValidators.url(''), isNull);
      expect(AppValidators.url(null), isNull);
    });

    test('rejects garbage input', () {
      expect(AppValidators.url('not a url'), isNotNull);
    });
  });

  group('AppValidators.minLength', () {
    test('enforces minimum length', () {
      expect(AppValidators.minLength('short', 100), isNotNull);
      expect(AppValidators.minLength('x' * 100, 100), isNull);
    });
  });
}
