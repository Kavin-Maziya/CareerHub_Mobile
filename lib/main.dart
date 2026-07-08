// lib/main.dart

import 'package:flutter/material.dart';
import 'package:careerhub_mobile/models/job.dart';
import 'package:careerhub_mobile/widgets/job_card.dart';

void main() {
  runApp(const CareerHubApp());
}

class CareerHubApp extends StatelessWidget {
  const CareerHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B36), // custom deep teal
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Job> _jobs = [

    //Job 1 - Fully populated, open job.
    Job(
      title: 'Senior Frontend Software Engineer',
      company: 'TechCorp Cape Town',
      location: 'Cape Town',
      description: 'We are looking for a talented Senior Frontend Engineer...',
      employmentType: 'Full-Time',
      isOpen: true,
      salary: 37500,
      closingDate: DateTime(2026, 7, 24),
    ),

    // Job 2 - Open job, no salary disclosed, no closing date.
    Job(
      title: 'UX/Web Designer',
      company: 'DesignHouse Sandton',
      location: 'Sandton',
      description: 'We are looking for a creative UX/Web Designer...',
      employmentType: 'Contract',
      isOpen: true,
    ),

    // Job 3 - Closed job via named constructor.
    Job.closed(
      title: 'Data Analyst Intern',
      company: 'DataWorks Pretoria',
      location: 'Pretoria/Hybrid',
      description: 'We are looking for a Data Analyst Intern...',
      employmentType: 'Internship',
      salary: 18500,
      closingDate: DateTime(2026, 6, 19),
    ),

    // Job 4 - Remote job via named constructor.
    Job.remote(
      title: 'Part-Time Content Writer/Promoter',
      company: 'MediaCo',
      description: 'We are looking for a Content Writer...',
      employmentType: 'Part-Time',
      isOpen: true,
      salary: 15000,
      closingDate: DateTime(2026, 7, 24),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerHub'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _jobs.length,
        itemBuilder: (context, index) => JobCard(job: _jobs[index]),
      ),
    );
  }
}