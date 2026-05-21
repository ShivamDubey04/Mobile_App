import 'dart:convert';
import 'package:c_app/course/model/course_model.dart';
import 'package:http/http.dart' as http;


class ApiServices {
  Future<List<Course>> getCourses() async {
    final response = await http.get(
      Uri.parse('https://69920a5f8f29113acd3d0c68.mockapi.io/banner'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => Course.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

    Future<List<Course>> getAllCourses() async {
    final response = await http.get(
      Uri.parse('https://69920a5f8f29113acd3d0c68.mockapi.io/banner'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => Course.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }
}