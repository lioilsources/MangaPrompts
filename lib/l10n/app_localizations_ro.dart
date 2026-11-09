// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get screenBuilder => 'Constructor de prompturi';

  @override
  String get screenRestyle => 'Schimbă stilul unei fotografii';

  @override
  String get screenHair => 'Încearcă o tunsoare';

  @override
  String get screenAnimate => 'Animează o fotografie';

  @override
  String get settings => 'Setări';

  @override
  String get shopTooltipVideo => 'Credite de animație și pachete';

  @override
  String get shopTooltip => 'Credite și pachete';

  @override
  String get switchCard => 'Schimbă cardul';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de credite de animație adăugate 🎉',
      few: '$count credite de animație adăugate 🎉',
      one: '1 credit de animație adăugat 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de credite adăugate 🎉',
      few: '$count credite adăugate 🎉',
      one: '1 credit adăugat 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Plata a eșuat, încearcă din nou';

  @override
  String errorDetail(String error) {
    return 'Eroare: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Nu s-au putut încărca creditele: $error';
  }

  @override
  String get tryAgain => 'Încearcă din nou';

  @override
  String get animationsTitle => 'Animații';

  @override
  String get creditsTitle => 'Credite';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animații gratuite azi: $free din $limit · credite de animație: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Generări gratuite azi: $free din $limit · credite: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 credit = 1 videoclip, plătit cu Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 credit = 1 imagine, plătită cu Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de credite',
      few: '$count credite',
      one: '1 credit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de animații',
      few: '$count animații',
      one: '1 animație',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose nu este disponibil pe web';

  @override
  String get reposeTooltip => 'Repose (chip într-o poziție)';

  @override
  String get presets => 'Presetări';

  @override
  String get template => 'Șablon';

  @override
  String get backToTop => 'Înapoi sus';

  @override
  String get generating => 'Se generează…';

  @override
  String get generate => 'Generează';

  @override
  String get needCredentials => 'Setează o cheie API sau credențiale în Setări';

  @override
  String presetLoaded(String name) {
    return 'Presetarea „$name” a fost încărcată';
  }

  @override
  String get connectionLostVideo =>
      'Conexiune pierdută — botul va livra totuși videoclipul în chatul tău.';

  @override
  String videoServerDown(String error) {
    return 'Serverul video nu este disponibil momentan.\n$error';
  }

  @override
  String get scene => 'Scenă';

  @override
  String get uploading => 'Se încarcă…';

  @override
  String get animate => 'Animează';

  @override
  String get pickPhoto => 'Alege o fotografie';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip de ~$seconds s · randare ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'La coadă · poziția $position';
  }

  @override
  String get queueWaiting => 'La coadă…';

  @override
  String get finishing => 'Se finalizează (se netezește mișcarea)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Timp $beat/$beats · mai are ~$minutes min';
  }

  @override
  String get videoDone =>
      'Gata! Videoclipul a fost trimis în chatul tău Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Eșuat: $error';
  }

  @override
  String get unknownError => 'eroare necunoscută';

  @override
  String get starting => 'Pornire…';

  @override
  String get canCloseApp =>
      'Poți închide aplicația — videoclipul ajunge în chat.';

  @override
  String get notCharged =>
      'Videoclipul tău gratuit / creditul nu a fost consumat.';

  @override
  String get animateAnother => 'Animează încă una';

  @override
  String get restyleHint =>
      'Păstrează chipul și poziția ta. Funcționează cel mai bine cu o fotografie clară, din față, a unei singure persoane.';

  @override
  String get medium => 'Mediu';

  @override
  String get mediumPhoto => 'Fotografie';

  @override
  String get mediumIllustration => 'Ilustrație';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Filtrează stilurile';

  @override
  String get restyling => 'Se schimbă stilul…';

  @override
  String get restyle => 'Schimbă stilul';

  @override
  String get restyleBusy =>
      'Se schimbă stilul… aproximativ un minut.\nImaginea ajunge și în chatul tău.';

  @override
  String get groupPopular => 'Populare';

  @override
  String get groupPainters => 'Pictori';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Americile și Oceania';

  @override
  String get groupAfricaNearEast => 'Africa și Orientul Apropiat';

  @override
  String get hairHint =>
      'Păstrează chipul tău și culoarea părului, dacă nu alegi una nouă. Funcționează cel mai bine cu un portret din față, cu părul complet vizibil, fără căciulă.';

  @override
  String get noHairstyles => 'Încă nu există coafuri — revino în curând.';

  @override
  String get colour => 'Culoare';

  @override
  String get keepMine => 'O păstrez pe a mea';

  @override
  String get haircut => 'Tunsoare';

  @override
  String get keepMyCut => 'Păstrez tunsoarea mea';

  @override
  String get working => 'Se lucrează…';

  @override
  String get newColour => 'Culoare nouă';

  @override
  String get newHaircut => 'Tunsoare nouă';

  @override
  String get pickPortrait => 'Alege un portret';

  @override
  String get hairBusy =>
      'Se lucrează… aproximativ un minut.\nFotografia ajunge și în chatul tău.';

  @override
  String get hairWomen => 'Femei';

  @override
  String get hairMen => 'Bărbați';

  @override
  String get hairCuts => 'Tunsori';

  @override
  String get hairBangs => 'Breton';

  @override
  String get hairTexture => 'Textură';

  @override
  String get hairShort => 'Scurt';

  @override
  String get hairMedium => 'Mediu';

  @override
  String get hairLong => 'Lung';

  @override
  String get hairBraids => 'Împletituri';

  @override
  String get hairUpdos => 'Coafuri strânse';

  @override
  String get notDownloaded => 'Imaginea nu a fost încă descărcată';

  @override
  String get savedToGallery => 'Salvată în galerie';

  @override
  String couldNotSave(String error) {
    return 'Nu s-a putut salva: $error';
  }

  @override
  String get result => 'Rezultat';

  @override
  String get saveToGallery => 'Salvează în galerie';

  @override
  String get copyPrompt => 'Copiază promptul';

  @override
  String get promptCopied => 'Prompt copiat';

  @override
  String get imageNotAvailable => 'Imagine indisponibilă';

  @override
  String get promptUsed => 'Prompt folosit:';

  @override
  String get revisedPrompt => 'Prompt revizuit (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Nu s-a putut încărca: $error';
  }

  @override
  String get generation => 'Generare';

  @override
  String get generationWebInfo =>
      'Imaginile sunt generate de botul Tsumiki (ComfyUI). Imaginea finalizată este trimisă și în chatul tău cu botul.';

  @override
  String get workflow => 'Flux de lucru';

  @override
  String get generationBackend => 'Backend de generare';

  @override
  String get xaiInfo =>
      'Cheie API de la console.x.ai pentru generare prin Grok.';

  @override
  String get apiKey => 'Cheie API';

  @override
  String get ol1nInfo =>
      'AiStack local (API Flux diffusers). Introdu un token de serviciu CF Access sau lasă gol dacă este inclus în build (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI local (alegerea modelului mai jos). Folosește același token CF Access ca llm.ol1n.com.';

  @override
  String get save => 'Salvează';

  @override
  String get saved => 'Salvat';

  @override
  String get wfAuto => 'Automat — după șablonul ales';

  @override
  String get wfFlux => 'Flux — stiluri picturale și fotorealiste';

  @override
  String get wfPony => 'Pony Diffusion — anime, etichete Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — fotorealism rapid';

  @override
  String get wfWai => 'WAI Illustrious — anime, mai nou decât Pony';

  @override
  String templateChose(String workflow) {
    return 'Șablonul a ales: $workflow';
  }

  @override
  String get apiKeySaved => 'Cheia API a fost salvată';

  @override
  String get reposeScreenTitle => 'Repose — chip într-o poziție';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Chip';

  @override
  String get stepPose => '2. Poziție';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIV';

  @override
  String get reposePromptHint =>
      'fotografie cu o femeie, tot corpul, lumină naturală…';

  @override
  String couldNotLoadModels(String error) {
    return 'Nu s-au putut încărca modelele: $error';
  }

  @override
  String get noModels => 'Niciun model (verifică credențialele CF în Setări).';

  @override
  String get uploadFace => 'Încarcă un chip';

  @override
  String get changeFace => 'Schimbă chipul';

  @override
  String get pickFromGallery => 'Alege din galerie';

  @override
  String get takePhoto => 'Fă o fotografie';

  @override
  String get needCfCredentials =>
      'Setează credențialele Cloudflare Access în Setări';

  @override
  String get baseImageSelected => 'Imagine de bază selectată';

  @override
  String get baseImageOptional => 'Imagine de bază (opțional)';

  @override
  String get remove => 'Elimină';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model ales automat după șablon.\nÎl poți schimba în Setări.';

  @override
  String get modelManualTooltip => 'Model ales manual în Setări.';

  @override
  String get pickBlocks => 'Alege blocuri pentru a asambla un prompt...';
}
