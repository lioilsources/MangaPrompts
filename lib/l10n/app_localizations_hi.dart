// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get screenBuilder => 'प्रॉम्प्ट बिल्डर';

  @override
  String get screenRestyle => 'फ़ोटो की शैली बदलें';

  @override
  String get screenHair => 'हेयरकट आज़माएँ';

  @override
  String get screenAnimate => 'फ़ोटो को एनिमेट करें';

  @override
  String get settings => 'सेटिंग';

  @override
  String get shopTooltipVideo => 'एनिमेशन क्रेडिट और पैकेज';

  @override
  String get shopTooltip => 'क्रेडिट और पैकेज';

  @override
  String get switchCard => 'कार्ड बदलें';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एनिमेशन क्रेडिट जुड़ गए 🎉',
      one: '1 एनिमेशन क्रेडिट जुड़ गया 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्रेडिट जुड़ गए 🎉',
      one: '1 क्रेडिट जुड़ गया 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'भुगतान विफल रहा, कृपया फिर कोशिश करें';

  @override
  String errorDetail(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'क्रेडिट लोड नहीं हो सके: $error';
  }

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get animationsTitle => 'एनिमेशन';

  @override
  String get creditsTitle => 'क्रेडिट';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'आज के मुफ़्त एनिमेशन: $limit में से $free · एनिमेशन क्रेडिट: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'आज के मुफ़्त जनरेशन: $limit में से $free · क्रेडिट: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 क्रेडिट = 1 वीडियो, भुगतान Telegram Stars में।';

  @override
  String get imagePriceNote =>
      '1 क्रेडिट = 1 चित्र, भुगतान Telegram Stars में।';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्रेडिट',
      one: '1 क्रेडिट',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एनिमेशन',
      one: '1 एनिमेशन',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose वेब पर उपलब्ध नहीं है';

  @override
  String get reposeTooltip => 'Repose (पोज़ में चेहरा)';

  @override
  String get presets => 'प्रीसेट';

  @override
  String get template => 'टेम्पलेट';

  @override
  String get backToTop => 'ऊपर वापस जाएँ';

  @override
  String get generating => 'बना रहा है…';

  @override
  String get generate => 'बनाएँ';

  @override
  String get needCredentials => 'सेटिंग में API कुंजी या क्रेडेंशियल सेट करें';

  @override
  String presetLoaded(String name) {
    return 'प्रीसेट “$name” लोड हुआ';
  }

  @override
  String get connectionLostVideo =>
      'कनेक्शन टूट गया — बॉट फिर भी वीडियो आपकी चैट में पहुँचा देगा।';

  @override
  String videoServerDown(String error) {
    return 'वीडियो सर्वर अभी उपलब्ध नहीं है।\n$error';
  }

  @override
  String get scene => 'दृश्य';

  @override
  String get uploading => 'अपलोड हो रहा है…';

  @override
  String get animate => 'एनिमेट करें';

  @override
  String get pickPhoto => 'फ़ोटो चुनें';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'लगभग $seconds सेकंड की क्लिप · रेंडर लगभग $minutes मिनट';
  }

  @override
  String queuePosition(int position) {
    return 'कतार में · स्थान $position';
  }

  @override
  String get queueWaiting => 'कतार में…';

  @override
  String get finishing => 'पूरा हो रहा है (गति को सहज बनाया जा रहा है)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'बीट $beat/$beats · लगभग $minutes मिनट बाकी';
  }

  @override
  String get videoDone =>
      'हो गया! वीडियो आपकी Telegram चैट में भेज दिया गया 🎬';

  @override
  String failedDetail(String error) {
    return 'विफल: $error';
  }

  @override
  String get unknownError => 'अज्ञात त्रुटि';

  @override
  String get starting => 'शुरू हो रहा है…';

  @override
  String get canCloseApp => 'आप ऐप बंद कर सकते हैं — वीडियो चैट में आ जाएगा।';

  @override
  String get notCharged => 'आपका मुफ़्त वीडियो / क्रेडिट ख़र्च नहीं हुआ।';

  @override
  String get animateAnother => 'एक और एनिमेट करें';

  @override
  String get restyleHint =>
      'आपका चेहरा और पोज़ बना रहता है। एक व्यक्ति की साफ़, सामने से ली गई फ़ोटो के साथ सबसे अच्छा काम करता है।';

  @override
  String get medium => 'माध्यम';

  @override
  String get mediumPhoto => 'फ़ोटो';

  @override
  String get mediumIllustration => 'चित्रण';

  @override
  String get style => 'शैली';

  @override
  String get filterStyles => 'शैलियाँ फ़िल्टर करें';

  @override
  String get restyling => 'शैली बदली जा रही है…';

  @override
  String get restyle => 'शैली बदलें';

  @override
  String get restyleBusy =>
      'शैली बदली जा रही है… लगभग एक मिनट।\nचित्र आपकी चैट में भी आएगा।';

  @override
  String get groupPopular => 'लोकप्रिय';

  @override
  String get groupPainters => 'चित्रकार';

  @override
  String get groupAsia => 'एशिया';

  @override
  String get groupEurope => 'यूरोप';

  @override
  String get groupAmericasOceania => 'अमेरिका और ओशिनिया';

  @override
  String get groupAfricaNearEast => 'अफ़्रीका और निकट पूर्व';

  @override
  String get hairHint =>
      'आपका चेहरा और बालों का रंग बना रहता है, जब तक आप नया रंग न चुनें। सामने से ली गई ऐसी पोर्ट्रेट के साथ सबसे अच्छा काम करता है जिसमें बाल पूरे दिखें और टोपी न हो।';

  @override
  String get noHairstyles => 'अभी कोई हेयरस्टाइल नहीं — जल्द फिर देखें।';

  @override
  String get colour => 'रंग';

  @override
  String get keepMine => 'मेरा रखें';

  @override
  String get haircut => 'हेयरकट';

  @override
  String get keepMyCut => 'मेरा कट रखें';

  @override
  String get working => 'काम हो रहा है…';

  @override
  String get newColour => 'नया रंग';

  @override
  String get newHaircut => 'नया हेयरकट';

  @override
  String get pickPortrait => 'पोर्ट्रेट चुनें';

  @override
  String get hairBusy =>
      'काम हो रहा है… लगभग एक मिनट।\nफ़ोटो आपकी चैट में भी आएगी।';

  @override
  String get hairWomen => 'महिलाएँ';

  @override
  String get hairMen => 'पुरुष';

  @override
  String get hairCuts => 'कट';

  @override
  String get hairBangs => 'बैंग्स';

  @override
  String get hairTexture => 'बनावट';

  @override
  String get hairShort => 'छोटे';

  @override
  String get hairMedium => 'मध्यम';

  @override
  String get hairLong => 'लंबे';

  @override
  String get hairBraids => 'चोटियाँ';

  @override
  String get hairUpdos => 'अपडू';

  @override
  String get notDownloaded => 'चित्र अभी डाउनलोड नहीं हुआ है';

  @override
  String get savedToGallery => 'गैलरी में सहेजा गया';

  @override
  String couldNotSave(String error) {
    return 'सहेजा नहीं जा सका: $error';
  }

  @override
  String get result => 'परिणाम';

  @override
  String get saveToGallery => 'गैलरी में सहेजें';

  @override
  String get copyPrompt => 'प्रॉम्प्ट कॉपी करें';

  @override
  String get promptCopied => 'प्रॉम्प्ट कॉपी हो गया';

  @override
  String get imageNotAvailable => 'चित्र उपलब्ध नहीं है';

  @override
  String get promptUsed => 'उपयोग किया गया प्रॉम्प्ट:';

  @override
  String get revisedPrompt => 'संशोधित प्रॉम्प्ट (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'लोड नहीं हो सका: $error';
  }

  @override
  String get generation => 'जनरेशन';

  @override
  String get generationWebInfo =>
      'चित्र Tsumiki बॉट (ComfyUI) बनाता है। तैयार चित्र बॉट के साथ आपकी चैट में भी भेजा जाता है।';

  @override
  String get workflow => 'वर्कफ़्लो';

  @override
  String get generationBackend => 'जनरेशन बैकएंड';

  @override
  String get xaiInfo => 'Grok से बनाने के लिए console.x.ai की API कुंजी।';

  @override
  String get apiKey => 'API कुंजी';

  @override
  String get ol1nInfo =>
      'स्थानीय AiStack (Flux diffusers API)। CF Access सर्विस टोकन डालें, या बिल्ड में शामिल हो (--dart-define) तो खाली छोड़ दें।';

  @override
  String get comfyInfo =>
      'स्थानीय ComfyUI (मॉडल का चयन नीचे)। CF Access टोकन llm.ol1n.com के साथ साझा होता है।';

  @override
  String get save => 'सहेजें';

  @override
  String get saved => 'सहेजा गया';

  @override
  String get wfAuto => 'स्वचालित — चुने गए टेम्पलेट के अनुसार';

  @override
  String get wfFlux => 'Flux — चित्रात्मक और फ़ोटोरियलिस्टिक शैलियाँ';

  @override
  String get wfPony => 'Pony Diffusion — एनिमे, Danbooru टैग';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — तेज़ फ़ोटोरियलिस्टिक';

  @override
  String get wfWai => 'WAI Illustrious — एनिमे, Pony से नया';

  @override
  String templateChose(String workflow) {
    return 'टेम्पलेट ने चुना: $workflow';
  }

  @override
  String get apiKeySaved => 'API कुंजी सहेजी गई';

  @override
  String get reposeScreenTitle => 'Repose — पोज़ में चेहरा';

  @override
  String get model => 'मॉडल';

  @override
  String get stepFace => '1. चेहरा';

  @override
  String get stepPose => '2. पोज़';

  @override
  String get stepPrompt => '3. प्रॉम्प्ट';

  @override
  String get negative => 'नकारात्मक';

  @override
  String get reposePromptHint =>
      'एक महिला की फ़ोटो, पूरा शरीर, प्राकृतिक रोशनी…';

  @override
  String couldNotLoadModels(String error) {
    return 'मॉडल लोड नहीं हो सके: $error';
  }

  @override
  String get noModels => 'कोई मॉडल नहीं (सेटिंग में CF क्रेडेंशियल जाँचें)।';

  @override
  String get uploadFace => 'चेहरा अपलोड करें';

  @override
  String get changeFace => 'चेहरा बदलें';

  @override
  String get pickFromGallery => 'गैलरी से चुनें';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get needCfCredentials =>
      'सेटिंग में Cloudflare Access क्रेडेंशियल सेट करें';

  @override
  String get baseImageSelected => 'आधार चित्र चुना गया';

  @override
  String get baseImageOptional => 'आधार चित्र (वैकल्पिक)';

  @override
  String get remove => 'हटाएँ';

  @override
  String get prompt => 'प्रॉम्प्ट';

  @override
  String get modelAutoTooltip =>
      'मॉडल टेम्पलेट से अपने-आप चुना गया।\nआप इसे सेटिंग में बदल सकते हैं।';

  @override
  String get modelManualTooltip => 'मॉडल सेटिंग में हाथ से चुना गया।';

  @override
  String get pickBlocks => 'प्रॉम्प्ट बनाने के लिए ब्लॉक चुनें...';
}
