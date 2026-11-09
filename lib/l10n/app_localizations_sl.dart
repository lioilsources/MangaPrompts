// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get screenBuilder => 'Sestavljalnik pozivov';

  @override
  String get screenRestyle => 'Spremeni slog fotografije';

  @override
  String get screenHair => 'Preizkusi pričesko';

  @override
  String get screenAnimate => 'Animiraj fotografijo';

  @override
  String get settings => 'Nastavitve';

  @override
  String get shopTooltipVideo => 'Krediti za animacije in paketi';

  @override
  String get shopTooltip => 'Krediti in paketi';

  @override
  String get switchCard => 'Zamenjaj kartico';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodanih $count kreditov za animacije 🎉',
      few: 'Dodani $count krediti za animacije 🎉',
      two: 'Dodana $count kredita za animacije 🎉',
      one: 'Dodan 1 kredit za animacije 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodanih $count kreditov 🎉',
      few: 'Dodani $count krediti 🎉',
      two: 'Dodana $count kredita 🎉',
      one: 'Dodan 1 kredit 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Plačilo ni uspelo, poskusi znova';

  @override
  String errorDetail(String error) {
    return 'Napaka: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Kreditov ni bilo mogoče naložiti: $error';
  }

  @override
  String get tryAgain => 'Poskusi znova';

  @override
  String get animationsTitle => 'Animacije';

  @override
  String get creditsTitle => 'Krediti';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Brezplačne animacije danes: $free od $limit · krediti za animacije: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Brezplačna ustvarjanja danes: $free od $limit · krediti: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 kredit = 1 videoposnetek, plačilo s Telegram Stars.';

  @override
  String get imagePriceNote => '1 kredit = 1 slika, plačilo s Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditov',
      few: '$count krediti',
      two: '$count kredita',
      one: '1 kredit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animacij',
      few: '$count animacije',
      two: '$count animaciji',
      one: '1 animacija',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose na spletu ni na voljo';

  @override
  String get reposeTooltip => 'Repose (obraz v pozi)';

  @override
  String get presets => 'Prednastavitve';

  @override
  String get template => 'Predloga';

  @override
  String get backToTop => 'Na vrh';

  @override
  String get generating => 'Ustvarjanje…';

  @override
  String get generate => 'Ustvari';

  @override
  String get needCredentials => 'V nastavitvah vnesi API-ključ ali poverilnice';

  @override
  String presetLoaded(String name) {
    return 'Prednastavitev »$name« naložena';
  }

  @override
  String get connectionLostVideo =>
      'Povezava prekinjena — bot bo videoposnetek vseeno dostavil v tvoj klepet.';

  @override
  String videoServerDown(String error) {
    return 'Video strežnik trenutno ni na voljo.\n$error';
  }

  @override
  String get scene => 'Prizor';

  @override
  String get uploading => 'Nalaganje…';

  @override
  String get animate => 'Animiraj';

  @override
  String get pickPhoto => 'Izberi fotografijo';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'posnetek ~$seconds s · upodabljanje ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'V čakalni vrsti · mesto $position';
  }

  @override
  String get queueWaiting => 'V čakalni vrsti…';

  @override
  String get finishing => 'Zaključevanje (glajenje gibanja)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · še ~$minutes min';
  }

  @override
  String get videoDone =>
      'Končano! Videoposnetek je bil poslan v tvoj klepet v Telegramu 🎬';

  @override
  String failedDetail(String error) {
    return 'Ni uspelo: $error';
  }

  @override
  String get unknownError => 'neznana napaka';

  @override
  String get starting => 'Zagon…';

  @override
  String get canCloseApp =>
      'Aplikacijo lahko zapreš — videoposnetek prispe v klepet.';

  @override
  String get notCharged =>
      'Tvoj brezplačni videoposnetek / kredit ni bil porabljen.';

  @override
  String get animateAnother => 'Animiraj še eno';

  @override
  String get restyleHint =>
      'Ohrani tvoj obraz in pozo. Najbolje deluje z ostro fotografijo ene osebe od spredaj.';

  @override
  String get medium => 'Medij';

  @override
  String get mediumPhoto => 'Fotografija';

  @override
  String get mediumIllustration => 'Ilustracija';

  @override
  String get style => 'Slog';

  @override
  String get filterStyles => 'Filtriraj sloge';

  @override
  String get restyling => 'Spreminjanje sloga…';

  @override
  String get restyle => 'Spremeni slog';

  @override
  String get restyleBusy =>
      'Spreminjanje sloga… približno minuta.\nSlika prispe tudi v tvoj klepet.';

  @override
  String get groupPopular => 'Priljubljeno';

  @override
  String get groupPainters => 'Slikarji';

  @override
  String get groupAsia => 'Azija';

  @override
  String get groupEurope => 'Evropa';

  @override
  String get groupAmericasOceania => 'Ameriki in Oceanija';

  @override
  String get groupAfricaNearEast => 'Afrika in Bližnji vzhod';

  @override
  String get hairHint =>
      'Ohrani tvoj obraz in barvo las, razen če izbereš novo. Najbolje deluje s portretom od spredaj, kjer so lasje v celoti vidni, brez kape.';

  @override
  String get noHairstyles => 'Pričesk še ni — poglej kmalu spet.';

  @override
  String get colour => 'Barva';

  @override
  String get keepMine => 'Obdrži mojo';

  @override
  String get haircut => 'Pričeska';

  @override
  String get keepMyCut => 'Obdrži mojo pričesko';

  @override
  String get working => 'Delam…';

  @override
  String get newColour => 'Nova barva';

  @override
  String get newHaircut => 'Nova pričeska';

  @override
  String get pickPortrait => 'Izberi portret';

  @override
  String get hairBusy =>
      'Delam… približno minuta.\nFotografija prispe tudi v tvoj klepet.';

  @override
  String get hairWomen => 'Ženske';

  @override
  String get hairMen => 'Moške';

  @override
  String get hairCuts => 'Striženja';

  @override
  String get hairBangs => 'Čopek';

  @override
  String get hairTexture => 'Tekstura';

  @override
  String get hairShort => 'Kratki';

  @override
  String get hairMedium => 'Srednji';

  @override
  String get hairLong => 'Dolgi';

  @override
  String get hairBraids => 'Kitke';

  @override
  String get hairUpdos => 'Skodrane pričeske';

  @override
  String get notDownloaded => 'Slika še ni prenesena';

  @override
  String get savedToGallery => 'Shranjeno v galerijo';

  @override
  String couldNotSave(String error) {
    return 'Shranjevanje ni uspelo: $error';
  }

  @override
  String get result => 'Rezultat';

  @override
  String get saveToGallery => 'Shrani v galerijo';

  @override
  String get copyPrompt => 'Kopiraj poziv';

  @override
  String get promptCopied => 'Poziv kopiran';

  @override
  String get imageNotAvailable => 'Slika ni na voljo';

  @override
  String get promptUsed => 'Uporabljen poziv:';

  @override
  String get revisedPrompt => 'Popravljen poziv (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Nalaganje ni uspelo: $error';
  }

  @override
  String get generation => 'Ustvarjanje';

  @override
  String get generationWebInfo =>
      'Slike ustvarja bot Tsumiki (ComfyUI). Končana slika je poslana tudi v tvoj klepet z botom.';

  @override
  String get workflow => 'Potek dela';

  @override
  String get generationBackend => 'Ozadje ustvarjanja';

  @override
  String get xaiInfo => 'API-ključ s console.x.ai za ustvarjanje prek Groka.';

  @override
  String get apiKey => 'API-ključ';

  @override
  String get ol1nInfo =>
      'Lokalni AiStack (API Flux diffusers). Vnesi storitveni žeton CF Access ali pusti prazno, če je vgrajen v gradnjo (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokalni ComfyUI (izbira modela spodaj). Deli žeton CF Access z llm.ol1n.com.';

  @override
  String get save => 'Shrani';

  @override
  String get saved => 'Shranjeno';

  @override
  String get wfAuto => 'Samodejno — po izbrani predlogi';

  @override
  String get wfFlux => 'Flux — slikarski in fotorealistični slogi';

  @override
  String get wfPony => 'Pony Diffusion — anime, oznake Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — hiter fotorealizem';

  @override
  String get wfWai => 'WAI Illustrious — anime, novejši od Ponyja';

  @override
  String templateChose(String workflow) {
    return 'Predloga je izbrala: $workflow';
  }

  @override
  String get apiKeySaved => 'API-ključ shranjen';

  @override
  String get reposeScreenTitle => 'Repose — obraz v pozi';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Obraz';

  @override
  String get stepPose => '2. Poza';

  @override
  String get stepPrompt => '3. Poziv';

  @override
  String get negative => 'NEGATIVNO';

  @override
  String get reposePromptHint =>
      'fotografija ženske, celotno telo, naravna svetloba…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modelov ni bilo mogoče naložiti: $error';
  }

  @override
  String get noModels => 'Ni modelov (preveri poverilnice CF v nastavitvah).';

  @override
  String get uploadFace => 'Naloži obraz';

  @override
  String get changeFace => 'Zamenjaj obraz';

  @override
  String get pickFromGallery => 'Izberi iz galerije';

  @override
  String get takePhoto => 'Posnemi fotografijo';

  @override
  String get needCfCredentials =>
      'V nastavitvah vnesi poverilnice Cloudflare Access';

  @override
  String get baseImageSelected => 'Osnovna slika izbrana';

  @override
  String get baseImageOptional => 'Osnovna slika (neobvezno)';

  @override
  String get remove => 'Odstrani';

  @override
  String get prompt => 'Poziv';

  @override
  String get modelAutoTooltip =>
      'Model je samodejno izbran glede na predlogo.\nZamenjaš ga lahko v nastavitvah.';

  @override
  String get modelManualTooltip => 'Model je ročno izbran v nastavitvah.';

  @override
  String get pickBlocks => 'Izberi bloke za sestavo poziva...';
}
