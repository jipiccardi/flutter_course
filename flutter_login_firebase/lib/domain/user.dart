class MyUser {
  final String id;
  final String email;
  final String name;
  final String photoUrl;

  MyUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl = '',
  });

  factory MyUser.fromMap(Map<String, dynamic> data) {
    return MyUser(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
