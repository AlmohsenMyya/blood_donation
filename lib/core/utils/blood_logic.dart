class BloodLogic {
  static const List<String> allTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  /// Returns a list of blood types that can DONATE to the given recipient type.
  /// Use this when a Recipient is searching for Donors.
  static List<String> getCompatibleDonors(String recipientType) {
    switch (recipientType) {
      case 'AB+':
        return allTypes;
      case 'AB-':
        return ['AB-', 'A-', 'B-', 'O-'];
      case 'A+':
        return ['A+', 'A-', 'O+', 'O-'];
      case 'A-':
        return ['A-', 'O-'];
      case 'B+':
        return ['B+', 'B-', 'O+', 'O-'];
      case 'B-':
        return ['B-', 'O-'];
      case 'O+':
        return ['O+', 'O-'];
      case 'O-':
        return ['O-'];
      default:
        return [recipientType];
    }
  }

  /// Returns a list of blood types that can RECEIVE from the given donor type.
  /// Use this when a Donor is searching for Requests/Recipients.
  static List<String> getCompatibleRecipients(String donorType) {
    switch (donorType) {
      case 'O-':
        return allTypes;
      case 'O+':
        return ['O+', 'A+', 'B+', 'AB+'];
      case 'A-':
        return ['A-', 'A+', 'AB-', 'AB+'];
      case 'A+':
        return ['A+', 'AB+'];
      case 'B-':
        return ['B-', 'B+', 'AB-', 'AB+'];
      case 'B+':
        return ['B+', 'AB+'];
      case 'AB-':
        return ['AB-', 'AB+'];
      case 'AB+':
        return ['AB+'];
      default:
        return [donorType];
    }
  }

  /// Checks if two types are perfectly matched
  static bool isPerfectMatch(String type1, String type2) {
    return type1 == type2;
  }
}
