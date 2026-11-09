// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get screenBuilder => 'منشئ الأوامر';

  @override
  String get screenRestyle => 'تغيير نمط صورة';

  @override
  String get screenHair => 'جرّب قصة شعر';

  @override
  String get screenAnimate => 'حرّك صورة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get shopTooltipVideo => 'رصيد التحريك والباقات';

  @override
  String get shopTooltip => 'الرصيد والباقات';

  @override
  String get switchCard => 'تبديل البطاقة';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count رصيد تحريك 🎉',
      many: 'تمت إضافة $count رصيد تحريك 🎉',
      few: 'تمت إضافة $count أرصدة تحريك 🎉',
      two: 'تمت إضافة رصيدَي تحريك 🎉',
      one: 'تمت إضافة رصيد تحريك واحد 🎉',
      zero: 'لم تتم إضافة أي رصيد تحريك',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count رصيد 🎉',
      many: 'تمت إضافة $count رصيدًا 🎉',
      few: 'تمت إضافة $count أرصدة 🎉',
      two: 'تمت إضافة رصيدين 🎉',
      one: 'تمت إضافة رصيد واحد 🎉',
      zero: 'لم تتم إضافة أي رصيد',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'فشلت عملية الدفع، يرجى المحاولة مرة أخرى';

  @override
  String errorDetail(String error) {
    return 'خطأ: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'تعذّر تحميل الرصيد: $error';
  }

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get animationsTitle => 'التحريك';

  @override
  String get creditsTitle => 'الرصيد';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'التحريكات المجانية اليوم: $free من $limit · رصيد التحريك: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'عمليات الإنشاء المجانية اليوم: $free من $limit · الرصيد: $credits';
  }

  @override
  String get videoPriceNote =>
      'رصيد واحد = فيديو واحد، يُدفع عبر Telegram Stars.';

  @override
  String get imagePriceNote =>
      'رصيد واحد = صورة واحدة، يُدفع عبر Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رصيد',
      many: '$count رصيدًا',
      few: '$count أرصدة',
      two: 'رصيدان',
      one: 'رصيد واحد',
      zero: 'بلا رصيد',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تحريك',
      many: '$count تحريكًا',
      few: '$count تحريكات',
      two: 'تحريكان',
      one: 'تحريك واحد',
      zero: 'بلا تحريك',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose غير متاح على الويب';

  @override
  String get reposeTooltip => 'Repose (وجه بوضعية)';

  @override
  String get presets => 'الإعدادات المسبقة';

  @override
  String get template => 'القالب';

  @override
  String get backToTop => 'العودة إلى الأعلى';

  @override
  String get generating => 'جارٍ الإنشاء…';

  @override
  String get generate => 'إنشاء';

  @override
  String get needCredentials =>
      'عيّن مفتاح API أو بيانات الاعتماد في الإعدادات';

  @override
  String presetLoaded(String name) {
    return 'تم تحميل الإعداد المسبق «$name»';
  }

  @override
  String get connectionLostVideo =>
      'انقطع الاتصال — سيسلّم البوت الفيديو إلى محادثتك على أي حال.';

  @override
  String videoServerDown(String error) {
    return 'خادم الفيديو غير متاح حاليًا.\n$error';
  }

  @override
  String get scene => 'المشهد';

  @override
  String get uploading => 'جارٍ الرفع…';

  @override
  String get animate => 'تحريك';

  @override
  String get pickPhoto => 'اختر صورة';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'مقطع ~$seconds ث · عرض ~$minutes د';
  }

  @override
  String queuePosition(int position) {
    return 'في الانتظار · الترتيب $position';
  }

  @override
  String get queueWaiting => 'في الانتظار…';

  @override
  String get finishing => 'جارٍ الإنهاء (تنعيم الحركة)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'الإيقاع $beat/$beats · متبقٍ ~$minutes د';
  }

  @override
  String get videoDone => 'تم! أُرسل الفيديو إلى محادثتك على Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'فشل: $error';
  }

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get starting => 'جارٍ البدء…';

  @override
  String get canCloseApp => 'يمكنك إغلاق التطبيق — سيصل الفيديو إلى المحادثة.';

  @override
  String get notCharged => 'لم يُستهلك الفيديو المجاني / الرصيد.';

  @override
  String get animateAnother => 'حرّك صورة أخرى';

  @override
  String get restyleHint =>
      'يحافظ على وجهك ووضعيتك. يعمل بشكل أفضل مع صورة أمامية واضحة لشخص واحد.';

  @override
  String get medium => 'الوسيط';

  @override
  String get mediumPhoto => 'صورة فوتوغرافية';

  @override
  String get mediumIllustration => 'رسم توضيحي';

  @override
  String get style => 'النمط';

  @override
  String get filterStyles => 'تصفية الأنماط';

  @override
  String get restyling => 'جارٍ تغيير النمط…';

  @override
  String get restyle => 'تغيير النمط';

  @override
  String get restyleBusy =>
      'جارٍ تغيير النمط… نحو دقيقة.\nستصل الصورة أيضًا إلى محادثتك.';

  @override
  String get groupPopular => 'الأكثر شيوعًا';

  @override
  String get groupPainters => 'الرسامون';

  @override
  String get groupAsia => 'آسيا';

  @override
  String get groupEurope => 'أوروبا';

  @override
  String get groupAmericasOceania => 'الأمريكتان وأوقيانوسيا';

  @override
  String get groupAfricaNearEast => 'أفريقيا والشرق الأدنى';

  @override
  String get hairHint =>
      'يحافظ على وجهك ولون شعرك ما لم تختر لونًا جديدًا. يعمل بشكل أفضل مع صورة شخصية أمامية يظهر فيها الشعر كاملًا دون قبعة.';

  @override
  String get noHairstyles => 'لا توجد قصات شعر بعد — عُد قريبًا.';

  @override
  String get colour => 'اللون';

  @override
  String get keepMine => 'الاحتفاظ بلوني';

  @override
  String get haircut => 'قصة الشعر';

  @override
  String get keepMyCut => 'الاحتفاظ بقصتي';

  @override
  String get working => 'جارٍ العمل…';

  @override
  String get newColour => 'لون جديد';

  @override
  String get newHaircut => 'قصة جديدة';

  @override
  String get pickPortrait => 'اختر صورة شخصية';

  @override
  String get hairBusy =>
      'جارٍ العمل… نحو دقيقة.\nستصل الصورة أيضًا إلى محادثتك.';

  @override
  String get hairWomen => 'نساء';

  @override
  String get hairMen => 'رجال';

  @override
  String get hairCuts => 'القصّات';

  @override
  String get hairBangs => 'الغُرّة';

  @override
  String get hairTexture => 'الملمس';

  @override
  String get hairShort => 'قصير';

  @override
  String get hairMedium => 'متوسط';

  @override
  String get hairLong => 'طويل';

  @override
  String get hairBraids => 'الضفائر';

  @override
  String get hairUpdos => 'التسريحات المرفوعة';

  @override
  String get notDownloaded => 'لم يتم تنزيل الصورة بعد';

  @override
  String get savedToGallery => 'تم الحفظ في المعرض';

  @override
  String couldNotSave(String error) {
    return 'تعذّر الحفظ: $error';
  }

  @override
  String get result => 'النتيجة';

  @override
  String get saveToGallery => 'حفظ في المعرض';

  @override
  String get copyPrompt => 'نسخ الأمر';

  @override
  String get promptCopied => 'تم نسخ الأمر';

  @override
  String get imageNotAvailable => 'الصورة غير متاحة';

  @override
  String get promptUsed => 'الأمر المستخدم:';

  @override
  String get revisedPrompt => 'الأمر المعدّل (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'تعذّر التحميل: $error';
  }

  @override
  String get generation => 'الإنشاء';

  @override
  String get generationWebInfo =>
      'تُنشأ الصور بواسطة بوت Tsumiki (ComfyUI). وتُرسل الصورة النهائية أيضًا إلى محادثتك مع البوت.';

  @override
  String get workflow => 'سير العمل';

  @override
  String get generationBackend => 'الواجهة الخلفية للإنشاء';

  @override
  String get xaiInfo => 'مفتاح API من console.x.ai للإنشاء عبر Grok.';

  @override
  String get apiKey => 'مفتاح API';

  @override
  String get ol1nInfo =>
      'AiStack محلي (واجهة Flux diffusers). أدخل رمز خدمة CF Access، أو اتركه فارغًا إذا كان مدمجًا عند البناء (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI محلي (اختيار النموذج أدناه). يشارك رمز CF Access مع llm.ol1n.com.';

  @override
  String get save => 'حفظ';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get wfAuto => 'تلقائي — اتباع القالب المختار';

  @override
  String get wfFlux => 'Flux — أنماط فنية وواقعية';

  @override
  String get wfPony => 'Pony Diffusion — أنمي، وسوم Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — واقعية سريعة';

  @override
  String get wfWai => 'WAI Illustrious — أنمي، أحدث من Pony';

  @override
  String templateChose(String workflow) {
    return 'اختار القالب: $workflow';
  }

  @override
  String get apiKeySaved => 'تم حفظ مفتاح API';

  @override
  String get reposeScreenTitle => 'Repose — وجه بوضعية';

  @override
  String get model => 'النموذج';

  @override
  String get stepFace => '1. الوجه';

  @override
  String get stepPose => '2. الوضعية';

  @override
  String get stepPrompt => '3. الأمر';

  @override
  String get negative => 'سلبي';

  @override
  String get reposePromptHint => 'صورة لامرأة، بكامل الجسم، إضاءة طبيعية…';

  @override
  String couldNotLoadModels(String error) {
    return 'تعذّر تحميل النماذج: $error';
  }

  @override
  String get noModels =>
      'لا توجد نماذج (تحقق من بيانات اعتماد CF في الإعدادات).';

  @override
  String get uploadFace => 'رفع وجه';

  @override
  String get changeFace => 'تغيير الوجه';

  @override
  String get pickFromGallery => 'اختيار من المعرض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get needCfCredentials =>
      'عيّن بيانات اعتماد Cloudflare Access في الإعدادات';

  @override
  String get baseImageSelected => 'تم اختيار الصورة الأساسية';

  @override
  String get baseImageOptional => 'الصورة الأساسية (اختياري)';

  @override
  String get remove => 'إزالة';

  @override
  String get prompt => 'الأمر';

  @override
  String get modelAutoTooltip =>
      'اختير النموذج تلقائيًا من القالب.\nيمكنك تغييره في الإعدادات.';

  @override
  String get modelManualTooltip => 'نموذج مختار يدويًا في الإعدادات.';

  @override
  String get pickBlocks => 'اختر كتلًا لتجميع أمر...';
}
