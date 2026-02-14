class DocumentItem {
  final int id;
  final String title;
  final String type;
  final String size;
  final String uploadedBy;
  final String fileUrl;

  DocumentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.size,
    required this.uploadedBy,
    required this.fileUrl,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] ?? 0,
      title: json['media_name'] ?? 'Unknown',
      type: json['media_type'] ?? 'Unknown',
      size: '0kb', // Size is not provided in the API response based on previous knowledge, setting default
      uploadedBy: 'Unknown', // Uploader is not provided in the API response based on previous knowledge, setting default
      fileUrl: json['file'] ?? '',
    );
  }
}
