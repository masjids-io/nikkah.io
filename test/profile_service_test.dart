import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/services/profile_service.dart';

void main() {
  group('ProfileService Tests', () {
    group('buildNikkahProfileData', () {
      test('should build correct profile data structure', () {
        final result = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(result['profile'], isA<Map<String, dynamic>>());
        expect(result['profile']['name'], equals('John Doe'));
        expect(result['profile']['gender'], equals('MALE'));
        expect(result['profile']['birth_date'], isA<Map<String, dynamic>>());
        expect(result['profile']['birth_date']['year'], equals(1995));
        expect(result['profile']['birth_date']['month'], equals('JANUARY'));
        expect(result['profile']['birth_date']['day'], equals(15));
      });

      test('should handle different gender values', () {
        final maleResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        final femaleResult = ProfileService.buildNikkahProfileData(
          name: 'Jane Doe',
          gender: 'FEMALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(maleResult['profile']['gender'], equals('MALE'));
        expect(femaleResult['profile']['gender'], equals('FEMALE'));
      });

      test('should handle different birth months', () {
        final januaryResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        final decemberResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'DECEMBER',
          birthDay: 15,
        );

        expect(
            januaryResult['profile']['birth_date']['month'], equals('JANUARY'));
        expect(decemberResult['profile']['birth_date']['month'],
            equals('DECEMBER'));
      });

      test('should handle edge case birth dates', () {
        final leapYearResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 2000,
          birthMonth: 'FEBRUARY',
          birthDay: 29,
        );

        expect(leapYearResult['profile']['birth_date']['year'], equals(2000));
        expect(leapYearResult['profile']['birth_date']['month'],
            equals('FEBRUARY'));
        expect(leapYearResult['profile']['birth_date']['day'], equals(29));
      });

      test('should handle empty name', () {
        final result = ProfileService.buildNikkahProfileData(
          name: '',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(result['profile']['name'], equals(''));
      });

      test('should handle special characters in name', () {
        final result = ProfileService.buildNikkahProfileData(
          name: 'محمد أحمد',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(result['profile']['name'], equals('محمد أحمد'));
      });
    });

    group('Data validation tests', () {
      test('should validate age requirements', () {
        final currentYear = DateTime.now().year;

        // Test valid age (25 years old)
        final validAgeResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: currentYear - 25,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(validAgeResult['profile']['birth_date']['year'],
            equals(currentYear - 25));

        // Test minimum age (18 years old)
        final minimumAgeResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: currentYear - 18,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(minimumAgeResult['profile']['birth_date']['year'],
            equals(currentYear - 18));
      });

      test('should handle all month values', () {
        final months = [
          'JANUARY',
          'FEBRUARY',
          'MARCH',
          'APRIL',
          'MAY',
          'JUNE',
          'JULY',
          'AUGUST',
          'SEPTEMBER',
          'OCTOBER',
          'NOVEMBER',
          'DECEMBER'
        ];

        for (final month in months) {
          final result = ProfileService.buildNikkahProfileData(
            name: 'John Doe',
            gender: 'MALE',
            birthYear: 1995,
            birthMonth: month,
            birthDay: 15,
          );

          expect(result['profile']['birth_date']['month'], equals(month));
        }
      });

      test('should handle all day values', () {
        for (int day = 1; day <= 31; day++) {
          final result = ProfileService.buildNikkahProfileData(
            name: 'John Doe',
            gender: 'MALE',
            birthYear: 1995,
            birthMonth: 'JANUARY',
            birthDay: day,
          );

          expect(result['profile']['birth_date']['day'], equals(day));
        }
      });
    });

    group('API endpoint structure tests', () {
      test('should match expected API structure', () {
        final result = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        // Verify the structure matches the protobuf definition
        expect(result.containsKey('profile'), isTrue);
        expect(result['profile'].containsKey('name'), isTrue);
        expect(result['profile'].containsKey('gender'), isTrue);
        expect(result['profile'].containsKey('birth_date'), isTrue);
        expect(result['profile']['birth_date'].containsKey('year'), isTrue);
        expect(result['profile']['birth_date'].containsKey('month'), isTrue);
        expect(result['profile']['birth_date'].containsKey('day'), isTrue);
      });

      test('should not include user_id in request (handled by backend)', () {
        final result = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        // user_id should not be in the request payload
        expect(result['profile'].containsKey('user_id'), isFalse);
      });
    });
  });
}
