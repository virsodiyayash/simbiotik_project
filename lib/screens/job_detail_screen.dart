import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/job_controller.dart';
import '../models/job_model.dart';

class JobDetailScreen extends GetView<JobController> {
  const JobDetailScreen({super.key, required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Detail'),
        actions: <Widget>[
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleBookmarkForJob(job),
              icon: Icon(
                controller.isBookmarkedForJob(job)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: controller.isBookmarkedForJob(job)
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF7A8FB7),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                job.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _TagChip(icon: Icons.business, label: job.companyName),
                  _TagChip(icon: Icons.location_on, label: job.location),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _cleanDescription(job.description),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: const Color(0xFF334155),
                    ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _openSourceUrl(job.url),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Apply Now'),
          ),
        ),
      ),
    );
  }

  Future<void> _openSourceUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Invalid URL', 'This job post has an invalid apply link.');
      return;
    }

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      Get.snackbar('Unable to open', 'Could not launch the job URL.');
    }
  }

  String _cleanDescription(String value) {
    final String withBreaks = value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    final String withoutTags = withBreaks.replaceAll(RegExp(r'<[^>]*>'), '');

    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: const Color(0xFF315DA8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF315DA8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
