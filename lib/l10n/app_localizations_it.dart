// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get screenBuilder => 'Costruttore di prompt';

  @override
  String get screenRestyle => 'Cambia stile a una foto';

  @override
  String get screenHair => 'Prova un taglio di capelli';

  @override
  String get screenAnimate => 'Anima una foto';

  @override
  String get settings => 'Impostazioni';

  @override
  String get shopTooltipVideo => 'Crediti di animazione e pacchetti';

  @override
  String get shopTooltip => 'Crediti e pacchetti';

  @override
  String get switchCard => 'Cambia scheda';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crediti di animazione aggiunti 🎉',
      one: '1 credito di animazione aggiunto 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crediti aggiunti 🎉',
      one: '1 credito aggiunto 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Pagamento non riuscito, riprova';

  @override
  String errorDetail(String error) {
    return 'Errore: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Impossibile caricare i crediti: $error';
  }

  @override
  String get tryAgain => 'Riprova';

  @override
  String get animationsTitle => 'Animazioni';

  @override
  String get creditsTitle => 'Crediti';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animazioni gratuite oggi: $free su $limit · crediti di animazione: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Generazioni gratuite oggi: $free su $limit · crediti: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 credito = 1 video, pagato con Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 credito = 1 immagine, pagata con Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crediti',
      one: '1 credito',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animazioni',
      one: '1 animazione',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose non è disponibile sul web';

  @override
  String get reposeTooltip => 'Repose (volto in una posa)';

  @override
  String get presets => 'Preset';

  @override
  String get template => 'Modello';

  @override
  String get backToTop => 'Torna su';

  @override
  String get generating => 'Generazione…';

  @override
  String get generate => 'Genera';

  @override
  String get needCredentials =>
      'Imposta una chiave API o le credenziali nelle Impostazioni';

  @override
  String presetLoaded(String name) {
    return 'Preset «$name» caricato';
  }

  @override
  String get connectionLostVideo =>
      'Connessione persa: il bot consegnerà comunque il video nella tua chat.';

  @override
  String videoServerDown(String error) {
    return 'Il server video non è disponibile al momento.\n$error';
  }

  @override
  String get scene => 'Scena';

  @override
  String get uploading => 'Caricamento…';

  @override
  String get animate => 'Anima';

  @override
  String get pickPhoto => 'Scegli una foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip di ~$seconds s · ~$minutes min di rendering';
  }

  @override
  String queuePosition(int position) {
    return 'In coda · posizione $position';
  }

  @override
  String get queueWaiting => 'In coda…';

  @override
  String get finishing => 'Finalizzazione (smussatura del movimento)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Battuta $beat/$beats · mancano ~$minutes min';
  }

  @override
  String get videoDone =>
      'Fatto! Il video è stato inviato alla tua chat Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Non riuscito: $error';
  }

  @override
  String get unknownError => 'errore sconosciuto';

  @override
  String get starting => 'Avvio…';

  @override
  String get canCloseApp => 'Puoi chiudere l’app: il video arriva nella chat.';

  @override
  String get notCharged => 'Il tuo video gratuito / credito non è stato usato.';

  @override
  String get animateAnother => 'Anima un’altra';

  @override
  String get restyleHint =>
      'Mantiene il tuo volto e la tua posa. Funziona meglio con una foto nitida e frontale di una sola persona.';

  @override
  String get medium => 'Supporto';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Illustrazione';

  @override
  String get style => 'Stile';

  @override
  String get filterStyles => 'Filtra gli stili';

  @override
  String get restyling => 'Cambio di stile…';

  @override
  String get restyle => 'Cambia stile';

  @override
  String get restyleBusy =>
      'Cambio di stile… circa un minuto.\nL’immagine arriva anche nella tua chat.';

  @override
  String get groupPopular => 'Popolari';

  @override
  String get groupPainters => 'Pittori';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Americhe e Oceania';

  @override
  String get groupAfricaNearEast => 'Africa e Vicino Oriente';

  @override
  String get hairHint =>
      'Mantiene il tuo volto e il colore dei capelli, a meno che tu ne scelga uno nuovo. Funziona meglio con un ritratto frontale, capelli ben visibili, senza cappello.';

  @override
  String get noHairstyles => 'Ancora nessuna acconciatura: torna presto.';

  @override
  String get colour => 'Colore';

  @override
  String get keepMine => 'Mantieni il mio';

  @override
  String get haircut => 'Taglio';

  @override
  String get keepMyCut => 'Mantieni il mio taglio';

  @override
  String get working => 'In corso…';

  @override
  String get newColour => 'Nuovo colore';

  @override
  String get newHaircut => 'Nuovo taglio';

  @override
  String get pickPortrait => 'Scegli un ritratto';

  @override
  String get hairBusy =>
      'In corso… circa un minuto.\nLa foto arriva anche nella tua chat.';

  @override
  String get hairWomen => 'Donna';

  @override
  String get hairMen => 'Uomo';

  @override
  String get hairCuts => 'Tagli';

  @override
  String get hairBangs => 'Frangia';

  @override
  String get hairTexture => 'Texture';

  @override
  String get hairShort => 'Corti';

  @override
  String get hairMedium => 'Medi';

  @override
  String get hairLong => 'Lunghi';

  @override
  String get hairBraids => 'Trecce';

  @override
  String get hairUpdos => 'Raccolti';

  @override
  String get notDownloaded => 'L’immagine non è ancora stata scaricata';

  @override
  String get savedToGallery => 'Salvata nella galleria';

  @override
  String couldNotSave(String error) {
    return 'Impossibile salvare: $error';
  }

  @override
  String get result => 'Risultato';

  @override
  String get saveToGallery => 'Salva nella galleria';

  @override
  String get copyPrompt => 'Copia prompt';

  @override
  String get promptCopied => 'Prompt copiato';

  @override
  String get imageNotAvailable => 'Immagine non disponibile';

  @override
  String get promptUsed => 'Prompt usato:';

  @override
  String get revisedPrompt => 'Prompt rivisto (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Impossibile caricare: $error';
  }

  @override
  String get generation => 'Generazione';

  @override
  String get generationWebInfo =>
      'Le immagini sono generate dal bot Tsumiki (ComfyUI). L’immagine finita viene inviata anche alla tua chat con il bot.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Backend di generazione';

  @override
  String get xaiInfo => 'Chiave API da console.x.ai per generare con Grok.';

  @override
  String get apiKey => 'Chiave API';

  @override
  String get ol1nInfo =>
      'AiStack locale (API Flux diffusers). Inserisci un token di servizio CF Access, oppure lascia vuoto se è incluso nella build (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI locale (scelta del modello qui sotto). Condivide il token CF Access con llm.ol1n.com.';

  @override
  String get save => 'Salva';

  @override
  String get saved => 'Salvato';

  @override
  String get wfAuto => 'Automatico: segue il modello scelto';

  @override
  String get wfFlux => 'Flux: stili pittorici e fotorealistici';

  @override
  String get wfPony => 'Pony Diffusion: anime, tag Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning: fotorealismo veloce';

  @override
  String get wfWai => 'WAI Illustrious: anime, più recente di Pony';

  @override
  String templateChose(String workflow) {
    return 'Il modello ha scelto: $workflow';
  }

  @override
  String get apiKeySaved => 'Chiave API salvata';

  @override
  String get reposeScreenTitle => 'Repose: volto in una posa';

  @override
  String get model => 'Modello';

  @override
  String get stepFace => '1. Volto';

  @override
  String get stepPose => '2. Posa';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIVO';

  @override
  String get reposePromptHint =>
      'foto di una donna, figura intera, luce naturale…';

  @override
  String couldNotLoadModels(String error) {
    return 'Impossibile caricare i modelli: $error';
  }

  @override
  String get noModels =>
      'Nessun modello (controlla le credenziali CF nelle Impostazioni).';

  @override
  String get uploadFace => 'Carica un volto';

  @override
  String get changeFace => 'Cambia volto';

  @override
  String get pickFromGallery => 'Scegli dalla galleria';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get needCfCredentials =>
      'Imposta le credenziali Cloudflare Access nelle Impostazioni';

  @override
  String get baseImageSelected => 'Immagine di base selezionata';

  @override
  String get baseImageOptional => 'Immagine di base (facoltativa)';

  @override
  String get remove => 'Rimuovi';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modello scelto automaticamente dal modello di prompt.\nPuoi cambiarlo nelle Impostazioni.';

  @override
  String get modelManualTooltip =>
      'Modello scelto manualmente nelle Impostazioni.';

  @override
  String get pickBlocks => 'Scegli i blocchi per comporre un prompt...';
}
