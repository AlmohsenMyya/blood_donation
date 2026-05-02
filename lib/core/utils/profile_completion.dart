class ProfileSection {
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final int weight;
  final bool isComplete;
  final bool requiresHospital;

  const ProfileSection({
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.weight,
    required this.isComplete,
    this.requiresHospital = false,
  });
}

class ProfileCompletion {
  static const int basicWeight = 20;
  static const int healthWeight = 20;
  static const int medicalWeight = 15;
  static const int emergencyWeight = 10;
  static const int verifiedWeight = 35;

  static int calculate(Map<String, dynamic> data) {
    int score = 0;
    if (basicComplete(data)) score += basicWeight;
    if (healthComplete(data)) score += healthWeight;
    if (medicalComplete(data)) score += medicalWeight;
    if (emergencyComplete(data)) score += emergencyWeight;
    if (bloodVerified(data)) score += verifiedWeight;
    return score;
  }

  static bool basicComplete(Map<String, dynamic> d) =>
      _filled(d['name']) &&
      _filled(d['phone']) &&
      _filled(d['city']) &&
      _filled(d['bloodGroup']);

  static bool healthComplete(Map<String, dynamic> d) =>
      d['height'] != null &&
      d['weight'] != null &&
      _filled(d['gender']) &&
      _filled(d['smokingStatus']);

  static bool medicalComplete(Map<String, dynamic> d) =>
      _filled(d['lastDonated']);

  static bool emergencyComplete(Map<String, dynamic> d) =>
      _filled(d['emergencyContactName']) &&
      _filled(d['emergencyContactPhone']);

  static bool bloodVerified(Map<String, dynamic> d) =>
      d['bloodGroupVerified'] == true;

  static bool _filled(dynamic v) =>
      v != null && v.toString().trim().isNotEmpty;

  static List<ProfileSection> getSections(Map<String, dynamic> data) {
    return [
      ProfileSection(
        titleEn: 'Basic Information',
        titleAr: 'المعلومات الأساسية',
        subtitleEn: 'Name, phone, city, blood group',
        subtitleAr: 'الاسم، الهاتف، المدينة، زمرة الدم',
        weight: basicWeight,
        isComplete: basicComplete(data),
      ),
      ProfileSection(
        titleEn: 'Health Profile',
        titleAr: 'البيانات الصحية',
        subtitleEn: 'Height, weight, gender, smoking status',
        subtitleAr: 'الطول، الوزن، الجنس، حالة التدخين',
        weight: healthWeight,
        isComplete: healthComplete(data),
      ),
      ProfileSection(
        titleEn: 'Medical History',
        titleAr: 'السجل الطبي',
        subtitleEn: 'Last donation date, diseases, allergies',
        subtitleAr: 'تاريخ آخر تبرع، الأمراض المزمنة، الحساسية',
        weight: medicalWeight,
        isComplete: medicalComplete(data),
      ),
      ProfileSection(
        titleEn: 'Emergency Contact',
        titleAr: 'جهة الاتصال الطارئة',
        subtitleEn: 'Trusted person name and phone number',
        subtitleAr: 'اسم وهاتف شخص موثوق للطوارئ',
        weight: emergencyWeight,
        isComplete: emergencyComplete(data),
      ),
      ProfileSection(
        titleEn: 'Blood Group Verification',
        titleAr: 'توثيق زمرة الدم',
        subtitleEn: 'Verified by hospital staff via QR scan',
        subtitleAr: 'موثق من قِبل المستشفى عبر مسح الرمز',
        weight: verifiedWeight,
        isComplete: bloodVerified(data),
        requiresHospital: true,
      ),
    ];
  }
}
