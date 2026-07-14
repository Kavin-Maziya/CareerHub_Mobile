// Mirrors the CareerHub API's JobListResponse JSON exactly. Captures
// every field the API returns, including ones the Flutter UI doesn't currently show

class JobDto {
  final String id; 
  final String title;
  final String companyName;
  final String location;
  final String description;
  final DateTime postedAt;
  final String salaryDisplay; 
  final DateTime closingDate;
  final int applicationCount;
  final bool isActive;
  final String employmentType; 

  const JobDto({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.description,
    required this.postedAt,
    required this.salaryDisplay,
    required this.closingDate,
    required this.applicationCount,
    required this.isActive,
    required this.employmentType,
  });

  factory JobDto.fromJson(Map<String, dynamic> json) {
    return JobDto(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['companyName'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      salaryDisplay: json['salaryDisplay'] as String,
      closingDate: DateTime.parse(json['closingDate'] as String),
      applicationCount: json['applicationCount'] as int,
      isActive: json['isActive'] as bool,
      employmentType: json['employmentType'] as String,
    );
  }
}