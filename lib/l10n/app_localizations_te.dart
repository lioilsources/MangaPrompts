// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get screenBuilder => 'ప్రాంప్ట్ బిల్డర్';

  @override
  String get screenRestyle => 'ఫోటో శైలిని మార్చండి';

  @override
  String get screenHair => 'హెయిర్‌కట్ ప్రయత్నించండి';

  @override
  String get screenAnimate => 'ఫోటోను యానిమేట్ చేయండి';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get shopTooltipVideo => 'యానిమేషన్ క్రెడిట్‌లు, ప్యాకేజీలు';

  @override
  String get shopTooltip => 'క్రెడిట్‌లు, ప్యాకేజీలు';

  @override
  String get switchCard => 'కార్డ్ మార్చండి';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యానిమేషన్ క్రెడిట్‌లు జోడించబడ్డాయి 🎉',
      one: '1 యానిమేషన్ క్రెడిట్ జోడించబడింది 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count క్రెడిట్‌లు జోడించబడ్డాయి 🎉',
      one: '1 క్రెడిట్ జోడించబడింది 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'చెల్లింపు విఫలమైంది, దయచేసి మళ్లీ ప్రయత్నించండి';

  @override
  String errorDetail(String error) {
    return 'లోపం: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'క్రెడిట్‌లను లోడ్ చేయలేకపోయాం: $error';
  }

  @override
  String get tryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get animationsTitle => 'యానిమేషన్‌లు';

  @override
  String get creditsTitle => 'క్రెడిట్‌లు';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'ఈ రోజు ఉచిత యానిమేషన్‌లు: $limit లో $free · యానిమేషన్ క్రెడిట్‌లు: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'ఈ రోజు ఉచిత జనరేషన్‌లు: $limit లో $free · క్రెడిట్‌లు: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 క్రెడిట్ = 1 వీడియో, Telegram Stars లో చెల్లింపు.';

  @override
  String get imagePriceNote =>
      '1 క్రెడిట్ = 1 చిత్రం, Telegram Stars లో చెల్లింపు.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count క్రెడిట్‌లు',
      one: '1 క్రెడిట్',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యానిమేషన్‌లు',
      one: '1 యానిమేషన్',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'వెబ్‌లో Repose అందుబాటులో లేదు';

  @override
  String get reposeTooltip => 'Repose (భంగిమలో ముఖం)';

  @override
  String get presets => 'ప్రీసెట్‌లు';

  @override
  String get template => 'టెంప్లేట్';

  @override
  String get backToTop => 'పైకి తిరిగి వెళ్లండి';

  @override
  String get generating => 'సృష్టిస్తోంది…';

  @override
  String get generate => 'సృష్టించండి';

  @override
  String get needCredentials =>
      'సెట్టింగ్‌లలో API కీ లేదా ఆధారాలను సెట్ చేయండి';

  @override
  String presetLoaded(String name) {
    return 'ప్రీసెట్ “$name” లోడ్ అయింది';
  }

  @override
  String get connectionLostVideo =>
      'కనెక్షన్ తెగిపోయింది — బాట్ అయినా వీడియోను మీ చాట్‌కు అందజేస్తుంది.';

  @override
  String videoServerDown(String error) {
    return 'వీడియో సర్వర్ ఇప్పుడు అందుబాటులో లేదు.\n$error';
  }

  @override
  String get scene => 'దృశ్యం';

  @override
  String get uploading => 'అప్‌లోడ్ అవుతోంది…';

  @override
  String get animate => 'యానిమేట్ చేయండి';

  @override
  String get pickPhoto => 'ఫోటో ఎంచుకోండి';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds సె క్లిప్ · రెండర్ ~$minutes నిమిషాలు';
  }

  @override
  String queuePosition(int position) {
    return 'క్యూలో · స్థానం $position';
  }

  @override
  String get queueWaiting => 'క్యూలో…';

  @override
  String get finishing => 'ముగిస్తోంది (కదలికను సున్నితం చేస్తోంది)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'బీట్ $beat/$beats · ~$minutes నిమిషాలు మిగిలాయి';
  }

  @override
  String get videoDone => 'అయిపోయింది! వీడియో మీ Telegram చాట్‌కు పంపబడింది 🎬';

  @override
  String failedDetail(String error) {
    return 'విఫలమైంది: $error';
  }

  @override
  String get unknownError => 'తెలియని లోపం';

  @override
  String get starting => 'ప్రారంభమవుతోంది…';

  @override
  String get canCloseApp =>
      'మీరు యాప్‌ను మూసివేయవచ్చు — వీడియో చాట్‌కు వస్తుంది.';

  @override
  String get notCharged => 'మీ ఉచిత వీడియో / క్రెడిట్ ఖర్చు కాలేదు.';

  @override
  String get animateAnother => 'మరొకటి యానిమేట్ చేయండి';

  @override
  String get restyleHint =>
      'మీ ముఖం, భంగిమను అలాగే ఉంచుతుంది. ఒక వ్యక్తి స్పష్టమైన, ముందు నుండి తీసిన ఫోటోతో ఉత్తమంగా పనిచేస్తుంది.';

  @override
  String get medium => 'మాధ్యమం';

  @override
  String get mediumPhoto => 'ఫోటో';

  @override
  String get mediumIllustration => 'చిత్రీకరణ';

  @override
  String get style => 'శైలి';

  @override
  String get filterStyles => 'శైలులను ఫిల్టర్ చేయండి';

  @override
  String get restyling => 'శైలి మారుస్తోంది…';

  @override
  String get restyle => 'శైలి మార్చండి';

  @override
  String get restyleBusy =>
      'శైలి మారుస్తోంది… సుమారు ఒక నిమిషం.\nచిత్రం మీ చాట్‌కు కూడా వస్తుంది.';

  @override
  String get groupPopular => 'ప్రసిద్ధమైనవి';

  @override
  String get groupPainters => 'చిత్రకారులు';

  @override
  String get groupAsia => 'ఆసియా';

  @override
  String get groupEurope => 'యూరప్';

  @override
  String get groupAmericasOceania => 'అమెరికాలు & ఓషియానియా';

  @override
  String get groupAfricaNearEast => 'ఆఫ్రికా & సమీప తూర్పు';

  @override
  String get hairHint =>
      'మీ ముఖాన్ని, కొత్త రంగు ఎంచుకోకపోతే జుట్టు రంగును అలాగే ఉంచుతుంది. జుట్టు పూర్తిగా కనిపించే, టోపీ లేని ముందు నుండి తీసిన పోర్ట్రెయిట్‌తో ఉత్తమంగా పనిచేస్తుంది.';

  @override
  String get noHairstyles =>
      'ఇంకా హెయిర్‌స్టైల్‌లు లేవు — త్వరలో మళ్లీ చూడండి.';

  @override
  String get colour => 'రంగు';

  @override
  String get keepMine => 'నాదాన్ని ఉంచు';

  @override
  String get haircut => 'హెయిర్‌కట్';

  @override
  String get keepMyCut => 'నా కట్ ఉంచు';

  @override
  String get working => 'పని జరుగుతోంది…';

  @override
  String get newColour => 'కొత్త రంగు';

  @override
  String get newHaircut => 'కొత్త హెయిర్‌కట్';

  @override
  String get pickPortrait => 'పోర్ట్రెయిట్ ఎంచుకోండి';

  @override
  String get hairBusy =>
      'పని జరుగుతోంది… సుమారు ఒక నిమిషం.\nఫోటో మీ చాట్‌కు కూడా వస్తుంది.';

  @override
  String get hairWomen => 'మహిళలు';

  @override
  String get hairMen => 'పురుషులు';

  @override
  String get hairCuts => 'కట్‌లు';

  @override
  String get hairBangs => 'బ్యాంగ్స్';

  @override
  String get hairTexture => 'ఆకృతి';

  @override
  String get hairShort => 'పొట్టి';

  @override
  String get hairMedium => 'మధ్యస్థం';

  @override
  String get hairLong => 'పొడవు';

  @override
  String get hairBraids => 'జడలు';

  @override
  String get hairUpdos => 'అప్‌డోలు';

  @override
  String get notDownloaded => 'చిత్రం ఇంకా డౌన్‌లోడ్ కాలేదు';

  @override
  String get savedToGallery => 'గ్యాలరీలో సేవ్ చేయబడింది';

  @override
  String couldNotSave(String error) {
    return 'సేవ్ చేయలేకపోయాం: $error';
  }

  @override
  String get result => 'ఫలితం';

  @override
  String get saveToGallery => 'గ్యాలరీలో సేవ్ చేయండి';

  @override
  String get copyPrompt => 'ప్రాంప్ట్ కాపీ చేయండి';

  @override
  String get promptCopied => 'ప్రాంప్ట్ కాపీ అయింది';

  @override
  String get imageNotAvailable => 'చిత్రం అందుబాటులో లేదు';

  @override
  String get promptUsed => 'ఉపయోగించిన ప్రాంప్ట్:';

  @override
  String get revisedPrompt => 'సవరించిన ప్రాంప్ట్ (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'లోడ్ చేయలేకపోయాం: $error';
  }

  @override
  String get generation => 'జనరేషన్';

  @override
  String get generationWebInfo =>
      'చిత్రాలను Tsumiki బాట్ (ComfyUI) సృష్టిస్తుంది. పూర్తయిన చిత్రం బాట్‌తో మీ చాట్‌కు కూడా పంపబడుతుంది.';

  @override
  String get workflow => 'వర్క్‌ఫ్లో';

  @override
  String get generationBackend => 'జనరేషన్ బ్యాకెండ్';

  @override
  String get xaiInfo => 'Grok ద్వారా సృష్టించడానికి console.x.ai నుండి API కీ.';

  @override
  String get apiKey => 'API కీ';

  @override
  String get ol1nInfo =>
      'స్థానిక AiStack (Flux diffusers API). CF Access సర్వీస్ టోకెన్ నమోదు చేయండి, లేదా బిల్డ్‌లో పొందుపరిచి ఉంటే (--dart-define) ఖాళీగా వదలండి.';

  @override
  String get comfyInfo =>
      'స్థానిక ComfyUI (మోడల్ ఎంపిక కింద). CF Access టోకెన్‌ను llm.ol1n.com తో పంచుకుంటుంది.';

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get saved => 'సేవ్ అయింది';

  @override
  String get wfAuto => 'ఆటోమేటిక్ — ఎంచుకున్న టెంప్లేట్‌ను అనుసరించు';

  @override
  String get wfFlux => 'Flux — చిత్రకళా, ఫోటోరియలిస్టిక్ శైలులు';

  @override
  String get wfPony => 'Pony Diffusion — అనిమే, Danbooru ట్యాగ్‌లు';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — వేగవంతమైన ఫోటోరియల్';

  @override
  String get wfWai => 'WAI Illustrious — అనిమే, Pony కంటే కొత్తది';

  @override
  String templateChose(String workflow) {
    return 'టెంప్లేట్ ఎంచుకున్నది: $workflow';
  }

  @override
  String get apiKeySaved => 'API కీ సేవ్ అయింది';

  @override
  String get reposeScreenTitle => 'Repose — భంగిమలో ముఖం';

  @override
  String get model => 'మోడల్';

  @override
  String get stepFace => '1. ముఖం';

  @override
  String get stepPose => '2. భంగిమ';

  @override
  String get stepPrompt => '3. ప్రాంప్ట్';

  @override
  String get negative => 'నెగెటివ్';

  @override
  String get reposePromptHint => 'ఒక స్త్రీ ఫోటో, పూర్తి శరీరం, సహజ కాంతి…';

  @override
  String couldNotLoadModels(String error) {
    return 'మోడల్‌లను లోడ్ చేయలేకపోయాం: $error';
  }

  @override
  String get noModels =>
      'మోడల్‌లు లేవు (సెట్టింగ్‌లలో CF ఆధారాలను తనిఖీ చేయండి).';

  @override
  String get uploadFace => 'ముఖం అప్‌లోడ్ చేయండి';

  @override
  String get changeFace => 'ముఖం మార్చండి';

  @override
  String get pickFromGallery => 'గ్యాలరీ నుండి ఎంచుకోండి';

  @override
  String get takePhoto => 'ఫోటో తీయండి';

  @override
  String get needCfCredentials =>
      'సెట్టింగ్‌లలో Cloudflare Access ఆధారాలను సెట్ చేయండి';

  @override
  String get baseImageSelected => 'ఆధార చిత్రం ఎంచుకోబడింది';

  @override
  String get baseImageOptional => 'ఆధార చిత్రం (ఐచ్ఛికం)';

  @override
  String get remove => 'తొలగించండి';

  @override
  String get prompt => 'ప్రాంప్ట్';

  @override
  String get modelAutoTooltip =>
      'టెంప్లేట్ నుండి మోడల్ ఆటోమేటిక్‌గా ఎంచుకోబడింది.\nసెట్టింగ్‌లలో మార్చవచ్చు.';

  @override
  String get modelManualTooltip =>
      'సెట్టింగ్‌లలో మాన్యువల్‌గా ఎంచుకున్న మోడల్.';

  @override
  String get pickBlocks => 'ప్రాంప్ట్ రూపొందించడానికి బ్లాక్‌లను ఎంచుకోండి...';
}
