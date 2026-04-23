// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Blood Donation App';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get donorDashboard => 'Donor Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get friend => 'Friend';

  @override
  String get motivationTitle => 'Motivational Quote';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get city => 'City';

  @override
  String get usersBloodRequests => 'Users Blood Requests';

  @override
  String get viewAllRequestsFromUsersAcross =>
      'View all requests from users across';

  @override
  String get nearbyRequests => 'Nearby Requests';

  @override
  String get checkNearbyBloodRequests => 'Check nearby blood requests';

  @override
  String get awareness => 'Awareness';

  @override
  String get awarenessDonorSubtitle =>
      'Donate with confidence: Essential tips and guidelines';

  @override
  String get requestBlood => 'Request Blood';

  @override
  String get createNewBloodRequest => 'Create a new blood request';

  @override
  String get myRequests => 'My Requests';

  @override
  String get trackPreviousRequests => 'Track your previous requests';

  @override
  String get nearbyDonors => 'Nearby Donors';

  @override
  String get trackNearbyDonors => 'Track all your nearby donors';

  @override
  String get awarenessUserSubtitle =>
      'Stay Safe, Donate Safe: Essential Tips for Blood Donors';

  @override
  String get homeTab => 'Home';

  @override
  String get donorsTab => 'Donors';

  @override
  String get profileTab => 'Profile';

  @override
  String get allDonorsTab => 'All donors';

  @override
  String get roleWhoAreYou => 'Who are you?';

  @override
  String get roleSelectContinue => 'Select your role to continue';

  @override
  String get roleDonor => 'Donor';

  @override
  String get roleDonorSubtitle => 'I want to donate blood';

  @override
  String get roleUser => 'User';

  @override
  String get roleUserSubtitle => 'I need blood or browse donors';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get loginEnterEmailPassword => 'Enter email & password';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get welcomeBack => 'Welcome Back 👋';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccountSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get signupFillAllFields => 'Please fill all fields';

  @override
  String get signupValidEmail => 'Please enter a valid email';

  @override
  String get signupPasswordStrong =>
      'Password must be at least 6 characters and include letters & numbers';

  @override
  String get accountCreated => 'Account created';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get emailAlreadyInUse => 'Email already in use';

  @override
  String get createAccountTitle => 'Create Account 🩸';

  @override
  String get fillDetailsCreateAccount => 'Fill details to create an account';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneWithCountryCode => 'Phone (with country code)';

  @override
  String get enterCityOrVillage => 'Enter city or village';

  @override
  String get selectLastDonationDate => 'Select last donation date';

  @override
  String lastDonatedOn(String date) {
    return 'Last donated: $date';
  }

  @override
  String get signUp => 'Sign Up';

  @override
  String get requestFillRequiredFields => 'Please fill all required fields';

  @override
  String get requestSubmittedSuccessfully => 'Request submitted successfully';

  @override
  String requestSubmittingError(String error) {
    return 'Error submitting: $error';
  }

  @override
  String get createBloodRequest => 'Create Blood Request';

  @override
  String get patientName => 'Patient Name';

  @override
  String get hospitalName => 'Hospital Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get units => 'Units';

  @override
  String get whenBloodNeededTap => 'When is blood needed? (tap to select)';

  @override
  String neededAtValue(String date) {
    return 'Needed: $date';
  }

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get markAsDone => 'Mark as Done';

  @override
  String get confirmRequestFulfilled =>
      'Are you sure this blood request is fulfilled?';

  @override
  String get cancel => 'Cancel';

  @override
  String get yesDone => 'Yes, Done';

  @override
  String get myBloodRequests => 'My Blood Requests';

  @override
  String get noBloodRequestsFound => 'No blood requests found';

  @override
  String hospitalLabel(String value) {
    return '🏥 Hospital: $value';
  }

  @override
  String cityLabel(String value) {
    return '📍 City: $value';
  }

  @override
  String phoneLabel(String value) {
    return '📞 Phone: $value';
  }

  @override
  String unitsLabel(String value) {
    return '💉 Units: $value';
  }

  @override
  String neededAtLabel(String value) {
    return '🕒 Needed At: $value';
  }

  @override
  String requestedOnLabel(String value) {
    return '📅 Requested On: $value';
  }

  @override
  String get unknownPatient => 'Unknown Patient';

  @override
  String get notAvailable => 'N/A';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get statusDone => 'Done';

  @override
  String get statusPending => 'Pending';

  @override
  String get account => 'Account';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get privacyLegal => 'Privacy & Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About App';

  @override
  String get changePassword => 'Change Password';

  @override
  String get enterCurrentPassword => 'Enter current password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get passwordUpdated => 'Password updated successfully';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordResetSent => 'Password reset email sent';

  @override
  String sendResetLinkTo(String email) {
    return 'Send reset link to $email';
  }

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmSignOut => 'Are you sure you want to sign out?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get confirmDeleteAccount =>
      'This will permanently delete your account and data. This action cannot be undone. Are you sure?';

  @override
  String get permanentlyDeleteData =>
      'Permanently delete your account and data';

  @override
  String get confirmPasswordToDelete =>
      'Enter your current password to delete your account.';

  @override
  String get allRequestsDeleted => 'All requests deleted successfully';

  @override
  String get resetAllRequests => 'Reset All Requests';

  @override
  String get confirmResetRequests =>
      'Are you sure you want to delete all your requests?';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get resetRequests => 'Reset Requests';

  @override
  String get all => 'All';

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String get cannotMakeCall => 'Cannot make call';

  @override
  String get availableDonors => 'Available Donors';

  @override
  String get noDonorsFound => 'No donors found';

  @override
  String get unknown => 'Unknown';

  @override
  String get quote1 => 'Your single act can save lives.';

  @override
  String get quote2 => 'Be the reason someone survives today.';

  @override
  String get quote3 => 'Every drop counts — donate blood.';

  @override
  String get quote4 => 'Giving blood is giving hope.';

  @override
  String get quote5 => 'Heroes don’t wear capes, they donate blood.';

  @override
  String get quote6 => 'You can make a difference today.';

  @override
  String get quote7 => 'One call, one donation, one life saved.';

  @override
  String get donorDetails => 'Donor Details';

  @override
  String get donorNotFound => 'Donor not found';

  @override
  String get unknownDonor => 'Unknown Donor';

  @override
  String bloodGroupLabel(String value) {
    return 'Blood Group: $value';
  }

  @override
  String get phone => 'Phone';

  @override
  String get lastDonated => 'Last Donated';

  @override
  String get availableToDonate => 'Available to Donate';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get callDonor => 'Call Donor';

  @override
  String get myProfile => 'My Profile';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get bloodDonor => 'Blood Donor';

  @override
  String get unknownCity => 'Unknown City';

  @override
  String get name => 'Name';

  @override
  String get accountType => 'Account Type';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get requiredField => 'Required field';

  @override
  String get noNearbyRequests => 'No nearby requests';

  @override
  String get call => 'Call';

  @override
  String get unableToDetectCity => 'Unable to detect your city.';

  @override
  String noDonorsFoundInCity(String city) {
    return 'No donors found in $city';
  }
}
