import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nb'),
    Locale('nl'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'PT'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @screenBuilder.
  ///
  /// In en, this message translates to:
  /// **'Prompt builder'**
  String get screenBuilder;

  /// No description provided for @screenRestyle.
  ///
  /// In en, this message translates to:
  /// **'Restyle a photo'**
  String get screenRestyle;

  /// No description provided for @screenHair.
  ///
  /// In en, this message translates to:
  /// **'Try a haircut'**
  String get screenHair;

  /// No description provided for @screenAnimate.
  ///
  /// In en, this message translates to:
  /// **'Animate a photo'**
  String get screenAnimate;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shopTooltipVideo.
  ///
  /// In en, this message translates to:
  /// **'Animation credits and packages'**
  String get shopTooltipVideo;

  /// No description provided for @shopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Credits and packages'**
  String get shopTooltip;

  /// No description provided for @switchCard.
  ///
  /// In en, this message translates to:
  /// **'Switch card'**
  String get switchCard;

  /// No description provided for @paidVideo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 animation credit added 🎉} other{{count} animation credits added 🎉}}'**
  String paidVideo(int count);

  /// No description provided for @paidImages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit added 🎉} other{{count} credits added 🎉}}'**
  String paidImages(int count);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed, please try again'**
  String get paymentFailed;

  /// No description provided for @errorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorDetail(String error);

  /// No description provided for @creditsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load credits: {error}'**
  String creditsLoadFailed(String error);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @animationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animationsTitle;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @videoQuota.
  ///
  /// In en, this message translates to:
  /// **'Free animations today: {free} of {limit} · animation credits: {credits}'**
  String videoQuota(int free, int limit, int credits);

  /// No description provided for @imageQuota.
  ///
  /// In en, this message translates to:
  /// **'Free generations today: {free} of {limit} · credits: {credits}'**
  String imageQuota(int free, int limit, int credits);

  /// No description provided for @videoPriceNote.
  ///
  /// In en, this message translates to:
  /// **'1 credit = 1 video, paid in Telegram Stars.'**
  String get videoPriceNote;

  /// No description provided for @imagePriceNote.
  ///
  /// In en, this message translates to:
  /// **'1 credit = 1 image, paid in Telegram Stars.'**
  String get imagePriceNote;

  /// No description provided for @packageImages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}}'**
  String packageImages(int count);

  /// No description provided for @packageVideos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 animation} other{{count} animations}}'**
  String packageVideos(int count);

  /// No description provided for @reposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Repose'**
  String get reposeTitle;

  /// No description provided for @reposeWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Repose is not available on the web'**
  String get reposeWebUnavailable;

  /// No description provided for @reposeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Repose (face in a pose)'**
  String get reposeTooltip;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @backToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get backToTop;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get generating;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @needCredentials.
  ///
  /// In en, this message translates to:
  /// **'Set an API key or credentials in Settings'**
  String get needCredentials;

  /// No description provided for @presetLoaded.
  ///
  /// In en, this message translates to:
  /// **'Preset \"{name}\" loaded'**
  String presetLoaded(String name);

  /// No description provided for @connectionLostVideo.
  ///
  /// In en, this message translates to:
  /// **'Connection lost — the bot will still deliver the video to your chat.'**
  String get connectionLostVideo;

  /// No description provided for @videoServerDown.
  ///
  /// In en, this message translates to:
  /// **'The video server is unavailable right now.\n{error}'**
  String videoServerDown(String error);

  /// No description provided for @scene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get scene;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @animate.
  ///
  /// In en, this message translates to:
  /// **'Animate'**
  String get animate;

  /// No description provided for @pickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo'**
  String get pickPhoto;

  /// No description provided for @sceneInfo.
  ///
  /// In en, this message translates to:
  /// **'~{seconds} s clip · ~{minutes} min render'**
  String sceneInfo(int seconds, int minutes);

  /// No description provided for @queuePosition.
  ///
  /// In en, this message translates to:
  /// **'In line · position {position}'**
  String queuePosition(int position);

  /// No description provided for @queueWaiting.
  ///
  /// In en, this message translates to:
  /// **'In line…'**
  String get queueWaiting;

  /// No description provided for @finishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing (smoothing the motion)…'**
  String get finishing;

  /// No description provided for @beatProgress.
  ///
  /// In en, this message translates to:
  /// **'Beat {beat}/{beats} · ~{minutes} min left'**
  String beatProgress(int beat, int beats, int minutes);

  /// No description provided for @videoDone.
  ///
  /// In en, this message translates to:
  /// **'Done! The video was sent to your Telegram chat 🎬'**
  String get videoDone;

  /// No description provided for @failedDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedDetail(String error);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'unknown error'**
  String get unknownError;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get starting;

  /// No description provided for @canCloseApp.
  ///
  /// In en, this message translates to:
  /// **'You can close the app — the video arrives in the chat.'**
  String get canCloseApp;

  /// No description provided for @notCharged.
  ///
  /// In en, this message translates to:
  /// **'Your free video / credit was not spent.'**
  String get notCharged;

  /// No description provided for @animateAnother.
  ///
  /// In en, this message translates to:
  /// **'Animate another'**
  String get animateAnother;

  /// No description provided for @restyleHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps your face and pose. Works best with a clear, front-facing photo of one person.'**
  String get restyleHint;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @mediumPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get mediumPhoto;

  /// No description provided for @mediumIllustration.
  ///
  /// In en, this message translates to:
  /// **'Illustration'**
  String get mediumIllustration;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @filterStyles.
  ///
  /// In en, this message translates to:
  /// **'Filter styles'**
  String get filterStyles;

  /// No description provided for @restyling.
  ///
  /// In en, this message translates to:
  /// **'Restyling…'**
  String get restyling;

  /// No description provided for @restyle.
  ///
  /// In en, this message translates to:
  /// **'Restyle'**
  String get restyle;

  /// No description provided for @restyleBusy.
  ///
  /// In en, this message translates to:
  /// **'Restyling… about a minute.\nThe image also arrives in your chat.'**
  String get restyleBusy;

  /// No description provided for @groupPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get groupPopular;

  /// No description provided for @groupPainters.
  ///
  /// In en, this message translates to:
  /// **'Painters'**
  String get groupPainters;

  /// No description provided for @groupAsia.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get groupAsia;

  /// No description provided for @groupEurope.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get groupEurope;

  /// No description provided for @groupAmericasOceania.
  ///
  /// In en, this message translates to:
  /// **'Americas & Oceania'**
  String get groupAmericasOceania;

  /// No description provided for @groupAfricaNearEast.
  ///
  /// In en, this message translates to:
  /// **'Africa & Near East'**
  String get groupAfricaNearEast;

  /// No description provided for @hairHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps your face, and your hair colour unless you pick a new one. Works best with a front-facing portrait, hair fully visible, no hat.'**
  String get hairHint;

  /// No description provided for @noHairstyles.
  ///
  /// In en, this message translates to:
  /// **'No hairstyles yet — check back soon.'**
  String get noHairstyles;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @keepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get keepMine;

  /// No description provided for @haircut.
  ///
  /// In en, this message translates to:
  /// **'Haircut'**
  String get haircut;

  /// No description provided for @keepMyCut.
  ///
  /// In en, this message translates to:
  /// **'Keep my cut'**
  String get keepMyCut;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get working;

  /// No description provided for @newColour.
  ///
  /// In en, this message translates to:
  /// **'New colour'**
  String get newColour;

  /// No description provided for @newHaircut.
  ///
  /// In en, this message translates to:
  /// **'New haircut'**
  String get newHaircut;

  /// No description provided for @pickPortrait.
  ///
  /// In en, this message translates to:
  /// **'Pick a portrait'**
  String get pickPortrait;

  /// No description provided for @hairBusy.
  ///
  /// In en, this message translates to:
  /// **'Working… about a minute.\nThe photo also arrives in your chat.'**
  String get hairBusy;

  /// No description provided for @hairWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get hairWomen;

  /// No description provided for @hairMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get hairMen;

  /// No description provided for @hairCuts.
  ///
  /// In en, this message translates to:
  /// **'Cuts'**
  String get hairCuts;

  /// No description provided for @hairBangs.
  ///
  /// In en, this message translates to:
  /// **'Bangs'**
  String get hairBangs;

  /// No description provided for @hairTexture.
  ///
  /// In en, this message translates to:
  /// **'Texture'**
  String get hairTexture;

  /// No description provided for @hairShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get hairShort;

  /// No description provided for @hairMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hairMedium;

  /// No description provided for @hairLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get hairLong;

  /// No description provided for @hairBraids.
  ///
  /// In en, this message translates to:
  /// **'Braids'**
  String get hairBraids;

  /// No description provided for @hairUpdos.
  ///
  /// In en, this message translates to:
  /// **'Updos'**
  String get hairUpdos;

  /// No description provided for @notDownloaded.
  ///
  /// In en, this message translates to:
  /// **'The image has not been downloaded yet'**
  String get notDownloaded;

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to the gallery'**
  String get savedToGallery;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String couldNotSave(String error);

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get saveToGallery;

  /// No description provided for @copyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Copy prompt'**
  String get copyPrompt;

  /// No description provided for @promptCopied.
  ///
  /// In en, this message translates to:
  /// **'Prompt copied'**
  String get promptCopied;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @promptUsed.
  ///
  /// In en, this message translates to:
  /// **'Prompt used:'**
  String get promptUsed;

  /// No description provided for @revisedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Revised prompt (Grok):'**
  String get revisedPrompt;

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load: {error}'**
  String couldNotLoad(String error);

  /// No description provided for @generation.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get generation;

  /// No description provided for @generationWebInfo.
  ///
  /// In en, this message translates to:
  /// **'Images are generated by the Tsumiki bot (ComfyUI). The finished image is also sent to your chat with the bot.'**
  String get generationWebInfo;

  /// No description provided for @workflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get workflow;

  /// No description provided for @generationBackend.
  ///
  /// In en, this message translates to:
  /// **'Generation backend'**
  String get generationBackend;

  /// No description provided for @xaiInfo.
  ///
  /// In en, this message translates to:
  /// **'API key from console.x.ai for generating through Grok.'**
  String get xaiInfo;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get apiKey;

  /// No description provided for @ol1nInfo.
  ///
  /// In en, this message translates to:
  /// **'Local AiStack (Flux diffusers API). Enter a CF Access service token, or leave empty if it is baked in at build time (--dart-define).'**
  String get ol1nInfo;

  /// No description provided for @comfyInfo.
  ///
  /// In en, this message translates to:
  /// **'Local ComfyUI (model selection below). Shares the CF Access token with llm.ol1n.com.'**
  String get comfyInfo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @wfAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic — follow the chosen template'**
  String get wfAuto;

  /// No description provided for @wfFlux.
  ///
  /// In en, this message translates to:
  /// **'Flux — painterly and photorealistic styles'**
  String get wfFlux;

  /// No description provided for @wfPony.
  ///
  /// In en, this message translates to:
  /// **'Pony Diffusion — anime, Danbooru tags'**
  String get wfPony;

  /// No description provided for @wfJuggernaut.
  ///
  /// In en, this message translates to:
  /// **'Juggernaut XL Lightning — fast photoreal'**
  String get wfJuggernaut;

  /// No description provided for @wfWai.
  ///
  /// In en, this message translates to:
  /// **'WAI Illustrious — anime, newer than Pony'**
  String get wfWai;

  /// No description provided for @templateChose.
  ///
  /// In en, this message translates to:
  /// **'Template chose: {workflow}'**
  String templateChose(String workflow);

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved'**
  String get apiKeySaved;

  /// No description provided for @reposeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Repose — face in a pose'**
  String get reposeScreenTitle;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @stepFace.
  ///
  /// In en, this message translates to:
  /// **'1. Face'**
  String get stepFace;

  /// No description provided for @stepPose.
  ///
  /// In en, this message translates to:
  /// **'2. Pose'**
  String get stepPose;

  /// No description provided for @stepPrompt.
  ///
  /// In en, this message translates to:
  /// **'3. Prompt'**
  String get stepPrompt;

  /// No description provided for @negative.
  ///
  /// In en, this message translates to:
  /// **'NEGATIVE'**
  String get negative;

  /// No description provided for @reposePromptHint.
  ///
  /// In en, this message translates to:
  /// **'photo of a woman, full body, natural light…'**
  String get reposePromptHint;

  /// No description provided for @couldNotLoadModels.
  ///
  /// In en, this message translates to:
  /// **'Could not load models: {error}'**
  String couldNotLoadModels(String error);

  /// No description provided for @noModels.
  ///
  /// In en, this message translates to:
  /// **'No models (check the CF credentials in Settings).'**
  String get noModels;

  /// No description provided for @uploadFace.
  ///
  /// In en, this message translates to:
  /// **'Upload a face'**
  String get uploadFace;

  /// No description provided for @changeFace.
  ///
  /// In en, this message translates to:
  /// **'Change face'**
  String get changeFace;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @needCfCredentials.
  ///
  /// In en, this message translates to:
  /// **'Set the Cloudflare Access credentials in Settings'**
  String get needCfCredentials;

  /// No description provided for @baseImageSelected.
  ///
  /// In en, this message translates to:
  /// **'Base image selected'**
  String get baseImageSelected;

  /// No description provided for @baseImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Base image (optional)'**
  String get baseImageOptional;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @modelAutoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Model chosen automatically from the template.\nYou can change it in Settings.'**
  String get modelAutoTooltip;

  /// No description provided for @modelManualTooltip.
  ///
  /// In en, this message translates to:
  /// **'Model chosen manually in Settings.'**
  String get modelManualTooltip;

  /// No description provided for @pickBlocks.
  ///
  /// In en, this message translates to:
  /// **'Pick blocks to assemble a prompt...'**
  String get pickBlocks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'gu',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'ms',
    'nb',
    'nl',
    'or',
    'pa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
