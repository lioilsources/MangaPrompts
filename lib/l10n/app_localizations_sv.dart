// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get screenBuilder => 'Promptbyggare';

  @override
  String get screenRestyle => 'Ändra stil på ett foto';

  @override
  String get screenHair => 'Prova en frisyr';

  @override
  String get screenAnimate => 'Animera ett foto';

  @override
  String get settings => 'Inställningar';

  @override
  String get shopTooltipVideo => 'Animationskrediter och paket';

  @override
  String get shopTooltip => 'Krediter och paket';

  @override
  String get switchCard => 'Byt kort';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animationskrediter tillagda 🎉',
      one: '1 animationskredit tillagd 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count krediter tillagda 🎉',
      one: '1 kredit tillagd 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Betalningen misslyckades, försök igen';

  @override
  String errorDetail(String error) {
    return 'Fel: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Det gick inte att läsa in krediter: $error';
  }

  @override
  String get tryAgain => 'Försök igen';

  @override
  String get animationsTitle => 'Animationer';

  @override
  String get creditsTitle => 'Krediter';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Gratis animationer idag: $free av $limit · animationskrediter: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Gratis genereringar idag: $free av $limit · krediter: $credits';
  }

  @override
  String get videoPriceNote => '1 kredit = 1 video, betald med Telegram Stars.';

  @override
  String get imagePriceNote => '1 kredit = 1 bild, betald med Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count krediter',
      one: '1 kredit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animationer',
      one: '1 animation',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose är inte tillgängligt på webben';

  @override
  String get reposeTooltip => 'Repose (ansikte i en pose)';

  @override
  String get presets => 'Förinställningar';

  @override
  String get template => 'Mall';

  @override
  String get backToTop => 'Till toppen';

  @override
  String get generating => 'Genererar…';

  @override
  String get generate => 'Generera';

  @override
  String get needCredentials =>
      'Ange en API-nyckel eller inloggning i Inställningar';

  @override
  String presetLoaded(String name) {
    return 'Förinställningen ”$name” lästes in';
  }

  @override
  String get connectionLostVideo =>
      'Anslutningen bröts — boten levererar ändå videon till din chatt.';

  @override
  String videoServerDown(String error) {
    return 'Videoservern är inte tillgänglig just nu.\n$error';
  }

  @override
  String get scene => 'Scen';

  @override
  String get uploading => 'Laddar upp…';

  @override
  String get animate => 'Animera';

  @override
  String get pickPhoto => 'Välj ett foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds s klipp · ~$minutes min rendering';
  }

  @override
  String queuePosition(int position) {
    return 'I kö · plats $position';
  }

  @override
  String get queueWaiting => 'I kö…';

  @override
  String get finishing => 'Avslutar (jämnar ut rörelsen)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · ~$minutes min kvar';
  }

  @override
  String get videoDone => 'Klart! Videon skickades till din Telegram-chatt 🎬';

  @override
  String failedDetail(String error) {
    return 'Misslyckades: $error';
  }

  @override
  String get unknownError => 'okänt fel';

  @override
  String get starting => 'Startar…';

  @override
  String get canCloseApp => 'Du kan stänga appen — videon kommer till chatten.';

  @override
  String get notCharged => 'Din gratisvideo / kredit användes inte.';

  @override
  String get animateAnother => 'Animera en till';

  @override
  String get restyleHint =>
      'Behåller ditt ansikte och din pose. Fungerar bäst med ett tydligt foto framifrån av en person.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Illustration';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Filtrera stilar';

  @override
  String get restyling => 'Ändrar stil…';

  @override
  String get restyle => 'Ändra stil';

  @override
  String get restyleBusy =>
      'Ändrar stil… ungefär en minut.\nBilden kommer också till din chatt.';

  @override
  String get groupPopular => 'Populära';

  @override
  String get groupPainters => 'Målare';

  @override
  String get groupAsia => 'Asien';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amerika och Oceanien';

  @override
  String get groupAfricaNearEast => 'Afrika och Främre Orienten';

  @override
  String get hairHint =>
      'Behåller ditt ansikte och din hårfärg om du inte väljer en ny. Fungerar bäst med ett porträtt framifrån där håret syns helt, utan mössa.';

  @override
  String get noHairstyles => 'Inga frisyrer än — kom tillbaka snart.';

  @override
  String get colour => 'Färg';

  @override
  String get keepMine => 'Behåll min';

  @override
  String get haircut => 'Frisyr';

  @override
  String get keepMyCut => 'Behåll min frisyr';

  @override
  String get working => 'Arbetar…';

  @override
  String get newColour => 'Ny färg';

  @override
  String get newHaircut => 'Ny frisyr';

  @override
  String get pickPortrait => 'Välj ett porträtt';

  @override
  String get hairBusy =>
      'Arbetar… ungefär en minut.\nFotot kommer också till din chatt.';

  @override
  String get hairWomen => 'Dam';

  @override
  String get hairMen => 'Herr';

  @override
  String get hairCuts => 'Klippningar';

  @override
  String get hairBangs => 'Lugg';

  @override
  String get hairTexture => 'Struktur';

  @override
  String get hairShort => 'Kort';

  @override
  String get hairMedium => 'Halvlångt';

  @override
  String get hairLong => 'Långt';

  @override
  String get hairBraids => 'Flätor';

  @override
  String get hairUpdos => 'Uppsättningar';

  @override
  String get notDownloaded => 'Bilden har inte laddats ned än';

  @override
  String get savedToGallery => 'Sparad i galleriet';

  @override
  String couldNotSave(String error) {
    return 'Det gick inte att spara: $error';
  }

  @override
  String get result => 'Resultat';

  @override
  String get saveToGallery => 'Spara i galleriet';

  @override
  String get copyPrompt => 'Kopiera prompt';

  @override
  String get promptCopied => 'Prompten kopierades';

  @override
  String get imageNotAvailable => 'Bilden är inte tillgänglig';

  @override
  String get promptUsed => 'Använd prompt:';

  @override
  String get revisedPrompt => 'Reviderad prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Det gick inte att läsa in: $error';
  }

  @override
  String get generation => 'Generering';

  @override
  String get generationWebInfo =>
      'Bilder genereras av Tsumiki-boten (ComfyUI). Den färdiga bilden skickas också till din chatt med boten.';

  @override
  String get workflow => 'Arbetsflöde';

  @override
  String get generationBackend => 'Genereringsbackend';

  @override
  String get xaiInfo => 'API-nyckel från console.x.ai för generering via Grok.';

  @override
  String get apiKey => 'API-nyckel';

  @override
  String get ol1nInfo =>
      'Lokal AiStack (Flux diffusers-API). Ange en CF Access-servicetoken, eller lämna tomt om den är inbyggd i bygget (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokal ComfyUI (modellval nedan). Delar CF Access-token med llm.ol1n.com.';

  @override
  String get save => 'Spara';

  @override
  String get saved => 'Sparat';

  @override
  String get wfAuto => 'Automatiskt — följ vald mall';

  @override
  String get wfFlux => 'Flux — målerisk och fotorealistisk stil';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru-taggar';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — snabb fotorealism';

  @override
  String get wfWai => 'WAI Illustrious — anime, nyare än Pony';

  @override
  String templateChose(String workflow) {
    return 'Mallen valde: $workflow';
  }

  @override
  String get apiKeySaved => 'API-nyckeln sparades';

  @override
  String get reposeScreenTitle => 'Repose — ansikte i en pose';

  @override
  String get model => 'Modell';

  @override
  String get stepFace => '1. Ansikte';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIV';

  @override
  String get reposePromptHint => 'foto av en kvinna, helfigur, naturligt ljus…';

  @override
  String couldNotLoadModels(String error) {
    return 'Det gick inte att läsa in modeller: $error';
  }

  @override
  String get noModels =>
      'Inga modeller (kontrollera CF-inloggningen i Inställningar).';

  @override
  String get uploadFace => 'Ladda upp ett ansikte';

  @override
  String get changeFace => 'Byt ansikte';

  @override
  String get pickFromGallery => 'Välj från galleriet';

  @override
  String get takePhoto => 'Ta ett foto';

  @override
  String get needCfCredentials =>
      'Ange Cloudflare Access-inloggningen i Inställningar';

  @override
  String get baseImageSelected => 'Basbild vald';

  @override
  String get baseImageOptional => 'Basbild (valfritt)';

  @override
  String get remove => 'Ta bort';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modell vald automatiskt utifrån mallen.\nDu kan ändra den i Inställningar.';

  @override
  String get modelManualTooltip => 'Modell vald manuellt i Inställningar.';

  @override
  String get pickBlocks => 'Välj block för att sätta ihop en prompt...';
}
