import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/services/profile_service.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';

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
        expect(result['profile']['birthDate'], isA<Map<String, dynamic>>());
        expect(result['profile']['birthDate']['year'], equals(1995));
        expect(result['profile']['birthDate']['month'], equals('JANUARY'));
        expect(result['profile']['birthDate']['day'], equals(15));
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
            januaryResult['profile']['birthDate']['month'], equals('JANUARY'));
        expect(decemberResult['profile']['birthDate']['month'],
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

        expect(leapYearResult['profile']['birthDate']['year'], equals(2000));
        expect(leapYearResult['profile']['birthDate']['month'],
            equals('FEBRUARY'));
        expect(leapYearResult['profile']['birthDate']['day'], equals(29));
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

      test('should include optional fields when provided', () {
        final result = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
          country: 'USA',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          latitude: 40,
          longitude: -74,
          education: 'BACHELOR',
          occupation: 'Software Engineer',
          heightCm: 180,
          sect: 'SUNNI',
          hobbies: ['READING', 'TRAVELING'],
        );

        expect(result['profile']['location']['country'], equals('USA'));
        expect(result['profile']['location']['city'], equals('New York'));
        expect(result['profile']['location']['state'], equals('NY'));
        expect(result['profile']['location']['zipCode'], equals('10001'));
        expect(result['profile']['location']['latitude'], equals(40));
        expect(result['profile']['location']['longitude'], equals(-74));
        expect(result['profile']['education'], equals('BACHELOR'));
        expect(result['profile']['occupation'], equals('Software Engineer'));
        expect(result['profile']['height']['cm'], equals(180));
        expect(result['profile']['sect'], equals('SUNNI'));
        expect(result['profile']['hobbies'], equals(['READING', 'TRAVELING']));
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

        expect(validAgeResult['profile']['birthDate']['year'],
            equals(currentYear - 25));

        // Test minimum age (18 years old)
        final minimumAgeResult = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: currentYear - 18,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        expect(minimumAgeResult['profile']['birthDate']['year'],
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

          expect(result['profile']['birthDate']['month'], equals(month));
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

          expect(result['profile']['birthDate']['day'], equals(day));
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

        // Verify the structure matches the API definition
        expect(result.containsKey('profile'), isTrue);
        expect(result['profile'].containsKey('name'), isTrue);
        expect(result['profile'].containsKey('gender'), isTrue);
        expect(result['profile'].containsKey('birthDate'), isTrue);
        expect(result['profile']['birthDate'].containsKey('year'), isTrue);
        expect(result['profile']['birthDate'].containsKey('month'), isTrue);
        expect(result['profile']['birthDate'].containsKey('day'), isTrue);
      });

      test('should not include userId in request (handled by backend)', () {
        final result = ProfileService.buildNikkahProfileData(
          name: 'John Doe',
          gender: 'MALE',
          birthYear: 1995,
          birthMonth: 'JANUARY',
          birthDay: 15,
        );

        // userId should not be in the request payload
        expect(result['profile'].containsKey('userId'), isFalse);
      });
    });
  });

  group('NikkahProfile Model Tests', () {
    test('should create NikkahProfile from JSON', () {
      final json = {
        'id': 'profile-123',
        'userId': 'user-456',
        'name': 'John Doe',
        'gender': 'MALE',
        'birthDate': {
          'year': 1995,
          'month': 'JANUARY',
          'day': 15,
        },
        'location': {
          'country': 'USA',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'latitude': 40,
          'longitude': -74,
        },
        'education': 'BACHELOR',
        'occupation': 'Software Engineer',
        'height': {
          'cm': 180,
        },
        'sect': 'SUNNI',
        'hobbies': ['READING', 'TRAVELING'],
        'createTime': '2024-01-01T00:00:00Z',
        'updateTime': '2024-01-01T00:00:00Z',
      };

      final profile = NikkahProfile.fromJson(json);

      expect(profile.id, equals('profile-123'));
      expect(profile.userId, equals('user-456'));
      expect(profile.name, equals('John Doe'));
      expect(profile.gender, equals('MALE'));
      expect(profile.birthDate?.year, equals(1995));
      expect(profile.birthDate?.month, equals('JANUARY'));
      expect(profile.birthDate?.day, equals(15));
      expect(profile.location?.country, equals('USA'));
      expect(profile.location?.city, equals('New York'));
      expect(profile.education, equals('BACHELOR'));
      expect(profile.occupation, equals('Software Engineer'));
      expect(profile.height?.cm, equals(180));
      expect(profile.sect, equals('SUNNI'));
      expect(profile.hobbies, equals(['READING', 'TRAVELING']));
    });

    test('should calculate age correctly', () {
      final currentYear = DateTime.now().year;
      final profile = NikkahProfile(
        birthDate: BirthDate(year: currentYear - 25, month: 'JANUARY', day: 15),
      );

      expect(profile.age, equals(25));
    });

    test('should handle null birth date for age calculation', () {
      final profile = NikkahProfile(birthDate: null);
      expect(profile.age, isNull);
    });

    test('should format location display correctly', () {
      final location = Location(
        country: 'USA',
        city: 'New York',
        state: 'NY',
      );

      expect(location.displayLocation, equals('New York, NY, USA'));
    });

    test('should handle empty location for display', () {
      final location = Location();
      expect(location.displayLocation, equals('Location not specified'));
    });

    test('should format height display correctly', () {
      final height = Height(cm: 180);
      expect(height.displayHeight, contains('5\' 11"'));
      expect(height.displayHeight, contains('180cm'));
    });

    test('should handle null height for display', () {
      final height = Height();
      expect(height.displayHeight, equals('Not specified'));
    });
  });

  group('API Response Model Tests', () {
    test('should create NikkahApiResponse from JSON', () {
      final json = {
        'code': '200',
        'status': 'success',
        'message': 'Profile retrieved successfully',
        'nikkahProfile': {
          'id': 'profile-123',
          'name': 'John Doe',
          'gender': 'MALE',
        },
      };

      final response = NikkahApiResponse.fromJson(json);

      expect(response.code, equals('200'));
      expect(response.status, equals('success'));
      expect(response.message, equals('Profile retrieved successfully'));
      expect(response.nikkahProfile?.id, equals('profile-123'));
      expect(response.nikkahProfile?.name, equals('John Doe'));
    });

    test('should create ListNikkahProfilesResponse from JSON', () {
      final json = {
        'profiles': [
          {
            'id': 'profile-1',
            'name': 'John Doe',
            'gender': 'MALE',
          },
          {
            'id': 'profile-2',
            'name': 'Jane Doe',
            'gender': 'FEMALE',
          },
        ],
        'totalCount': 2,
        'currentPage': 1,
        'totalPages': 1,
      };

      final response = ListNikkahProfilesResponse.fromJson(json);

      expect(response.profiles?.length, equals(2));
      expect(response.totalCount, equals(2));
      expect(response.currentPage, equals(1));
      expect(response.totalPages, equals(1));
      expect(response.profiles?[0].name, equals('John Doe'));
      expect(response.profiles?[1].name, equals('Jane Doe'));
    });
  });
}
