// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get screenBuilder => 'Promptbygger';

  @override
  String get screenRestyle => 'Ændr stil på et foto';

  @override
  String get screenHair => 'Prøv en frisure';

  @override
  String get screenAnimate => 'Animér et foto';

  @override
  String get settings => 'Indstillinger';

  @override
  String get shopTooltipVideo => 'Animationskreditter og pakker';

  @override
  String get shopTooltip => 'Kreditter og pakker';

  @override
  String get switchCard => 'Skift kort';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animationskreditter tilføjet 🎉',
      one: '1 animationskredit tilføjet 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditter tilføjet 🎉',
      one: '1 kredit tilføjet 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Betalingen mislykkedes, prøv igen';

  @override
  String errorDetail(String error) {
    return 'Fejl: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Kreditter kunne ikke indlæses: $error';
  }

  @override
  String get tryAgain => 'Prøv igen';

  @override
  String get animationsTitle => 'Animationer';

  @override
  String get creditsTitle => 'Kreditter';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Gratis animationer i dag: $free af $limit · animationskreditter: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Gratis genereringer i dag: $free af $limit · kreditter: $credits';
  }

  @override
  String get videoPriceNote => '1 kredit = 1 video, betalt med Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 kredit = 1 billede, betalt med Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditter',
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
  String get reposeWebUnavailable => 'Repose er ikke tilgængelig på nettet';

  @override
  String get reposeTooltip => 'Repose (ansigt i en positur)';

  @override
  String get presets => 'Forudindstillinger';

  @override
  String get template => 'Skabelon';

  @override
  String get backToTop => 'Til toppen';

  @override
  String get generating => 'Genererer…';

  @override
  String get generate => 'Generér';

  @override
  String get needCredentials =>
      'Angiv en API-nøgle eller loginoplysninger i Indstillinger';

  @override
  String presetLoaded(String name) {
    return 'Forudindstillingen “$name” er indlæst';
  }

  @override
  String get connectionLostVideo =>
      'Forbindelsen blev afbrudt — botten leverer stadig videoen til din chat.';

  @override
  String videoServerDown(String error) {
    return 'Videoserveren er ikke tilgængelig lige nu.\n$error';
  }

  @override
  String get scene => 'Scene';

  @override
  String get uploading => 'Uploader…';

  @override
  String get animate => 'Animér';

  @override
  String get pickPhoto => 'Vælg et foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds s klip · ~$minutes min rendering';
  }

  @override
  String queuePosition(int position) {
    return 'I kø · plads $position';
  }

  @override
  String get queueWaiting => 'I kø…';

  @override
  String get finishing => 'Afslutter (udjævner bevægelsen)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · ~$minutes min tilbage';
  }

  @override
  String get videoDone => 'Færdig! Videoen er sendt til din Telegram-chat 🎬';

  @override
  String failedDetail(String error) {
    return 'Mislykkedes: $error';
  }

  @override
  String get unknownError => 'ukendt fejl';

  @override
  String get starting => 'Starter…';

  @override
  String get canCloseApp => 'Du kan lukke appen — videoen kommer i chatten.';

  @override
  String get notCharged => 'Din gratis video / kredit blev ikke brugt.';

  @override
  String get animateAnother => 'Animér en til';

  @override
  String get restyleHint =>
      'Bevarer dit ansigt og din positur. Virker bedst med et skarpt foto forfra af én person.';

  @override
  String get medium => 'Medie';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Illustration';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Filtrér stilarter';

  @override
  String get restyling => 'Ændrer stil…';

  @override
  String get restyle => 'Ændr stil';

  @override
  String get restyleBusy =>
      'Ændrer stil… cirka et minut.\nBilledet kommer også til din chat.';

  @override
  String get groupPopular => 'Populære';

  @override
  String get groupPainters => 'Malere';

  @override
  String get groupAsia => 'Asien';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amerika og Oceanien';

  @override
  String get groupAfricaNearEast => 'Afrika og Mellemøsten';

  @override
  String get hairHint =>
      'Bevarer dit ansigt og din hårfarve, medmindre du vælger en ny. Virker bedst med et portræt forfra, hvor håret er helt synligt, uden hat.';

  @override
  String get noHairstyles => 'Ingen frisurer endnu — kig snart forbi igen.';

  @override
  String get colour => 'Farve';

  @override
  String get keepMine => 'Behold min';

  @override
  String get haircut => 'Frisure';

  @override
  String get keepMyCut => 'Behold min frisure';

  @override
  String get working => 'Arbejder…';

  @override
  String get newColour => 'Ny farve';

  @override
  String get newHaircut => 'Ny frisure';

  @override
  String get pickPortrait => 'Vælg et portræt';

  @override
  String get hairBusy =>
      'Arbejder… cirka et minut.\nFotoet kommer også til din chat.';

  @override
  String get hairWomen => 'Dame';

  @override
  String get hairMen => 'Herre';

  @override
  String get hairCuts => 'Klip';

  @override
  String get hairBangs => 'Pandehår';

  @override
  String get hairTexture => 'Struktur';

  @override
  String get hairShort => 'Kort';

  @override
  String get hairMedium => 'Mellem';

  @override
  String get hairLong => 'Langt';

  @override
  String get hairBraids => 'Fletninger';

  @override
  String get hairUpdos => 'Opsætninger';

  @override
  String get notDownloaded => 'Billedet er ikke hentet endnu';

  @override
  String get savedToGallery => 'Gemt i galleriet';

  @override
  String couldNotSave(String error) {
    return 'Kunne ikke gemme: $error';
  }

  @override
  String get result => 'Resultat';

  @override
  String get saveToGallery => 'Gem i galleriet';

  @override
  String get copyPrompt => 'Kopiér prompt';

  @override
  String get promptCopied => 'Prompt kopieret';

  @override
  String get imageNotAvailable => 'Billedet er ikke tilgængeligt';

  @override
  String get promptUsed => 'Brugt prompt:';

  @override
  String get revisedPrompt => 'Revideret prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Kunne ikke indlæse: $error';
  }

  @override
  String get generation => 'Generering';

  @override
  String get generationWebInfo =>
      'Billeder genereres af Tsumiki-botten (ComfyUI). Det færdige billede sendes også til din chat med botten.';

  @override
  String get workflow => 'Arbejdsgang';

  @override
  String get generationBackend => 'Genereringsbackend';

  @override
  String get xaiInfo => 'API-nøgle fra console.x.ai til generering via Grok.';

  @override
  String get apiKey => 'API-nøgle';

  @override
  String get ol1nInfo =>
      'Lokal AiStack (Flux diffusers-API). Angiv et CF Access-servicetoken, eller lad feltet stå tomt, hvis det er indbygget i buildet (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokal ComfyUI (modelvalg nedenfor). Deler CF Access-token med llm.ol1n.com.';

  @override
  String get save => 'Gem';

  @override
  String get saved => 'Gemt';

  @override
  String get wfAuto => 'Automatisk — følg den valgte skabelon';

  @override
  String get wfFlux => 'Flux — malerisk og fotorealistisk stil';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru-tags';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — hurtig fotorealisme';

  @override
  String get wfWai => 'WAI Illustrious — anime, nyere end Pony';

  @override
  String templateChose(String workflow) {
    return 'Skabelonen valgte: $workflow';
  }

  @override
  String get apiKeySaved => 'API-nøgle gemt';

  @override
  String get reposeScreenTitle => 'Repose — ansigt i en positur';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Ansigt';

  @override
  String get stepPose => '2. Positur';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIV';

  @override
  String get reposePromptHint => 'foto af en kvinde, helfigur, naturligt lys…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modeller kunne ikke indlæses: $error';
  }

  @override
  String get noModels =>
      'Ingen modeller (tjek CF-loginoplysningerne i Indstillinger).';

  @override
  String get uploadFace => 'Upload et ansigt';

  @override
  String get changeFace => 'Skift ansigt';

  @override
  String get pickFromGallery => 'Vælg fra galleriet';

  @override
  String get takePhoto => 'Tag et foto';

  @override
  String get needCfCredentials =>
      'Angiv Cloudflare Access-loginoplysninger i Indstillinger';

  @override
  String get baseImageSelected => 'Basisbillede valgt';

  @override
  String get baseImageOptional => 'Basisbillede (valgfrit)';

  @override
  String get remove => 'Fjern';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model valgt automatisk ud fra skabelonen.\nDu kan ændre den i Indstillinger.';

  @override
  String get modelManualTooltip => 'Model valgt manuelt i Indstillinger.';

  @override
  String get pickBlocks => 'Vælg blokke for at sammensætte en prompt...';
}
