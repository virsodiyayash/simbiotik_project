class JobModel {
  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.description,
    required this.url,
  });

  final String id;
  final String title;
  final String companyName;
  final String location;
  final String description;
  final String url;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final String urlValue = (json['url'] ?? '').toString().trim();
    final String titleValue = (json['title'] ?? 'Untitled role').toString().trim();
    final String companyValue =
        (json['company_name'] ?? 'Unknown company').toString().trim();
    final String locationValue = (json['location'] ?? 'Unknown location').toString().trim();
    final String idValue = urlValue.isNotEmpty
      ? urlValue
      : '$titleValue-$companyValue-$locationValue';
    final String normalizedId = idValue.trim().toLowerCase();
    return JobModel(
      id: normalizedId,
      title: titleValue,
      companyName: companyValue,
      location: locationValue,
      description: (json['description'] ?? '').toString(),
      url: urlValue,
    );
  }
}
