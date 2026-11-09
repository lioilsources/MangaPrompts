// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get screenBuilder => 'Prompt-építő';

  @override
  String get screenRestyle => 'Fotó stílusának módosítása';

  @override
  String get screenHair => 'Frizura kipróbálása';

  @override
  String get screenAnimate => 'Fotó animálása';

  @override
  String get settings => 'Beállítások';

  @override
  String get shopTooltipVideo => 'Animációs kreditek és csomagok';

  @override
  String get shopTooltip => 'Kreditek és csomagok';

  @override
  String get switchCard => 'Kártya váltása';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animációs kredit hozzáadva 🎉',
      one: '1 animációs kredit hozzáadva 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit hozzáadva 🎉',
      one: '1 kredit hozzáadva 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'A fizetés nem sikerült, próbáld újra';

  @override
  String errorDetail(String error) {
    return 'Hiba: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'A kreditek betöltése nem sikerült: $error';
  }

  @override
  String get tryAgain => 'Újra';

  @override
  String get animationsTitle => 'Animációk';

  @override
  String get creditsTitle => 'Kreditek';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Mai ingyenes animációk: $free / $limit · animációs kreditek: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Mai ingyenes generálások: $free / $limit · kreditek: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 kredit = 1 videó, fizetés Telegram Starsszal.';

  @override
  String get imagePriceNote => '1 kredit = 1 kép, fizetés Telegram Starsszal.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit',
      one: '1 kredit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animáció',
      one: '1 animáció',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'A Repose weben nem érhető el';

  @override
  String get reposeTooltip => 'Repose (arc egy pózban)';

  @override
  String get presets => 'Előbeállítások';

  @override
  String get template => 'Sablon';

  @override
  String get backToTop => 'Vissza a tetejére';

  @override
  String get generating => 'Generálás…';

  @override
  String get generate => 'Generálás';

  @override
  String get needCredentials =>
      'Állíts be API-kulcsot vagy hozzáférési adatokat a Beállításokban';

  @override
  String presetLoaded(String name) {
    return 'A(z) „$name” előbeállítás betöltve';
  }

  @override
  String get connectionLostVideo =>
      'A kapcsolat megszakadt — a bot a videót így is kézbesíti a csevegésedbe.';

  @override
  String videoServerDown(String error) {
    return 'A videószerver jelenleg nem érhető el.\n$error';
  }

  @override
  String get scene => 'Jelenet';

  @override
  String get uploading => 'Feltöltés…';

  @override
  String get animate => 'Animálás';

  @override
  String get pickPhoto => 'Fotó kiválasztása';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds mp-es klip · ~$minutes perc renderelés';
  }

  @override
  String queuePosition(int position) {
    return 'Sorban · $position. hely';
  }

  @override
  String get queueWaiting => 'Sorban…';

  @override
  String get finishing => 'Befejezés (a mozgás simítása)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return '$beat/$beats. ütem · még ~$minutes perc';
  }

  @override
  String get videoDone => 'Kész! A videót elküldtük a Telegram-csevegésedbe 🎬';

  @override
  String failedDetail(String error) {
    return 'Sikertelen: $error';
  }

  @override
  String get unknownError => 'ismeretlen hiba';

  @override
  String get starting => 'Indítás…';

  @override
  String get canCloseApp =>
      'Bezárhatod az appot — a videó megérkezik a csevegésbe.';

  @override
  String get notCharged => 'Az ingyenes videód / kredited nem fogyott el.';

  @override
  String get animateAnother => 'Még egy animálása';

  @override
  String get restyleHint =>
      'Megtartja az arcodat és a pózodat. Egy személy éles, szemből készült fotójával működik a legjobban.';

  @override
  String get medium => 'Közeg';

  @override
  String get mediumPhoto => 'Fotó';

  @override
  String get mediumIllustration => 'Illusztráció';

  @override
  String get style => 'Stílus';

  @override
  String get filterStyles => 'Stílusok szűrése';

  @override
  String get restyling => 'Stílusváltás…';

  @override
  String get restyle => 'Stílus módosítása';

  @override
  String get restyleBusy =>
      'Stílusváltás… körülbelül egy perc.\nA kép a csevegésedbe is megérkezik.';

  @override
  String get groupPopular => 'Népszerű';

  @override
  String get groupPainters => 'Festők';

  @override
  String get groupAsia => 'Ázsia';

  @override
  String get groupEurope => 'Európa';

  @override
  String get groupAmericasOceania => 'Amerika és Óceánia';

  @override
  String get groupAfricaNearEast => 'Afrika és Közel-Kelet';

  @override
  String get hairHint =>
      'Megtartja az arcodat és a hajszíned, hacsak nem választasz újat. Szemből készült portréval működik a legjobban, teljesen látható hajjal, sapka nélkül.';

  @override
  String get noHairstyles => 'Még nincsenek frizurák — nézz vissza hamarosan.';

  @override
  String get colour => 'Szín';

  @override
  String get keepMine => 'Az enyém marad';

  @override
  String get haircut => 'Frizura';

  @override
  String get keepMyCut => 'Marad a frizurám';

  @override
  String get working => 'Dolgozom…';

  @override
  String get newColour => 'Új szín';

  @override
  String get newHaircut => 'Új frizura';

  @override
  String get pickPortrait => 'Portré kiválasztása';

  @override
  String get hairBusy =>
      'Dolgozom… körülbelül egy perc.\nA fotó a csevegésedbe is megérkezik.';

  @override
  String get hairWomen => 'Női';

  @override
  String get hairMen => 'Férfi';

  @override
  String get hairCuts => 'Vágások';

  @override
  String get hairBangs => 'Frufru';

  @override
  String get hairTexture => 'Textúra';

  @override
  String get hairShort => 'Rövid';

  @override
  String get hairMedium => 'Közepes';

  @override
  String get hairLong => 'Hosszú';

  @override
  String get hairBraids => 'Fonatok';

  @override
  String get hairUpdos => 'Feltűzött frizurák';

  @override
  String get notDownloaded => 'A képet még nem töltötted le';

  @override
  String get savedToGallery => 'Mentve a galériába';

  @override
  String couldNotSave(String error) {
    return 'A mentés nem sikerült: $error';
  }

  @override
  String get result => 'Eredmény';

  @override
  String get saveToGallery => 'Mentés a galériába';

  @override
  String get copyPrompt => 'Prompt másolása';

  @override
  String get promptCopied => 'Prompt másolva';

  @override
  String get imageNotAvailable => 'A kép nem érhető el';

  @override
  String get promptUsed => 'Használt prompt:';

  @override
  String get revisedPrompt => 'Átdolgozott prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'A betöltés nem sikerült: $error';
  }

  @override
  String get generation => 'Generálás';

  @override
  String get generationWebInfo =>
      'A képeket a Tsumiki bot (ComfyUI) generálja. A kész képet a botnál lévő csevegésedbe is elküldjük.';

  @override
  String get workflow => 'Munkafolyamat';

  @override
  String get generationBackend => 'Generáló háttérrendszer';

  @override
  String get xaiInfo =>
      'API-kulcs a console.x.ai oldalról a Grokkal való generáláshoz.';

  @override
  String get apiKey => 'API-kulcs';

  @override
  String get ol1nInfo =>
      'Helyi AiStack (Flux diffusers API). Adj meg egy CF Access szolgáltatási tokent, vagy hagyd üresen, ha be van építve a buildbe (--dart-define).';

  @override
  String get comfyInfo =>
      'Helyi ComfyUI (modellválasztás lent). A CF Access tokent az llm.ol1n.com-mal közösen használja.';

  @override
  String get save => 'Mentés';

  @override
  String get saved => 'Mentve';

  @override
  String get wfAuto => 'Automatikus — a választott sablon szerint';

  @override
  String get wfFlux => 'Flux — festői és fotórealisztikus stílusok';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru-címkék';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — gyors fotórealizmus';

  @override
  String get wfWai => 'WAI Illustrious — anime, újabb a Ponynál';

  @override
  String templateChose(String workflow) {
    return 'A sablon ezt választotta: $workflow';
  }

  @override
  String get apiKeySaved => 'API-kulcs mentve';

  @override
  String get reposeScreenTitle => 'Repose — arc egy pózban';

  @override
  String get model => 'Modell';

  @override
  String get stepFace => '1. Arc';

  @override
  String get stepPose => '2. Póz';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATÍV';

  @override
  String get reposePromptHint =>
      'fotó egy nőről, egész alak, természetes fény…';

  @override
  String couldNotLoadModels(String error) {
    return 'A modellek betöltése nem sikerült: $error';
  }

  @override
  String get noModels =>
      'Nincs modell (ellenőrizd a CF hozzáférési adatokat a Beállításokban).';

  @override
  String get uploadFace => 'Arc feltöltése';

  @override
  String get changeFace => 'Arc cseréje';

  @override
  String get pickFromGallery => 'Választás a galériából';

  @override
  String get takePhoto => 'Fotó készítése';

  @override
  String get needCfCredentials =>
      'Állítsd be a Cloudflare Access hozzáférési adatait a Beállításokban';

  @override
  String get baseImageSelected => 'Alapkép kiválasztva';

  @override
  String get baseImageOptional => 'Alapkép (nem kötelező)';

  @override
  String get remove => 'Eltávolítás';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'A modellt automatikusan a sablon alapján választottuk.\nA Beállításokban módosíthatod.';

  @override
  String get modelManualTooltip =>
      'A modellt kézzel választottad a Beállításokban.';

  @override
  String get pickBlocks => 'Válassz építőelemeket a prompt összeállításához...';
}
