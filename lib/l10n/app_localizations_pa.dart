// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get screenBuilder => 'ਪ੍ਰੌਂਪਟ ਬਿਲਡਰ';

  @override
  String get screenRestyle => 'ਫ਼ੋਟੋ ਦੀ ਸ਼ੈਲੀ ਬਦਲੋ';

  @override
  String get screenHair => 'ਹੇਅਰਕੱਟ ਅਜ਼ਮਾਓ';

  @override
  String get screenAnimate => 'ਫ਼ੋਟੋ ਨੂੰ ਐਨੀਮੇਟ ਕਰੋ';

  @override
  String get settings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get shopTooltipVideo => 'ਐਨੀਮੇਸ਼ਨ ਕ੍ਰੈਡਿਟ ਅਤੇ ਪੈਕੇਜ';

  @override
  String get shopTooltip => 'ਕ੍ਰੈਡਿਟ ਅਤੇ ਪੈਕੇਜ';

  @override
  String get switchCard => 'ਕਾਰਡ ਬਦਲੋ';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਐਨੀਮੇਸ਼ਨ ਕ੍ਰੈਡਿਟ ਜੋੜੇ ਗਏ 🎉',
      one: '1 ਐਨੀਮੇਸ਼ਨ ਕ੍ਰੈਡਿਟ ਜੋੜਿਆ ਗਿਆ 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕ੍ਰੈਡਿਟ ਜੋੜੇ ਗਏ 🎉',
      one: '1 ਕ੍ਰੈਡਿਟ ਜੋੜਿਆ ਗਿਆ 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ਭੁਗਤਾਨ ਅਸਫਲ ਰਿਹਾ, ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String errorDetail(String error) {
    return 'ਗਲਤੀ: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'ਕ੍ਰੈਡਿਟ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੇ: $error';
  }

  @override
  String get tryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get animationsTitle => 'ਐਨੀਮੇਸ਼ਨਾਂ';

  @override
  String get creditsTitle => 'ਕ੍ਰੈਡਿਟ';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'ਅੱਜ ਦੀਆਂ ਮੁਫ਼ਤ ਐਨੀਮੇਸ਼ਨਾਂ: $limit ਵਿੱਚੋਂ $free · ਐਨੀਮੇਸ਼ਨ ਕ੍ਰੈਡਿਟ: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'ਅੱਜ ਦੀਆਂ ਮੁਫ਼ਤ ਜਨਰੇਸ਼ਨਾਂ: $limit ਵਿੱਚੋਂ $free · ਕ੍ਰੈਡਿਟ: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 ਕ੍ਰੈਡਿਟ = 1 ਵੀਡੀਓ, ਭੁਗਤਾਨ Telegram Stars ਵਿੱਚ।';

  @override
  String get imagePriceNote =>
      '1 ਕ੍ਰੈਡਿਟ = 1 ਤਸਵੀਰ, ਭੁਗਤਾਨ Telegram Stars ਵਿੱਚ।';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕ੍ਰੈਡਿਟ',
      one: '1 ਕ੍ਰੈਡਿਟ',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਐਨੀਮੇਸ਼ਨਾਂ',
      one: '1 ਐਨੀਮੇਸ਼ਨ',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose ਵੈੱਬ ’ਤੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get reposeTooltip => 'Repose (ਪੋਜ਼ ਵਿੱਚ ਚਿਹਰਾ)';

  @override
  String get presets => 'ਪ੍ਰੀਸੈੱਟ';

  @override
  String get template => 'ਟੈਂਪਲੇਟ';

  @override
  String get backToTop => 'ਉੱਪਰ ਵਾਪਸ ਜਾਓ';

  @override
  String get generating => 'ਬਣਾਇਆ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get generate => 'ਬਣਾਓ';

  @override
  String get needCredentials =>
      'ਸੈਟਿੰਗਾਂ ਵਿੱਚ API ਕੁੰਜੀ ਜਾਂ ਪ੍ਰਮਾਣ-ਪੱਤਰ ਸੈੱਟ ਕਰੋ';

  @override
  String presetLoaded(String name) {
    return 'ਪ੍ਰੀਸੈੱਟ “$name” ਲੋਡ ਹੋ ਗਿਆ';
  }

  @override
  String get connectionLostVideo =>
      'ਕਨੈਕਸ਼ਨ ਟੁੱਟ ਗਿਆ — ਬੌਟ ਫਿਰ ਵੀ ਵੀਡੀਓ ਤੁਹਾਡੀ ਚੈਟ ਵਿੱਚ ਪਹੁੰਚਾ ਦੇਵੇਗਾ।';

  @override
  String videoServerDown(String error) {
    return 'ਵੀਡੀਓ ਸਰਵਰ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।\n$error';
  }

  @override
  String get scene => 'ਦ੍ਰਿਸ਼';

  @override
  String get uploading => 'ਅੱਪਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get animate => 'ਐਨੀਮੇਟ ਕਰੋ';

  @override
  String get pickPhoto => 'ਫ਼ੋਟੋ ਚੁਣੋ';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds ਸਕਿੰਟ ਦੀ ਕਲਿੱਪ · ਰੈਂਡਰ ~$minutes ਮਿੰਟ';
  }

  @override
  String queuePosition(int position) {
    return 'ਕਤਾਰ ਵਿੱਚ · ਥਾਂ $position';
  }

  @override
  String get queueWaiting => 'ਕਤਾਰ ਵਿੱਚ…';

  @override
  String get finishing => 'ਪੂਰਾ ਹੋ ਰਿਹਾ ਹੈ (ਹਰਕਤ ਸੁਚਾਰੂ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'ਬੀਟ $beat/$beats · ~$minutes ਮਿੰਟ ਬਾਕੀ';
  }

  @override
  String get videoDone =>
      'ਹੋ ਗਿਆ! ਵੀਡੀਓ ਤੁਹਾਡੀ Telegram ਚੈਟ ਵਿੱਚ ਭੇਜ ਦਿੱਤੀ ਗਈ 🎬';

  @override
  String failedDetail(String error) {
    return 'ਅਸਫਲ: $error';
  }

  @override
  String get unknownError => 'ਅਣਜਾਣ ਗਲਤੀ';

  @override
  String get starting => 'ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get canCloseApp =>
      'ਤੁਸੀਂ ਐਪ ਬੰਦ ਕਰ ਸਕਦੇ ਹੋ — ਵੀਡੀਓ ਚੈਟ ਵਿੱਚ ਆ ਜਾਵੇਗੀ।';

  @override
  String get notCharged => 'ਤੁਹਾਡੀ ਮੁਫ਼ਤ ਵੀਡੀਓ / ਕ੍ਰੈਡਿਟ ਖਰਚ ਨਹੀਂ ਹੋਇਆ।';

  @override
  String get animateAnother => 'ਇੱਕ ਹੋਰ ਐਨੀਮੇਟ ਕਰੋ';

  @override
  String get restyleHint =>
      'ਤੁਹਾਡਾ ਚਿਹਰਾ ਅਤੇ ਪੋਜ਼ ਕਾਇਮ ਰੱਖਦਾ ਹੈ। ਇੱਕ ਵਿਅਕਤੀ ਦੀ ਸਾਫ਼, ਸਾਹਮਣੇ ਤੋਂ ਲਈ ਫ਼ੋਟੋ ਨਾਲ ਸਭ ਤੋਂ ਵਧੀਆ ਕੰਮ ਕਰਦਾ ਹੈ।';

  @override
  String get medium => 'ਮਾਧਿਅਮ';

  @override
  String get mediumPhoto => 'ਫ਼ੋਟੋ';

  @override
  String get mediumIllustration => 'ਚਿੱਤਰਕਾਰੀ';

  @override
  String get style => 'ਸ਼ੈਲੀ';

  @override
  String get filterStyles => 'ਸ਼ੈਲੀਆਂ ਫਿਲਟਰ ਕਰੋ';

  @override
  String get restyling => 'ਸ਼ੈਲੀ ਬਦਲੀ ਜਾ ਰਹੀ ਹੈ…';

  @override
  String get restyle => 'ਸ਼ੈਲੀ ਬਦਲੋ';

  @override
  String get restyleBusy =>
      'ਸ਼ੈਲੀ ਬਦਲੀ ਜਾ ਰਹੀ ਹੈ… ਲਗਭਗ ਇੱਕ ਮਿੰਟ।\nਤਸਵੀਰ ਤੁਹਾਡੀ ਚੈਟ ਵਿੱਚ ਵੀ ਆਵੇਗੀ।';

  @override
  String get groupPopular => 'ਮਸ਼ਹੂਰ';

  @override
  String get groupPainters => 'ਚਿੱਤਰਕਾਰ';

  @override
  String get groupAsia => 'ਏਸ਼ੀਆ';

  @override
  String get groupEurope => 'ਯੂਰਪ';

  @override
  String get groupAmericasOceania => 'ਅਮਰੀਕਾ ਅਤੇ ਓਸ਼ੇਨੀਆ';

  @override
  String get groupAfricaNearEast => 'ਅਫ਼ਰੀਕਾ ਅਤੇ ਨੇੜਲਾ ਪੂਰਬ';

  @override
  String get hairHint =>
      'ਤੁਹਾਡਾ ਚਿਹਰਾ ਅਤੇ, ਜੇ ਤੁਸੀਂ ਨਵਾਂ ਰੰਗ ਨਾ ਚੁਣੋ, ਵਾਲਾਂ ਦਾ ਰੰਗ ਕਾਇਮ ਰੱਖਦਾ ਹੈ। ਸਾਹਮਣੇ ਤੋਂ ਲਏ ਅਜਿਹੇ ਪੋਰਟਰੇਟ ਨਾਲ ਸਭ ਤੋਂ ਵਧੀਆ ਚੱਲਦਾ ਹੈ ਜਿਸ ਵਿੱਚ ਵਾਲ ਪੂਰੇ ਦਿਸਣ ਅਤੇ ਟੋਪੀ ਨਾ ਹੋਵੇ।';

  @override
  String get noHairstyles => 'ਹਾਲੇ ਕੋਈ ਹੇਅਰਸਟਾਈਲ ਨਹੀਂ — ਜਲਦੀ ਦੁਬਾਰਾ ਵੇਖੋ।';

  @override
  String get colour => 'ਰੰਗ';

  @override
  String get keepMine => 'ਮੇਰਾ ਰੱਖੋ';

  @override
  String get haircut => 'ਹੇਅਰਕੱਟ';

  @override
  String get keepMyCut => 'ਮੇਰਾ ਕੱਟ ਰੱਖੋ';

  @override
  String get working => 'ਕੰਮ ਜਾਰੀ ਹੈ…';

  @override
  String get newColour => 'ਨਵਾਂ ਰੰਗ';

  @override
  String get newHaircut => 'ਨਵਾਂ ਹੇਅਰਕੱਟ';

  @override
  String get pickPortrait => 'ਪੋਰਟਰੇਟ ਚੁਣੋ';

  @override
  String get hairBusy =>
      'ਕੰਮ ਜਾਰੀ ਹੈ… ਲਗਭਗ ਇੱਕ ਮਿੰਟ।\nਫ਼ੋਟੋ ਤੁਹਾਡੀ ਚੈਟ ਵਿੱਚ ਵੀ ਆਵੇਗੀ।';

  @override
  String get hairWomen => 'ਔਰਤਾਂ';

  @override
  String get hairMen => 'ਮਰਦ';

  @override
  String get hairCuts => 'ਕੱਟ';

  @override
  String get hairBangs => 'ਬੈਂਗਜ਼';

  @override
  String get hairTexture => 'ਬਣਤਰ';

  @override
  String get hairShort => 'ਛੋਟੇ';

  @override
  String get hairMedium => 'ਦਰਮਿਆਨੇ';

  @override
  String get hairLong => 'ਲੰਮੇ';

  @override
  String get hairBraids => 'ਗੁੱਤਾਂ';

  @override
  String get hairUpdos => 'ਅੱਪਡੂ';

  @override
  String get notDownloaded => 'ਤਸਵੀਰ ਹਾਲੇ ਡਾਊਨਲੋਡ ਨਹੀਂ ਹੋਈ';

  @override
  String get savedToGallery => 'ਗੈਲਰੀ ਵਿੱਚ ਸੰਭਾਲੀ ਗਈ';

  @override
  String couldNotSave(String error) {
    return 'ਸੰਭਾਲੀ ਨਹੀਂ ਜਾ ਸਕੀ: $error';
  }

  @override
  String get result => 'ਨਤੀਜਾ';

  @override
  String get saveToGallery => 'ਗੈਲਰੀ ਵਿੱਚ ਸੰਭਾਲੋ';

  @override
  String get copyPrompt => 'ਪ੍ਰੌਂਪਟ ਕਾਪੀ ਕਰੋ';

  @override
  String get promptCopied => 'ਪ੍ਰੌਂਪਟ ਕਾਪੀ ਹੋ ਗਿਆ';

  @override
  String get imageNotAvailable => 'ਤਸਵੀਰ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get promptUsed => 'ਵਰਤਿਆ ਗਿਆ ਪ੍ਰੌਂਪਟ:';

  @override
  String get revisedPrompt => 'ਸੋਧਿਆ ਪ੍ਰੌਂਪਟ (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ: $error';
  }

  @override
  String get generation => 'ਜਨਰੇਸ਼ਨ';

  @override
  String get generationWebInfo =>
      'ਤਸਵੀਰਾਂ Tsumiki ਬੌਟ (ComfyUI) ਬਣਾਉਂਦਾ ਹੈ। ਤਿਆਰ ਤਸਵੀਰ ਬੌਟ ਨਾਲ ਤੁਹਾਡੀ ਚੈਟ ਵਿੱਚ ਵੀ ਭੇਜੀ ਜਾਂਦੀ ਹੈ।';

  @override
  String get workflow => 'ਵਰਕਫਲੋ';

  @override
  String get generationBackend => 'ਜਨਰੇਸ਼ਨ ਬੈਕਐਂਡ';

  @override
  String get xaiInfo => 'Grok ਰਾਹੀਂ ਬਣਾਉਣ ਲਈ console.x.ai ਦੀ API ਕੁੰਜੀ।';

  @override
  String get apiKey => 'API ਕੁੰਜੀ';

  @override
  String get ol1nInfo =>
      'ਲੋਕਲ AiStack (Flux diffusers API)। CF Access ਸਰਵਿਸ ਟੋਕਨ ਦਾਖਲ ਕਰੋ, ਜਾਂ ਬਿਲਡ ਵਿੱਚ ਸ਼ਾਮਲ ਹੋਵੇ (--dart-define) ਤਾਂ ਖਾਲੀ ਛੱਡੋ।';

  @override
  String get comfyInfo =>
      'ਲੋਕਲ ComfyUI (ਮਾਡਲ ਦੀ ਚੋਣ ਹੇਠਾਂ)। CF Access ਟੋਕਨ llm.ol1n.com ਨਾਲ ਸਾਂਝਾ ਹੈ।';

  @override
  String get save => 'ਸੰਭਾਲੋ';

  @override
  String get saved => 'ਸੰਭਾਲਿਆ ਗਿਆ';

  @override
  String get wfAuto => 'ਆਟੋਮੈਟਿਕ — ਚੁਣੇ ਟੈਂਪਲੇਟ ਅਨੁਸਾਰ';

  @override
  String get wfFlux => 'Flux — ਚਿੱਤਰਕਾਰੀ ਅਤੇ ਫ਼ੋਟੋਰੀਅਲਿਸਟਿਕ ਸ਼ੈਲੀਆਂ';

  @override
  String get wfPony => 'Pony Diffusion — ਐਨੀਮੇ, Danbooru ਟੈਗ';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — ਤੇਜ਼ ਫ਼ੋਟੋਰੀਅਲ';

  @override
  String get wfWai => 'WAI Illustrious — ਐਨੀਮੇ, Pony ਤੋਂ ਨਵਾਂ';

  @override
  String templateChose(String workflow) {
    return 'ਟੈਂਪਲੇਟ ਨੇ ਚੁਣਿਆ: $workflow';
  }

  @override
  String get apiKeySaved => 'API ਕੁੰਜੀ ਸੰਭਾਲੀ ਗਈ';

  @override
  String get reposeScreenTitle => 'Repose — ਪੋਜ਼ ਵਿੱਚ ਚਿਹਰਾ';

  @override
  String get model => 'ਮਾਡਲ';

  @override
  String get stepFace => '1. ਚਿਹਰਾ';

  @override
  String get stepPose => '2. ਪੋਜ਼';

  @override
  String get stepPrompt => '3. ਪ੍ਰੌਂਪਟ';

  @override
  String get negative => 'ਨੈਗੇਟਿਵ';

  @override
  String get reposePromptHint => 'ਇੱਕ ਔਰਤ ਦੀ ਫ਼ੋਟੋ, ਪੂਰਾ ਸਰੀਰ, ਕੁਦਰਤੀ ਰੌਸ਼ਨੀ…';

  @override
  String couldNotLoadModels(String error) {
    return 'ਮਾਡਲ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੇ: $error';
  }

  @override
  String get noModels => 'ਕੋਈ ਮਾਡਲ ਨਹੀਂ (ਸੈਟਿੰਗਾਂ ਵਿੱਚ CF ਪ੍ਰਮਾਣ-ਪੱਤਰ ਜਾਂਚੋ)।';

  @override
  String get uploadFace => 'ਚਿਹਰਾ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get changeFace => 'ਚਿਹਰਾ ਬਦਲੋ';

  @override
  String get pickFromGallery => 'ਗੈਲਰੀ ਤੋਂ ਚੁਣੋ';

  @override
  String get takePhoto => 'ਫ਼ੋਟੋ ਖਿੱਚੋ';

  @override
  String get needCfCredentials =>
      'ਸੈਟਿੰਗਾਂ ਵਿੱਚ Cloudflare Access ਪ੍ਰਮਾਣ-ਪੱਤਰ ਸੈੱਟ ਕਰੋ';

  @override
  String get baseImageSelected => 'ਆਧਾਰ ਤਸਵੀਰ ਚੁਣੀ ਗਈ';

  @override
  String get baseImageOptional => 'ਆਧਾਰ ਤਸਵੀਰ (ਵਿਕਲਪਿਕ)';

  @override
  String get remove => 'ਹਟਾਓ';

  @override
  String get prompt => 'ਪ੍ਰੌਂਪਟ';

  @override
  String get modelAutoTooltip =>
      'ਮਾਡਲ ਟੈਂਪਲੇਟ ਤੋਂ ਆਪਣੇ-ਆਪ ਚੁਣਿਆ ਗਿਆ।\nਤੁਸੀਂ ਇਸ ਨੂੰ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਬਦਲ ਸਕਦੇ ਹੋ।';

  @override
  String get modelManualTooltip => 'ਮਾਡਲ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਹੱਥੀਂ ਚੁਣਿਆ ਗਿਆ।';

  @override
  String get pickBlocks => 'ਪ੍ਰੌਂਪਟ ਬਣਾਉਣ ਲਈ ਬਲਾਕ ਚੁਣੋ...';
}
