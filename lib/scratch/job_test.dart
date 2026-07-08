// Standalone scratch file — proves the Job model works as specified
import 'package:careerhub_mobile/models/job.dart';

void main() {
  // 1. Fully populated, open job — salary present.

  final job1 = Job(
    title: 'Senior Frontend Software Engineer',
    company: 'TechCorp Cape Town', 
    location: 'Cape Town',
    description: 'We are looking for a talented Senior Frontend Engineer...',
    employmentType: 'Full-Time',
    isOpen: true,
    salary: 37500,
    closingDate: DateTime(2026, 7, 24),
  );

  // 2. Open job, all nullable fields omitted — salary undisclosed, no closing date.
  // salary/closingDate intentionally stripped here 
  //to demonstrate the "Market-related" fallback, since none
  final job2 = Job(
    title: 'UX/Web Designer',
    company: 'DesignHouse Sandton',
    location: 'Sandton',
    description: 'We are looking for a creative UX/Web Designer...',
    employmentType: 'Contract',
    isOpen: true,
    
  );

  // 3. Closed job via named constructor.
  
  final job3 = Job.closed(
    title: 'Data Analyst Intern',
    company: 'DataWorks Pretoria',
    location: 'Pretoria/Hybrid',
    description: 'We are looking for a Data Analyst Intern...',
    employmentType: 'Internship',
    salary: 18500, 
    closingDate: DateTime(2026, 6, 19), 
  );

  // 4. Remote job via named constructor.
  
  final job4 = Job.remote(
    title: 'Part-Time Content Writer/Promoter',
    company: 'MediaCo',
    description: 'We are looking for a Content Writer...',
    employmentType: 'Part-Time',
    isOpen: true,
    salary: 15000,
    closingDate: DateTime(2026, 7, 24),
  );

//Returns Jobs as an array data set
  final jobs = [job1, job2, job3, job4];

  for (final job in jobs) {
    print(job);
    print('  canApply: ${job.canApply}');
    print('  displaySalary: ${job.displaySalary}');
    print('---');
  }
}