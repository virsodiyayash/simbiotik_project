import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/job_model.dart';
import '../services/job_api_service.dart';

class JobController extends GetxController {
  JobController({required JobApiService apiService}) : _apiService = apiService;

  static const String _bookmarksKey = 'bookmarked_job_ids';

  final JobApiService _apiService;

  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> bookmarkedIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<JobModel> get filteredJobs {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return jobs;
    }

    return jobs.where((JobModel job) {
      return job.title.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _loadBookmarks();
    fetchJobs();
  }

  Future<void> _loadBookmarks() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> savedIds = preferences.getStringList(_bookmarksKey) ?? <String>[];
    final List<String> normalized = savedIds.map((String s) => s.trim().toLowerCase()).toList(growable: false);
    bookmarkedIds.assignAll(normalized);
  }

  Future<void> _saveBookmarks() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_bookmarksKey, bookmarkedIds.toList());
  }

  Future<void> fetchJobs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<JobModel> loadedJobs = await _apiService.fetchJobs();
      jobs.assignAll(loadedJobs);
      await _reconcileBookmarksWithJobs();
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _reconcileBookmarksWithJobs() async {
    if (bookmarkedIds.isEmpty || jobs.isEmpty) {
      return;
    }

    final List<String> saved = bookmarkedIds.toList(growable: false);
    final List<String> resolved = <String>[];

    for (final String sid in saved) {
      final String s = sid.trim().toLowerCase();
      final JobModel? match = jobs.firstWhereOrNull((JobModel j) =>
          j.id == s || j.url.trim().toLowerCase() == s ||
          ('${j.title}-${j.companyName}-${j.location}').trim().toLowerCase() == s);

      if (match != null) {
        resolved.add(match.id);
      }
    }

    if (resolved.isNotEmpty) {
      bookmarkedIds.assignAll(resolved);
      await _saveBookmarks();
    }
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  // Future<void> toggleBookmark(String jobId) async {
  //   final String nid = jobId.trim().toLowerCase();
  //   if (bookmarkedIds.contains(nid)) {
  //     bookmarkedIds.remove(nid);
  //   } else {
  //     bookmarkedIds.add(nid);
  //   }

  //   bookmarkedIds.refresh();
  //   await _saveBookmarks();
  // }

  /// Toggles bookmark for a job using multiple normalized id forms.
  Future<void> toggleBookmarkForJob(JobModel job) async {
    final String id = job.id.trim().toLowerCase();
    final String url = job.url.trim().toLowerCase();
    final String constructed = ('${job.title}-${job.companyName}-${job.location}').trim().toLowerCase();

    // Determine if any form is already bookmarked
    final bool exists = bookmarkedIds.contains(id) || bookmarkedIds.contains(url) || bookmarkedIds.contains(constructed);

    if (exists) {
      // remove all matching forms
      bookmarkedIds.removeWhere((String s) => s == id || s == url || s == constructed);
    } else {
      // add canonical id
      bookmarkedIds.add(id);
    }

    bookmarkedIds.refresh();
    await _saveBookmarks();
  }

  // bool isBookmarked(String jobId) {
  //   return bookmarkedIds.contains(jobId.trim().toLowerCase());
  // }

  bool isBookmarkedForJob(JobModel job) {
    final String id = job.id.trim().toLowerCase();
    final String url = job.url.trim().toLowerCase();
    final String constructed = ('${job.title}-${job.companyName}-${job.location}').trim().toLowerCase();

    return bookmarkedIds.contains(id) || bookmarkedIds.contains(url) || bookmarkedIds.contains(constructed);
  }
}
