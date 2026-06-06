import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/job_model.dart';

class JobApiService {
  static final Uri _endpoint =
      Uri.parse('https://www.arbeitnow.com/api/job-board-api');

  Future<List<JobModel>> fetchJobs() async {
    try {
      final http.Response response =
          await http.get(_endpoint).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Unable to load jobs right now.');
      }

      final dynamic payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        throw Exception('Unexpected response format.');
      }

      final dynamic rawData = payload['data'];
      if (rawData is! List) {
        throw Exception('Jobs payload is unavailable.');
      }

      return rawData
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList(growable: false);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on FormatException {
      throw Exception('Received malformed job data.');
    }
  }
}
