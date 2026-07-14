
import 'package:careerhub_mobile/data/job_dto.dart' as dto;

class Job {
  final String id; // changed from int -- API uses Guid, serialized as String
  final String title;
  final String company;
  final String location;
  final String description;
  final String employmentType;
  final bool isOpen;
  final String? salaryDisplay; // renamed from `salary` -- API already
                                // formats this server-side; the model no
                                // longer stores a raw number
  final DateTime? closingDate;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.employmentType,
    required this.isOpen,
    this.salaryDisplay,
    this.closingDate,
  });

  Job.closed({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.employmentType,
    this.salaryDisplay,
    this.closingDate,
  }) : isOpen = false;

  Job.remote({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.employmentType,
    required this.isOpen,
    this.salaryDisplay,
    this.closingDate,
  }) : location = 'Remote';

  // Maps the API's JobDto to the UI's Job. This factory is the
  // translation layer between the two naming conventions -- one side
  // uses the API's names (CompanyName, IsActive, SalaryDisplay), the
  // other uses the Flutter UI's names (company, isOpen, salaryDisplay).
  factory Job.fromDto(dto.JobDto d) {
    return Job(
      id: d.id,
      title: d.title,
      company: d.companyName, // API: CompanyName -> Flutter: company
      location: d.location,
      description: d.description,
      employmentType: d.employmentType,
      isOpen: d.isActive, // API: IsActive -> Flutter: isOpen
      // API: SalaryDisplay -> Flutter: salaryDisplay. 
      salaryDisplay:
          d.salaryDisplay.trim().isEmpty ? null : d.salaryDisplay,
      closingDate: d.closingDate,
    );
  }

  bool get canApply => isOpen;

  String get displaySalary => salaryDisplay ?? 'Market-related';

  @override
  String toString() {
    return 'Job(id: $id, title: $title, company: $company, location: $location, '
        'isOpen: $isOpen, salary: ${salaryDisplay ?? "confidential"}, '
        'closingDate: ${closingDate ?? "none"})';
  }
}