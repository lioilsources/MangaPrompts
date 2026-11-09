// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get screenBuilder => 'پرامپٹ بلڈر';

  @override
  String get screenRestyle => 'تصویر کا انداز بدلیں';

  @override
  String get screenHair => 'ہیئر اسٹائل آزمائیں';

  @override
  String get screenAnimate => 'تصویر کو متحرک کریں';

  @override
  String get settings => 'ترتیبات';

  @override
  String get shopTooltipVideo => 'اینیمیشن کریڈٹس اور پیکجز';

  @override
  String get shopTooltip => 'کریڈٹس اور پیکجز';

  @override
  String get switchCard => 'کارڈ تبدیل کریں';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اینیمیشن کریڈٹس شامل ہو گئے 🎉',
      one: '1 اینیمیشن کریڈٹ شامل ہو گیا 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کریڈٹس شامل ہو گئے 🎉',
      one: '1 کریڈٹ شامل ہو گیا 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ادائیگی ناکام ہو گئی، دوبارہ کوشش کریں';

  @override
  String errorDetail(String error) {
    return 'خرابی: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'کریڈٹس لوڈ نہیں ہو سکے: $error';
  }

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get animationsTitle => 'اینیمیشنز';

  @override
  String get creditsTitle => 'کریڈٹس';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'آج کی مفت اینیمیشنز: $limit میں سے $free · اینیمیشن کریڈٹس: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'آج کی مفت جنریشنز: $limit میں سے $free · کریڈٹس: $credits';
  }

  @override
  String get videoPriceNote => '1 کریڈٹ = 1 ویڈیو، ادائیگی Telegram Stars میں۔';

  @override
  String get imagePriceNote => '1 کریڈٹ = 1 تصویر، ادائیگی Telegram Stars میں۔';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کریڈٹس',
      one: '1 کریڈٹ',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اینیمیشنز',
      one: '1 اینیمیشن',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose ویب پر دستیاب نہیں';

  @override
  String get reposeTooltip => 'Repose (پوز میں چہرہ)';

  @override
  String get presets => 'پری سیٹس';

  @override
  String get template => 'ٹیمپلیٹ';

  @override
  String get backToTop => 'اوپر واپس جائیں';

  @override
  String get generating => 'بنایا جا رہا ہے…';

  @override
  String get generate => 'بنائیں';

  @override
  String get needCredentials => 'ترتیبات میں API کلید یا اسناد مقرر کریں';

  @override
  String presetLoaded(String name) {
    return 'پری سیٹ “$name” لوڈ ہو گیا';
  }

  @override
  String get connectionLostVideo =>
      'کنکشن ٹوٹ گیا — بوٹ پھر بھی ویڈیو آپ کی چیٹ میں پہنچا دے گا۔';

  @override
  String videoServerDown(String error) {
    return 'ویڈیو سرور ابھی دستیاب نہیں ہے۔\n$error';
  }

  @override
  String get scene => 'منظر';

  @override
  String get uploading => 'اپ لوڈ ہو رہا ہے…';

  @override
  String get animate => 'متحرک کریں';

  @override
  String get pickPhoto => 'تصویر منتخب کریں';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'تقریباً $seconds سیکنڈ کی کلپ · رینڈر تقریباً $minutes منٹ';
  }

  @override
  String queuePosition(int position) {
    return 'قطار میں · نمبر $position';
  }

  @override
  String get queueWaiting => 'قطار میں…';

  @override
  String get finishing => 'مکمل کیا جا رہا ہے (حرکت ہموار کی جا رہی ہے)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'بیٹ $beat/$beats · تقریباً $minutes منٹ باقی';
  }

  @override
  String get videoDone => 'ہو گیا! ویڈیو آپ کی Telegram چیٹ میں بھیج دی گئی 🎬';

  @override
  String failedDetail(String error) {
    return 'ناکام: $error';
  }

  @override
  String get unknownError => 'نامعلوم خرابی';

  @override
  String get starting => 'شروع ہو رہا ہے…';

  @override
  String get canCloseApp =>
      'آپ ایپ بند کر سکتے ہیں — ویڈیو چیٹ میں پہنچ جائے گی۔';

  @override
  String get notCharged => 'آپ کی مفت ویڈیو / کریڈٹ خرچ نہیں ہوا۔';

  @override
  String get animateAnother => 'ایک اور متحرک کریں';

  @override
  String get restyleHint =>
      'آپ کا چہرہ اور پوز برقرار رکھتا ہے۔ ایک شخص کی صاف، سامنے سے لی گئی تصویر کے ساتھ بہترین کام کرتا ہے۔';

  @override
  String get medium => 'میڈیم';

  @override
  String get mediumPhoto => 'تصویر';

  @override
  String get mediumIllustration => 'مصوّری';

  @override
  String get style => 'انداز';

  @override
  String get filterStyles => 'انداز فلٹر کریں';

  @override
  String get restyling => 'انداز بدلا جا رہا ہے…';

  @override
  String get restyle => 'انداز بدلیں';

  @override
  String get restyleBusy =>
      'انداز بدلا جا رہا ہے… تقریباً ایک منٹ۔\nتصویر آپ کی چیٹ میں بھی پہنچے گی۔';

  @override
  String get groupPopular => 'مقبول';

  @override
  String get groupPainters => 'مصور';

  @override
  String get groupAsia => 'ایشیا';

  @override
  String get groupEurope => 'یورپ';

  @override
  String get groupAmericasOceania => 'امریکا اور اوشیانا';

  @override
  String get groupAfricaNearEast => 'افریقا اور مشرقِ قریب';

  @override
  String get hairHint =>
      'آپ کا چہرہ اور بالوں کا رنگ برقرار رکھتا ہے، جب تک آپ نیا رنگ منتخب نہ کریں۔ سامنے سے لی گئی ایسی پورٹریٹ کے ساتھ بہترین کام کرتا ہے جس میں بال پورے نظر آئیں اور ٹوپی نہ ہو۔';

  @override
  String get noHairstyles => 'ابھی کوئی ہیئر اسٹائل نہیں — جلد دوبارہ دیکھیں۔';

  @override
  String get colour => 'رنگ';

  @override
  String get keepMine => 'میرا رکھیں';

  @override
  String get haircut => 'ہیئر کٹ';

  @override
  String get keepMyCut => 'میرا کٹ رکھیں';

  @override
  String get working => 'کام جاری ہے…';

  @override
  String get newColour => 'نیا رنگ';

  @override
  String get newHaircut => 'نیا ہیئر کٹ';

  @override
  String get pickPortrait => 'پورٹریٹ منتخب کریں';

  @override
  String get hairBusy =>
      'کام جاری ہے… تقریباً ایک منٹ۔\nتصویر آپ کی چیٹ میں بھی پہنچے گی۔';

  @override
  String get hairWomen => 'خواتین';

  @override
  String get hairMen => 'مرد';

  @override
  String get hairCuts => 'کٹ';

  @override
  String get hairBangs => 'بینگز';

  @override
  String get hairTexture => 'ساخت';

  @override
  String get hairShort => 'چھوٹے';

  @override
  String get hairMedium => 'درمیانے';

  @override
  String get hairLong => 'لمبے';

  @override
  String get hairBraids => 'چوٹیاں';

  @override
  String get hairUpdos => 'اپ ڈو';

  @override
  String get notDownloaded => 'تصویر ابھی ڈاؤن لوڈ نہیں ہوئی';

  @override
  String get savedToGallery => 'گیلری میں محفوظ ہو گئی';

  @override
  String couldNotSave(String error) {
    return 'محفوظ نہیں ہو سکی: $error';
  }

  @override
  String get result => 'نتیجہ';

  @override
  String get saveToGallery => 'گیلری میں محفوظ کریں';

  @override
  String get copyPrompt => 'پرامپٹ کاپی کریں';

  @override
  String get promptCopied => 'پرامپٹ کاپی ہو گیا';

  @override
  String get imageNotAvailable => 'تصویر دستیاب نہیں';

  @override
  String get promptUsed => 'استعمال شدہ پرامپٹ:';

  @override
  String get revisedPrompt => 'نظرِ ثانی شدہ پرامپٹ (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'لوڈ نہیں ہو سکا: $error';
  }

  @override
  String get generation => 'جنریشن';

  @override
  String get generationWebInfo =>
      'تصاویر Tsumiki بوٹ (ComfyUI) بناتا ہے۔ مکمل تصویر بوٹ کے ساتھ آپ کی چیٹ میں بھی بھیجی جاتی ہے۔';

  @override
  String get workflow => 'ورک فلو';

  @override
  String get generationBackend => 'جنریشن بیک اینڈ';

  @override
  String get xaiInfo => 'Grok کے ذریعے بنانے کے لیے console.x.ai سے API کلید۔';

  @override
  String get apiKey => 'API کلید';

  @override
  String get ol1nInfo =>
      'مقامی AiStack (Flux diffusers API)۔ CF Access سروس ٹوکن درج کریں، یا اگر بلڈ میں شامل ہے (--dart-define) تو خالی چھوڑ دیں۔';

  @override
  String get comfyInfo =>
      'مقامی ComfyUI (ماڈل کا انتخاب نیچے)۔ CF Access ٹوکن llm.ol1n.com کے ساتھ مشترک ہے۔';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get saved => 'محفوظ ہو گیا';

  @override
  String get wfAuto => 'خودکار — منتخب ٹیمپلیٹ کے مطابق';

  @override
  String get wfFlux => 'Flux — مصوّرانہ اور فوٹو ریئلسٹک انداز';

  @override
  String get wfPony => 'Pony Diffusion — اینیمے، Danbooru ٹیگز';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — تیز فوٹو ریئلسٹک';

  @override
  String get wfWai => 'WAI Illustrious — اینیمے، Pony سے نیا';

  @override
  String templateChose(String workflow) {
    return 'ٹیمپلیٹ نے منتخب کیا: $workflow';
  }

  @override
  String get apiKeySaved => 'API کلید محفوظ ہو گئی';

  @override
  String get reposeScreenTitle => 'Repose — پوز میں چہرہ';

  @override
  String get model => 'ماڈل';

  @override
  String get stepFace => '1. چہرہ';

  @override
  String get stepPose => '2. پوز';

  @override
  String get stepPrompt => '3. پرامپٹ';

  @override
  String get negative => 'منفی';

  @override
  String get reposePromptHint => 'ایک عورت کی تصویر، پورا جسم، قدرتی روشنی…';

  @override
  String couldNotLoadModels(String error) {
    return 'ماڈلز لوڈ نہیں ہو سکے: $error';
  }

  @override
  String get noModels => 'کوئی ماڈل نہیں (ترتیبات میں CF اسناد چیک کریں)۔';

  @override
  String get uploadFace => 'چہرہ اپ لوڈ کریں';

  @override
  String get changeFace => 'چہرہ بدلیں';

  @override
  String get pickFromGallery => 'گیلری سے منتخب کریں';

  @override
  String get takePhoto => 'تصویر کھینچیں';

  @override
  String get needCfCredentials =>
      'ترتیبات میں Cloudflare Access اسناد مقرر کریں';

  @override
  String get baseImageSelected => 'بنیادی تصویر منتخب ہو گئی';

  @override
  String get baseImageOptional => 'بنیادی تصویر (اختیاری)';

  @override
  String get remove => 'ہٹائیں';

  @override
  String get prompt => 'پرامپٹ';

  @override
  String get modelAutoTooltip =>
      'ماڈل ٹیمپلیٹ سے خودکار طور پر منتخب ہوا۔\nآپ اسے ترتیبات میں بدل سکتے ہیں۔';

  @override
  String get modelManualTooltip => 'ماڈل ترتیبات میں ہاتھ سے منتخب کیا گیا۔';

  @override
  String get pickBlocks => 'پرامپٹ بنانے کے لیے بلاکس منتخب کریں...';
}
