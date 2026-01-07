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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @emailReq.
  ///
  /// In en, this message translates to:
  /// **'Please Enter User Name'**
  String get emailReq;

  /// No description provided for @passReqField.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Password'**
  String get passReqField;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @selectedLangEng.
  ///
  /// In en, this message translates to:
  /// **'En'**
  String get selectedLangEng;

  /// No description provided for @selectedLangArb.
  ///
  /// In en, this message translates to:
  /// **'Ar'**
  String get selectedLangArb;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get dailyReminders;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @alreadyOppened.
  ///
  /// In en, this message translates to:
  /// **'Already Opened'**
  String get alreadyOppened;

  /// No description provided for @dateConflict.
  ///
  /// In en, this message translates to:
  /// **'Date Conflict'**
  String get dateConflict;

  /// No description provided for @timeConflict.
  ///
  /// In en, this message translates to:
  /// **'Time Conflict'**
  String get timeConflict;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'There is an Network Error!'**
  String get networkError;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show Details'**
  String get showDetails;

  /// No description provided for @error400.
  ///
  /// In en, this message translates to:
  /// **'There is something wrong'**
  String get error400;

  /// No description provided for @error401.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get error401;

  /// No description provided for @error405.
  ///
  /// In en, this message translates to:
  /// **'This transaction cannot be completed due to an incorrect request'**
  String get error405;

  /// No description provided for @error500.
  ///
  /// In en, this message translates to:
  /// **'The process could not be completed due to a server error'**
  String get error500;

  /// No description provided for @error406.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get error406;

  /// No description provided for @error204.
  ///
  /// In en, this message translates to:
  /// **'No User Found'**
  String get error204;

  /// No description provided for @error404.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get error404;

  /// No description provided for @error200.
  ///
  /// In en, this message translates to:
  /// **'Changes updated Successfully'**
  String get error200;

  /// No description provided for @worningPassOrEmeail.
  ///
  /// In en, this message translates to:
  /// **'Wrong password or email'**
  String get worningPassOrEmeail;

  /// No description provided for @wrongInput.
  ///
  /// In en, this message translates to:
  /// **'Please verify your password or email'**
  String get wrongInput;

  /// No description provided for @accountAlreadyLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'This account was logged in previously, do you want to log out from all accounts?'**
  String get accountAlreadyLoggedIn;

  /// No description provided for @systemSetup.
  ///
  /// In en, this message translates to:
  /// **'System Setup'**
  String get systemSetup;

  /// No description provided for @listOfCategories.
  ///
  /// In en, this message translates to:
  /// **'list of categories'**
  String get listOfCategories;

  /// No description provided for @listOfDepartment.
  ///
  /// In en, this message translates to:
  /// **'list of department'**
  String get listOfDepartment;

  /// No description provided for @addDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get addDepartment;

  /// No description provided for @listOfReminders.
  ///
  /// In en, this message translates to:
  /// **'list of reminders'**
  String get listOfReminders;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @documentExplorer.
  ///
  /// In en, this message translates to:
  /// **'Document Explorer'**
  String get documentExplorer;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocument;

  /// No description provided for @searchByContnet.
  ///
  /// In en, this message translates to:
  /// **'Search By Contnet'**
  String get searchByContnet;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'notes'**
  String get notes;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// No description provided for @viewUser.
  ///
  /// In en, this message translates to:
  /// **'View user'**
  String get viewUser;

  /// No description provided for @userCategories.
  ///
  /// In en, this message translates to:
  /// **'User Categories'**
  String get userCategories;

  /// No description provided for @addUserCategories.
  ///
  /// In en, this message translates to:
  /// **'Add User Categories'**
  String get addUserCategories;

  /// No description provided for @viewUserCategories.
  ///
  /// In en, this message translates to:
  /// **'View User Categories'**
  String get viewUserCategories;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @freezeColumnToStart.
  ///
  /// In en, this message translates to:
  /// **'Freeze to start'**
  String get freezeColumnToStart;

  /// No description provided for @freezeColumnToEnd.
  ///
  /// In en, this message translates to:
  /// **'Freeze to end'**
  String get freezeColumnToEnd;

  /// No description provided for @autoFit.
  ///
  /// In en, this message translates to:
  /// **'Auto Fit'**
  String get autoFit;

  /// No description provided for @hideColumn.
  ///
  /// In en, this message translates to:
  /// **'Hide column'**
  String get hideColumn;

  /// No description provided for @setColumns.
  ///
  /// In en, this message translates to:
  /// **'Set columns'**
  String get setColumns;

  /// No description provided for @setFilter.
  ///
  /// In en, this message translates to:
  /// **'Set filter'**
  String get setFilter;

  /// No description provided for @resetFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset filter'**
  String get resetFilter;

  /// No description provided for @tableColumn.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get tableColumn;

  /// No description provided for @equals.
  ///
  /// In en, this message translates to:
  /// **'Equals'**
  String get equals;

  /// No description provided for @startsWith.
  ///
  /// In en, this message translates to:
  /// **'Starts with'**
  String get startsWith;

  /// No description provided for @endsWith.
  ///
  /// In en, this message translates to:
  /// **'EndsWith'**
  String get endsWith;

  /// No description provided for @greaterThan.
  ///
  /// In en, this message translates to:
  /// **'Greater than'**
  String get greaterThan;

  /// No description provided for @greaterThanOrEqual.
  ///
  /// In en, this message translates to:
  /// **'Greater than or equal to'**
  String get greaterThanOrEqual;

  /// No description provided for @lessThan.
  ///
  /// In en, this message translates to:
  /// **'Less than'**
  String get lessThan;

  /// No description provided for @lessThanOrEqual.
  ///
  /// In en, this message translates to:
  /// **'Less than or equal to'**
  String get lessThanOrEqual;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get value;

  /// No description provided for @contains.
  ///
  /// In en, this message translates to:
  /// **'contains'**
  String get contains;

  /// No description provided for @autoFitAllColumns.
  ///
  /// In en, this message translates to:
  /// **'Auto Fit All Columns'**
  String get autoFitAllColumns;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'refresh'**
  String get refresh;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'edit'**
  String get edit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'view'**
  String get view;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export To Excel'**
  String get exportToExcel;

  /// No description provided for @advanceSearch.
  ///
  /// In en, this message translates to:
  /// **'Advance Search'**
  String get advanceSearch;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get delete;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @txtShortcode.
  ///
  /// In en, this message translates to:
  /// **'Short Code'**
  String get txtShortcode;

  /// No description provided for @txtDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get txtDescription;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'Total Count'**
  String get totalCount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done successfully'**
  String get done;

  /// No description provided for @addDoneSucess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addDoneSucess;

  /// No description provided for @pleaseAddAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please add all required fields'**
  String get pleaseAddAllRequiredFields;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @sureToDeleteThisCat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that you want to delete this node?'**
  String get sureToDeleteThisCat;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add Action'**
  String get addAction;

  /// No description provided for @startDateAfterEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date should be after Start Date'**
  String get startDateAfterEndDate;

  /// No description provided for @startTimeAfterEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time should be after Start Time'**
  String get startTimeAfterEndTime;

  /// No description provided for @validDay.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid day'**
  String get validDay;

  /// No description provided for @validMonth.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid month'**
  String get validMonth;

  /// No description provided for @validDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid date'**
  String get validDate;

  /// No description provided for @editDep.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get editDep;

  /// No description provided for @editDoneSucess.
  ///
  /// In en, this message translates to:
  /// **'Edited successfully'**
  String get editDoneSucess;

  /// No description provided for @areYouSureToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete  {name}?'**
  String areYouSureToDelete(Object name);

  /// No description provided for @areYouSureToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout'**
  String get areYouSureToLogOut;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit Action'**
  String get editAction;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @issueNo.
  ///
  /// In en, this message translates to:
  /// **'Issue No'**
  String get issueNo;

  /// No description provided for @arrivalDate.
  ///
  /// In en, this message translates to:
  /// **'Arrival Date'**
  String get arrivalDate;

  /// No description provided for @keyWords.
  ///
  /// In en, this message translates to:
  /// **'Key Words'**
  String get keyWords;

  /// No description provided for @contractType.
  ///
  /// In en, this message translates to:
  /// **'contract Type'**
  String get contractType;

  /// No description provided for @ref1.
  ///
  /// In en, this message translates to:
  /// **'Reference 1'**
  String get ref1;

  /// No description provided for @ref2.
  ///
  /// In en, this message translates to:
  /// **'Reference 2'**
  String get ref2;

  /// No description provided for @otherRef.
  ///
  /// In en, this message translates to:
  /// **'Other Reference'**
  String get otherRef;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'organization'**
  String get organization;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'following'**
  String get following;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'classification'**
  String get classification;

  /// No description provided for @keyword.
  ///
  /// In en, this message translates to:
  /// **'keyword'**
  String get keyword;

  /// No description provided for @sortedBy.
  ///
  /// In en, this message translates to:
  /// **'Sorted By'**
  String get sortedBy;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

  /// No description provided for @documentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document Details'**
  String get documentDetails;

  /// No description provided for @editDocumentDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Document Details'**
  String get editDocumentDetails;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'download'**
  String get download;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// No description provided for @notActive.
  ///
  /// In en, this message translates to:
  /// **'Not Active'**
  String get notActive;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @userStatus.
  ///
  /// In en, this message translates to:
  /// **'User Status'**
  String get userStatus;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'manager'**
  String get manager;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get user;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'admin'**
  String get admin;

  /// No description provided for @userCode.
  ///
  /// In en, this message translates to:
  /// **'User Code'**
  String get userCode;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'user Type '**
  String get userType;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @editPassword.
  ///
  /// In en, this message translates to:
  /// **'Edit Password'**
  String get editPassword;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @chooseListOfDepartment.
  ///
  /// In en, this message translates to:
  /// **'Choose list of Department'**
  String get chooseListOfDepartment;

  /// No description provided for @updateUserCat.
  ///
  /// In en, this message translates to:
  /// **'Update User Categories'**
  String get updateUserCat;

  /// No description provided for @expiredSessionLoginDialog.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired.please log in again'**
  String get expiredSessionLoginDialog;

  /// No description provided for @pleaseSelectCat.
  ///
  /// In en, this message translates to:
  /// **'Please Select Category'**
  String get pleaseSelectCat;

  /// No description provided for @oldPass.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPass;

  /// No description provided for @newPass.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPass;

  /// No description provided for @wrongPass.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPass;

  /// No description provided for @emptyFields.
  ///
  /// In en, this message translates to:
  /// **'Empty Fields'**
  String get emptyFields;

  /// No description provided for @fillDepField.
  ///
  /// In en, this message translates to:
  /// **'Please fill department field'**
  String get fillDepField;

  /// No description provided for @fillCatField.
  ///
  /// In en, this message translates to:
  /// **'Please fill category field'**
  String get fillCatField;

  /// No description provided for @fillFileUpload.
  ///
  /// In en, this message translates to:
  /// **'Please add a file'**
  String get fillFileUpload;

  /// No description provided for @fillDescField.
  ///
  /// In en, this message translates to:
  /// **'Please fill description field'**
  String get fillDescField;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillRequiredFields;

  /// No description provided for @previewFile.
  ///
  /// In en, this message translates to:
  /// **'Preview File'**
  String get previewFile;

  /// No description provided for @previewNotAvilable.
  ///
  /// In en, this message translates to:
  /// **'Preview Not Avilable'**
  String get previewNotAvilable;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @refNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get refNumber;

  /// No description provided for @userRefName.
  ///
  /// In en, this message translates to:
  /// **'User Reference Name'**
  String get userRefName;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'Url'**
  String get url;

  /// No description provided for @scanFile.
  ///
  /// In en, this message translates to:
  /// **'Scan File'**
  String get scanFile;

  /// No description provided for @scanners.
  ///
  /// In en, this message translates to:
  /// **'Scanners'**
  String get scanners;

  /// No description provided for @noSpacesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Passwords cannot contain spaces'**
  String get noSpacesAllowed;

  /// No description provided for @newPassConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get newPassConfirm;

  /// No description provided for @passwordNotEquals.
  ///
  /// In en, this message translates to:
  /// **'New Password Not Identical'**
  String get passwordNotEquals;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User Not Found'**
  String get userNotFound;

  /// No description provided for @archivingSystem.
  ///
  /// In en, this message translates to:
  /// **'Electronic archiving system'**
  String get archivingSystem;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @userDocs.
  ///
  /// In en, this message translates to:
  /// **'User Documents'**
  String get userDocs;

  /// No description provided for @docByCat.
  ///
  /// In en, this message translates to:
  /// **'Documents By Category'**
  String get docByCat;

  /// No description provided for @docByDep.
  ///
  /// In en, this message translates to:
  /// **'Documents By Department'**
  String get docByDep;

  /// No description provided for @totalDocs.
  ///
  /// In en, this message translates to:
  /// **'Total Documents'**
  String get totalDocs;

  /// No description provided for @totalDepts.
  ///
  /// In en, this message translates to:
  /// **'Total Departments'**
  String get totalDepts;

  /// No description provided for @totalCat.
  ///
  /// In en, this message translates to:
  /// **'Total User Categories'**
  String get totalCat;

  /// No description provided for @sendViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send Via WhatsApp'**
  String get sendViaWhatsApp;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Via Email'**
  String get sendViaEmail;

  /// No description provided for @sentDone.
  ///
  /// In en, this message translates to:
  /// **'Sent Done'**
  String get sentDone;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get templateName;

  /// No description provided for @searchByDep.
  ///
  /// In en, this message translates to:
  /// **'Search By Department'**
  String get searchByDep;

  /// No description provided for @workFlow.
  ///
  /// In en, this message translates to:
  /// **'Work Flow'**
  String get workFlow;

  /// No description provided for @docName.
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get docName;

  /// No description provided for @docDesc.
  ///
  /// In en, this message translates to:
  /// **'Document Description'**
  String get docDesc;

  /// No description provided for @addWorkFlow.
  ///
  /// In en, this message translates to:
  /// **'Add Work Flow'**
  String get addWorkFlow;

  /// No description provided for @editWorkFlow.
  ///
  /// In en, this message translates to:
  /// **'Edit Work Flow'**
  String get editWorkFlow;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get addStep;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @myApprovals.
  ///
  /// In en, this message translates to:
  /// **'My Approvals'**
  String get myApprovals;

  /// No description provided for @viewApprovals.
  ///
  /// In en, this message translates to:
  /// **'View Approvals'**
  String get viewApprovals;

  /// No description provided for @submitforWorkflowApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for Workflow Approvals'**
  String get submitforWorkflowApproval;

  /// No description provided for @stepNo.
  ///
  /// In en, this message translates to:
  /// **'Step Number'**
  String get stepNo;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @notAuthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to approve this step at this time'**
  String get notAuthorized;

  /// No description provided for @updatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'updated Success'**
  String get updatedSuccess;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @sureToApproveStep.
  ///
  /// In en, this message translates to:
  /// **'Are You sure you want to Approve this step?'**
  String get sureToApproveStep;

  /// No description provided for @sureToRejectStep.
  ///
  /// In en, this message translates to:
  /// **'Are You sure you want to Reject this step?'**
  String get sureToRejectStep;

  /// No description provided for @searchByStatus.
  ///
  /// In en, this message translates to:
  /// **'Search by Status'**
  String get searchByStatus;

  /// No description provided for @cannotEdit.
  ///
  /// In en, this message translates to:
  /// **'You cannot edit Confirmed step'**
  String get cannotEdit;

  /// No description provided for @stuckAprrovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Aprrovals'**
  String get stuckAprrovals;

  /// No description provided for @readyToApprove.
  ///
  /// In en, this message translates to:
  /// **'Ready to Approve'**
  String get readyToApprove;

  /// No description provided for @readyToApprovePending.
  ///
  /// In en, this message translates to:
  /// **'Ready to Approve/ Pending'**
  String get readyToApprovePending;

  /// No description provided for @approvalFlowDetails.
  ///
  /// In en, this message translates to:
  /// **'Approval Flow Details'**
  String get approvalFlowDetails;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @stepDescription.
  ///
  /// In en, this message translates to:
  /// **'Step Description'**
  String get stepDescription;

  /// No description provided for @workFlowSettings.
  ///
  /// In en, this message translates to:
  /// **'Workflow Settings'**
  String get workFlowSettings;

  /// No description provided for @arDescription.
  ///
  /// In en, this message translates to:
  /// **'Ar Description'**
  String get arDescription;

  /// No description provided for @verifyDocuments.
  ///
  /// In en, this message translates to:
  /// **'verify Documents'**
  String get verifyDocuments;

  /// No description provided for @pleaseAddExcel.
  ///
  /// In en, this message translates to:
  /// **'Please upload an Excel file containing a single column for the issue number'**
  String get pleaseAddExcel;

  /// No description provided for @uploadExcelFile.
  ///
  /// In en, this message translates to:
  /// **'Upload Excel File'**
  String get uploadExcelFile;

  /// No description provided for @isLimitAction.
  ///
  /// In en, this message translates to:
  /// **'Restrict acess to other department'**
  String get isLimitAction;

  /// No description provided for @notAllowedToEditDept.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized for this department.'**
  String get notAllowedToEditDept;

  /// No description provided for @noScannersFound.
  ///
  /// In en, this message translates to:
  /// **'No scanners found'**
  String get noScannersFound;

  /// No description provided for @urlError.
  ///
  /// In en, this message translates to:
  /// **'A user already exists with this URL. Do you want to add it again?'**
  String get urlError;

  /// No description provided for @numOfFilesNum.
  ///
  /// In en, this message translates to:
  /// **'Files Number Displayed'**
  String get numOfFilesNum;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @noFileAvailableToPreview.
  ///
  /// In en, this message translates to:
  /// **'No file available to preview.'**
  String get noFileAvailableToPreview;

  /// No description provided for @noFileContentReturned.
  ///
  /// In en, this message translates to:
  /// **'No file content returned.'**
  String get noFileContentReturned;

  /// No description provided for @sucessScanFile.
  ///
  /// In en, this message translates to:
  /// **'File Scaned'**
  String get sucessScanFile;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @downloadReady.
  ///
  /// In en, this message translates to:
  /// **'Download Ready'**
  String get downloadReady;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailed;

  /// No description provided for @noFilesFoundForThisDocument.
  ///
  /// In en, this message translates to:
  /// **'No files were found for this document.'**
  String get noFilesFoundForThisDocument;

  /// No description provided for @noValidFilesToZip.
  ///
  /// In en, this message translates to:
  /// **'No valid files to include in the ZIP.'**
  String get noValidFilesToZip;

  /// No description provided for @zippingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while preparing the ZIP.'**
  String get zippingError;

  /// No description provided for @canWrite.
  ///
  /// In en, this message translates to:
  /// **'can Write'**
  String get canWrite;

  /// No description provided for @filesPackedIntoZip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No files were packed.} one {1 file has been packed into {zipName}.} other {{count} files have been packed into {zipName}.}}'**
  String filesPackedIntoZip(int count, String zipName);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
