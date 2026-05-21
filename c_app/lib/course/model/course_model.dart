class Course {
  final String id;
  final String imageUrl;
  final String title;
  final String instructor;
  final String duration;
  final String level;
  final String category;
  final int lessons;
  final int students;
  final double rating;
  final bool isNew;
  final bool isTrending;

  Course({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.level,
    required this.category,
    required this.lessons,
    required this.students,
    required this.rating,
    this.isNew = false,
    this.isTrending = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      duration: json['duration'] ?? '',
      level: json['level'] ?? '',
      category: json['category'] ?? '',
      lessons: json['lessons'] ?? 0,
      students: json['students'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      isNew: json['isNew'] ?? false,
      isTrending: json['isTrending'] ?? false,
    );
  }
}