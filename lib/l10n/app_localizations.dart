import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Donation App'**
  String get appTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @donorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Donor Dashboard'**
  String get donorDashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @motivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Motivational Quote'**
  String get motivationTitle;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @usersBloodRequests.
  ///
  /// In en, this message translates to:
  /// **'Users Blood Requests'**
  String get usersBloodRequests;

  /// No description provided for @viewAllRequestsFromUsersAcross.
  ///
  /// In en, this message translates to:
  /// **'View all requests from users across'**
  String get viewAllRequestsFromUsersAcross;

  /// No description provided for @nearbyRequests.
  ///
  /// In en, this message translates to:
  /// **'Nearby Requests'**
  String get nearbyRequests;

  /// No description provided for @checkNearbyBloodRequests.
  ///
  /// In en, this message translates to:
  /// **'Check nearby blood requests'**
  String get checkNearbyBloodRequests;

  /// No description provided for @awareness.
  ///
  /// In en, this message translates to:
  /// **'Awareness'**
  String get awareness;

  /// No description provided for @awarenessDonorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Donate with confidence: Essential tips and guidelines'**
  String get awarenessDonorSubtitle;

  /// No description provided for @requestBlood.
  ///
  /// In en, this message translates to:
  /// **'Request Blood'**
  String get requestBlood;

  /// No description provided for @createNewBloodRequest.
  ///
  /// In en, this message translates to:
  /// **'Create a new blood request'**
  String get createNewBloodRequest;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @trackPreviousRequests.
  ///
  /// In en, this message translates to:
  /// **'Track your previous requests'**
  String get trackPreviousRequests;

  /// No description provided for @nearbyDonors.
  ///
  /// In en, this message translates to:
  /// **'Nearby Donors'**
  String get nearbyDonors;

  /// No description provided for @trackNearbyDonors.
  ///
  /// In en, this message translates to:
  /// **'Track all your nearby donors'**
  String get trackNearbyDonors;

  /// No description provided for @awarenessUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Safe, Donate Safe: Essential Tips for Blood Donors'**
  String get awarenessUserSubtitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @donorsTab.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get donorsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @allDonorsTab.
  ///
  /// In en, this message translates to:
  /// **'All donors'**
  String get allDonorsTab;

  /// No description provided for @roleWhoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get roleWhoAreYou;

  /// No description provided for @roleSelectContinue.
  ///
  /// In en, this message translates to:
  /// **'Select your role to continue'**
  String get roleSelectContinue;

  /// No description provided for @roleDonor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get roleDonor;

  /// No description provided for @roleDonorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I want to donate blood'**
  String get roleDonorSubtitle;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @roleUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I need blood or browse donors'**
  String get roleUserSubtitle;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @loginEnterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter email & password'**
  String get loginEnterEmailPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get welcomeBack;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dontHaveAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccountSignUp;

  /// No description provided for @signupFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get signupFillAllFields;

  /// No description provided for @signupValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get signupValidEmail;

  /// No description provided for @signupPasswordStrong.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters and include letters & numbers'**
  String get signupPasswordStrong;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreated;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account 🩸'**
  String get createAccountTitle;

  /// No description provided for @fillDetailsCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Fill details to create an account'**
  String get fillDetailsCreateAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneWithCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Phone (with country code)'**
  String get phoneWithCountryCode;

  /// No description provided for @enterCityOrVillage.
  ///
  /// In en, this message translates to:
  /// **'Enter city or village'**
  String get enterCityOrVillage;

  /// No description provided for @selectLastDonationDate.
  ///
  /// In en, this message translates to:
  /// **'Select last donation date'**
  String get selectLastDonationDate;

  /// No description provided for @lastDonatedOn.
  ///
  /// In en, this message translates to:
  /// **'Last donated: {date}'**
  String lastDonatedOn(String date);

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @requestFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get requestFillRequiredFields;

  /// No description provided for @requestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get requestSubmittedSuccessfully;

  /// No description provided for @requestSubmittingError.
  ///
  /// In en, this message translates to:
  /// **'Error submitting: {error}'**
  String requestSubmittingError(String error);

  /// No description provided for @createBloodRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Blood Request'**
  String get createBloodRequest;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get hospitalName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @whenBloodNeededTap.
  ///
  /// In en, this message translates to:
  /// **'When is blood needed? (tap to select)'**
  String get whenBloodNeededTap;

  /// No description provided for @neededAtValue.
  ///
  /// In en, this message translates to:
  /// **'Needed: {date}'**
  String neededAtValue(String date);

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get markAsDone;

  /// No description provided for @confirmRequestFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Are you sure this blood request is fulfilled?'**
  String get confirmRequestFulfilled;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yesDone.
  ///
  /// In en, this message translates to:
  /// **'Yes, Done'**
  String get yesDone;

  /// No description provided for @myBloodRequests.
  ///
  /// In en, this message translates to:
  /// **'My Blood Requests'**
  String get myBloodRequests;

  /// No description provided for @noBloodRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No blood requests found'**
  String get noBloodRequestsFound;

  /// No description provided for @hospitalLabel.
  ///
  /// In en, this message translates to:
  /// **'🏥 Hospital: {value}'**
  String hospitalLabel(String value);

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'📍 City: {value}'**
  String cityLabel(String value);

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'📞 Phone: {value}'**
  String phoneLabel(String value);

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'💉 Units: {value}'**
  String unitsLabel(String value);

  /// No description provided for @neededAtLabel.
  ///
  /// In en, this message translates to:
  /// **'🕒 Needed At: {value}'**
  String neededAtLabel(String value);

  /// No description provided for @requestedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'📅 Requested On: {value}'**
  String requestedOnLabel(String value);

  /// No description provided for @unknownPatient.
  ///
  /// In en, this message translates to:
  /// **'Unknown Patient'**
  String get unknownPatient;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(String error);

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @privacyLegal.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Legal'**
  String get privacyLegal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetSent;

  /// No description provided for @sendResetLinkTo.
  ///
  /// In en, this message translates to:
  /// **'Send reset link to {email}'**
  String sendResetLinkTo(String email);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and data. This action cannot be undone. Are you sure?'**
  String get confirmDeleteAccount;

  /// No description provided for @permanentlyDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get permanentlyDeleteData;

  /// No description provided for @confirmPasswordToDelete.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to delete your account.'**
  String get confirmPasswordToDelete;

  /// No description provided for @allRequestsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All requests deleted successfully'**
  String get allRequestsDeleted;

  /// No description provided for @resetAllRequests.
  ///
  /// In en, this message translates to:
  /// **'Reset All Requests'**
  String get resetAllRequests;

  /// No description provided for @confirmResetRequests.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all your requests?'**
  String get confirmResetRequests;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @resetRequests.
  ///
  /// In en, this message translates to:
  /// **'Reset Requests'**
  String get resetRequests;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhoneNumber;

  /// No description provided for @cannotMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Cannot make call'**
  String get cannotMakeCall;

  /// No description provided for @availableDonors.
  ///
  /// In en, this message translates to:
  /// **'Available Donors'**
  String get availableDonors;

  /// No description provided for @noDonorsFound.
  ///
  /// In en, this message translates to:
  /// **'No donors found'**
  String get noDonorsFound;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'Your single act can save lives.'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'Be the reason someone survives today.'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'Every drop counts — donate blood.'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In en, this message translates to:
  /// **'Giving blood is giving hope.'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In en, this message translates to:
  /// **'Heroes don’t wear capes, they donate blood.'**
  String get quote5;

  /// No description provided for @quote6.
  ///
  /// In en, this message translates to:
  /// **'You can make a difference today.'**
  String get quote6;

  /// No description provided for @quote7.
  ///
  /// In en, this message translates to:
  /// **'One call, one donation, one life saved.'**
  String get quote7;

  /// No description provided for @donorDetails.
  ///
  /// In en, this message translates to:
  /// **'Donor Details'**
  String get donorDetails;

  /// No description provided for @donorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Donor not found'**
  String get donorNotFound;

  /// No description provided for @unknownDonor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Donor'**
  String get unknownDonor;

  /// No description provided for @bloodGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood Group: {value}'**
  String bloodGroupLabel(String value);

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'phone'**
  String get phone;

  /// No description provided for @lastDonated.
  ///
  /// In en, this message translates to:
  /// **'Last Donated'**
  String get lastDonated;

  /// No description provided for @availableToDonate.
  ///
  /// In en, this message translates to:
  /// **'Available to Donate'**
  String get availableToDonate;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @callDonor.
  ///
  /// In en, this message translates to:
  /// **'Call Donor'**
  String get callDonor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
