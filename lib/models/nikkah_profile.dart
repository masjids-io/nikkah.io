class NikkahProfile {
  final String? id;
  final String? userId;
  final String? name;
  final String? gender;
  final BirthDate? birthDate;
  final Location? location;
  final String? education;
  final String? occupation;
  final Height? height;
  final String? sect;
  final List<Picture>? pictures;
  final List<String>? hobbies;
  final String? createTime;
  final String? updateTime;

  NikkahProfile({
    this.id,
    this.userId,
    this.name,
    this.gender,
    this.birthDate,
    this.location,
    this.education,
    this.occupation,
    this.height,
    this.sect,
    this.pictures,
    this.hobbies,
    this.createTime,
    this.updateTime,
  });

  factory NikkahProfile.fromJson(Map<String, dynamic> json) {
    return NikkahProfile(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      gender: json['gender'],
      birthDate: json['birthDate'] != null 
          ? BirthDate.fromJson(json['birthDate']) 
          : null,
      location: json['location'] != null 
          ? Location.fromJson(json['location']) 
          : null,
      education: json['education'],
      occupation: json['occupation'],
      height: json['height'] != null 
          ? Height.fromJson(json['height']) 
          : null,
      sect: json['sect'],
      pictures: json['pictures'] != null 
          ? List<Picture>.from(json['pictures'].map((x) => Picture.fromJson(x)))
          : null,
      hobbies: json['hobbies'] != null 
          ? List<String>.from(json['hobbies'])
          : null,
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'gender': gender,
      'birthDate': birthDate?.toJson(),
      'location': location?.toJson(),
      'education': education,
      'occupation': occupation,
      'height': height?.toJson(),
      'sect': sect,
      'pictures': pictures?.map((x) => x.toJson()).toList(),
      'hobbies': hobbies,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  int? get age {
    if (birthDate?.year != null) {
      return DateTime.now().year - birthDate!.year!;
    }
    return null;
  }
}

class BirthDate {
  final int? year;
  final String? month;
  final int? day;

  BirthDate({
    this.year,
    this.month,
    this.day,
  });

  factory BirthDate.fromJson(Map<String, dynamic> json) {
    return BirthDate(
      year: json['year'],
      month: json['month'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }
}

class Location {
  final String? country;
  final String? city;
  final String? state;
  final String? zipCode;
  final int? latitude;
  final int? longitude;

  Location({
    this.country,
    this.city,
    this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get displayLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.isEmpty ? 'Location not specified' : parts.join(', ');
  }
}

class Height {
  final int? cm;

  Height({this.cm});

  factory Height.fromJson(Map<String, dynamic> json) {
    return Height(cm: json['cm']);
  }

  Map<String, dynamic> toJson() {
    return {'cm': cm};
  }

  String get displayHeight {
    if (cm == null) return 'Not specified';
    final feet = cm! ~/ 30.48;
    final inches = ((cm! % 30.48) / 2.54).round();
    return '$feet\' $inches" (${cm}cm)';
  }
}

class Picture {
  final String? image;
  final String? mimeType;

  Picture({this.image, this.mimeType});

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      image: json['image'],
      mimeType: json['mimeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'mimeType': mimeType,
    };
  }
}

// API Response Models
class NikkahApiResponse {
  final String? code;
  final String? status;
  final String? message;
  final NikkahProfile? nikkahProfile;
  final ListNikkahProfilesResponse? listProfilesResponse;

  NikkahApiResponse({
    this.code,
    this.status,
    this.message,
    this.nikkahProfile,
    this.listProfilesResponse,
  });

  factory NikkahApiResponse.fromJson(Map<String, dynamic> json) {
    return NikkahApiResponse(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      nikkahProfile: json['nikkahProfile'] != null 
          ? NikkahProfile.fromJson(json['nikkahProfile'])
          : null,
      listProfilesResponse: json['listProfilesResponse'] != null 
          ? ListNikkahProfilesResponse.fromJson(json['listProfilesResponse'])
          : null,
    );
  }
}

class ListNikkahProfilesResponse {
  final List<NikkahProfile>? profiles;
  final int? totalCount;
  final int? currentPage;
  final int? totalPages;

  ListNikkahProfilesResponse({
    this.profiles,
    this.totalCount,
    this.currentPage,
    this.totalPages,
  });

  factory ListNikkahProfilesResponse.fromJson(Map<String, dynamic> json) {
    return ListNikkahProfilesResponse(
      profiles: json['profiles'] != null 
          ? List<NikkahProfile>.from(
              json['profiles'].map((x) => NikkahProfile.fromJson(x)))
          : null,
      totalCount: json['totalCount'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
    );
  }
} 