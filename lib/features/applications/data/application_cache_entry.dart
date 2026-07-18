// Isar collection for caching job applications on-device.
// SEPARATE class from JobApplication (the domain model) -- this is
// a database row, not a business concept. Status is stored as a plain
// String, not the enum directly, since Isar's @enumerated storage
// couples the schema to the enum's exact declaration order, which is
// fragile; storing the API's raw string and re-parsing via
// ApplicationStatus.fromApiValue on read keeps the schema decoupled.

import 'package:isar_community/isar.dart';

part 'application_cache_entry.g.dart';

@collection
class ApplicationCacheEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String applicationId; 

  late String jobTitle;
  late DateTime submittedAt;
  late String status; 
}