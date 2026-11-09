// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get screenBuilder => 'בונה פרומפטים';

  @override
  String get screenRestyle => 'שינוי סגנון תמונה';

  @override
  String get screenHair => 'נסו תספורת';

  @override
  String get screenAnimate => 'הנפשת תמונה';

  @override
  String get settings => 'הגדרות';

  @override
  String get shopTooltipVideo => 'קרדיטים להנפשה וחבילות';

  @override
  String get shopTooltip => 'קרדיטים וחבילות';

  @override
  String get switchCard => 'החלפת כרטיס';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נוספו $count קרדיטים להנפשה 🎉',
      two: 'נוספו שני קרדיטים להנפשה 🎉',
      one: 'נוסף קרדיט הנפשה אחד 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נוספו $count קרדיטים 🎉',
      two: 'נוספו שני קרדיטים 🎉',
      one: 'נוסף קרדיט אחד 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'התשלום נכשל, נסו שוב';

  @override
  String errorDetail(String error) {
    return 'שגיאה: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'טעינת הקרדיטים נכשלה: $error';
  }

  @override
  String get tryAgain => 'נסו שוב';

  @override
  String get animationsTitle => 'הנפשות';

  @override
  String get creditsTitle => 'קרדיטים';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'הנפשות חינם היום: $free מתוך $limit · קרדיטים להנפשה: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'יצירות חינם היום: $free מתוך $limit · קרדיטים: $credits';
  }

  @override
  String get videoPriceNote =>
      'קרדיט אחד = סרטון אחד, בתשלום ב‑Telegram Stars.';

  @override
  String get imagePriceNote =>
      'קרדיט אחד = תמונה אחת, בתשלום ב‑Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count קרדיטים',
      two: 'שני קרדיטים',
      one: 'קרדיט אחד',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count הנפשות',
      two: 'שתי הנפשות',
      one: 'הנפשה אחת',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose אינו זמין באינטרנט';

  @override
  String get reposeTooltip => 'Repose (פנים בתנוחה)';

  @override
  String get presets => 'הגדרות מוכנות';

  @override
  String get template => 'תבנית';

  @override
  String get backToTop => 'חזרה למעלה';

  @override
  String get generating => 'יוצר…';

  @override
  String get generate => 'צור';

  @override
  String get needCredentials => 'הגדירו מפתח API או פרטי גישה בהגדרות';

  @override
  String presetLoaded(String name) {
    return 'ההגדרה המוכנה „$name” נטענה';
  }

  @override
  String get connectionLostVideo =>
      'החיבור אבד — הבוט עדיין ישלח את הסרטון לצ׳אט שלכם.';

  @override
  String videoServerDown(String error) {
    return 'שרת הווידאו אינו זמין כרגע.\n$error';
  }

  @override
  String get scene => 'סצנה';

  @override
  String get uploading => 'מעלה…';

  @override
  String get animate => 'הנפש';

  @override
  String get pickPhoto => 'בחרו תמונה';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'קליפ של ~$seconds שנ׳ · רינדור ~$minutes דק׳';
  }

  @override
  String queuePosition(int position) {
    return 'בתור · מקום $position';
  }

  @override
  String get queueWaiting => 'בתור…';

  @override
  String get finishing => 'מסיים (מחליק את התנועה)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'פעימה $beat/$beats · נותרו ~$minutes דק׳';
  }

  @override
  String get videoDone => 'הסתיים! הסרטון נשלח לצ׳אט שלכם בטלגרם 🎬';

  @override
  String failedDetail(String error) {
    return 'נכשל: $error';
  }

  @override
  String get unknownError => 'שגיאה לא ידועה';

  @override
  String get starting => 'מתחיל…';

  @override
  String get canCloseApp => 'אפשר לסגור את האפליקציה — הסרטון יגיע לצ׳אט.';

  @override
  String get notCharged => 'הסרטון החינמי / הקרדיט שלכם לא נוצל.';

  @override
  String get animateAnother => 'הנפש עוד אחת';

  @override
  String get restyleHint =>
      'שומר על הפנים והתנוחה שלכם. עובד הכי טוב עם תמונה חדה מלפנים של אדם אחד.';

  @override
  String get medium => 'מדיום';

  @override
  String get mediumPhoto => 'צילום';

  @override
  String get mediumIllustration => 'איור';

  @override
  String get style => 'סגנון';

  @override
  String get filterStyles => 'סינון סגנונות';

  @override
  String get restyling => 'משנה סגנון…';

  @override
  String get restyle => 'שנה סגנון';

  @override
  String get restyleBusy => 'משנה סגנון… כדקה.\nהתמונה תגיע גם לצ׳אט שלכם.';

  @override
  String get groupPopular => 'פופולריים';

  @override
  String get groupPainters => 'ציירים';

  @override
  String get groupAsia => 'אסיה';

  @override
  String get groupEurope => 'אירופה';

  @override
  String get groupAmericasOceania => 'אמריקה ואוקיאניה';

  @override
  String get groupAfricaNearEast => 'אפריקה והמזרח התיכון';

  @override
  String get hairHint =>
      'שומר על הפנים ועל צבע השיער שלכם, אלא אם תבחרו צבע חדש. עובד הכי טוב עם פורטרט מלפנים שבו השיער נראה במלואו, בלי כובע.';

  @override
  String get noHairstyles => 'עדיין אין תסרוקות — חזרו בקרוב.';

  @override
  String get colour => 'צבע';

  @override
  String get keepMine => 'השאר את שלי';

  @override
  String get haircut => 'תספורת';

  @override
  String get keepMyCut => 'השאר את התספורת שלי';

  @override
  String get working => 'עובד…';

  @override
  String get newColour => 'צבע חדש';

  @override
  String get newHaircut => 'תספורת חדשה';

  @override
  String get pickPortrait => 'בחרו פורטרט';

  @override
  String get hairBusy => 'עובד… כדקה.\nהתמונה תגיע גם לצ׳אט שלכם.';

  @override
  String get hairWomen => 'נשים';

  @override
  String get hairMen => 'גברים';

  @override
  String get hairCuts => 'תספורות';

  @override
  String get hairBangs => 'פוני';

  @override
  String get hairTexture => 'מרקם';

  @override
  String get hairShort => 'קצר';

  @override
  String get hairMedium => 'בינוני';

  @override
  String get hairLong => 'ארוך';

  @override
  String get hairBraids => 'צמות';

  @override
  String get hairUpdos => 'תסרוקות אסופות';

  @override
  String get notDownloaded => 'התמונה עדיין לא הורדה';

  @override
  String get savedToGallery => 'נשמר בגלריה';

  @override
  String couldNotSave(String error) {
    return 'השמירה נכשלה: $error';
  }

  @override
  String get result => 'תוצאה';

  @override
  String get saveToGallery => 'שמור בגלריה';

  @override
  String get copyPrompt => 'העתק פרומפט';

  @override
  String get promptCopied => 'הפרומפט הועתק';

  @override
  String get imageNotAvailable => 'התמונה אינה זמינה';

  @override
  String get promptUsed => 'הפרומפט שנעשה בו שימוש:';

  @override
  String get revisedPrompt => 'פרומפט מתוקן (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'הטעינה נכשלה: $error';
  }

  @override
  String get generation => 'יצירה';

  @override
  String get generationWebInfo =>
      'התמונות נוצרות על ידי הבוט של Tsumiki (ComfyUI). התמונה המוכנה נשלחת גם לצ׳אט שלכם עם הבוט.';

  @override
  String get workflow => 'תהליך עבודה';

  @override
  String get generationBackend => 'מנוע יצירה';

  @override
  String get xaiInfo => 'מפתח API מ‑console.x.ai ליצירה דרך Grok.';

  @override
  String get apiKey => 'מפתח API';

  @override
  String get ol1nInfo =>
      'AiStack מקומי (ממשק Flux diffusers). הזינו אסימון שירות של CF Access, או השאירו ריק אם הוא מוטמע בבנייה (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI מקומי (בחירת מודל למטה). משתף את אסימון CF Access עם llm.ol1n.com.';

  @override
  String get save => 'שמור';

  @override
  String get saved => 'נשמר';

  @override
  String get wfAuto => 'אוטומטי — לפי התבנית שנבחרה';

  @override
  String get wfFlux => 'Flux — סגנונות ציוריים ופוטוריאליסטיים';

  @override
  String get wfPony => 'Pony Diffusion — אנימה, תגיות Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — פוטוריאליזם מהיר';

  @override
  String get wfWai => 'WAI Illustrious — אנימה, חדש יותר מ‑Pony';

  @override
  String templateChose(String workflow) {
    return 'התבנית בחרה: $workflow';
  }

  @override
  String get apiKeySaved => 'מפתח ה‑API נשמר';

  @override
  String get reposeScreenTitle => 'Repose — פנים בתנוחה';

  @override
  String get model => 'מודל';

  @override
  String get stepFace => '1. פנים';

  @override
  String get stepPose => '2. תנוחה';

  @override
  String get stepPrompt => '3. פרומפט';

  @override
  String get negative => 'שלילי';

  @override
  String get reposePromptHint => 'תצלום של אישה, גוף מלא, אור טבעי…';

  @override
  String couldNotLoadModels(String error) {
    return 'טעינת המודלים נכשלה: $error';
  }

  @override
  String get noModels => 'אין מודלים (בדקו את פרטי הגישה של CF בהגדרות).';

  @override
  String get uploadFace => 'העלאת פנים';

  @override
  String get changeFace => 'החלפת פנים';

  @override
  String get pickFromGallery => 'בחירה מהגלריה';

  @override
  String get takePhoto => 'צילום תמונה';

  @override
  String get needCfCredentials =>
      'הגדירו את פרטי הגישה של Cloudflare Access בהגדרות';

  @override
  String get baseImageSelected => 'נבחרה תמונת בסיס';

  @override
  String get baseImageOptional => 'תמונת בסיס (אופציונלי)';

  @override
  String get remove => 'הסר';

  @override
  String get prompt => 'פרומפט';

  @override
  String get modelAutoTooltip =>
      'המודל נבחר אוטומטית לפי התבנית.\nאפשר לשנות אותו בהגדרות.';

  @override
  String get modelManualTooltip => 'מודל שנבחר ידנית בהגדרות.';

  @override
  String get pickBlocks => 'בחרו אבני בניין כדי להרכיב פרומפט...';
}
