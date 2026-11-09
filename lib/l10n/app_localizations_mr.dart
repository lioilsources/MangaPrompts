// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get screenBuilder => 'प्रॉम्प्ट बिल्डर';

  @override
  String get screenRestyle => 'फोटोची शैली बदला';

  @override
  String get screenHair => 'हेअरकट करून पहा';

  @override
  String get screenAnimate => 'फोटो अ‍ॅनिमेट करा';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get shopTooltipVideo => 'अ‍ॅनिमेशन क्रेडिट आणि पॅकेज';

  @override
  String get shopTooltip => 'क्रेडिट आणि पॅकेज';

  @override
  String get switchCard => 'कार्ड बदला';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अ‍ॅनिमेशन क्रेडिट जोडले 🎉',
      one: '1 अ‍ॅनिमेशन क्रेडिट जोडले 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्रेडिट जोडले 🎉',
      one: '1 क्रेडिट जोडले 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'पेमेंट अयशस्वी झाले, कृपया पुन्हा प्रयत्न करा';

  @override
  String errorDetail(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'क्रेडिट लोड करता आले नाहीत: $error';
  }

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get animationsTitle => 'अ‍ॅनिमेशन';

  @override
  String get creditsTitle => 'क्रेडिट';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'आजची मोफत अ‍ॅनिमेशन: $limit पैकी $free · अ‍ॅनिमेशन क्रेडिट: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'आजची मोफत जनरेशन: $limit पैकी $free · क्रेडिट: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 क्रेडिट = 1 व्हिडिओ, पेमेंट Telegram Stars मध्ये.';

  @override
  String get imagePriceNote =>
      '1 क्रेडिट = 1 प्रतिमा, पेमेंट Telegram Stars मध्ये.';

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
      other: '$count अ‍ॅनिमेशन',
      one: '1 अ‍ॅनिमेशन',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose वेबवर उपलब्ध नाही';

  @override
  String get reposeTooltip => 'Repose (पोझमधील चेहरा)';

  @override
  String get presets => 'प्रीसेट';

  @override
  String get template => 'टेम्पलेट';

  @override
  String get backToTop => 'वर परत जा';

  @override
  String get generating => 'तयार होत आहे…';

  @override
  String get generate => 'तयार करा';

  @override
  String get needCredentials =>
      'सेटिंग्जमध्ये API की किंवा क्रेडेन्शियल सेट करा';

  @override
  String presetLoaded(String name) {
    return 'प्रीसेट “$name” लोड झाले';
  }

  @override
  String get connectionLostVideo =>
      'कनेक्शन तुटले — बॉट तरीही व्हिडिओ तुमच्या चॅटमध्ये पोहोचवेल.';

  @override
  String videoServerDown(String error) {
    return 'व्हिडिओ सर्व्हर सध्या उपलब्ध नाही.\n$error';
  }

  @override
  String get scene => 'दृश्य';

  @override
  String get uploading => 'अपलोड होत आहे…';

  @override
  String get animate => 'अ‍ॅनिमेट करा';

  @override
  String get pickPhoto => 'फोटो निवडा';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds से क्लिप · रेंडर ~$minutes मिनिटे';
  }

  @override
  String queuePosition(int position) {
    return 'रांगेत · क्रमांक $position';
  }

  @override
  String get queueWaiting => 'रांगेत…';

  @override
  String get finishing => 'पूर्ण होत आहे (हालचाल सुरळीत केली जात आहे)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'बीट $beat/$beats · ~$minutes मिनिटे बाकी';
  }

  @override
  String get videoDone => 'झाले! व्हिडिओ तुमच्या Telegram चॅटमध्ये पाठवला 🎬';

  @override
  String failedDetail(String error) {
    return 'अयशस्वी: $error';
  }

  @override
  String get unknownError => 'अज्ञात त्रुटी';

  @override
  String get starting => 'सुरू होत आहे…';

  @override
  String get canCloseApp => 'तुम्ही अ‍ॅप बंद करू शकता — व्हिडिओ चॅटमध्ये येईल.';

  @override
  String get notCharged => 'तुमचा मोफत व्हिडिओ / क्रेडिट वापरला गेला नाही.';

  @override
  String get animateAnother => 'आणखी एक अ‍ॅनिमेट करा';

  @override
  String get restyleHint =>
      'तुमचा चेहरा आणि पोझ तसेच ठेवते. एका व्यक्तीच्या स्पष्ट, समोरून काढलेल्या फोटोसह सर्वोत्तम काम करते.';

  @override
  String get medium => 'माध्यम';

  @override
  String get mediumPhoto => 'फोटो';

  @override
  String get mediumIllustration => 'चित्रण';

  @override
  String get style => 'शैली';

  @override
  String get filterStyles => 'शैली फिल्टर करा';

  @override
  String get restyling => 'शैली बदलत आहे…';

  @override
  String get restyle => 'शैली बदला';

  @override
  String get restyleBusy =>
      'शैली बदलत आहे… सुमारे एक मिनिट.\nप्रतिमा तुमच्या चॅटमध्येही येईल.';

  @override
  String get groupPopular => 'लोकप्रिय';

  @override
  String get groupPainters => 'चित्रकार';

  @override
  String get groupAsia => 'आशिया';

  @override
  String get groupEurope => 'युरोप';

  @override
  String get groupAmericasOceania => 'अमेरिका आणि ओशनिया';

  @override
  String get groupAfricaNearEast => 'आफ्रिका आणि जवळचे पूर्व';

  @override
  String get hairHint =>
      'तुमचा चेहरा आणि, नवा रंग निवडला नाही तर, केसांचा रंग तसाच ठेवते. केस पूर्ण दिसणाऱ्या, टोपी नसलेल्या समोरच्या पोर्ट्रेटसह सर्वोत्तम काम करते.';

  @override
  String get noHairstyles => 'अजून हेअरस्टाइल नाहीत — लवकरच पुन्हा पहा.';

  @override
  String get colour => 'रंग';

  @override
  String get keepMine => 'माझा ठेवा';

  @override
  String get haircut => 'हेअरकट';

  @override
  String get keepMyCut => 'माझा कट ठेवा';

  @override
  String get working => 'काम सुरू आहे…';

  @override
  String get newColour => 'नवा रंग';

  @override
  String get newHaircut => 'नवा हेअरकट';

  @override
  String get pickPortrait => 'पोर्ट्रेट निवडा';

  @override
  String get hairBusy =>
      'काम सुरू आहे… सुमारे एक मिनिट.\nफोटो तुमच्या चॅटमध्येही येईल.';

  @override
  String get hairWomen => 'महिला';

  @override
  String get hairMen => 'पुरुष';

  @override
  String get hairCuts => 'कट';

  @override
  String get hairBangs => 'बँग्ज';

  @override
  String get hairTexture => 'पोत';

  @override
  String get hairShort => 'लहान';

  @override
  String get hairMedium => 'मध्यम';

  @override
  String get hairLong => 'लांब';

  @override
  String get hairBraids => 'वेण्या';

  @override
  String get hairUpdos => 'अपडू';

  @override
  String get notDownloaded => 'प्रतिमा अजून डाउनलोड झालेली नाही';

  @override
  String get savedToGallery => 'गॅलरीत जतन केले';

  @override
  String couldNotSave(String error) {
    return 'जतन करता आले नाही: $error';
  }

  @override
  String get result => 'निकाल';

  @override
  String get saveToGallery => 'गॅलरीत जतन करा';

  @override
  String get copyPrompt => 'प्रॉम्प्ट कॉपी करा';

  @override
  String get promptCopied => 'प्रॉम्प्ट कॉपी केला';

  @override
  String get imageNotAvailable => 'प्रतिमा उपलब्ध नाही';

  @override
  String get promptUsed => 'वापरलेला प्रॉम्प्ट:';

  @override
  String get revisedPrompt => 'सुधारित प्रॉम्प्ट (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'लोड करता आले नाही: $error';
  }

  @override
  String get generation => 'जनरेशन';

  @override
  String get generationWebInfo =>
      'प्रतिमा Tsumiki बॉट (ComfyUI) तयार करतो. तयार प्रतिमा बॉटसोबतच्या तुमच्या चॅटमध्येही पाठवली जाते.';

  @override
  String get workflow => 'वर्कफ्लो';

  @override
  String get generationBackend => 'जनरेशन बॅकएंड';

  @override
  String get xaiInfo => 'Grok द्वारे तयार करण्यासाठी console.x.ai ची API की.';

  @override
  String get apiKey => 'API की';

  @override
  String get ol1nInfo =>
      'स्थानिक AiStack (Flux diffusers API). CF Access सर्व्हिस टोकन टाका, किंवा बिल्डमध्ये अंतर्भूत असल्यास (--dart-define) रिकामे ठेवा.';

  @override
  String get comfyInfo =>
      'स्थानिक ComfyUI (मॉडेल निवड खाली). CF Access टोकन llm.ol1n.com सोबत शेअर केले जाते.';

  @override
  String get save => 'जतन करा';

  @override
  String get saved => 'जतन केले';

  @override
  String get wfAuto => 'स्वयंचलित — निवडलेल्या टेम्पलेटनुसार';

  @override
  String get wfFlux => 'Flux — चित्रमय आणि फोटोरिअलिस्टिक शैली';

  @override
  String get wfPony => 'Pony Diffusion — अ‍ॅनिमे, Danbooru टॅग';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — जलद फोटोरिअल';

  @override
  String get wfWai => 'WAI Illustrious — अ‍ॅनिमे, Pony पेक्षा नवे';

  @override
  String templateChose(String workflow) {
    return 'टेम्पलेटने निवडले: $workflow';
  }

  @override
  String get apiKeySaved => 'API की जतन केली';

  @override
  String get reposeScreenTitle => 'Repose — पोझमधील चेहरा';

  @override
  String get model => 'मॉडेल';

  @override
  String get stepFace => '1. चेहरा';

  @override
  String get stepPose => '2. पोझ';

  @override
  String get stepPrompt => '3. प्रॉम्प्ट';

  @override
  String get negative => 'निगेटिव्ह';

  @override
  String get reposePromptHint =>
      'एका स्त्रीचा फोटो, पूर्ण शरीर, नैसर्गिक प्रकाश…';

  @override
  String couldNotLoadModels(String error) {
    return 'मॉडेल लोड करता आले नाहीत: $error';
  }

  @override
  String get noModels => 'मॉडेल नाहीत (सेटिंग्जमध्ये CF क्रेडेन्शियल तपासा).';

  @override
  String get uploadFace => 'चेहरा अपलोड करा';

  @override
  String get changeFace => 'चेहरा बदला';

  @override
  String get pickFromGallery => 'गॅलरीतून निवडा';

  @override
  String get takePhoto => 'फोटो काढा';

  @override
  String get needCfCredentials =>
      'सेटिंग्जमध्ये Cloudflare Access क्रेडेन्शियल सेट करा';

  @override
  String get baseImageSelected => 'मूळ प्रतिमा निवडली';

  @override
  String get baseImageOptional => 'मूळ प्रतिमा (ऐच्छिक)';

  @override
  String get remove => 'काढा';

  @override
  String get prompt => 'प्रॉम्प्ट';

  @override
  String get modelAutoTooltip =>
      'टेम्पलेटवरून मॉडेल आपोआप निवडले.\nसेटिंग्जमध्ये बदलता येते.';

  @override
  String get modelManualTooltip => 'सेटिंग्जमध्ये हाताने निवडलेले मॉडेल.';

  @override
  String get pickBlocks => 'प्रॉम्प्ट बनवण्यासाठी ब्लॉक निवडा...';
}
