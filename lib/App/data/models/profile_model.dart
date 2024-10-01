// lib/app/models/profile.dart
class Profile {
  String? brandName;
  String? mobileNumber;
  String? imagePath;

  Profile({this.brandName, this.mobileNumber, this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'brand_name': brandName,
      'mobile_number': mobileNumber,
      'image_path': imagePath, // Add image path to map
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      brandName: map['brand_name'],
      mobileNumber: map['mobile_number'],
      imagePath: map['image_path'], // Retrieve image path from map
    );
  }
}
