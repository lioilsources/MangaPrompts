// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get screenBuilder => 'ಪ್ರಾಂಪ್ಟ್ ಬಿಲ್ಡರ್';

  @override
  String get screenRestyle => 'ಫೋಟೋದ ಶೈಲಿ ಬದಲಿಸಿ';

  @override
  String get screenHair => 'ಹೇರ್‌ಕಟ್ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get screenAnimate => 'ಫೋಟೋವನ್ನು ಅನಿಮೇಟ್ ಮಾಡಿ';

  @override
  String get settings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get shopTooltipVideo => 'ಅನಿಮೇಷನ್ ಕ್ರೆಡಿಟ್‌ಗಳು ಮತ್ತು ಪ್ಯಾಕೇಜ್‌ಗಳು';

  @override
  String get shopTooltip => 'ಕ್ರೆಡಿಟ್‌ಗಳು ಮತ್ತು ಪ್ಯಾಕೇಜ್‌ಗಳು';

  @override
  String get switchCard => 'ಕಾರ್ಡ್ ಬದಲಿಸಿ';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಅನಿಮೇಷನ್ ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ 🎉',
      one: '1 ಅನಿಮೇಷನ್ ಕ್ರೆಡಿಟ್ ಸೇರಿಸಲಾಗಿದೆ 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ 🎉',
      one: '1 ಕ್ರೆಡಿಟ್ ಸೇರಿಸಲಾಗಿದೆ 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ಪಾವತಿ ವಿಫಲವಾಗಿದೆ, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String errorDetail(String error) {
    return 'ದೋಷ: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ: $error';
  }

  @override
  String get tryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get animationsTitle => 'ಅನಿಮೇಷನ್‌ಗಳು';

  @override
  String get creditsTitle => 'ಕ್ರೆಡಿಟ್‌ಗಳು';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'ಇಂದಿನ ಉಚಿತ ಅನಿಮೇಷನ್‌ಗಳು: $limit ರಲ್ಲಿ $free · ಅನಿಮೇಷನ್ ಕ್ರೆಡಿಟ್‌ಗಳು: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'ಇಂದಿನ ಉಚಿತ ಜನರೇಷನ್‌ಗಳು: $limit ರಲ್ಲಿ $free · ಕ್ರೆಡಿಟ್‌ಗಳು: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 ಕ್ರೆಡಿಟ್ = 1 ವೀಡಿಯೊ, Telegram Stars ನಲ್ಲಿ ಪಾವತಿ.';

  @override
  String get imagePriceNote =>
      '1 ಕ್ರೆಡಿಟ್ = 1 ಚಿತ್ರ, Telegram Stars ನಲ್ಲಿ ಪಾವತಿ.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕ್ರೆಡಿಟ್‌ಗಳು',
      one: '1 ಕ್ರೆಡಿಟ್',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಅನಿಮೇಷನ್‌ಗಳು',
      one: '1 ಅನಿಮೇಷನ್',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose ವೆಬ್‌ನಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get reposeTooltip => 'Repose (ಭಂಗಿಯಲ್ಲಿ ಮುಖ)';

  @override
  String get presets => 'ಪ್ರೀಸೆಟ್‌ಗಳು';

  @override
  String get template => 'ಟೆಂಪ್ಲೇಟ್';

  @override
  String get backToTop => 'ಮೇಲಕ್ಕೆ ಹಿಂತಿರುಗಿ';

  @override
  String get generating => 'ರಚಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get generate => 'ರಚಿಸಿ';

  @override
  String get needCredentials =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ API ಕೀ ಅಥವಾ ರುಜುವಾತುಗಳನ್ನು ಹೊಂದಿಸಿ';

  @override
  String presetLoaded(String name) {
    return 'ಪ್ರೀಸೆಟ್ “$name” ಲೋಡ್ ಆಯಿತು';
  }

  @override
  String get connectionLostVideo =>
      'ಸಂಪರ್ಕ ಕಡಿತವಾಯಿತು — ಬಾಟ್ ಆದರೂ ವೀಡಿಯೊವನ್ನು ನಿಮ್ಮ ಚಾಟ್‌ಗೆ ತಲುಪಿಸುತ್ತದೆ.';

  @override
  String videoServerDown(String error) {
    return 'ವೀಡಿಯೊ ಸರ್ವರ್ ಈಗ ಲಭ್ಯವಿಲ್ಲ.\n$error';
  }

  @override
  String get scene => 'ದೃಶ್ಯ';

  @override
  String get uploading => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get animate => 'ಅನಿಮೇಟ್ ಮಾಡಿ';

  @override
  String get pickPhoto => 'ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds ಸೆ ಕ್ಲಿಪ್ · ರೆಂಡರ್ ~$minutes ನಿಮಿಷ';
  }

  @override
  String queuePosition(int position) {
    return 'ಸರದಿಯಲ್ಲಿ · ಸ್ಥಾನ $position';
  }

  @override
  String get queueWaiting => 'ಸರದಿಯಲ್ಲಿ…';

  @override
  String get finishing => 'ಮುಗಿಸಲಾಗುತ್ತಿದೆ (ಚಲನೆಯನ್ನು ಸುಗಮಗೊಳಿಸಲಾಗುತ್ತಿದೆ)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'ಬೀಟ್ $beat/$beats · ~$minutes ನಿಮಿಷ ಉಳಿದಿದೆ';
  }

  @override
  String get videoDone =>
      'ಆಯಿತು! ವೀಡಿಯೊವನ್ನು ನಿಮ್ಮ Telegram ಚಾಟ್‌ಗೆ ಕಳುಹಿಸಲಾಗಿದೆ 🎬';

  @override
  String failedDetail(String error) {
    return 'ವಿಫಲ: $error';
  }

  @override
  String get unknownError => 'ಅಜ್ಞಾತ ದೋಷ';

  @override
  String get starting => 'ಪ್ರಾರಂಭವಾಗುತ್ತಿದೆ…';

  @override
  String get canCloseApp => 'ನೀವು ಆ್ಯಪ್ ಮುಚ್ಚಬಹುದು — ವೀಡಿಯೊ ಚಾಟ್‌ಗೆ ಬರುತ್ತದೆ.';

  @override
  String get notCharged => 'ನಿಮ್ಮ ಉಚಿತ ವೀಡಿಯೊ / ಕ್ರೆಡಿಟ್ ಖರ್ಚಾಗಿಲ್ಲ.';

  @override
  String get animateAnother => 'ಇನ್ನೊಂದನ್ನು ಅನಿಮೇಟ್ ಮಾಡಿ';

  @override
  String get restyleHint =>
      'ನಿಮ್ಮ ಮುಖ ಮತ್ತು ಭಂಗಿಯನ್ನು ಉಳಿಸುತ್ತದೆ. ಒಬ್ಬ ವ್ಯಕ್ತಿಯ ಸ್ಪಷ್ಟ, ಮುಂಭಾಗದ ಫೋಟೋದಲ್ಲಿ ಉತ್ತಮವಾಗಿ ಕೆಲಸ ಮಾಡುತ್ತದೆ.';

  @override
  String get medium => 'ಮಾಧ್ಯಮ';

  @override
  String get mediumPhoto => 'ಫೋಟೋ';

  @override
  String get mediumIllustration => 'ಚಿತ್ರಣ';

  @override
  String get style => 'ಶೈಲಿ';

  @override
  String get filterStyles => 'ಶೈಲಿಗಳನ್ನು ಫಿಲ್ಟರ್ ಮಾಡಿ';

  @override
  String get restyling => 'ಶೈಲಿ ಬದಲಾಗುತ್ತಿದೆ…';

  @override
  String get restyle => 'ಶೈಲಿ ಬದಲಿಸಿ';

  @override
  String get restyleBusy =>
      'ಶೈಲಿ ಬದಲಾಗುತ್ತಿದೆ… ಸುಮಾರು ಒಂದು ನಿಮಿಷ.\nಚಿತ್ರವು ನಿಮ್ಮ ಚಾಟ್‌ಗೂ ಬರುತ್ತದೆ.';

  @override
  String get groupPopular => 'ಜನಪ್ರಿಯ';

  @override
  String get groupPainters => 'ಚಿತ್ರಕಾರರು';

  @override
  String get groupAsia => 'ಏಷ್ಯಾ';

  @override
  String get groupEurope => 'ಯುರೋಪ್';

  @override
  String get groupAmericasOceania => 'ಅಮೆರಿಕ ಮತ್ತು ಓಷಿಯಾನಿಯಾ';

  @override
  String get groupAfricaNearEast => 'ಆಫ್ರಿಕಾ ಮತ್ತು ಹತ್ತಿರದ ಪೂರ್ವ';

  @override
  String get hairHint =>
      'ನಿಮ್ಮ ಮುಖವನ್ನು ಮತ್ತು, ಹೊಸ ಬಣ್ಣ ಆಯ್ಕೆ ಮಾಡದಿದ್ದರೆ, ಕೂದಲಿನ ಬಣ್ಣವನ್ನು ಉಳಿಸುತ್ತದೆ. ಪೂರ್ಣ ಕೂದಲು ಕಾಣುವ, ಟೋಪಿ ಇಲ್ಲದ ಮುಂಭಾಗದ ಭಾವಚಿತ್ರದಲ್ಲಿ ಉತ್ತಮ.';

  @override
  String get noHairstyles =>
      'ಇನ್ನೂ ಹೇರ್‌ಸ್ಟೈಲ್‌ಗಳಿಲ್ಲ — ಶೀಘ್ರದಲ್ಲೇ ಮತ್ತೆ ನೋಡಿ.';

  @override
  String get colour => 'ಬಣ್ಣ';

  @override
  String get keepMine => 'ನನ್ನದನ್ನು ಉಳಿಸಿ';

  @override
  String get haircut => 'ಹೇರ್‌ಕಟ್';

  @override
  String get keepMyCut => 'ನನ್ನ ಕಟ್ ಉಳಿಸಿ';

  @override
  String get working => 'ಕೆಲಸ ನಡೆಯುತ್ತಿದೆ…';

  @override
  String get newColour => 'ಹೊಸ ಬಣ್ಣ';

  @override
  String get newHaircut => 'ಹೊಸ ಹೇರ್‌ಕಟ್';

  @override
  String get pickPortrait => 'ಭಾವಚಿತ್ರ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get hairBusy =>
      'ಕೆಲಸ ನಡೆಯುತ್ತಿದೆ… ಸುಮಾರು ಒಂದು ನಿಮಿಷ.\nಫೋಟೋ ನಿಮ್ಮ ಚಾಟ್‌ಗೂ ಬರುತ್ತದೆ.';

  @override
  String get hairWomen => 'ಮಹಿಳೆಯರು';

  @override
  String get hairMen => 'ಪುರುಷರು';

  @override
  String get hairCuts => 'ಕಟ್‌ಗಳು';

  @override
  String get hairBangs => 'ಬ್ಯಾಂಗ್ಸ್';

  @override
  String get hairTexture => 'ರಚನೆ';

  @override
  String get hairShort => 'ಚಿಕ್ಕ';

  @override
  String get hairMedium => 'ಮಧ್ಯಮ';

  @override
  String get hairLong => 'ಉದ್ದ';

  @override
  String get hairBraids => 'ಜಡೆಗಳು';

  @override
  String get hairUpdos => 'ಅಪ್‌ಡೊಗಳು';

  @override
  String get notDownloaded => 'ಚಿತ್ರವನ್ನು ಇನ್ನೂ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿಲ್ಲ';

  @override
  String get savedToGallery => 'ಗ್ಯಾಲರಿಯಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String couldNotSave(String error) {
    return 'ಉಳಿಸಲಾಗಲಿಲ್ಲ: $error';
  }

  @override
  String get result => 'ಫಲಿತಾಂಶ';

  @override
  String get saveToGallery => 'ಗ್ಯಾಲರಿಯಲ್ಲಿ ಉಳಿಸಿ';

  @override
  String get copyPrompt => 'ಪ್ರಾಂಪ್ಟ್ ನಕಲಿಸಿ';

  @override
  String get promptCopied => 'ಪ್ರಾಂಪ್ಟ್ ನಕಲಿಸಲಾಗಿದೆ';

  @override
  String get imageNotAvailable => 'ಚಿತ್ರ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get promptUsed => 'ಬಳಸಿದ ಪ್ರಾಂಪ್ಟ್:';

  @override
  String get revisedPrompt => 'ಪರಿಷ್ಕೃತ ಪ್ರಾಂಪ್ಟ್ (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ: $error';
  }

  @override
  String get generation => 'ಜನರೇಷನ್';

  @override
  String get generationWebInfo =>
      'ಚಿತ್ರಗಳನ್ನು Tsumiki ಬಾಟ್ (ComfyUI) ರಚಿಸುತ್ತದೆ. ಸಿದ್ಧ ಚಿತ್ರವನ್ನು ಬಾಟ್‌ನೊಂದಿಗಿನ ನಿಮ್ಮ ಚಾಟ್‌ಗೂ ಕಳುಹಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get workflow => 'ವರ್ಕ್‌ಫ್ಲೋ';

  @override
  String get generationBackend => 'ಜನರೇಷನ್ ಬ್ಯಾಕೆಂಡ್';

  @override
  String get xaiInfo => 'Grok ಮೂಲಕ ರಚಿಸಲು console.x.ai ನ API ಕೀ.';

  @override
  String get apiKey => 'API ಕೀ';

  @override
  String get ol1nInfo =>
      'ಸ್ಥಳೀಯ AiStack (Flux diffusers API). CF Access ಸೇವಾ ಟೋಕನ್ ನಮೂದಿಸಿ, ಅಥವಾ ಬಿಲ್ಡ್‌ನಲ್ಲಿ ಅಳವಡಿಸಿದ್ದರೆ (--dart-define) ಖಾಲಿ ಬಿಡಿ.';

  @override
  String get comfyInfo =>
      'ಸ್ಥಳೀಯ ComfyUI (ಮಾದರಿ ಆಯ್ಕೆ ಕೆಳಗೆ). CF Access ಟೋಕನ್ ಅನ್ನು llm.ol1n.com ನೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳುತ್ತದೆ.';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get saved => 'ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get wfAuto => 'ಸ್ವಯಂಚಾಲಿತ — ಆಯ್ದ ಟೆಂಪ್ಲೇಟ್ ಅನುಸರಿಸಿ';

  @override
  String get wfFlux => 'Flux — ಚಿತ್ರಕಲಾ ಮತ್ತು ಫೋಟೋರಿಯಲಿಸ್ಟಿಕ್ ಶೈಲಿಗಳು';

  @override
  String get wfPony => 'Pony Diffusion — ಅನಿಮೆ, Danbooru ಟ್ಯಾಗ್‌ಗಳು';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — ವೇಗದ ಫೋಟೋರಿಯಲ್';

  @override
  String get wfWai => 'WAI Illustrious — ಅನಿಮೆ, Pony ಗಿಂತ ಹೊಸದು';

  @override
  String templateChose(String workflow) {
    return 'ಟೆಂಪ್ಲೇಟ್ ಆಯ್ಕೆ ಮಾಡಿದ್ದು: $workflow';
  }

  @override
  String get apiKeySaved => 'API ಕೀ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get reposeScreenTitle => 'Repose — ಭಂಗಿಯಲ್ಲಿ ಮುಖ';

  @override
  String get model => 'ಮಾದರಿ';

  @override
  String get stepFace => '1. ಮುಖ';

  @override
  String get stepPose => '2. ಭಂಗಿ';

  @override
  String get stepPrompt => '3. ಪ್ರಾಂಪ್ಟ್';

  @override
  String get negative => 'ನೆಗೆಟಿವ್';

  @override
  String get reposePromptHint => 'ಒಬ್ಬ ಮಹಿಳೆಯ ಫೋಟೋ, ಪೂರ್ಣ ದೇಹ, ನೈಸರ್ಗಿಕ ಬೆಳಕು…';

  @override
  String couldNotLoadModels(String error) {
    return 'ಮಾದರಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ: $error';
  }

  @override
  String get noModels =>
      'ಮಾದರಿಗಳಿಲ್ಲ (ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ CF ರುಜುವಾತುಗಳನ್ನು ಪರಿಶೀಲಿಸಿ).';

  @override
  String get uploadFace => 'ಮುಖ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get changeFace => 'ಮುಖ ಬದಲಿಸಿ';

  @override
  String get pickFromGallery => 'ಗ್ಯಾಲರಿಯಿಂದ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get takePhoto => 'ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get needCfCredentials =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ Cloudflare Access ರುಜುವಾತುಗಳನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get baseImageSelected => 'ಮೂಲ ಚಿತ್ರ ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ';

  @override
  String get baseImageOptional => 'ಮೂಲ ಚಿತ್ರ (ಐಚ್ಛಿಕ)';

  @override
  String get remove => 'ತೆಗೆದುಹಾಕಿ';

  @override
  String get prompt => 'ಪ್ರಾಂಪ್ಟ್';

  @override
  String get modelAutoTooltip =>
      'ಟೆಂಪ್ಲೇಟ್‌ನಿಂದ ಮಾದರಿ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಆಯ್ಕೆಯಾಗಿದೆ.\nಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಬದಲಿಸಬಹುದು.';

  @override
  String get modelManualTooltip => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಕೈಯಾರೆ ಆಯ್ಕೆ ಮಾಡಿದ ಮಾದರಿ.';

  @override
  String get pickBlocks => 'ಪ್ರಾಂಪ್ಟ್ ರಚಿಸಲು ಬ್ಲಾಕ್‌ಗಳನ್ನು ಆರಿಸಿ...';
}
