// Core domain model for a CareerHub job listing.

class Job {
  // Required fields always present for a valid job listing.
   final int id; // stable identifier
  final String title;
  final String company;
  final String location;
  final String description;
  final String employmentType;
  final bool isOpen;
  // Nullable fields
  final double? salary;
  final DateTime? closingDate;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.employmentType,
    required this.isOpen,
    this.salary,
    this.closingDate,
  });

  // Named constructor: represents a job that is closed,
  Job.closed({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.employmentType,
    this.salary,
    this.closingDate,
  }) : isOpen = false;

  // Named constructor: represents a remote listing. Pre-fills location
  // consistently so remote jobs aren't scattered across variant strings
  Job.remote({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.employmentType,
    required this.isOpen,
    this.salary,
    this.closingDate,
  }) : location = 'Remote';

//returns true only if the job is in a state a JobSeeker can apply to  
  bool get canApply => isOpen;

  // Single source of truth for how salary is displayed. The widget layer
  // must never touch the raw `salary` field directly — it calls this instead.
  String get displaySalary {
    if (salary == null) {
      return 'Market-related';
    }
    return 'R${salary!.toStringAsFixed(0)} per month';
  }

  @override
  String toString() {
    return 'Job(id: $id, title: $title, company: $company, location: $location, '
        'isOpen: $isOpen, salary: ${salary ?? "confidential"}, '
        'closingDate: ${closingDate ?? "none"})';
  }
}