import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/core/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils', () {
    group('generateSignature', () {
      test('should generate consistent signature for same data', () {
        final data = {
          'code': 'ABC123',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
        };
        const secretKey = 'test_secret_key';

        final sig1 = CryptoUtils.generateSignature(data, secretKey);
        final sig2 = CryptoUtils.generateSignature(data, secretKey);

        expect(sig1, equals(sig2));
      });

      test('should generate different signature for different data', () {
        final data1 = {
          'code': 'ABC123',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
        };
        final data2 = {
          'code': 'XYZ789',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
        };
        const secretKey = 'test_secret_key';

        final sig1 = CryptoUtils.generateSignature(data1, secretKey);
        final sig2 = CryptoUtils.generateSignature(data2, secretKey);

        expect(sig1, isNot(equals(sig2)));
      });

      test('should generate different signature for different secret keys', () {
        final data = {
          'code': 'ABC123',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
        };

        final sig1 = CryptoUtils.generateSignature(data, 'key1');
        final sig2 = CryptoUtils.generateSignature(data, 'key2');

        expect(sig1, isNot(equals(sig2)));
      });

      test('should return base64 encoded string', () {
        final data = {
          'code': 'ABC123',
          'name': 'Test',
          'cert': 'CERT-001',
        };

        final sig = CryptoUtils.generateSignature(data, 'secret');

        expect(sig, isNotEmpty);
        expect(() => sig.contains(RegExp(r'^[A-Za-z0-9+/=]+$')), returnsNormally);
      });
    });

    group('verifySignature', () {
      test('should return true for valid signature', () {
        final data = {
          'code': 'ABC123',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
        };
        const secretKey = 'test_secret_key';
        final sig = CryptoUtils.generateSignature(data, secretKey);
        
        final qrData = {...data, 'sig': sig};

        expect(CryptoUtils.verifySignature(qrData, secretKey), true);
      });

      test('should return false for invalid signature', () {
        final qrData = {
          'code': 'ABC123',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
          'sig': 'invalid_signature',
        };

        expect(CryptoUtils.verifySignature(qrData, 'secret'), false);
      });

      test('should return false for tampered data', () {
        final originalData = {
          'code': 'ABC123',
          'name': 'Ahmad bin Ali',
          'cert': 'CERT-2024-001',
        };
        const secretKey = 'test_secret_key';
        final sig = CryptoUtils.generateSignature(originalData, secretKey);
        
        final tamperedData = {
          'code': 'ABC123',
          'name': 'Hacker', // Tampered
          'cert': 'CERT-2024-001',
          'sig': sig,
        };

        expect(CryptoUtils.verifySignature(tamperedData, secretKey), false);
      });
    });

    group('hashPassword', () {
      test('should generate consistent hash for same password', () {
        const password = 'myPassword123';

        final hash1 = CryptoUtils.hashPassword(password);
        final hash2 = CryptoUtils.hashPassword(password);

        expect(hash1, equals(hash2));
      });

      test('should generate different hash for different passwords', () {
        final hash1 = CryptoUtils.hashPassword('password1');
        final hash2 = CryptoUtils.hashPassword('password2');

        expect(hash1, isNot(equals(hash2)));
      });

      test('should generate 64-character hex string (SHA-256)', () {
        final hash = CryptoUtils.hashPassword('test');

        expect(hash.length, 64);
        expect(hash, matches(RegExp(r'^[a-f0-9]+$')));
      });

      test('should hash empty password', () {
        final hash = CryptoUtils.hashPassword('');

        expect(hash, isNotEmpty);
        expect(hash.length, 64);
      });
    });

    group('verifyPassword', () {
      test('should return true for correct password', () {
        const password = 'correctPassword';
        final hash = CryptoUtils.hashPassword(password);

        expect(CryptoUtils.verifyPassword(password, hash), true);
      });

      test('should return false for incorrect password', () {
        final hash = CryptoUtils.hashPassword('correctPassword');

        expect(CryptoUtils.verifyPassword('wrongPassword', hash), false);
      });

      test('should be case sensitive', () {
        final hash = CryptoUtils.hashPassword('Password');

        expect(CryptoUtils.verifyPassword('password', hash), false);
        expect(CryptoUtils.verifyPassword('PASSWORD', hash), false);
      });
    });

    group('maskIcNumber', () {
      test('should mask IC number after first 6 digits', () {
        final masked = CryptoUtils.maskIcNumber('901234567890');

        expect(masked, '901234******');
      });

      test('should return original if less than 6 characters', () {
        expect(CryptoUtils.maskIcNumber('12345'), '12345');
        expect(CryptoUtils.maskIcNumber('123'), '123');
        expect(CryptoUtils.maskIcNumber(''), '');
      });

      test('should handle exactly 6 characters', () {
        final masked = CryptoUtils.maskIcNumber('123456');

        expect(masked, '123456');
      });

      test('should handle 12-digit IC number', () {
        final masked = CryptoUtils.maskIcNumber('850101145678');

        expect(masked, '850101******');
        expect(masked.length, 12);
      });
    });
  });
}
