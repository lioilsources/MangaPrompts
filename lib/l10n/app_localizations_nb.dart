// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get screenBuilder => 'Promptbygger';

  @override
  String get screenRestyle => 'Endre stil på et bilde';

  @override
  String get screenHair => 'Prøv en frisyre';

  @override
  String get screenAnimate => 'Animer et bilde';

  @override
  String get settings => 'Innstillinger';

  @override
  String get shopTooltipVideo => 'Animasjonskreditter og pakker';

  @override
  String get shopTooltip => 'Kreditter og pakker';

  @override
  String get switchCard => 'Bytt kort';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animasjonskreditter lagt til 🎉',
      one: '1 animasjonskreditt lagt til 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditter lagt til 🎉',
      one: '1 kreditt lagt til 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Betalingen mislyktes, prøv igjen';

  @override
  String errorDetail(String error) {
    return 'Feil: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Kunne ikke laste kreditter: $error';
  }

  @override
  String get tryAgain => 'Prøv igjen';

  @override
  String get animationsTitle => 'Animasjoner';

  @override
  String get creditsTitle => 'Kreditter';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Gratis animasjoner i dag: $free av $limit · animasjonskreditter: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Gratis genereringer i dag: $free av $limit · kreditter: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 kreditt = 1 video, betalt med Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 kreditt = 1 bilde, betalt med Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditter',
      one: '1 kreditt',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animasjoner',
      one: '1 animasjon',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose er ikke tilgjengelig på nettet';

  @override
  String get reposeTooltip => 'Repose (ansikt i en positur)';

  @override
  String get presets => 'Forhåndsinnstillinger';

  @override
  String get template => 'Mal';

  @override
  String get backToTop => 'Til toppen';

  @override
  String get generating => 'Genererer…';

  @override
  String get generate => 'Generer';

  @override
  String get needCredentials =>
      'Angi en API-nøkkel eller pålogging i Innstillinger';

  @override
  String presetLoaded(String name) {
    return 'Forhåndsinnstillingen «$name» er lastet';
  }

  @override
  String get connectionLostVideo =>
      'Forbindelsen ble brutt — boten leverer likevel videoen til chatten din.';

  @override
  String videoServerDown(String error) {
    return 'Videoserveren er ikke tilgjengelig akkurat nå.\n$error';
  }

  @override
  String get scene => 'Scene';

  @override
  String get uploading => 'Laster opp…';

  @override
  String get animate => 'Animer';

  @override
  String get pickPhoto => 'Velg et bilde';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds s klipp · ~$minutes min rendering';
  }

  @override
  String queuePosition(int position) {
    return 'I kø · plass $position';
  }

  @override
  String get queueWaiting => 'I kø…';

  @override
  String get finishing => 'Avslutter (jevner ut bevegelsen)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · ~$minutes min igjen';
  }

  @override
  String get videoDone =>
      'Ferdig! Videoen er sendt til Telegram-chatten din 🎬';

  @override
  String failedDetail(String error) {
    return 'Mislyktes: $error';
  }

  @override
  String get unknownError => 'ukjent feil';

  @override
  String get starting => 'Starter…';

  @override
  String get canCloseApp => 'Du kan lukke appen — videoen kommer i chatten.';

  @override
  String get notCharged => 'Din gratis video / kreditt ble ikke brukt.';

  @override
  String get animateAnother => 'Animer et til';

  @override
  String get restyleHint =>
      'Beholder ansiktet og positurene dine. Fungerer best med et skarpt bilde forfra av én person.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Illustrasjon';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Filtrer stiler';

  @override
  String get restyling => 'Endrer stil…';

  @override
  String get restyle => 'Endre stil';

  @override
  String get restyleBusy =>
      'Endrer stil… omtrent ett minutt.\nBildet kommer også til chatten din.';

  @override
  String get groupPopular => 'Populære';

  @override
  String get groupPainters => 'Malere';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amerika og Oseania';

  @override
  String get groupAfricaNearEast => 'Afrika og Midtøsten';

  @override
  String get hairHint =>
      'Beholder ansiktet og hårfargen din med mindre du velger en ny. Fungerer best med et portrett forfra der håret er helt synlig, uten lue.';

  @override
  String get noHairstyles => 'Ingen frisyrer ennå — kom snart tilbake.';

  @override
  String get colour => 'Farge';

  @override
  String get keepMine => 'Behold min';

  @override
  String get haircut => 'Frisyre';

  @override
  String get keepMyCut => 'Behold frisyren min';

  @override
  String get working => 'Jobber…';

  @override
  String get newColour => 'Ny farge';

  @override
  String get newHaircut => 'Ny frisyre';

  @override
  String get pickPortrait => 'Velg et portrett';

  @override
  String get hairBusy =>
      'Jobber… omtrent ett minutt.\nBildet kommer også til chatten din.';

  @override
  String get hairWomen => 'Dame';

  @override
  String get hairMen => 'Herre';

  @override
  String get hairCuts => 'Klipp';

  @override
  String get hairBangs => 'Pannelugg';

  @override
  String get hairTexture => 'Struktur';

  @override
  String get hairShort => 'Kort';

  @override
  String get hairMedium => 'Middels';

  @override
  String get hairLong => 'Langt';

  @override
  String get hairBraids => 'Fletter';

  @override
  String get hairUpdos => 'Opptak';

  @override
  String get notDownloaded => 'Bildet er ikke lastet ned ennå';

  @override
  String get savedToGallery => 'Lagret i galleriet';

  @override
  String couldNotSave(String error) {
    return 'Kunne ikke lagre: $error';
  }

  @override
  String get result => 'Resultat';

  @override
  String get saveToGallery => 'Lagre i galleriet';

  @override
  String get copyPrompt => 'Kopier prompt';

  @override
  String get promptCopied => 'Prompten er kopiert';

  @override
  String get imageNotAvailable => 'Bildet er ikke tilgjengelig';

  @override
  String get promptUsed => 'Brukt prompt:';

  @override
  String get revisedPrompt => 'Revidert prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Kunne ikke laste: $error';
  }

  @override
  String get generation => 'Generering';

  @override
  String get generationWebInfo =>
      'Bilder genereres av Tsumiki-boten (ComfyUI). Det ferdige bildet sendes også til chatten din med boten.';

  @override
  String get workflow => 'Arbeidsflyt';

  @override
  String get generationBackend => 'Genereringsbackend';

  @override
  String get xaiInfo => 'API-nøkkel fra console.x.ai for generering via Grok.';

  @override
  String get apiKey => 'API-nøkkel';

  @override
  String get ol1nInfo =>
      'Lokal AiStack (Flux diffusers-API). Angi et CF Access-servicetoken, eller la feltet stå tomt hvis det er bygget inn (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokal ComfyUI (modellvalg nedenfor). Deler CF Access-token med llm.ol1n.com.';

  @override
  String get save => 'Lagre';

  @override
  String get saved => 'Lagret';

  @override
  String get wfAuto => 'Automatisk — følg valgt mal';

  @override
  String get wfFlux => 'Flux — malerisk og fotorealistisk stil';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru-tagger';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — rask fotorealisme';

  @override
  String get wfWai => 'WAI Illustrious — anime, nyere enn Pony';

  @override
  String templateChose(String workflow) {
    return 'Malen valgte: $workflow';
  }

  @override
  String get apiKeySaved => 'API-nøkkelen er lagret';

  @override
  String get reposeScreenTitle => 'Repose — ansikt i en positur';

  @override
  String get model => 'Modell';

  @override
  String get stepFace => '1. Ansikt';

  @override
  String get stepPose => '2. Positur';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIV';

  @override
  String get reposePromptHint => 'foto av en kvinne, helfigur, naturlig lys…';

  @override
  String couldNotLoadModels(String error) {
    return 'Kunne ikke laste modeller: $error';
  }

  @override
  String get noModels =>
      'Ingen modeller (sjekk CF-påloggingen i Innstillinger).';

  @override
  String get uploadFace => 'Last opp et ansikt';

  @override
  String get changeFace => 'Bytt ansikt';

  @override
  String get pickFromGallery => 'Velg fra galleriet';

  @override
  String get takePhoto => 'Ta et bilde';

  @override
  String get needCfCredentials =>
      'Angi Cloudflare Access-pålogging i Innstillinger';

  @override
  String get baseImageSelected => 'Basisbilde valgt';

  @override
  String get baseImageOptional => 'Basisbilde (valgfritt)';

  @override
  String get remove => 'Fjern';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modell valgt automatisk ut fra malen.\nDu kan endre den i Innstillinger.';

  @override
  String get modelManualTooltip => 'Modell valgt manuelt i Innstillinger.';

  @override
  String get pickBlocks => 'Velg blokker for å sette sammen en prompt...';
}
