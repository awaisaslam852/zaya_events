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
  /// **'Zaya Events'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

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

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'I am planning an event'**
  String get roleCustomer;

  /// No description provided for @roleVendor.
  ///
  /// In en, this message translates to:
  /// **'I am a vendor'**
  String get roleVendor;

  /// No description provided for @businessNameEn.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessNameEn;

  /// No description provided for @businessNameAr.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessNameAr;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get myEvents;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get empty;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @venues.
  ///
  /// In en, this message translates to:
  /// **'Venues'**
  String get venues;

  /// No description provided for @vendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendors;

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// No description provided for @accommodations.
  ///
  /// In en, this message translates to:
  /// **'Stays'**
  String get accommodations;

  /// No description provided for @honeymoon.
  ///
  /// In en, this message translates to:
  /// **'Honeymoon'**
  String get honeymoon;

  /// No description provided for @flights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get flights;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @venueVisits.
  ///
  /// In en, this message translates to:
  /// **'Venue visits'**
  String get venueVisits;

  /// No description provided for @aiPlanner.
  ///
  /// In en, this message translates to:
  /// **'AI planner'**
  String get aiPlanner;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @vendorProfile.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get vendorProfile;

  /// No description provided for @callHistory.
  ///
  /// In en, this message translates to:
  /// **'Call history'**
  String get callHistory;

  /// No description provided for @incomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get incomingCall;

  /// No description provided for @outgoingCall.
  ///
  /// In en, this message translates to:
  /// **'Calling…'**
  String get outgoingCall;

  /// No description provided for @activeCall.
  ///
  /// In en, this message translates to:
  /// **'In call'**
  String get activeCall;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endCall;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @earpiece.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get earpiece;

  /// No description provided for @connectingCall.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connectingCall;

  /// No description provided for @ringingCall.
  ///
  /// In en, this message translates to:
  /// **'Ringing…'**
  String get ringingCall;

  /// No description provided for @encryptedCall.
  ///
  /// In en, this message translates to:
  /// **'Secure voice call'**
  String get encryptedCall;

  /// No description provided for @micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access'**
  String get micPermissionTitle;

  /// No description provided for @micPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow the microphone so the other person can hear you.'**
  String get micPermissionBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @adminRedirect.
  ///
  /// In en, this message translates to:
  /// **'Admin accounts use the web portal.'**
  String get adminRedirect;

  /// No description provided for @openAdmin.
  ///
  /// In en, this message translates to:
  /// **'Open admin portal'**
  String get openAdmin;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get offline;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get createEvent;

  /// No description provided for @inquire.
  ///
  /// In en, this message translates to:
  /// **'Inquire'**
  String get inquire;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get removeFavorite;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'New listing'**
  String get createListing;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publish;

  /// No description provided for @unpublish.
  ///
  /// In en, this message translates to:
  /// **'Unpublished'**
  String get unpublish;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get underReview;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @stubNotice.
  ///
  /// In en, this message translates to:
  /// **'Live partner search is not connected yet. Showing catalog stubs.'**
  String get stubNotice;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get upload;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get destination;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get typeMessage;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @listingTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get listingTitle;

  /// No description provided for @listingDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get listingDescription;

  /// No description provided for @startingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting price'**
  String get startingPrice;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @legalName.
  ///
  /// In en, this message translates to:
  /// **'Legal name'**
  String get legalName;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @requiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please add a title and choose a category.'**
  String get requiredFields;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saveSuccess;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose any language. Dates and layout follow your choice. English and Arabic have full translations; other languages use English for now.'**
  String get languageHint;

  /// No description provided for @searchLanguages.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get searchLanguages;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @searchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get searchCountries;

  /// No description provided for @chooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose country'**
  String get chooseCountry;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @checkYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Check your details'**
  String get checkYourDetails;

  /// No description provided for @fixHighlightedFields.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted fields and try again.'**
  String get fixHighlightedFields;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name.'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name.'**
  String get enterLastName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password of at least 8 characters.'**
  String get enterPassword;

  /// No description provided for @chooseCountryError.
  ///
  /// In en, this message translates to:
  /// **'Choose your country.'**
  String get chooseCountryError;

  /// No description provided for @enterBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name.'**
  String get enterBusinessName;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter your city.'**
  String get enterCity;

  /// No description provided for @enterVendorPhone.
  ///
  /// In en, this message translates to:
  /// **'Vendors need a phone number with at least 8 digits.'**
  String get enterVendorPhone;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try signing in.'**
  String get emailAlreadyUsed;

  /// No description provided for @enterLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterLoginPassword;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get eventTitle;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Event date'**
  String get eventDate;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @voiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCall;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @photosHint.
  ///
  /// In en, this message translates to:
  /// **'Add several photos. Tap one to zoom, or tap X to remove it.'**
  String get photosHint;

  /// No description provided for @removePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this photo?'**
  String get removePhotoTitle;

  /// No description provided for @removePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'It will be taken off this listing when you save.'**
  String get removePhotoMessage;

  /// No description provided for @coverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverPhoto;

  /// No description provided for @eventHub.
  ///
  /// In en, this message translates to:
  /// **'My event'**
  String get eventHub;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @eventEnd.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get eventEnd;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @preferredVenue.
  ///
  /// In en, this message translates to:
  /// **'Preferred venue type'**
  String get preferredVenue;

  /// No description provided for @budgetMin.
  ///
  /// In en, this message translates to:
  /// **'Budget min'**
  String get budgetMin;

  /// No description provided for @budgetMax.
  ///
  /// In en, this message translates to:
  /// **'Budget max'**
  String get budgetMax;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event details'**
  String get eventDetails;

  /// No description provided for @eventLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'One title is enough. Switch app language from Profile.'**
  String get eventLanguageHint;

  /// No description provided for @venueHall.
  ///
  /// In en, this message translates to:
  /// **'Hall'**
  String get venueHall;

  /// No description provided for @venueGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get venueGarden;

  /// No description provided for @venueBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get venueBeach;

  /// No description provided for @venueHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get venueHotel;

  /// No description provided for @venueVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get venueVilla;

  /// No description provided for @venueOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get venueOutdoor;

  /// No description provided for @venueRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get venueRestaurant;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @costOverview.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costOverview;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @willBook.
  ///
  /// In en, this message translates to:
  /// **'We will book this venue'**
  String get willBook;

  /// No description provided for @wontBook.
  ///
  /// In en, this message translates to:
  /// **'Not this venue'**
  String get wontBook;

  /// No description provided for @cancelVisit.
  ///
  /// In en, this message translates to:
  /// **'Cancel visit'**
  String get cancelVisit;

  /// No description provided for @modifyBooking.
  ///
  /// In en, this message translates to:
  /// **'Change dates'**
  String get modifyBooking;

  /// No description provided for @payDeposit.
  ///
  /// In en, this message translates to:
  /// **'Pay deposit'**
  String get payDeposit;

  /// No description provided for @payBalance.
  ///
  /// In en, this message translates to:
  /// **'Pay remaining balance'**
  String get payBalance;

  /// No description provided for @eventBrief.
  ///
  /// In en, this message translates to:
  /// **'Event brief'**
  String get eventBrief;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// No description provided for @guestPaid.
  ///
  /// In en, this message translates to:
  /// **'Guest paid'**
  String get guestPaid;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @vendorBookingHint.
  ///
  /// In en, this message translates to:
  /// **'Prepare for this date and guest count. Message the guest if anything is missing.'**
  String get vendorBookingHint;

  /// No description provided for @completeBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark this booking complete?'**
  String get completeBookingTitle;

  /// No description provided for @completeBookingMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this after you have hosted the event.'**
  String get completeBookingMessage;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get markComplete;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @searchFlights.
  ///
  /// In en, this message translates to:
  /// **'Search flights'**
  String get searchFlights;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get getDirections;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @justListed.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get justListed;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String fromPrice(String price);

  /// No description provided for @photoCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String photoCounter(String current, String total);

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(String count);

  /// No description provided for @bookFlight.
  ///
  /// In en, this message translates to:
  /// **'Book this flight'**
  String get bookFlight;

  /// No description provided for @departDate.
  ///
  /// In en, this message translates to:
  /// **'Departure date'**
  String get departDate;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Where is the celebration?'**
  String get searchHint;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @recommendedVenues.
  ///
  /// In en, this message translates to:
  /// **'Recommended venues'**
  String get recommendedVenues;

  /// No description provided for @recommendedCars.
  ///
  /// In en, this message translates to:
  /// **'Wedding cars'**
  String get recommendedCars;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Venues, vendors, cars and honeymoons — compare, enquire, book.'**
  String get tagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @partnerHub.
  ///
  /// In en, this message translates to:
  /// **'Partner hub'**
  String get partnerHub;

  /// No description provided for @partnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage listings, dates and incoming bookings.'**
  String get partnerSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try a demo account'**
  String get tryDemo;

  /// No description provided for @demoCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get demoCustomer;

  /// No description provided for @demoVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get demoVendor;

  /// No description provided for @apiHost.
  ///
  /// In en, this message translates to:
  /// **'API host for this session'**
  String get apiHost;

  /// No description provided for @useThisApi.
  ///
  /// In en, this message translates to:
  /// **'Use this API'**
  String get useThisApi;

  /// No description provided for @occupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get occupancy;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @recentBookings.
  ///
  /// In en, this message translates to:
  /// **'Recent bookings'**
  String get recentBookings;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;

  /// No description provided for @pendingRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'{count} requests waiting for a reply'**
  String pendingRequestsHint(String count);

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet. New enquiries will appear here.'**
  String get noBookingsYet;

  /// No description provided for @myCatalog.
  ///
  /// In en, this message translates to:
  /// **'My catalog'**
  String get myCatalog;

  /// No description provided for @catalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, edit and publish everything you sell.'**
  String get catalogSubtitle;

  /// No description provided for @catalogAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catalogAll;

  /// No description provided for @chooseListingType.
  ///
  /// In en, this message translates to:
  /// **'What are you adding?'**
  String get chooseListingType;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteItem;

  /// No description provided for @bookingHistory.
  ///
  /// In en, this message translates to:
  /// **'Booking history'**
  String get bookingHistory;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incoming;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentHistory;

  /// No description provided for @vehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get vehicleMake;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get vehicleModel;

  /// No description provided for @vehicleYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get vehicleYear;

  /// No description provided for @vehicleSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get vehicleSeats;

  /// No description provided for @transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @dailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily rate'**
  String get dailyRate;

  /// No description provided for @nightlyRate.
  ///
  /// In en, this message translates to:
  /// **'Nightly rate'**
  String get nightlyRate;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @tripDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get tripDestination;

  /// No description provided for @nightsCount.
  ///
  /// In en, this message translates to:
  /// **'Nights'**
  String get nightsCount;

  /// No description provided for @capacityMin.
  ///
  /// In en, this message translates to:
  /// **'Min guests'**
  String get capacityMin;

  /// No description provided for @capacityMax.
  ///
  /// In en, this message translates to:
  /// **'Max guests'**
  String get capacityMax;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @requestVisit.
  ///
  /// In en, this message translates to:
  /// **'Request a visit'**
  String get requestVisit;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @addToEvent.
  ///
  /// In en, this message translates to:
  /// **'Add to this event'**
  String get addToEvent;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @availabilitySent.
  ///
  /// In en, this message translates to:
  /// **'Availability request sent. Check Bookings for the demo reservation.'**
  String get availabilitySent;

  /// No description provided for @capacityGuests.
  ///
  /// In en, this message translates to:
  /// **'Capacity {min}–{max} guests'**
  String capacityGuests(String min, String max);

  /// No description provided for @eventsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your celebrations'**
  String get eventsHeadline;

  /// No description provided for @eventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan the day, then enquire and book vendors in one place.'**
  String get eventsSubtitle;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @noEventsHint.
  ///
  /// In en, this message translates to:
  /// **'Create an event, pick a date, then add venues, cars and stays.'**
  String get noEventsHint;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @pastEvents.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastEvents;

  /// No description provided for @eventToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get eventToday;

  /// No description provided for @daysToGo.
  ///
  /// In en, this message translates to:
  /// **'{count} days to go'**
  String daysToGo(String count);

  /// No description provided for @daysAgoLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgoLabel(String count);

  /// No description provided for @favoritesHeadline.
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get favoritesHeadline;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Venues, vendors and ideas you liked.'**
  String get favoritesSubtitle;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get noFavoritesYet;

  /// No description provided for @noFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a venue, car or stay to keep it here.'**
  String get noFavoritesHint;

  /// No description provided for @browseToSave.
  ///
  /// In en, this message translates to:
  /// **'Browse venues'**
  String get browseToSave;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @notificationsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get notificationsHeadline;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings, visits and messages about your event.'**
  String get notificationsSubtitle;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Booking updates, visit times and messages will show up here.'**
  String get noNotificationsHint;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(String count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(String count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookings;

  /// No description provided for @bookingsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your reservations'**
  String get bookingsHeadline;

  /// No description provided for @bookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track enquiries, deposits and confirmed dates.'**
  String get bookingsSubtitle;

  /// No description provided for @noBookingsHint.
  ///
  /// In en, this message translates to:
  /// **'Book a venue, car or stay and it will show up here.'**
  String get noBookingsHint;

  /// No description provided for @browseToBook.
  ///
  /// In en, this message translates to:
  /// **'Browse venues'**
  String get browseToBook;

  /// No description provided for @bookingRef.
  ///
  /// In en, this message translates to:
  /// **'Booking {number}'**
  String bookingRef(String number);

  /// No description provided for @planning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @askPlannerHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about venues, budget, guests or the timeline.'**
  String get askPlannerHint;

  /// No description provided for @noVisitsYet.
  ///
  /// In en, this message translates to:
  /// **'No venue visits yet'**
  String get noVisitsYet;

  /// No description provided for @noVisitsHint.
  ///
  /// In en, this message translates to:
  /// **'Request a visit from a venue page and it will appear here.'**
  String get noVisitsHint;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @noPaymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Deposits and balances you pay will show up here.'**
  String get noPaymentsHint;

  /// No description provided for @noCallsYet.
  ///
  /// In en, this message translates to:
  /// **'No calls yet'**
  String get noCallsYet;

  /// No description provided for @cartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review items, then checkout into bookings.'**
  String get cartSubtitle;

  /// No description provided for @paymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deposits, balances and receipts.'**
  String get paymentsSubtitle;

  /// No description provided for @visitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tour dates you requested with venues.'**
  String get visitsSubtitle;

  /// No description provided for @aiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas for the day, the budget and the guest list.'**
  String get aiSubtitle;

  /// No description provided for @flightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search and book travel around your event.'**
  String get flightsSubtitle;

  /// No description provided for @hotelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a stay for the wedding party.'**
  String get hotelsSubtitle;

  /// No description provided for @callsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Voice and video calls with vendors.'**
  String get callsSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language and app information.'**
  String get settingsSubtitle;

  /// No description provided for @paySecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay securely'**
  String get paySecurely;

  /// No description provided for @cardCheckoutHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your debit or credit card in Stripe’s secure sheet. Card details stay on this device and are never sent to Zaya.'**
  String get cardCheckoutHint;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccess;

  /// No description provided for @paymentCanceled.
  ///
  /// In en, this message translates to:
  /// **'Payment canceled'**
  String get paymentCanceled;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @introWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your event, one place'**
  String get introWelcomeTitle;

  /// No description provided for @introWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Find venues, vendors, cars and stays — then plan the day without jumping between apps.'**
  String get introWelcomeBody;

  /// No description provided for @introDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse what you need'**
  String get introDiscoverTitle;

  /// No description provided for @introDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'Compare halls, services, honeymoons and travel. Save favourites and request a venue visit in a tap.'**
  String get introDiscoverBody;

  /// No description provided for @introPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay the deposit in the app'**
  String get introPayTitle;

  /// No description provided for @introPayBody.
  ///
  /// In en, this message translates to:
  /// **'Secure card checkout stays on your phone. Pay the deposit now and the rest when you are ready.'**
  String get introPayBody;

  /// No description provided for @introConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk, visit, plan'**
  String get introConnectTitle;

  /// No description provided for @introConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Chat and call vendors, keep bookings in one list, and use the planner when you need ideas.'**
  String get introConnectBody;

  /// No description provided for @replayIntro.
  ///
  /// In en, this message translates to:
  /// **'See the intro again'**
  String get replayIntro;

  /// No description provided for @replayIntroHint.
  ///
  /// In en, this message translates to:
  /// **'Replay the welcome screens anytime.'**
  String get replayIntroHint;

  /// No description provided for @deleteCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing?'**
  String get deleteCatalogTitle;

  /// No description provided for @deleteCatalogMessage.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed from your catalog. This cannot be undone.'**
  String deleteCatalogMessage(String name);

  /// No description provided for @unpublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide from customers?'**
  String get unpublishTitle;

  /// No description provided for @unpublishMessage.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be unpublished and will no longer appear in search.'**
  String unpublishMessage(String name);

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get cancelBookingTitle;

  /// No description provided for @cancelBookingMessage.
  ///
  /// In en, this message translates to:
  /// **'The vendor will be notified. You may still be charged according to the booking terms.'**
  String get cancelBookingMessage;

  /// No description provided for @cancelVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this visit?'**
  String get cancelVisitTitle;

  /// No description provided for @cancelVisitMessage.
  ///
  /// In en, this message translates to:
  /// **'The venue will be told you are no longer coming on this date.'**
  String get cancelVisitMessage;

  /// No description provided for @removeCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from cart?'**
  String get removeCartTitle;

  /// No description provided for @removeCartMessage.
  ///
  /// In en, this message translates to:
  /// **'This item will be removed from your cart.'**
  String get removeCartMessage;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of Zaya?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime with the same account.'**
  String get logoutMessage;

  /// No description provided for @confirmRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm this booking?'**
  String get confirmRequestTitle;

  /// No description provided for @confirmRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'The customer will be notified that you have accepted the request.'**
  String get confirmRequestMessage;

  /// No description provided for @rejectRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this request?'**
  String get rejectRequestTitle;

  /// No description provided for @rejectRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'The customer will be told this booking is not available.'**
  String get rejectRequestMessage;

  /// No description provided for @willBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark this venue as booked?'**
  String get willBookTitle;

  /// No description provided for @willBookMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ll tell the venue you plan to book after the visit.'**
  String get willBookMessage;

  /// No description provided for @wontBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Pass on this venue?'**
  String get wontBookTitle;

  /// No description provided for @wontBookMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ll tell the venue you are not booking after the visit.'**
  String get wontBookMessage;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get keepBooking;

  /// No description provided for @keepVisit.
  ///
  /// In en, this message translates to:
  /// **'Keep visit'**
  String get keepVisit;

  /// No description provided for @staySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in'**
  String get staySignedIn;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @viewVenue.
  ///
  /// In en, this message translates to:
  /// **'View venue'**
  String get viewVenue;

  /// No description provided for @visitSchedule.
  ///
  /// In en, this message translates to:
  /// **'Visit time'**
  String get visitSchedule;

  /// No description provided for @visitHost.
  ///
  /// In en, this message translates to:
  /// **'Your host'**
  String get visitHost;

  /// No description provided for @visitWhatsNext.
  ///
  /// In en, this message translates to:
  /// **'What’s next'**
  String get visitWhatsNext;

  /// No description provided for @visitStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get visitStatusRequested;

  /// No description provided for @visitStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get visitStatusApproved;

  /// No description provided for @visitStatusRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get visitStatusRescheduled;

  /// No description provided for @visitStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get visitStatusConfirmed;

  /// No description provided for @visitStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get visitStatusCompleted;

  /// No description provided for @visitStatusDecided.
  ///
  /// In en, this message translates to:
  /// **'Decided'**
  String get visitStatusDecided;

  /// No description provided for @visitStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get visitStatusCancelled;

  /// No description provided for @visitStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get visitStatusNoShow;

  /// No description provided for @visitRequestedHint.
  ///
  /// In en, this message translates to:
  /// **'The venue has your request and will confirm this time.'**
  String get visitRequestedHint;

  /// No description provided for @visitApprovedHint.
  ///
  /// In en, this message translates to:
  /// **'The venue approved this tour. A host may still be assigned.'**
  String get visitApprovedHint;

  /// No description provided for @visitRescheduledHint.
  ///
  /// In en, this message translates to:
  /// **'This tour was moved to a new time.'**
  String get visitRescheduledHint;

  /// No description provided for @visitConfirmedHint.
  ///
  /// In en, this message translates to:
  /// **'Your visit is confirmed. Arrive a few minutes early.'**
  String get visitConfirmedHint;

  /// No description provided for @visitCompletedHint.
  ///
  /// In en, this message translates to:
  /// **'This tour is complete. Tell us if you will book.'**
  String get visitCompletedHint;

  /// No description provided for @visitDecidedHint.
  ///
  /// In en, this message translates to:
  /// **'You already shared your decision after this visit.'**
  String get visitDecidedHint;

  /// No description provided for @visitCancelledHint.
  ///
  /// In en, this message translates to:
  /// **'This visit was cancelled.'**
  String get visitCancelledHint;

  /// No description provided for @visitNoShowHint.
  ///
  /// In en, this message translates to:
  /// **'This visit was marked as a no-show.'**
  String get visitNoShowHint;

  /// No description provided for @acceptVisit.
  ///
  /// In en, this message translates to:
  /// **'Accept visit'**
  String get acceptVisit;

  /// No description provided for @acceptVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this visit?'**
  String get acceptVisitTitle;

  /// No description provided for @acceptVisitMessage.
  ///
  /// In en, this message translates to:
  /// **'The customer will be told this time works for your venue.'**
  String get acceptVisitMessage;

  /// No description provided for @completeVisit.
  ///
  /// In en, this message translates to:
  /// **'Mark visit complete'**
  String get completeVisit;

  /// No description provided for @completeVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark this visit complete?'**
  String get completeVisitTitle;

  /// No description provided for @completeVisitMessage.
  ///
  /// In en, this message translates to:
  /// **'The customer can then tell you if they will book the venue.'**
  String get completeVisitMessage;

  /// No description provided for @declineVisit.
  ///
  /// In en, this message translates to:
  /// **'Decline visit'**
  String get declineVisit;

  /// No description provided for @vendorVisitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers who asked to tour your venues.'**
  String get vendorVisitsSubtitle;

  /// No description provided for @vendorNoVisitsHint.
  ///
  /// In en, this message translates to:
  /// **'When a customer requests a visit, it appears here so you can accept it.'**
  String get vendorNoVisitsHint;

  /// No description provided for @visitGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get visitGuest;

  /// No description provided for @vendorRequestedHint.
  ///
  /// In en, this message translates to:
  /// **'Accept this time to confirm the tour, or decline if you cannot host.'**
  String get vendorRequestedHint;

  /// No description provided for @vendorApprovedHint.
  ///
  /// In en, this message translates to:
  /// **'The tour is accepted. After they visit, mark it complete.'**
  String get vendorApprovedHint;

  /// No description provided for @vendorConfirmedHint.
  ///
  /// In en, this message translates to:
  /// **'The tour is on. After they visit, mark it complete.'**
  String get vendorConfirmedHint;

  /// No description provided for @vendorCompletedHint.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the customer to say if they will book.'**
  String get vendorCompletedHint;

  /// No description provided for @visitAccepted.
  ///
  /// In en, this message translates to:
  /// **'Visit accepted'**
  String get visitAccepted;

  /// No description provided for @visitMarkedComplete.
  ///
  /// In en, this message translates to:
  /// **'Visit marked complete'**
  String get visitMarkedComplete;

  /// No description provided for @bookingInbox.
  ///
  /// In en, this message translates to:
  /// **'Booking inbox'**
  String get bookingInbox;

  /// No description provided for @bookingInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm or decline new enquiries. Confirmed jobs move to booking history.'**
  String get bookingInboxSubtitle;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get noPendingRequests;

  /// No description provided for @noPendingRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'New customer enquiries appear here. Confirmed bookings are in Booking history.'**
  String get noPendingRequestsHint;

  /// No description provided for @messageVendor.
  ///
  /// In en, this message translates to:
  /// **'Message vendor'**
  String get messageVendor;

  /// No description provided for @messageGuest.
  ///
  /// In en, this message translates to:
  /// **'Message guest'**
  String get messageGuest;

  /// No description provided for @priceToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Price to be confirmed'**
  String get priceToConfirm;

  /// No description provided for @pricingModel.
  ///
  /// In en, this message translates to:
  /// **'How is this priced?'**
  String get pricingModel;

  /// No description provided for @pricingHire.
  ///
  /// In en, this message translates to:
  /// **'Hall hire — one price for the event'**
  String get pricingHire;

  /// No description provided for @pricingPerGuest.
  ///
  /// In en, this message translates to:
  /// **'Per guest / per plate'**
  String get pricingPerGuest;

  /// No description provided for @pricingHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hire + optional guest packages'**
  String get pricingHybrid;

  /// No description provided for @pricePerGuest.
  ///
  /// In en, this message translates to:
  /// **'Price per guest'**
  String get pricePerGuest;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveReview;

  /// No description provided for @rateVendor.
  ///
  /// In en, this message translates to:
  /// **'Rate this vendor'**
  String get rateVendor;

  /// No description provided for @rateGuest.
  ///
  /// In en, this message translates to:
  /// **'Rate this guest'**
  String get rateGuest;

  /// No description provided for @rateVendorHint.
  ///
  /// In en, this message translates to:
  /// **'Reviews open after the booking is completed. Other guests will see this on the listing.'**
  String get rateVendorHint;

  /// No description provided for @rateGuestHint.
  ///
  /// In en, this message translates to:
  /// **'Reviews open after the booking is completed. This stays between you and the guest.'**
  String get rateGuestHint;

  /// No description provided for @reviewComment.
  ///
  /// In en, this message translates to:
  /// **'What stood out?'**
  String get reviewComment;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @starRating.
  ///
  /// In en, this message translates to:
  /// **'{rating} / 5'**
  String starRating(String rating);

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @reviewFromGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest review'**
  String get reviewFromGuest;

  /// No description provided for @reviewFromVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor review'**
  String get reviewFromVendor;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you for the review'**
  String get reviewSubmitted;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @guestReviews.
  ///
  /// In en, this message translates to:
  /// **'Guest reviews'**
  String get guestReviews;
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
