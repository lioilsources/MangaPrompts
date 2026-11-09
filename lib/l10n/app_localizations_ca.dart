// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get screenBuilder => 'Constructor de prompts';

  @override
  String get screenRestyle => 'Canvia l’estil d’una foto';

  @override
  String get screenHair => 'Prova un pentinat';

  @override
  String get screenAnimate => 'Anima una foto';

  @override
  String get settings => 'Configuració';

  @override
  String get shopTooltipVideo => 'Crèdits d’animació i paquets';

  @override
  String get shopTooltip => 'Crèdits i paquets';

  @override
  String get switchCard => 'Canvia de targeta';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crèdits d’animació afegits 🎉',
      one: '1 crèdit d’animació afegit 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crèdits afegits 🎉',
      one: '1 crèdit afegit 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'El pagament ha fallat, torna-ho a provar';

  @override
  String errorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'No s’han pogut carregar els crèdits: $error';
  }

  @override
  String get tryAgain => 'Torna-ho a provar';

  @override
  String get animationsTitle => 'Animacions';

  @override
  String get creditsTitle => 'Crèdits';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animacions gratis avui: $free de $limit · crèdits d’animació: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Generacions gratis avui: $free de $limit · crèdits: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 crèdit = 1 vídeo, es paga amb Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 crèdit = 1 imatge, es paga amb Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crèdits',
      one: '1 crèdit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animacions',
      one: '1 animació',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose no està disponible al web';

  @override
  String get reposeTooltip => 'Repose (rostre en una postura)';

  @override
  String get presets => 'Valors predefinits';

  @override
  String get template => 'Plantilla';

  @override
  String get backToTop => 'Torna a dalt';

  @override
  String get generating => 'Generant…';

  @override
  String get generate => 'Genera';

  @override
  String get needCredentials =>
      'Defineix una clau d’API o credencials a Configuració';

  @override
  String presetLoaded(String name) {
    return 'S’ha carregat el valor predefinit «$name»';
  }

  @override
  String get connectionLostVideo =>
      'Connexió perduda: el bot lliurarà igualment el vídeo al teu xat.';

  @override
  String videoServerDown(String error) {
    return 'El servidor de vídeo no està disponible ara mateix.\n$error';
  }

  @override
  String get scene => 'Escena';

  @override
  String get uploading => 'Pujant…';

  @override
  String get animate => 'Anima';

  @override
  String get pickPhoto => 'Tria una foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip de ~$seconds s · ~$minutes min de renderització';
  }

  @override
  String queuePosition(int position) {
    return 'A la cua · posició $position';
  }

  @override
  String get queueWaiting => 'A la cua…';

  @override
  String get finishing => 'Acabant (suavitzant el moviment)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Temps $beat/$beats · queden ~$minutes min';
  }

  @override
  String get videoDone => 'Fet! El vídeo s’ha enviat al teu xat de Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Ha fallat: $error';
  }

  @override
  String get unknownError => 'error desconegut';

  @override
  String get starting => 'Iniciant…';

  @override
  String get canCloseApp => 'Pots tancar l’app: el vídeo arribarà al xat.';

  @override
  String get notCharged => 'No s’ha gastat el teu vídeo gratuït / crèdit.';

  @override
  String get animateAnother => 'Anima’n una altra';

  @override
  String get restyleHint =>
      'Conserva el teu rostre i la teva postura. Funciona millor amb una foto nítida i de front d’una sola persona.';

  @override
  String get medium => 'Mitjà';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Il·lustració';

  @override
  String get style => 'Estil';

  @override
  String get filterStyles => 'Filtra els estils';

  @override
  String get restyling => 'Canviant l’estil…';

  @override
  String get restyle => 'Canvia l’estil';

  @override
  String get restyleBusy =>
      'Canviant l’estil… aproximadament un minut.\nLa imatge també arriba al teu xat.';

  @override
  String get groupPopular => 'Populars';

  @override
  String get groupPainters => 'Pintors';

  @override
  String get groupAsia => 'Àsia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amèrica i Oceania';

  @override
  String get groupAfricaNearEast => 'Àfrica i Pròxim Orient';

  @override
  String get hairHint =>
      'Conserva el teu rostre i el color del cabell, tret que en triïs un de nou. Funciona millor amb un retrat de front, amb tot el cabell visible i sense gorra.';

  @override
  String get noHairstyles => 'Encara no hi ha pentinats: torna aviat.';

  @override
  String get colour => 'Color';

  @override
  String get keepMine => 'Conserva el meu';

  @override
  String get haircut => 'Tall de cabell';

  @override
  String get keepMyCut => 'Conserva el meu tall';

  @override
  String get working => 'Treballant…';

  @override
  String get newColour => 'Color nou';

  @override
  String get newHaircut => 'Tall nou';

  @override
  String get pickPortrait => 'Tria un retrat';

  @override
  String get hairBusy =>
      'Treballant… aproximadament un minut.\nLa foto també arriba al teu xat.';

  @override
  String get hairWomen => 'Dona';

  @override
  String get hairMen => 'Home';

  @override
  String get hairCuts => 'Talls';

  @override
  String get hairBangs => 'Serrell';

  @override
  String get hairTexture => 'Textura';

  @override
  String get hairShort => 'Curt';

  @override
  String get hairMedium => 'Mitjà';

  @override
  String get hairLong => 'Llarg';

  @override
  String get hairBraids => 'Trenes';

  @override
  String get hairUpdos => 'Recollits';

  @override
  String get notDownloaded => 'La imatge encara no s’ha baixat';

  @override
  String get savedToGallery => 'Desat a la galeria';

  @override
  String couldNotSave(String error) {
    return 'No s’ha pogut desar: $error';
  }

  @override
  String get result => 'Resultat';

  @override
  String get saveToGallery => 'Desa a la galeria';

  @override
  String get copyPrompt => 'Copia el prompt';

  @override
  String get promptCopied => 'Prompt copiat';

  @override
  String get imageNotAvailable => 'Imatge no disponible';

  @override
  String get promptUsed => 'Prompt utilitzat:';

  @override
  String get revisedPrompt => 'Prompt revisat (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'No s’ha pogut carregar: $error';
  }

  @override
  String get generation => 'Generació';

  @override
  String get generationWebInfo =>
      'Les imatges les genera el bot de Tsumiki (ComfyUI). La imatge acabada també s’envia al teu xat amb el bot.';

  @override
  String get workflow => 'Flux de treball';

  @override
  String get generationBackend => 'Backend de generació';

  @override
  String get xaiInfo => 'Clau d’API de console.x.ai per generar amb Grok.';

  @override
  String get apiKey => 'Clau d’API';

  @override
  String get ol1nInfo =>
      'AiStack local (API Flux diffusers). Introdueix un testimoni de servei de CF Access, o deixa-ho buit si va incorporat a la compilació (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI local (tria de model a sota). Comparteix el testimoni de CF Access amb llm.ol1n.com.';

  @override
  String get save => 'Desa';

  @override
  String get saved => 'Desat';

  @override
  String get wfAuto => 'Automàtic: segueix la plantilla triada';

  @override
  String get wfFlux => 'Flux: estils pictòrics i fotorealistes';

  @override
  String get wfPony => 'Pony Diffusion: anime, etiquetes Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning: fotorealisme ràpid';

  @override
  String get wfWai => 'WAI Illustrious: anime, més nou que Pony';

  @override
  String templateChose(String workflow) {
    return 'La plantilla ha triat: $workflow';
  }

  @override
  String get apiKeySaved => 'Clau d’API desada';

  @override
  String get reposeScreenTitle => 'Repose: rostre en una postura';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Rostre';

  @override
  String get stepPose => '2. Postura';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIU';

  @override
  String get reposePromptHint => 'foto d’una dona, cos sencer, llum natural…';

  @override
  String couldNotLoadModels(String error) {
    return 'No s’han pogut carregar els models: $error';
  }

  @override
  String get noModels =>
      'Cap model (comprova les credencials de CF a Configuració).';

  @override
  String get uploadFace => 'Puja un rostre';

  @override
  String get changeFace => 'Canvia el rostre';

  @override
  String get pickFromGallery => 'Tria de la galeria';

  @override
  String get takePhoto => 'Fes una foto';

  @override
  String get needCfCredentials =>
      'Defineix les credencials de Cloudflare Access a Configuració';

  @override
  String get baseImageSelected => 'Imatge base seleccionada';

  @override
  String get baseImageOptional => 'Imatge base (opcional)';

  @override
  String get remove => 'Treu';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model triat automàticament segons la plantilla.\nEl pots canviar a Configuració.';

  @override
  String get modelManualTooltip => 'Model triat manualment a Configuració.';

  @override
  String get pickBlocks => 'Tria blocs per muntar un prompt...';
}
