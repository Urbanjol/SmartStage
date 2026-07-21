class UserModel{
  final String uid;
  final String name;
  final String phoneNumber; //primary key for MoMo
  final String role;
  final double rating;
  final String? profilePic;
  final String? taxiPlate;
  final String? referredBy; //this will be used to refer the app to others
  final int referralPoints; //this is the reward
  final bool isVerified;
  final Map<String,String> savedLocations; //for saving locations for easy accessibility

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.rating = 5.0,
    this.profilePic,
    this.taxiPlate,
    this.referredBy,
    this.referralPoints = 0,
    this.isVerified = false,
    required this.savedLocations,
  });
  //Convert to JSON to send to firebase
  Map<String,dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'phoneNumber': phoneNumber,
    'role': role,
    'rating': rating,
    'profilePic':profilePic,
    'taxiPlate': taxiPlate,
    'referredBy': referredBy,
    'referralPoints': referralPoints,
    'isVerified': isVerified,
    'savedLocations': savedLocations,
  };
//From json
  factory UserModel.fromMap(Map<String, dynamic>map){
   return UserModel(
     uid: map['uid'] ?? '',
     name: map['name'] ?? '',
     phoneNumber: map['phoneNumber'] ?? '',
     role: map['role'] ?? '',
     rating: (map['rating'] ?? 5.0).toDouble(),
     savedLocations: Map<String,String>.from(map['savedLocations'] ?? {}),
     //rating: map['rating'] ?? '',

   );
  }
}