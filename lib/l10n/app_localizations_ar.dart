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
}
