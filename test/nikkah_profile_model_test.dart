import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';

void main() {
  group('NikkahProfile Model Tests', () {
    group('NikkahProfile', () {
      test('should create NikkahProfile with all fields', () {
        final profile = NikkahProfile(
          id: 'profile-123',
          userId: 'user-456',
          name: 'John Doe',
          gender: 'MALE',
          birthDate: BirthDate(year: 1995, month: 'JANUARY', day: 15),
          location: Location(
            country: 'USA',
            city: 'New York',
            state: 'NY',
            zipCode: '10001',
            latitude: 40,
            longitude: -74,
          ),
          education: 'BACHELOR',
          occupation: 'Software Engineer',
          height: Height(cm: 180),
          sect: 'SUNNI',
          pictures: [
            Picture(image: 'base64-image-data', mimeType: 'image/jpeg'),
          ],
          hobbies: ['READING', 'TRAVELING'],
          createTime: '2024-01-01T00:00:00Z',
          updateTime: '2024-01-01T00:00:00Z',
        );

        expect(profile.id, equals('profile-123'));
        expect(profile.userId, equals('user-456'));
        expect(profile.name, equals('John Doe'));
        expect(profile.gender, equals('MALE'));
        expect(profile.education, equals('BACHELOR'));
        expect(profile.occupation, equals('Software Engineer'));
        expect(profile.sect, equals('SUNNI'));
        expect(profile.hobbies, equals(['READING', 'TRAVELING']));
        expect(profile.createTime, equals('2024-01-01T00:00:00Z'));
        expect(profile.updateTime, equals('2024-01-01T00:00:00Z'));
      });

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
          'pictures': [
            {
              'image': 'base64-image-data',
              'mimeType': 'image/jpeg',
            },
          ],
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
        expect(profile.pictures?.length, equals(1));
        expect(profile.pictures?[0].mimeType, equals('image/jpeg'));
      });

      test('should convert NikkahProfile to JSON', () {
        final profile = NikkahProfile(
          id: 'profile-123',
          name: 'John Doe',
          gender: 'MALE',
          birthDate: BirthDate(year: 1995, month: 'JANUARY', day: 15),
          location: Location(city: 'New York', country: 'USA'),
          education: 'BACHELOR',
          occupation: 'Software Engineer',
          height: Height(cm: 180),
          sect: 'SUNNI',
          hobbies: ['READING', 'TRAVELING'],
        );

        final json = profile.toJson();

        expect(json['id'], equals('profile-123'));
        expect(json['name'], equals('John Doe'));
        expect(json['gender'], equals('MALE'));
        expect(json['birthDate']['year'], equals(1995));
        expect(json['location']['city'], equals('New York'));
        expect(json['education'], equals('BACHELOR'));
        expect(json['occupation'], equals('Software Engineer'));
        expect(json['height']['cm'], equals(180));
        expect(json['sect'], equals('SUNNI'));
        expect(json['hobbies'], equals(['READING', 'TRAVELING']));
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

      test('should handle missing fields gracefully', () {
        final profile = NikkahProfile.fromJson({});

        expect(profile.id, isNull);
        expect(profile.name, isNull);
        expect(profile.gender, isNull);
        expect(profile.birthDate, isNull);
        expect(profile.location, isNull);
        expect(profile.education, isNull);
        expect(profile.occupation, isNull);
        expect(profile.height, isNull);
        expect(profile.sect, isNull);
        expect(profile.hobbies, isNull);
        expect(profile.pictures, isNull);
      });
    });

    group('BirthDate', () {
      test('should create BirthDate with all fields', () {
        final birthDate = BirthDate(
          year: 1995,
          month: 'JANUARY',
          day: 15,
        );

        expect(birthDate.year, equals(1995));
        expect(birthDate.month, equals('JANUARY'));
        expect(birthDate.day, equals(15));
      });

      test('should create BirthDate from JSON', () {
        final json = {
          'year': 1995,
          'month': 'JANUARY',
          'day': 15,
        };

        final birthDate = BirthDate.fromJson(json);

        expect(birthDate.year, equals(1995));
        expect(birthDate.month, equals('JANUARY'));
        expect(birthDate.day, equals(15));
      });

      test('should convert BirthDate to JSON', () {
        final birthDate = BirthDate(
          year: 1995,
          month: 'JANUARY',
          day: 15,
        );

        final json = birthDate.toJson();

        expect(json['year'], equals(1995));
        expect(json['month'], equals('JANUARY'));
        expect(json['day'], equals(15));
      });
    });

    group('Location', () {
      test('should create Location with all fields', () {
        final location = Location(
          country: 'USA',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          latitude: 40,
          longitude: -74,
        );

        expect(location.country, equals('USA'));
        expect(location.city, equals('New York'));
        expect(location.state, equals('NY'));
        expect(location.zipCode, equals('10001'));
        expect(location.latitude, equals(40));
        expect(location.longitude, equals(-74));
      });

      test('should create Location from JSON', () {
        final json = {
          'country': 'USA',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'latitude': 40,
          'longitude': -74,
        };

        final location = Location.fromJson(json);

        expect(location.country, equals('USA'));
        expect(location.city, equals('New York'));
        expect(location.state, equals('NY'));
        expect(location.zipCode, equals('10001'));
        expect(location.latitude, equals(40));
        expect(location.longitude, equals(-74));
      });

      test('should convert Location to JSON', () {
        final location = Location(
          country: 'USA',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          latitude: 40,
          longitude: -74,
        );

        final json = location.toJson();

        expect(json['country'], equals('USA'));
        expect(json['city'], equals('New York'));
        expect(json['state'], equals('NY'));
        expect(json['zipCode'], equals('10001'));
        expect(json['latitude'], equals(40));
        expect(json['longitude'], equals(-74));
      });

      test('should format display location correctly', () {
        final location = Location(
          country: 'USA',
          city: 'New York',
          state: 'NY',
        );

        expect(location.displayLocation, equals('New York, NY, USA'));
      });

      test('should handle partial location data', () {
        final location = Location(
          city: 'New York',
          country: 'USA',
        );

        expect(location.displayLocation, equals('New York, USA'));
      });

      test('should handle empty location for display', () {
        final location = Location();
        expect(location.displayLocation, equals('Location not specified'));
      });

      test('should handle null values in location', () {
        final location = Location(
          city: 'New York',
          state: null,
          country: null,
        );

        expect(location.displayLocation, equals('New York'));
      });
    });

    group('Height', () {
      test('should create Height with cm value', () {
        final height = Height(cm: 180);
        expect(height.cm, equals(180));
      });

      test('should create Height from JSON', () {
        final json = {'cm': 180};
        final height = Height.fromJson(json);
        expect(height.cm, equals(180));
      });

      test('should convert Height to JSON', () {
        final height = Height(cm: 180);
        final json = height.toJson();
        expect(json['cm'], equals(180));
      });

      test('should format height display correctly', () {
        final height = Height(cm: 180);
        final display = height.displayHeight;
        expect(display, contains('5\' 11"'));
        expect(display, contains('180cm'));
      });

      test('should handle null height for display', () {
        final height = Height();
        expect(height.displayHeight, equals('Not specified'));
      });

      test('should handle different height values', () {
        final height1 = Height(cm: 150);
        final height2 = Height(cm: 200);

        expect(height1.displayHeight, contains('150cm'));
        expect(height2.displayHeight, contains('200cm'));
      });
    });

    group('Picture', () {
      test('should create Picture with image and mime type', () {
        final picture = Picture(
          image: 'base64-image-data',
          mimeType: 'image/jpeg',
        );

        expect(picture.image, equals('base64-image-data'));
        expect(picture.mimeType, equals('image/jpeg'));
      });

      test('should create Picture from JSON', () {
        final json = {
          'image': 'base64-image-data',
          'mimeType': 'image/jpeg',
        };

        final picture = Picture.fromJson(json);

        expect(picture.image, equals('base64-image-data'));
        expect(picture.mimeType, equals('image/jpeg'));
      });

      test('should convert Picture to JSON', () {
        final picture = Picture(
          image: 'base64-image-data',
          mimeType: 'image/jpeg',
        );

        final json = picture.toJson();

        expect(json['image'], equals('base64-image-data'));
        expect(json['mimeType'], equals('image/jpeg'));
      });
    });

    group('API Response Models', () {
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

      test('should handle empty response data', () {
        final json = {
          'code': '200',
          'status': 'success',
          'message': 'No profiles found',
        };

        final response = NikkahApiResponse.fromJson(json);

        expect(response.code, equals('200'));
        expect(response.status, equals('success'));
        expect(response.message, equals('No profiles found'));
        expect(response.nikkahProfile, isNull);
        expect(response.listProfilesResponse, isNull);
      });
    });
  });
} 