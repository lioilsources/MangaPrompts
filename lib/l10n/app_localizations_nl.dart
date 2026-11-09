// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get screenBuilder => 'Promptbouwer';

  @override
  String get screenRestyle => 'Foto opnieuw stylen';

  @override
  String get screenHair => 'Een kapsel proberen';

  @override
  String get screenAnimate => 'Foto animeren';

  @override
  String get settings => 'Instellingen';

  @override
  String get shopTooltipVideo => 'Animatietegoed en pakketten';

  @override
  String get shopTooltip => 'Tegoed en pakketten';

  @override
  String get switchCard => 'Kaart wisselen';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animatietegoeden toegevoegd 🎉',
      one: '1 animatietegoed toegevoegd 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tegoeden toegevoegd 🎉',
      one: '1 tegoed toegevoegd 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Betaling mislukt, probeer het opnieuw';

  @override
  String errorDetail(String error) {
    return 'Fout: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Tegoed laden mislukt: $error';
  }

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get animationsTitle => 'Animaties';

  @override
  String get creditsTitle => 'Tegoed';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Gratis animaties vandaag: $free van $limit · animatietegoed: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Gratis generaties vandaag: $free van $limit · tegoed: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 tegoed = 1 video, betaald met Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 tegoed = 1 afbeelding, betaald met Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tegoeden',
      one: '1 tegoed',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animaties',
      one: '1 animatie',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose is niet beschikbaar op het web';

  @override
  String get reposeTooltip => 'Repose (gezicht in een pose)';

  @override
  String get presets => 'Voorinstellingen';

  @override
  String get template => 'Sjabloon';

  @override
  String get backToTop => 'Terug naar boven';

  @override
  String get generating => 'Genereren…';

  @override
  String get generate => 'Genereren';

  @override
  String get needCredentials =>
      'Stel een API-sleutel of inloggegevens in bij Instellingen';

  @override
  String presetLoaded(String name) {
    return 'Voorinstelling “$name” geladen';
  }

  @override
  String get connectionLostVideo =>
      'Verbinding verbroken — de bot bezorgt de video alsnog in je chat.';

  @override
  String videoServerDown(String error) {
    return 'De videoserver is momenteel niet beschikbaar.\n$error';
  }

  @override
  String get scene => 'Scène';

  @override
  String get uploading => 'Uploaden…';

  @override
  String get animate => 'Animeren';

  @override
  String get pickPhoto => 'Kies een foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip van ~$seconds s · ~$minutes min renderen';
  }

  @override
  String queuePosition(int position) {
    return 'In de wachtrij · positie $position';
  }

  @override
  String get queueWaiting => 'In de wachtrij…';

  @override
  String get finishing => 'Afronden (beweging wordt gladgestreken)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Beat $beat/$beats · nog ~$minutes min';
  }

  @override
  String get videoDone =>
      'Klaar! De video is naar je Telegram-chat gestuurd 🎬';

  @override
  String failedDetail(String error) {
    return 'Mislukt: $error';
  }

  @override
  String get unknownError => 'onbekende fout';

  @override
  String get starting => 'Starten…';

  @override
  String get canCloseApp =>
      'Je kunt de app sluiten — de video komt in de chat.';

  @override
  String get notCharged => 'Je gratis video / tegoed is niet gebruikt.';

  @override
  String get animateAnother => 'Nog een animeren';

  @override
  String get restyleHint =>
      'Behoudt je gezicht en houding. Werkt het best met een scherpe foto van voren van één persoon.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Illustratie';

  @override
  String get style => 'Stijl';

  @override
  String get filterStyles => 'Stijlen filteren';

  @override
  String get restyling => 'Opnieuw stylen…';

  @override
  String get restyle => 'Opnieuw stylen';

  @override
  String get restyleBusy =>
      'Opnieuw stylen… ongeveer een minuut.\nDe afbeelding komt ook in je chat.';

  @override
  String get groupPopular => 'Populair';

  @override
  String get groupPainters => 'Schilders';

  @override
  String get groupAsia => 'Azië';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amerika & Oceanië';

  @override
  String get groupAfricaNearEast => 'Afrika & Nabije Oosten';

  @override
  String get hairHint =>
      'Behoudt je gezicht en je haarkleur, tenzij je een nieuwe kiest. Werkt het best met een portret van voren, haar volledig zichtbaar, zonder pet.';

  @override
  String get noHairstyles => 'Nog geen kapsels — kom snel terug.';

  @override
  String get colour => 'Kleur';

  @override
  String get keepMine => 'Mijn kleur houden';

  @override
  String get haircut => 'Kapsel';

  @override
  String get keepMyCut => 'Mijn kapsel houden';

  @override
  String get working => 'Bezig…';

  @override
  String get newColour => 'Nieuwe kleur';

  @override
  String get newHaircut => 'Nieuw kapsel';

  @override
  String get pickPortrait => 'Kies een portret';

  @override
  String get hairBusy =>
      'Bezig… ongeveer een minuut.\nDe foto komt ook in je chat.';

  @override
  String get hairWomen => 'Dames';

  @override
  String get hairMen => 'Heren';

  @override
  String get hairCuts => 'Knipsels';

  @override
  String get hairBangs => 'Pony';

  @override
  String get hairTexture => 'Textuur';

  @override
  String get hairShort => 'Kort';

  @override
  String get hairMedium => 'Half lang';

  @override
  String get hairLong => 'Lang';

  @override
  String get hairBraids => 'Vlechten';

  @override
  String get hairUpdos => 'Opsteekkapsels';

  @override
  String get notDownloaded => 'De afbeelding is nog niet gedownload';

  @override
  String get savedToGallery => 'Bewaard in de galerij';

  @override
  String couldNotSave(String error) {
    return 'Bewaren mislukt: $error';
  }

  @override
  String get result => 'Resultaat';

  @override
  String get saveToGallery => 'Bewaar in galerij';

  @override
  String get copyPrompt => 'Prompt kopiëren';

  @override
  String get promptCopied => 'Prompt gekopieerd';

  @override
  String get imageNotAvailable => 'Afbeelding niet beschikbaar';

  @override
  String get promptUsed => 'Gebruikte prompt:';

  @override
  String get revisedPrompt => 'Herziene prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Laden mislukt: $error';
  }

  @override
  String get generation => 'Generatie';

  @override
  String get generationWebInfo =>
      'Afbeeldingen worden gegenereerd door de Tsumiki-bot (ComfyUI). De afgewerkte afbeelding wordt ook naar je chat met de bot gestuurd.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Generatiebackend';

  @override
  String get xaiInfo =>
      'API-sleutel van console.x.ai om met Grok te genereren.';

  @override
  String get apiKey => 'API-sleutel';

  @override
  String get ol1nInfo =>
      'Lokale AiStack (Flux diffusers-API). Voer een CF Access-servicetoken in, of laat leeg als het in de build is ingebakken (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokale ComfyUI (modelkeuze hieronder). Deelt het CF Access-token met llm.ol1n.com.';

  @override
  String get save => 'Bewaren';

  @override
  String get saved => 'Bewaard';

  @override
  String get wfAuto => 'Automatisch — het gekozen sjabloon volgen';

  @override
  String get wfFlux => 'Flux — schilderachtige en fotorealistische stijlen';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru-tags';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — snel fotorealistisch';

  @override
  String get wfWai => 'WAI Illustrious — anime, nieuwer dan Pony';

  @override
  String templateChose(String workflow) {
    return 'Sjabloon koos: $workflow';
  }

  @override
  String get apiKeySaved => 'API-sleutel bewaard';

  @override
  String get reposeScreenTitle => 'Repose — gezicht in een pose';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Gezicht';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIEF';

  @override
  String get reposePromptHint =>
      'foto van een vrouw, volledig lichaam, natuurlijk licht…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modellen laden mislukt: $error';
  }

  @override
  String get noModels =>
      'Geen modellen (controleer de CF-inloggegevens bij Instellingen).';

  @override
  String get uploadFace => 'Gezicht uploaden';

  @override
  String get changeFace => 'Gezicht wijzigen';

  @override
  String get pickFromGallery => 'Kies uit galerij';

  @override
  String get takePhoto => 'Foto maken';

  @override
  String get needCfCredentials =>
      'Stel de Cloudflare Access-inloggegevens in bij Instellingen';

  @override
  String get baseImageSelected => 'Basisafbeelding geselecteerd';

  @override
  String get baseImageOptional => 'Basisafbeelding (optioneel)';

  @override
  String get remove => 'Verwijderen';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model automatisch gekozen op basis van het sjabloon.\nJe kunt het wijzigen bij Instellingen.';

  @override
  String get modelManualTooltip => 'Model handmatig gekozen bij Instellingen.';

  @override
  String get pickBlocks => 'Kies blokken om een prompt samen te stellen...';
}
