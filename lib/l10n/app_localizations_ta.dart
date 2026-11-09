// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get screenBuilder => 'ப்ராம்ப்ட் பில்டர்';

  @override
  String get screenRestyle => 'புகைப்படத்தின் பாணியை மாற்று';

  @override
  String get screenHair => 'சிகை அலங்காரத்தை முயற்சி செய்';

  @override
  String get screenAnimate => 'புகைப்படத்தை அசைவூட்டு';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get shopTooltipVideo => 'அசைவூட்டக் கிரெடிட்டுகளும் தொகுப்புகளும்';

  @override
  String get shopTooltip => 'கிரெடிட்டுகளும் தொகுப்புகளும்';

  @override
  String get switchCard => 'அட்டையை மாற்று';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அசைவூட்டக் கிரெடிட்டுகள் சேர்க்கப்பட்டன 🎉',
      one: '1 அசைவூட்டக் கிரெடிட் சேர்க்கப்பட்டது 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கிரெடிட்டுகள் சேர்க்கப்பட்டன 🎉',
      one: '1 கிரெடிட் சேர்க்கப்பட்டது 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'கட்டணம் தோல்வியடைந்தது, மீண்டும் முயலவும்';

  @override
  String errorDetail(String error) {
    return 'பிழை: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'கிரெடிட்டுகளை ஏற்ற முடியவில்லை: $error';
  }

  @override
  String get tryAgain => 'மீண்டும் முயல்';

  @override
  String get animationsTitle => 'அசைவூட்டங்கள்';

  @override
  String get creditsTitle => 'கிரெடிட்டுகள்';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'இன்றைய இலவச அசைவூட்டங்கள்: $limit இல் $free · அசைவூட்டக் கிரெடிட்டுகள்: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'இன்றைய இலவச உருவாக்கங்கள்: $limit இல் $free · கிரெடிட்டுகள்: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 கிரெடிட் = 1 வீடியோ, Telegram Stars மூலம் கட்டணம்.';

  @override
  String get imagePriceNote =>
      '1 கிரெடிட் = 1 படம், Telegram Stars மூலம் கட்டணம்.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கிரெடிட்டுகள்',
      one: '1 கிரெடிட்',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அசைவூட்டங்கள்',
      one: '1 அசைவூட்டம்',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'வலையில் Repose கிடைக்காது';

  @override
  String get reposeTooltip => 'Repose (தோரணையில் முகம்)';

  @override
  String get presets => 'முன்னமைவுகள்';

  @override
  String get template => 'வார்ப்புரு';

  @override
  String get backToTop => 'மேலே திரும்பு';

  @override
  String get generating => 'உருவாக்குகிறது…';

  @override
  String get generate => 'உருவாக்கு';

  @override
  String get needCredentials =>
      'அமைப்புகளில் API விசை அல்லது சான்றுகளை அமைக்கவும்';

  @override
  String presetLoaded(String name) {
    return 'முன்னமைவு “$name” ஏற்றப்பட்டது';
  }

  @override
  String get connectionLostVideo =>
      'இணைப்பு துண்டிக்கப்பட்டது — போட் இருந்தாலும் வீடியோவை உங்கள் அரட்டைக்கு வழங்கும்.';

  @override
  String videoServerDown(String error) {
    return 'வீடியோ சேவையகம் இப்போது கிடைக்கவில்லை.\n$error';
  }

  @override
  String get scene => 'காட்சி';

  @override
  String get uploading => 'பதிவேற்றுகிறது…';

  @override
  String get animate => 'அசைவூட்டு';

  @override
  String get pickPhoto => 'புகைப்படத்தைத் தேர்ந்தெடு';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds வி கிளிப் · ரெண்டர் ~$minutes நிமிடம்';
  }

  @override
  String queuePosition(int position) {
    return 'வரிசையில் · இடம் $position';
  }

  @override
  String get queueWaiting => 'வரிசையில்…';

  @override
  String get finishing => 'முடிக்கிறது (இயக்கத்தை மென்மையாக்குகிறது)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'பீட் $beat/$beats · ~$minutes நிமிடம் மீதம்';
  }

  @override
  String get videoDone =>
      'முடிந்தது! வீடியோ உங்கள் Telegram அரட்டைக்கு அனுப்பப்பட்டது 🎬';

  @override
  String failedDetail(String error) {
    return 'தோல்வி: $error';
  }

  @override
  String get unknownError => 'அறியப்படாத பிழை';

  @override
  String get starting => 'தொடங்குகிறது…';

  @override
  String get canCloseApp =>
      'நீங்கள் செயலியை மூடலாம் — வீடியோ அரட்டைக்கு வந்துவிடும்.';

  @override
  String get notCharged => 'உங்கள் இலவச வீடியோ / கிரெடிட் செலவாகவில்லை.';

  @override
  String get animateAnother => 'இன்னொன்றை அசைவூட்டு';

  @override
  String get restyleHint =>
      'உங்கள் முகத்தையும் தோரணையையும் அப்படியே வைத்திருக்கும். ஒருவரின் தெளிவான, முன்புறப் புகைப்படத்துடன் சிறப்பாகச் செயல்படும்.';

  @override
  String get medium => 'ஊடகம்';

  @override
  String get mediumPhoto => 'புகைப்படம்';

  @override
  String get mediumIllustration => 'விளக்கப்படம்';

  @override
  String get style => 'பாணி';

  @override
  String get filterStyles => 'பாணிகளை வடிகட்டு';

  @override
  String get restyling => 'பாணியை மாற்றுகிறது…';

  @override
  String get restyle => 'பாணியை மாற்று';

  @override
  String get restyleBusy =>
      'பாணியை மாற்றுகிறது… சுமார் ஒரு நிமிடம்.\nபடம் உங்கள் அரட்டைக்கும் வரும்.';

  @override
  String get groupPopular => 'பிரபலமானவை';

  @override
  String get groupPainters => 'ஓவியர்கள்';

  @override
  String get groupAsia => 'ஆசியா';

  @override
  String get groupEurope => 'ஐரோப்பா';

  @override
  String get groupAmericasOceania => 'அமெரிக்காக்கள் & ஓசியானியா';

  @override
  String get groupAfricaNearEast => 'ஆப்பிரிக்கா & அண்மைக் கிழக்கு';

  @override
  String get hairHint =>
      'உங்கள் முகத்தையும், புதிய நிறத்தைத் தேர்ந்தெடுக்காவிட்டால் முடியின் நிறத்தையும் வைத்திருக்கும். முடி முழுமையாகத் தெரியும், தொப்பி இல்லாத முன்புற உருவப்படத்துடன் சிறப்பாகச் செயல்படும்.';

  @override
  String get noHairstyles =>
      'இன்னும் சிகை அலங்காரங்கள் இல்லை — விரைவில் மீண்டும் பாருங்கள்.';

  @override
  String get colour => 'நிறம்';

  @override
  String get keepMine => 'என்னுடையதை வைத்திரு';

  @override
  String get haircut => 'முடிவெட்டு';

  @override
  String get keepMyCut => 'என் வெட்டை வைத்திரு';

  @override
  String get working => 'வேலை நடக்கிறது…';

  @override
  String get newColour => 'புதிய நிறம்';

  @override
  String get newHaircut => 'புதிய முடிவெட்டு';

  @override
  String get pickPortrait => 'உருவப்படத்தைத் தேர்ந்தெடு';

  @override
  String get hairBusy =>
      'வேலை நடக்கிறது… சுமார் ஒரு நிமிடம்.\nபுகைப்படம் உங்கள் அரட்டைக்கும் வரும்.';

  @override
  String get hairWomen => 'பெண்கள்';

  @override
  String get hairMen => 'ஆண்கள்';

  @override
  String get hairCuts => 'வெட்டுகள்';

  @override
  String get hairBangs => 'நெற்றி முடி';

  @override
  String get hairTexture => 'இழைமம்';

  @override
  String get hairShort => 'குட்டை';

  @override
  String get hairMedium => 'நடுத்தரம்';

  @override
  String get hairLong => 'நீளம்';

  @override
  String get hairBraids => 'பின்னல்கள்';

  @override
  String get hairUpdos => 'கொண்டைகள்';

  @override
  String get notDownloaded => 'படம் இன்னும் பதிவிறக்கப்படவில்லை';

  @override
  String get savedToGallery => 'தொகுப்பில் சேமிக்கப்பட்டது';

  @override
  String couldNotSave(String error) {
    return 'சேமிக்க முடியவில்லை: $error';
  }

  @override
  String get result => 'முடிவு';

  @override
  String get saveToGallery => 'தொகுப்பில் சேமி';

  @override
  String get copyPrompt => 'ப்ராம்ப்டை நகலெடு';

  @override
  String get promptCopied => 'ப்ராம்ப்ட் நகலெடுக்கப்பட்டது';

  @override
  String get imageNotAvailable => 'படம் கிடைக்கவில்லை';

  @override
  String get promptUsed => 'பயன்படுத்திய ப்ராம்ப்ட்:';

  @override
  String get revisedPrompt => 'திருத்தப்பட்ட ப்ராம்ப்ட் (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'ஏற்ற முடியவில்லை: $error';
  }

  @override
  String get generation => 'உருவாக்கம்';

  @override
  String get generationWebInfo =>
      'படங்களை Tsumiki போட் (ComfyUI) உருவாக்குகிறது. முடிந்த படம் போட்டுடனான உங்கள் அரட்டைக்கும் அனுப்பப்படும்.';

  @override
  String get workflow => 'பணிப்பாய்வு';

  @override
  String get generationBackend => 'உருவாக்கப் பின்னணி';

  @override
  String get xaiInfo => 'Grok மூலம் உருவாக்க console.x.ai இலிருந்து API விசை.';

  @override
  String get apiKey => 'API விசை';

  @override
  String get ol1nInfo =>
      'உள்ளூர் AiStack (Flux diffusers API). CF Access சேவை டோக்கனை உள்ளிடவும், அல்லது உருவாக்கத்தில் உட்பொதிக்கப்பட்டிருந்தால் (--dart-define) காலியாக விடவும்.';

  @override
  String get comfyInfo =>
      'உள்ளூர் ComfyUI (மாதிரித் தேர்வு கீழே). CF Access டோக்கனை llm.ol1n.com உடன் பகிர்கிறது.';

  @override
  String get save => 'சேமி';

  @override
  String get saved => 'சேமிக்கப்பட்டது';

  @override
  String get wfAuto => 'தானியங்கி — தேர்ந்தெடுத்த வார்ப்புருவைப் பின்பற்று';

  @override
  String get wfFlux => 'Flux — ஓவிய மற்றும் புகைப்பட யதார்த்த பாணிகள்';

  @override
  String get wfPony => 'Pony Diffusion — அனிமே, Danbooru குறிச்சொற்கள்';

  @override
  String get wfJuggernaut =>
      'Juggernaut XL Lightning — வேகமான புகைப்பட யதார்த்தம்';

  @override
  String get wfWai => 'WAI Illustrious — அனிமே, Pony ஐ விடப் புதியது';

  @override
  String templateChose(String workflow) {
    return 'வார்ப்புரு தேர்ந்தெடுத்தது: $workflow';
  }

  @override
  String get apiKeySaved => 'API விசை சேமிக்கப்பட்டது';

  @override
  String get reposeScreenTitle => 'Repose — தோரணையில் முகம்';

  @override
  String get model => 'மாதிரி';

  @override
  String get stepFace => '1. முகம்';

  @override
  String get stepPose => '2. தோரணை';

  @override
  String get stepPrompt => '3. ப்ராம்ப்ட்';

  @override
  String get negative => 'எதிர்மறை';

  @override
  String get reposePromptHint =>
      'ஒரு பெண்ணின் புகைப்படம், முழு உடல், இயற்கை ஒளி…';

  @override
  String couldNotLoadModels(String error) {
    return 'மாதிரிகளை ஏற்ற முடியவில்லை: $error';
  }

  @override
  String get noModels =>
      'மாதிரிகள் இல்லை (அமைப்புகளில் CF சான்றுகளைச் சரிபார்க்கவும்).';

  @override
  String get uploadFace => 'முகத்தைப் பதிவேற்று';

  @override
  String get changeFace => 'முகத்தை மாற்று';

  @override
  String get pickFromGallery => 'தொகுப்பிலிருந்து தேர்ந்தெடு';

  @override
  String get takePhoto => 'புகைப்படம் எடு';

  @override
  String get needCfCredentials =>
      'அமைப்புகளில் Cloudflare Access சான்றுகளை அமைக்கவும்';

  @override
  String get baseImageSelected => 'அடிப்படைப் படம் தேர்ந்தெடுக்கப்பட்டது';

  @override
  String get baseImageOptional => 'அடிப்படைப் படம் (விருப்பம்)';

  @override
  String get remove => 'நீக்கு';

  @override
  String get prompt => 'ப்ராம்ப்ட்';

  @override
  String get modelAutoTooltip =>
      'வார்ப்புருவிலிருந்து மாதிரி தானாகத் தேர்ந்தெடுக்கப்பட்டது.\nஅமைப்புகளில் மாற்றலாம்.';

  @override
  String get modelManualTooltip =>
      'அமைப்புகளில் கைமுறையாகத் தேர்ந்தெடுத்த மாதிரி.';

  @override
  String get pickBlocks =>
      'ப்ராம்ப்ட்டை உருவாக்கத் தொகுதிகளைத் தேர்ந்தெடுக்கவும்...';
}
