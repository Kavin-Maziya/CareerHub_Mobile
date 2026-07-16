enum ApplicationStatus {
  submitted,
  underReview,
  shortlisted,
  offered,
  rejected;

  String get displayLabel => switch (this) {
        ApplicationStatus.submitted => 'Submitted',
        ApplicationStatus.underReview => 'Under Review',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.offered => 'Offered',
        ApplicationStatus.rejected => 'Rejected',
      };

  static ApplicationStatus fromApiValue(String value) => switch (value) {
        'Submitted' => ApplicationStatus.submitted,
        'UnderReview' => ApplicationStatus.underReview,
        'Shortlisted' => ApplicationStatus.shortlisted,
        'Offered' => ApplicationStatus.offered,
        'Rejected' => ApplicationStatus.rejected,
        _ => throw ArgumentError('Unknown application status: $value'),
      };
}