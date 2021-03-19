import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'course_mock.g.dart';

@JsonLiteral('data/course_response.json')
String get courseResponse => json.encode(_$courseResponseJsonLiteral);

const getCoursesLink = '''
<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="current",<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="next",<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="first",<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="last"
''';

@JsonLiteral('data/course_response_2.json')
String get courseResponse2 => json.encode(_$courseResponse2JsonLiteral);

const getCoursesLink2 = '''
<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="current",<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="prev",<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="first",<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="last"
''';

@JsonLiteral('data/single_course.json')
String get singleCourse => json.encode(_$singleCourseJsonLiteral);
