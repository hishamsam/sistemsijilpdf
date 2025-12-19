import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('formatDate', () {
      test('should format date correctly', () {
        final date = DateTime(2024, 12, 25);
        final formatted = AppDateUtils.formatDate(date);

        expect(formatted, contains('25'));
        expect(formatted, contains('2024'));
      });

      test('should handle single digit day', () {
        final date = DateTime(2024, 1, 5);
        final formatted = AppDateUtils.formatDate(date);

        expect(formatted, contains('5'));
        expect(formatted, contains('2024'));
      });
    });

    group('formatDateShort', () {
      test('should format date in dd/MM/yyyy format', () {
        final date = DateTime(2024, 12, 25);
        final formatted = AppDateUtils.formatDateShort(date);

        expect(formatted, '25/12/2024');
      });

      test('should pad single digit day and month', () {
        final date = DateTime(2024, 1, 5);
        final formatted = AppDateUtils.formatDateShort(date);

        expect(formatted, '05/01/2024');
      });
    });

    group('formatDateTime', () {
      test('should format date with time', () {
        final dateTime = DateTime(2024, 12, 25, 14, 30);
        final formatted = AppDateUtils.formatDateTime(dateTime);

        expect(formatted, '25/12/2024 14:30');
      });

      test('should handle midnight', () {
        final dateTime = DateTime(2024, 1, 1, 0, 0);
        final formatted = AppDateUtils.formatDateTime(dateTime);

        expect(formatted, '01/01/2024 00:00');
      });
    });

    group('formatDateMalay', () {
      test('should format date in Malay with Januari', () {
        final date = DateTime(2024, 1, 15);
        final formatted = AppDateUtils.formatDateMalay(date);

        expect(formatted, '15 Januari 2024');
      });

      test('should format date in Malay with Mac', () {
        final date = DateTime(2024, 3, 10);
        final formatted = AppDateUtils.formatDateMalay(date);

        expect(formatted, '10 Mac 2024');
      });

      test('should format date in Malay with Disember', () {
        final date = DateTime(2024, 12, 25);
        final formatted = AppDateUtils.formatDateMalay(date);

        expect(formatted, '25 Disember 2024');
      });

      test('should handle all Malay months', () {
        final months = [
          'Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun',
          'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember'
        ];

        for (int i = 1; i <= 12; i++) {
          final date = DateTime(2024, i, 1);
          final formatted = AppDateUtils.formatDateMalay(date);
          expect(formatted, contains(months[i - 1]));
        }
      });
    });

    group('parseDate', () {
      test('should parse valid ISO date string', () {
        final date = AppDateUtils.parseDate('2024-12-25T10:30:00.000');

        expect(date, isNotNull);
        expect(date!.year, 2024);
        expect(date.month, 12);
        expect(date.day, 25);
      });

      test('should return null for null input', () {
        final date = AppDateUtils.parseDate(null);

        expect(date, isNull);
      });

      test('should return null for empty string', () {
        final date = AppDateUtils.parseDate('');

        expect(date, isNull);
      });

      test('should return null for invalid date string', () {
        final date = AppDateUtils.parseDate('invalid-date');

        expect(date, isNull);
      });

      test('should parse date-only string', () {
        final date = AppDateUtils.parseDate('2024-06-15');

        expect(date, isNotNull);
        expect(date!.year, 2024);
        expect(date.month, 6);
        expect(date.day, 15);
      });
    });

    group('toIsoString', () {
      test('should convert DateTime to ISO string', () {
        final date = DateTime(2024, 12, 25, 10, 30, 45);
        final isoString = AppDateUtils.toIsoString(date);

        expect(isoString, startsWith('2024-12-25'));
        expect(isoString, contains('10:30:45'));
      });

      test('should produce parseable ISO string', () {
        final original = DateTime(2024, 6, 15, 14, 30);
        final isoString = AppDateUtils.toIsoString(original);
        final parsed = DateTime.parse(isoString);

        expect(parsed.year, original.year);
        expect(parsed.month, original.month);
        expect(parsed.day, original.day);
        expect(parsed.hour, original.hour);
        expect(parsed.minute, original.minute);
      });
    });
  });
}
