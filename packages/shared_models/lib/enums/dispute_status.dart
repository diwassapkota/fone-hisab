enum DisputeStatus {
  pending,
  resolved,
  rejected,
}

extension DisputeStatusExtension on DisputeStatus {
  String get displayName {
    switch (this) {
      case DisputeStatus.pending:
        return 'Pending';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.rejected:
        return 'Rejected';
    }
  }

  String get nepaliName {
    switch (this) {
      case DisputeStatus.pending:
        return 'विचाराधीन';
      case DisputeStatus.resolved:
        return 'समाधान भयो';
      case DisputeStatus.rejected:
        return 'अस्वीकृत';
    }
  }
}
