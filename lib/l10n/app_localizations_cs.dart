// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get screenBuilder => 'Skládání promptů';

  @override
  String get screenRestyle => 'Změnit styl fotky';

  @override
  String get screenHair => 'Vyzkoušet účes';

  @override
  String get screenAnimate => 'Rozpohybovat fotku';

  @override
  String get settings => 'Nastavení';

  @override
  String get shopTooltipVideo => 'Kredity na animace a balíčky';

  @override
  String get shopTooltip => 'Kredity a balíčky';

  @override
  String get switchCard => 'Přepnout kartu';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přidáno $count kreditů na animace 🎉',
      few: 'Přidány $count kredity na animace 🎉',
      one: 'Přidán 1 kredit na animace 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přidáno $count kreditů 🎉',
      few: 'Přidány $count kredity 🎉',
      one: 'Přidán 1 kredit 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Platba selhala, zkus to znovu';

  @override
  String errorDetail(String error) {
    return 'Chyba: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Kredity se nepodařilo načíst: $error';
  }

  @override
  String get tryAgain => 'Zkusit znovu';

  @override
  String get animationsTitle => 'Animace';

  @override
  String get creditsTitle => 'Kredity';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Dnešní animace zdarma: $free z $limit · kredity na animace: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Dnešní generování zdarma: $free z $limit · kredity: $credits';
  }

  @override
  String get videoPriceNote => '1 kredit = 1 video, placeno v Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 kredit = 1 obrázek, placeno v Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditů',
      few: '$count kredity',
      one: '1 kredit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animací',
      few: '$count animace',
      one: '1 animace',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose není na webu dostupné';

  @override
  String get reposeTooltip => 'Repose (obličej v pozici)';

  @override
  String get presets => 'Předvolby';

  @override
  String get template => 'Šablona';

  @override
  String get backToTop => 'Zpět nahoru';

  @override
  String get generating => 'Generuji…';

  @override
  String get generate => 'Generovat';

  @override
  String get needCredentials =>
      'Nastav v Nastavení API klíč nebo přihlašovací údaje';

  @override
  String presetLoaded(String name) {
    return 'Předvolba „$name“ načtena';
  }

  @override
  String get connectionLostVideo =>
      'Spojení se přerušilo — bot video do tvého chatu přesto doručí.';

  @override
  String videoServerDown(String error) {
    return 'Videoserver teď není dostupný.\n$error';
  }

  @override
  String get scene => 'Scéna';

  @override
  String get uploading => 'Nahrávám…';

  @override
  String get animate => 'Rozpohybovat';

  @override
  String get pickPhoto => 'Vybrat fotku';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'klip ~$seconds s · renderování ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'Ve frontě · pozice $position';
  }

  @override
  String get queueWaiting => 'Ve frontě…';

  @override
  String get finishing => 'Dokončuji (vyhlazuji pohyb)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · zbývá ~$minutes min';
  }

  @override
  String get videoDone =>
      'Hotovo! Video bylo odesláno do tvého chatu v Telegramu 🎬';

  @override
  String failedDetail(String error) {
    return 'Selhalo: $error';
  }

  @override
  String get unknownError => 'neznámá chyba';

  @override
  String get starting => 'Spouštím…';

  @override
  String get canCloseApp => 'Aplikaci můžeš zavřít — video dorazí do chatu.';

  @override
  String get notCharged => 'Tvé video zdarma / kredit se nespotřeboval.';

  @override
  String get animateAnother => 'Rozpohybovat další';

  @override
  String get restyleHint =>
      'Zachová tvůj obličej a pózu. Nejlépe funguje s ostrou fotkou jedné osoby zpředu.';

  @override
  String get medium => 'Médium';

  @override
  String get mediumPhoto => 'Fotka';

  @override
  String get mediumIllustration => 'Ilustrace';

  @override
  String get style => 'Styl';

  @override
  String get filterStyles => 'Filtrovat styly';

  @override
  String get restyling => 'Měním styl…';

  @override
  String get restyle => 'Změnit styl';

  @override
  String get restyleBusy =>
      'Měním styl… asi minutu.\nObrázek dorazí také do tvého chatu.';

  @override
  String get groupPopular => 'Oblíbené';

  @override
  String get groupPainters => 'Malíři';

  @override
  String get groupAsia => 'Asie';

  @override
  String get groupEurope => 'Evropa';

  @override
  String get groupAmericasOceania => 'Amerika a Oceánie';

  @override
  String get groupAfricaNearEast => 'Afrika a Blízký východ';

  @override
  String get hairHint =>
      'Zachová tvůj obličej a barvu vlasů, pokud nevybereš novou. Nejlépe funguje s portrétem zpředu, na kterém jsou vlasy celé vidět, bez čepice.';

  @override
  String get noHairstyles => 'Zatím žádné účesy — zkus to brzy znovu.';

  @override
  String get colour => 'Barva';

  @override
  String get keepMine => 'Ponechat mou';

  @override
  String get haircut => 'Střih';

  @override
  String get keepMyCut => 'Ponechat můj střih';

  @override
  String get working => 'Pracuji…';

  @override
  String get newColour => 'Nová barva';

  @override
  String get newHaircut => 'Nový střih';

  @override
  String get pickPortrait => 'Vybrat portrét';

  @override
  String get hairBusy =>
      'Pracuji… asi minutu.\nFotka dorazí také do tvého chatu.';

  @override
  String get hairWomen => 'Dámské';

  @override
  String get hairMen => 'Pánské';

  @override
  String get hairCuts => 'Střihy';

  @override
  String get hairBangs => 'Ofina';

  @override
  String get hairTexture => 'Struktura';

  @override
  String get hairShort => 'Krátké';

  @override
  String get hairMedium => 'Střední';

  @override
  String get hairLong => 'Dlouhé';

  @override
  String get hairBraids => 'Copy';

  @override
  String get hairUpdos => 'Vyčesané';

  @override
  String get notDownloaded => 'Obrázek ještě nebyl stažen';

  @override
  String get savedToGallery => 'Uloženo do galerie';

  @override
  String couldNotSave(String error) {
    return 'Nepodařilo se uložit: $error';
  }

  @override
  String get result => 'Výsledek';

  @override
  String get saveToGallery => 'Uložit do galerie';

  @override
  String get copyPrompt => 'Kopírovat prompt';

  @override
  String get promptCopied => 'Prompt zkopírován';

  @override
  String get imageNotAvailable => 'Obrázek není k dispozici';

  @override
  String get promptUsed => 'Použitý prompt:';

  @override
  String get revisedPrompt => 'Upravený prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Nepodařilo se načíst: $error';
  }

  @override
  String get generation => 'Generování';

  @override
  String get generationWebInfo =>
      'Obrázky generuje bot Tsumiki (ComfyUI). Hotový obrázek se pošle i do tvého chatu s botem.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Generovací backend';

  @override
  String get xaiInfo => 'API klíč z console.x.ai pro generování přes Grok.';

  @override
  String get apiKey => 'API klíč';

  @override
  String get ol1nInfo =>
      'Lokální AiStack (Flux diffusers API). Zadej servisní token CF Access, nebo nech prázdné, pokud je zabudovaný do buildu (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokální ComfyUI (výběr modelu níže). Sdílí token CF Access s llm.ol1n.com.';

  @override
  String get save => 'Uložit';

  @override
  String get saved => 'Uloženo';

  @override
  String get wfAuto => 'Automaticky — podle zvolené šablony';

  @override
  String get wfFlux => 'Flux — malířské a fotorealistické styly';

  @override
  String get wfPony => 'Pony Diffusion — anime, tagy Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — rychlý fotorealismus';

  @override
  String get wfWai => 'WAI Illustrious — anime, novější než Pony';

  @override
  String templateChose(String workflow) {
    return 'Šablona zvolila: $workflow';
  }

  @override
  String get apiKeySaved => 'API klíč uložen';

  @override
  String get reposeScreenTitle => 'Repose — obličej v pozici';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Obličej';

  @override
  String get stepPose => '2. Póza';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIVNÍ';

  @override
  String get reposePromptHint => 'fotka ženy, celá postava, přirozené světlo…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modely se nepodařilo načíst: $error';
  }

  @override
  String get noModels =>
      'Žádné modely (zkontroluj přihlašovací údaje CF v Nastavení).';

  @override
  String get uploadFace => 'Nahrát obličej';

  @override
  String get changeFace => 'Změnit obličej';

  @override
  String get pickFromGallery => 'Vybrat z galerie';

  @override
  String get takePhoto => 'Vyfotit';

  @override
  String get needCfCredentials =>
      'Nastav v Nastavení přihlašovací údaje Cloudflare Access';

  @override
  String get baseImageSelected => 'Základní obrázek vybrán';

  @override
  String get baseImageOptional => 'Základní obrázek (volitelné)';

  @override
  String get remove => 'Odebrat';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model zvolen automaticky podle šablony.\nMůžeš ho změnit v Nastavení.';

  @override
  String get modelManualTooltip => 'Model zvolen ručně v Nastavení.';

  @override
  String get pickBlocks => 'Vyber bloky a slož prompt...';
}
