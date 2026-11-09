// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get screenBuilder => 'Graditelj promptova';

  @override
  String get screenRestyle => 'Promijeni stil fotografije';

  @override
  String get screenHair => 'Isprobaj frizuru';

  @override
  String get screenAnimate => 'Animiraj fotografiju';

  @override
  String get settings => 'Postavke';

  @override
  String get shopTooltipVideo => 'Krediti za animacije i paketi';

  @override
  String get shopTooltip => 'Krediti i paketi';

  @override
  String get switchCard => 'Promijeni karticu';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano je $count kredita za animacije 🎉',
      few: 'Dodana su $count kredita za animacije 🎉',
      one: 'Dodan je 1 kredit za animacije 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano je $count kredita 🎉',
      few: 'Dodana su $count kredita 🎉',
      one: 'Dodan je 1 kredit 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Plaćanje nije uspjelo, pokušaj ponovno';

  @override
  String errorDetail(String error) {
    return 'Pogreška: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Krediti se nisu učitali: $error';
  }

  @override
  String get tryAgain => 'Pokušaj ponovno';

  @override
  String get animationsTitle => 'Animacije';

  @override
  String get creditsTitle => 'Krediti';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Besplatne animacije danas: $free od $limit · krediti za animacije: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Besplatna generiranja danas: $free od $limit · krediti: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 kredit = 1 videozapis, plaća se Telegram Starsima.';

  @override
  String get imagePriceNote =>
      '1 kredit = 1 slika, plaća se Telegram Starsima.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredita',
      few: '$count kredita',
      one: '1 kredit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animacija',
      few: '$count animacije',
      one: '1 animacija',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose nije dostupan na webu';

  @override
  String get reposeTooltip => 'Repose (lice u pozi)';

  @override
  String get presets => 'Predlošci';

  @override
  String get template => 'Predložak';

  @override
  String get backToTop => 'Na vrh';

  @override
  String get generating => 'Generiranje…';

  @override
  String get generate => 'Generiraj';

  @override
  String get needCredentials =>
      'Postavi API ključ ili vjerodajnice u Postavkama';

  @override
  String presetLoaded(String name) {
    return 'Predložak „$name” učitan';
  }

  @override
  String get connectionLostVideo =>
      'Veza je prekinuta — bot će svejedno isporučiti videozapis u tvoj chat.';

  @override
  String videoServerDown(String error) {
    return 'Video poslužitelj trenutačno nije dostupan.\n$error';
  }

  @override
  String get scene => 'Scena';

  @override
  String get uploading => 'Prijenos…';

  @override
  String get animate => 'Animiraj';

  @override
  String get pickPhoto => 'Odaberi fotografiju';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'isječak ~$seconds s · renderiranje ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'U redu · pozicija $position';
  }

  @override
  String get queueWaiting => 'U redu…';

  @override
  String get finishing => 'Završavanje (zaglađivanje pokreta)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · preostalo ~$minutes min';
  }

  @override
  String get videoDone =>
      'Gotovo! Videozapis je poslan u tvoj Telegram chat 🎬';

  @override
  String failedDetail(String error) {
    return 'Neuspjeh: $error';
  }

  @override
  String get unknownError => 'nepoznata pogreška';

  @override
  String get starting => 'Pokretanje…';

  @override
  String get canCloseApp =>
      'Aplikaciju možeš zatvoriti — videozapis stiže u chat.';

  @override
  String get notCharged => 'Tvoj besplatni videozapis / kredit nije potrošen.';

  @override
  String get animateAnother => 'Animiraj još jednu';

  @override
  String get restyleHint =>
      'Zadržava tvoje lice i pozu. Najbolje radi s jasnom fotografijom jedne osobe s prednje strane.';

  @override
  String get medium => 'Medij';

  @override
  String get mediumPhoto => 'Fotografija';

  @override
  String get mediumIllustration => 'Ilustracija';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Filtriraj stilove';

  @override
  String get restyling => 'Promjena stila…';

  @override
  String get restyle => 'Promijeni stil';

  @override
  String get restyleBusy =>
      'Promjena stila… otprilike minutu.\nSlika stiže i u tvoj chat.';

  @override
  String get groupPopular => 'Popularno';

  @override
  String get groupPainters => 'Slikari';

  @override
  String get groupAsia => 'Azija';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amerike i Oceanija';

  @override
  String get groupAfricaNearEast => 'Afrika i Bliski istok';

  @override
  String get hairHint =>
      'Zadržava tvoje lice i boju kose, osim ako odabereš novu. Najbolje radi s portretom s prednje strane, s potpuno vidljivom kosom i bez kape.';

  @override
  String get noHairstyles => 'Još nema frizura — navrati uskoro.';

  @override
  String get colour => 'Boja';

  @override
  String get keepMine => 'Zadrži moju';

  @override
  String get haircut => 'Frizura';

  @override
  String get keepMyCut => 'Zadrži moju frizuru';

  @override
  String get working => 'Radim…';

  @override
  String get newColour => 'Nova boja';

  @override
  String get newHaircut => 'Nova frizura';

  @override
  String get pickPortrait => 'Odaberi portret';

  @override
  String get hairBusy =>
      'Radim… otprilike minutu.\nFotografija stiže i u tvoj chat.';

  @override
  String get hairWomen => 'Žene';

  @override
  String get hairMen => 'Muškarci';

  @override
  String get hairCuts => 'Šišanja';

  @override
  String get hairBangs => 'Šiške';

  @override
  String get hairTexture => 'Tekstura';

  @override
  String get hairShort => 'Kratka';

  @override
  String get hairMedium => 'Srednja';

  @override
  String get hairLong => 'Duga';

  @override
  String get hairBraids => 'Pletenice';

  @override
  String get hairUpdos => 'Podignute frizure';

  @override
  String get notDownloaded => 'Slika još nije preuzeta';

  @override
  String get savedToGallery => 'Spremljeno u galeriju';

  @override
  String couldNotSave(String error) {
    return 'Spremanje nije uspjelo: $error';
  }

  @override
  String get result => 'Rezultat';

  @override
  String get saveToGallery => 'Spremi u galeriju';

  @override
  String get copyPrompt => 'Kopiraj prompt';

  @override
  String get promptCopied => 'Prompt kopiran';

  @override
  String get imageNotAvailable => 'Slika nije dostupna';

  @override
  String get promptUsed => 'Korišteni prompt:';

  @override
  String get revisedPrompt => 'Prerađeni prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Učitavanje nije uspjelo: $error';
  }

  @override
  String get generation => 'Generiranje';

  @override
  String get generationWebInfo =>
      'Slike generira Tsumiki bot (ComfyUI). Gotova slika šalje se i u tvoj chat s botom.';

  @override
  String get workflow => 'Tijek rada';

  @override
  String get generationBackend => 'Pozadina generiranja';

  @override
  String get xaiInfo => 'API ključ s console.x.ai za generiranje putem Groka.';

  @override
  String get apiKey => 'API ključ';

  @override
  String get ol1nInfo =>
      'Lokalni AiStack (Flux diffusers API). Unesi servisni token CF Accessa ili ostavi prazno ako je ugrađen u build (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokalni ComfyUI (odabir modela ispod). Dijeli CF Access token s llm.ol1n.com.';

  @override
  String get save => 'Spremi';

  @override
  String get saved => 'Spremljeno';

  @override
  String get wfAuto => 'Automatski — prema odabranom predlošku';

  @override
  String get wfFlux => 'Flux — slikarski i fotorealistični stilovi';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru oznake';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — brzi fotorealizam';

  @override
  String get wfWai => 'WAI Illustrious — anime, noviji od Ponyja';

  @override
  String templateChose(String workflow) {
    return 'Predložak je odabrao: $workflow';
  }

  @override
  String get apiKeySaved => 'API ključ spremljen';

  @override
  String get reposeScreenTitle => 'Repose — lice u pozi';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Lice';

  @override
  String get stepPose => '2. Poza';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIV';

  @override
  String get reposePromptHint =>
      'fotografija žene, cijelo tijelo, prirodno svjetlo…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modeli se nisu učitali: $error';
  }

  @override
  String get noModels => 'Nema modela (provjeri CF vjerodajnice u Postavkama).';

  @override
  String get uploadFace => 'Učitaj lice';

  @override
  String get changeFace => 'Promijeni lice';

  @override
  String get pickFromGallery => 'Odaberi iz galerije';

  @override
  String get takePhoto => 'Snimi fotografiju';

  @override
  String get needCfCredentials =>
      'Postavi Cloudflare Access vjerodajnice u Postavkama';

  @override
  String get baseImageSelected => 'Osnovna slika odabrana';

  @override
  String get baseImageOptional => 'Osnovna slika (neobavezno)';

  @override
  String get remove => 'Ukloni';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model je automatski odabran prema predlošku.\nMožeš ga promijeniti u Postavkama.';

  @override
  String get modelManualTooltip => 'Model je ručno odabran u Postavkama.';

  @override
  String get pickBlocks => 'Odaberi blokove za sastavljanje prompta...';
}
