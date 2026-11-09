// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get screenBuilder => 'પ્રૉમ્પ્ટ બિલ્ડર';

  @override
  String get screenRestyle => 'ફોટોની શૈલી બદલો';

  @override
  String get screenHair => 'હેરકટ અજમાવો';

  @override
  String get screenAnimate => 'ફોટોને એનિમેટ કરો';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get shopTooltipVideo => 'એનિમેશન ક્રેડિટ અને પૅકેજ';

  @override
  String get shopTooltip => 'ક્રેડિટ અને પૅકેજ';

  @override
  String get switchCard => 'કાર્ડ બદલો';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count એનિમેશન ક્રેડિટ ઉમેરાયા 🎉',
      one: '1 એનિમેશન ક્રેડિટ ઉમેરાયું 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ક્રેડિટ ઉમેરાયા 🎉',
      one: '1 ક્રેડિટ ઉમેરાયું 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ચુકવણી નિષ્ફળ ગઈ, ફરી પ્રયાસ કરો';

  @override
  String errorDetail(String error) {
    return 'ભૂલ: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'ક્રેડિટ લોડ થઈ શક્યા નથી: $error';
  }

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get animationsTitle => 'એનિમેશન';

  @override
  String get creditsTitle => 'ક્રેડિટ';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'આજના મફત એનિમેશન: $limit માંથી $free · એનિમેશન ક્રેડિટ: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'આજના મફત જનરેશન: $limit માંથી $free · ક્રેડિટ: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 ક્રેડિટ = 1 વીડિયો, ચુકવણી Telegram Stars માં.';

  @override
  String get imagePriceNote => '1 ક્રેડિટ = 1 છબી, ચુકવણી Telegram Stars માં.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ક્રેડિટ',
      one: '1 ક્રેડિટ',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count એનિમેશન',
      one: '1 એનિમેશન',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose વેબ પર ઉપલબ્ધ નથી';

  @override
  String get reposeTooltip => 'Repose (પોઝમાં ચહેરો)';

  @override
  String get presets => 'પ્રીસેટ';

  @override
  String get template => 'ટેમ્પલેટ';

  @override
  String get backToTop => 'ઉપર પાછા જાઓ';

  @override
  String get generating => 'બનાવી રહ્યું છે…';

  @override
  String get generate => 'બનાવો';

  @override
  String get needCredentials => 'સેટિંગ્સમાં API કી અથવા ઓળખપત્રો સેટ કરો';

  @override
  String presetLoaded(String name) {
    return 'પ્રીસેટ “$name” લોડ થયું';
  }

  @override
  String get connectionLostVideo =>
      'કનેક્શન તૂટ્યું — બૉટ છતાં વીડિયો તમારી ચેટમાં પહોંચાડશે.';

  @override
  String videoServerDown(String error) {
    return 'વીડિયો સર્વર હાલ ઉપલબ્ધ નથી.\n$error';
  }

  @override
  String get scene => 'દૃશ્ય';

  @override
  String get uploading => 'અપલોડ થઈ રહ્યું છે…';

  @override
  String get animate => 'એનિમેટ કરો';

  @override
  String get pickPhoto => 'ફોટો પસંદ કરો';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds સેકન્ડની ક્લિપ · રેન્ડર ~$minutes મિનિટ';
  }

  @override
  String queuePosition(int position) {
    return 'કતારમાં · સ્થાન $position';
  }

  @override
  String get queueWaiting => 'કતારમાં…';

  @override
  String get finishing => 'પૂરું થઈ રહ્યું છે (ગતિ સરળ બનાવાય છે)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'બીટ $beat/$beats · ~$minutes મિનિટ બાકી';
  }

  @override
  String get videoDone => 'થઈ ગયું! વીડિયો તમારી Telegram ચેટમાં મોકલાયો 🎬';

  @override
  String failedDetail(String error) {
    return 'નિષ્ફળ: $error';
  }

  @override
  String get unknownError => 'અજ્ઞાત ભૂલ';

  @override
  String get starting => 'શરૂ થઈ રહ્યું છે…';

  @override
  String get canCloseApp => 'તમે ઍપ બંધ કરી શકો છો — વીડિયો ચેટમાં આવશે.';

  @override
  String get notCharged => 'તમારો મફત વીડિયો / ક્રેડિટ વપરાયો નથી.';

  @override
  String get animateAnother => 'બીજો એનિમેટ કરો';

  @override
  String get restyleHint =>
      'તમારો ચહેરો અને પોઝ જાળવે છે. એક વ્યક્તિના સ્પષ્ટ, સામેથી લીધેલા ફોટા સાથે શ્રેષ્ઠ કામ કરે છે.';

  @override
  String get medium => 'માધ્યમ';

  @override
  String get mediumPhoto => 'ફોટો';

  @override
  String get mediumIllustration => 'ચિત્રણ';

  @override
  String get style => 'શૈલી';

  @override
  String get filterStyles => 'શૈલીઓ ફિલ્ટર કરો';

  @override
  String get restyling => 'શૈલી બદલાઈ રહી છે…';

  @override
  String get restyle => 'શૈલી બદલો';

  @override
  String get restyleBusy =>
      'શૈલી બદલાઈ રહી છે… લગભગ એક મિનિટ.\nછબી તમારી ચેટમાં પણ આવશે.';

  @override
  String get groupPopular => 'લોકપ્રિય';

  @override
  String get groupPainters => 'ચિત્રકારો';

  @override
  String get groupAsia => 'એશિયા';

  @override
  String get groupEurope => 'યુરોપ';

  @override
  String get groupAmericasOceania => 'અમેરિકા અને ઓશનિયા';

  @override
  String get groupAfricaNearEast => 'આફ્રિકા અને નજીકનું પૂર્વ';

  @override
  String get hairHint =>
      'તમારો ચહેરો અને, નવો રંગ ન પસંદ કરો ત્યાં સુધી, વાળનો રંગ જાળવે છે. આખા વાળ દેખાતા, ટોપી વગરના સામેથી લીધેલા પોર્ટ્રેટ સાથે શ્રેષ્ઠ કામ કરે છે.';

  @override
  String get noHairstyles => 'હજી કોઈ હેરસ્ટાઇલ નથી — જલદી ફરી જુઓ.';

  @override
  String get colour => 'રંગ';

  @override
  String get keepMine => 'મારો રાખો';

  @override
  String get haircut => 'હેરકટ';

  @override
  String get keepMyCut => 'મારો કટ રાખો';

  @override
  String get working => 'કામ ચાલુ છે…';

  @override
  String get newColour => 'નવો રંગ';

  @override
  String get newHaircut => 'નવો હેરકટ';

  @override
  String get pickPortrait => 'પોર્ટ્રેટ પસંદ કરો';

  @override
  String get hairBusy =>
      'કામ ચાલુ છે… લગભગ એક મિનિટ.\nફોટો તમારી ચેટમાં પણ આવશે.';

  @override
  String get hairWomen => 'મહિલાઓ';

  @override
  String get hairMen => 'પુરુષો';

  @override
  String get hairCuts => 'કટ';

  @override
  String get hairBangs => 'બેંગ્સ';

  @override
  String get hairTexture => 'બનાવટ';

  @override
  String get hairShort => 'ટૂંકા';

  @override
  String get hairMedium => 'મધ્યમ';

  @override
  String get hairLong => 'લાંબા';

  @override
  String get hairBraids => 'ચોટલા';

  @override
  String get hairUpdos => 'અપડુ';

  @override
  String get notDownloaded => 'છબી હજી ડાઉનલોડ થઈ નથી';

  @override
  String get savedToGallery => 'ગૅલેરીમાં સાચવ્યું';

  @override
  String couldNotSave(String error) {
    return 'સાચવી શકાયું નથી: $error';
  }

  @override
  String get result => 'પરિણામ';

  @override
  String get saveToGallery => 'ગૅલેરીમાં સાચવો';

  @override
  String get copyPrompt => 'પ્રૉમ્પ્ટ કૉપિ કરો';

  @override
  String get promptCopied => 'પ્રૉમ્પ્ટ કૉપિ થયો';

  @override
  String get imageNotAvailable => 'છબી ઉપલબ્ધ નથી';

  @override
  String get promptUsed => 'વપરાયેલ પ્રૉમ્પ્ટ:';

  @override
  String get revisedPrompt => 'સુધારેલ પ્રૉમ્પ્ટ (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'લોડ થઈ શક્યું નથી: $error';
  }

  @override
  String get generation => 'જનરેશન';

  @override
  String get generationWebInfo =>
      'છબીઓ Tsumiki બૉટ (ComfyUI) બનાવે છે. તૈયાર છબી બૉટ સાથેની તમારી ચેટમાં પણ મોકલાય છે.';

  @override
  String get workflow => 'વર્કફ્લો';

  @override
  String get generationBackend => 'જનરેશન બૅકએન્ડ';

  @override
  String get xaiInfo => 'Grok દ્વારા બનાવવા console.x.ai ની API કી.';

  @override
  String get apiKey => 'API કી';

  @override
  String get ol1nInfo =>
      'સ્થાનિક AiStack (Flux diffusers API). CF Access સર્વિસ ટોકન દાખલ કરો, અથવા બિલ્ડમાં સમાવેલ હોય (--dart-define) તો ખાલી રાખો.';

  @override
  String get comfyInfo =>
      'સ્થાનિક ComfyUI (મૉડલ નીચે પસંદ કરો). CF Access ટોકન llm.ol1n.com સાથે વહેંચાય છે.';

  @override
  String get save => 'સાચવો';

  @override
  String get saved => 'સાચવ્યું';

  @override
  String get wfAuto => 'આપમેળે — પસંદ કરેલા ટેમ્પલેટ મુજબ';

  @override
  String get wfFlux => 'Flux — ચિત્રાત્મક અને ફોટોરિયલિસ્ટિક શૈલીઓ';

  @override
  String get wfPony => 'Pony Diffusion — એનિમે, Danbooru ટૅગ';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — ઝડપી ફોટોરિયલ';

  @override
  String get wfWai => 'WAI Illustrious — એનિમે, Pony કરતાં નવું';

  @override
  String templateChose(String workflow) {
    return 'ટેમ્પલેટે પસંદ કર્યું: $workflow';
  }

  @override
  String get apiKeySaved => 'API કી સાચવાઈ';

  @override
  String get reposeScreenTitle => 'Repose — પોઝમાં ચહેરો';

  @override
  String get model => 'મૉડલ';

  @override
  String get stepFace => '1. ચહેરો';

  @override
  String get stepPose => '2. પોઝ';

  @override
  String get stepPrompt => '3. પ્રૉમ્પ્ટ';

  @override
  String get negative => 'નેગેટિવ';

  @override
  String get reposePromptHint => 'એક સ્ત્રીનો ફોટો, આખું શરીર, કુદરતી પ્રકાશ…';

  @override
  String couldNotLoadModels(String error) {
    return 'મૉડલ લોડ થઈ શક્યા નથી: $error';
  }

  @override
  String get noModels => 'કોઈ મૉડલ નથી (સેટિંગ્સમાં CF ઓળખપત્રો તપાસો).';

  @override
  String get uploadFace => 'ચહેરો અપલોડ કરો';

  @override
  String get changeFace => 'ચહેરો બદલો';

  @override
  String get pickFromGallery => 'ગૅલેરીમાંથી પસંદ કરો';

  @override
  String get takePhoto => 'ફોટો લો';

  @override
  String get needCfCredentials =>
      'સેટિંગ્સમાં Cloudflare Access ઓળખપત્રો સેટ કરો';

  @override
  String get baseImageSelected => 'મૂળ છબી પસંદ કરી';

  @override
  String get baseImageOptional => 'મૂળ છબી (વૈકલ્પિક)';

  @override
  String get remove => 'દૂર કરો';

  @override
  String get prompt => 'પ્રૉમ્પ્ટ';

  @override
  String get modelAutoTooltip =>
      'ટેમ્પલેટ પરથી મૉડલ આપમેળે પસંદ થયું.\nતમે સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String get modelManualTooltip => 'સેટિંગ્સમાં હાથે પસંદ કરેલું મૉડલ.';

  @override
  String get pickBlocks => 'પ્રૉમ્પ્ટ બનાવવા બ્લૉક પસંદ કરો...';
}
