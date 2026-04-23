// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق التبرع بالدم';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get donorDashboard => 'لوحة المتبرع';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get friend => 'صديقي';

  @override
  String get motivationTitle => 'اقتباس تحفيزي';

  @override
  String get bloodGroup => 'فصيلة الدم';

  @override
  String get city => 'المدينة';

  @override
  String get usersBloodRequests => 'طلبات الدم للمستخدمين';

  @override
  String get viewAllRequestsFromUsersAcross => 'عرض جميع طلبات المستخدمين';

  @override
  String get nearbyRequests => 'الطلبات القريبة';

  @override
  String get checkNearbyBloodRequests => 'تحقق من طلبات الدم القريبة';

  @override
  String get awareness => 'التوعية';

  @override
  String get awarenessDonorSubtitle => 'تبرع بثقة: نصائح وإرشادات أساسية';

  @override
  String get requestBlood => 'طلب دم';

  @override
  String get createNewBloodRequest => 'إنشاء طلب دم جديد';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get trackPreviousRequests => 'تابع طلباتك السابقة';

  @override
  String get nearbyDonors => 'المتبرعون القريبون';

  @override
  String get trackNearbyDonors => 'تابع جميع المتبرعين القريبين';

  @override
  String get awarenessUserSubtitle => 'تبرع بأمان: نصائح أساسية للمتبرعين';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get donorsTab => 'المتبرعون';

  @override
  String get profileTab => 'الملف الشخصي';

  @override
  String get allDonorsTab => 'كل المتبرعين';

  @override
  String get roleWhoAreYou => 'من أنت؟';

  @override
  String get roleSelectContinue => 'اختر دورك للمتابعة';

  @override
  String get roleDonor => 'متبرع';

  @override
  String get roleDonorSubtitle => 'أريد التبرع بالدم';

  @override
  String get roleUser => 'مستخدم';

  @override
  String get roleUserSubtitle => 'أحتاج دماً أو أريد تصفح المتبرعين';

  @override
  String get alreadyHaveAccountLogin => 'لديك حساب بالفعل؟ سجل الدخول';

  @override
  String get loginEnterEmailPassword => 'أدخل البريد الإلكتروني وكلمة المرور';

  @override
  String loginFailed(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get welcomeBack => 'مرحباً بعودتك 👋';

  @override
  String get loginToAccount => 'سجل الدخول إلى حسابك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get dontHaveAccountSignUp => 'ليس لديك حساب؟ أنشئ حساباً';

  @override
  String get signupFillAllFields => 'يرجى تعبئة جميع الحقول';

  @override
  String get signupValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get signupPasswordStrong =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل وتحتوي على أحرف وأرقام';

  @override
  String get accountCreated => 'تم إنشاء الحساب';

  @override
  String get signupFailed => 'فشل إنشاء الحساب';

  @override
  String get emailAlreadyInUse => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get createAccountTitle => 'إنشاء حساب 🩸';

  @override
  String get fillDetailsCreateAccount => 'املأ البيانات لإنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneWithCountryCode => 'رقم الهاتف (مع رمز الدولة)';

  @override
  String get enterCityOrVillage => 'أدخل المدينة أو القرية';

  @override
  String get selectLastDonationDate => 'اختر تاريخ آخر تبرع';

  @override
  String lastDonatedOn(String date) {
    return 'آخر تبرع: $date';
  }

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get requestFillRequiredFields => 'يرجى تعبئة جميع الحقول المطلوبة';

  @override
  String get requestSubmittedSuccessfully => 'تم إرسال الطلب بنجاح';

  @override
  String requestSubmittingError(String error) {
    return 'خطأ أثناء الإرسال: $error';
  }

  @override
  String get createBloodRequest => 'إنشاء طلب دم';

  @override
  String get patientName => 'اسم المريض';

  @override
  String get hospitalName => 'اسم المستشفى';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get units => 'الوحدات';

  @override
  String get whenBloodNeededTap => 'متى تحتاج الدم؟ (اضغط للاختيار)';

  @override
  String neededAtValue(String date) {
    return 'مطلوب في: $date';
  }

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get markAsDone => 'تحديد كمكتمل';

  @override
  String get confirmRequestFulfilled => 'هل أنت متأكد أن طلب الدم تم تلبيته؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get yesDone => 'نعم، مكتمل';

  @override
  String get myBloodRequests => 'طلبات دمي';

  @override
  String get noBloodRequestsFound => 'لم يتم العثور على طلبات دم';

  @override
  String hospitalLabel(String value) {
    return '🏥 المستشفى: $value';
  }

  @override
  String cityLabel(String value) {
    return '📍 المدينة: $value';
  }

  @override
  String phoneLabel(String value) {
    return '📞 الهاتف: $value';
  }

  @override
  String unitsLabel(String value) {
    return '💉 الوحدات: $value';
  }

  @override
  String neededAtLabel(String value) {
    return '🕒 المطلوب في: $value';
  }

  @override
  String requestedOnLabel(String value) {
    return '📅 تاريخ الطلب: $value';
  }

  @override
  String get unknownPatient => 'مريض غير معروف';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String genericError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get statusDone => 'مكتمل';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get account => 'الحساب';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get contactSupport => 'اتصل بالدعم';

  @override
  String get privacyLegal => 'الخصوصية والقانون';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsConditions => 'الشروط والأحكام';

  @override
  String get about => 'حول';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get enterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get currentPasswordIncorrect => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get passwordResetSent =>
      'تم إرسال بريد إلكتروني لإعادة تعيين كلمة المرور';

  @override
  String sendResetLinkTo(String email) {
    return 'إرسال رابط إعادة التعيين إلى $email';
  }

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get confirmSignOut => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get confirmDeleteAccount =>
      'سيؤدي هذا إلى حذف حسابك وبياناتك نهائيًا. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟';

  @override
  String get permanentlyDeleteData => 'حذف حسابك وبياناتك نهائيًا';

  @override
  String get confirmPasswordToDelete => 'أدخل كلمة المرور الحالية لحذف حسابك.';

  @override
  String get allRequestsDeleted => 'تم حذف جميع الطلبات بنجاح';

  @override
  String get resetAllRequests => 'إعادة تعيين جميع الطلبات';

  @override
  String get confirmResetRequests => 'هل أنت متأكد أنك تريد حذف جميع طلباتك؟';

  @override
  String get appPreferences => 'تفضيلات التطبيق';

  @override
  String get resetRequests => 'إعادة تعيين الطلبات';

  @override
  String get all => 'الكل';

  @override
  String get noPhoneNumber => 'لا يوجد رقم هاتف';

  @override
  String get cannotMakeCall => 'لا يمكن إجراء المكالمة';

  @override
  String get availableDonors => 'المتبرعون المتاحون';

  @override
  String get noDonorsFound => 'لم يتم العثور على متبرعين';

  @override
  String get unknown => 'غير معروف';

  @override
  String get quote1 => 'عملك البسيط قد ينقذ حياة.';

  @override
  String get quote2 => 'كن السبب في بقاء شخص ما على قيد الحياة اليوم.';

  @override
  String get quote3 => 'كل قطرة تهم — تبرع بالدم.';

  @override
  String get quote4 => 'إعطاء الدم هو إعطاء الأمل.';

  @override
  String get quote5 => 'الأبطال لا يرتدون عباءات، بل يتبرعون بالدم.';

  @override
  String get quote6 => 'يمكنك إحداث فرق اليوم.';

  @override
  String get quote7 => 'مكالمة واحدة، تبرع واحد، إنقاذ حياة واحدة.';

  @override
  String get donorDetails => 'تفاصيل المتبرع';

  @override
  String get donorNotFound => 'المتبرع غير موجود';

  @override
  String get unknownDonor => 'متبرع غير معروف';

  @override
  String bloodGroupLabel(String value) {
    return 'فصيلة الدم: $value';
  }

  @override
  String get phone => 'الهاتف';

  @override
  String get lastDonated => 'تاريخ آخر تبرع';

  @override
  String get availableToDonate => 'متاح للتبرع';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get callDonor => 'الاتصال بالمتبرع';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String get bloodDonor => 'متبرع بالدم';

  @override
  String get unknownCity => 'مدينة غير معروفة';

  @override
  String get name => 'الاسم';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get requiredField => 'حقل مطلوب';

  @override
  String get noNearbyRequests => 'لا توجد طلبات قريبة';

  @override
  String get call => 'اتصال';
}
