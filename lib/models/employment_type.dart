
enum EmploymentType {
  fullTime,
  partTime,
  contract,
  internship;

  // Switch expression -- maps each enum value to its user-facing label.
  // The analyzer verifies this is exhaustive: adding a new enum value
  // without a matching case here is a compile error, not a runtime bug.

  String get displayName => switch (this) {
        EmploymentType.fullTime => 'Full-Time',
        EmploymentType.partTime => 'Part-Time',
        EmploymentType.contract => 'Contract',
        EmploymentType.internship => 'Internship',
      };

  // Parses the API's raw PascalCase value into the enum.
  // This is where the real the API's naming and the Flutter model's
  // naming no longer have to agree by coincidence.

  static EmploymentType fromApiValue(String value) => switch (value) {
        'FullTime' => EmploymentType.fullTime,
        'PartTime' => EmploymentType.partTime,
        'Contract' => EmploymentType.contract,
        'Internship' => EmploymentType.internship,
        _ => throw ArgumentError('Unknown employment type: $value'),
      };
}