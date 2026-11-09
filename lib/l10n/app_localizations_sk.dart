// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get screenBuilder => 'Skladanie promptov';

  @override
  String get screenRestyle => 'Zmeniť štýl fotky';

  @override
  String get screenHair => 'Vyskúšať účes';

  @override
  String get screenAnimate => 'Rozpohybovať fotku';

  @override
  String get settings => 'Nastavenia';

  @override
  String get shopTooltipVideo => 'Kredity na animácie a balíčky';

  @override
  String get shopTooltip => 'Kredity a balíčky';

  @override
  String get switchCard => 'Prepnúť kartu';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pridaných $count kreditov na animácie 🎉',
      few: 'Pridané $count kredity na animácie 🎉',
      one: 'Pridaný 1 kredit na animácie 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pridaných $count kreditov 🎉',
      few: 'Pridané $count kredity 🎉',
      one: 'Pridaný 1 kredit 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Platba zlyhala, skús to znova';

  @override
  String errorDetail(String error) {
    return 'Chyba: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Kredity sa nepodarilo načítať: $error';
  }

  @override
  String get tryAgain => 'Skúsiť znova';

  @override
  String get animationsTitle => 'Animácie';

  @override
  String get creditsTitle => 'Kredity';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Dnešné animácie zadarmo: $free z $limit · kredity na animácie: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Dnešné generovania zadarmo: $free z $limit · kredity: $credits';
  }

  @override
  String get videoPriceNote => '1 kredit = 1 video, platené v Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 kredit = 1 obrázok, platené v Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kreditov',
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
      other: '$count animácií',
      few: '$count animácie',
      one: '1 animácia',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose nie je na webe dostupné';

  @override
  String get reposeTooltip => 'Repose (tvár v póze)';

  @override
  String get presets => 'Predvoľby';

  @override
  String get template => 'Šablóna';

  @override
  String get backToTop => 'Späť hore';

  @override
  String get generating => 'Generujem…';

  @override
  String get generate => 'Generovať';

  @override
  String get needCredentials =>
      'Nastav v Nastaveniach API kľúč alebo prihlasovacie údaje';

  @override
  String presetLoaded(String name) {
    return 'Predvoľba „$name“ načítaná';
  }

  @override
  String get connectionLostVideo =>
      'Spojenie sa prerušilo — bot video do tvojho chatu aj tak doručí.';

  @override
  String videoServerDown(String error) {
    return 'Videoserver teraz nie je dostupný.\n$error';
  }

  @override
  String get scene => 'Scéna';

  @override
  String get uploading => 'Nahrávam…';

  @override
  String get animate => 'Rozpohybovať';

  @override
  String get pickPhoto => 'Vybrať fotku';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'klip ~$seconds s · renderovanie ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'Vo fronte · pozícia $position';
  }

  @override
  String get queueWaiting => 'Vo fronte…';

  @override
  String get finishing => 'Dokončujem (vyhladzujem pohyb)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · zostáva ~$minutes min';
  }

  @override
  String get videoDone =>
      'Hotovo! Video bolo odoslané do tvojho chatu v Telegrame 🎬';

  @override
  String failedDetail(String error) {
    return 'Zlyhalo: $error';
  }

  @override
  String get unknownError => 'neznáma chyba';

  @override
  String get starting => 'Spúšťam…';

  @override
  String get canCloseApp => 'Aplikáciu môžeš zavrieť — video príde do chatu.';

  @override
  String get notCharged => 'Tvoje video zadarmo / kredit sa nespotrebovalo.';

  @override
  String get animateAnother => 'Rozpohybovať ďalšiu';

  @override
  String get restyleHint =>
      'Zachová tvoju tvár a pózu. Najlepšie funguje s ostrou fotkou jednej osoby spredu.';

  @override
  String get medium => 'Médium';

  @override
  String get mediumPhoto => 'Fotka';

  @override
  String get mediumIllustration => 'Ilustrácia';

  @override
  String get style => 'Štýl';

  @override
  String get filterStyles => 'Filtrovať štýly';

  @override
  String get restyling => 'Mením štýl…';

  @override
  String get restyle => 'Zmeniť štýl';

  @override
  String get restyleBusy =>
      'Mením štýl… asi minútu.\nObrázok príde aj do tvojho chatu.';

  @override
  String get groupPopular => 'Obľúbené';

  @override
  String get groupPainters => 'Maliari';

  @override
  String get groupAsia => 'Ázia';

  @override
  String get groupEurope => 'Európa';

  @override
  String get groupAmericasOceania => 'Amerika a Oceánia';

  @override
  String get groupAfricaNearEast => 'Afrika a Blízky východ';

  @override
  String get hairHint =>
      'Zachová tvoju tvár a farbu vlasov, ak nevyberieš novú. Najlepšie funguje s portrétom spredu, na ktorom sú vlasy celé vidieť, bez čiapky.';

  @override
  String get noHairstyles => 'Zatiaľ žiadne účesy — skús to čoskoro znova.';

  @override
  String get colour => 'Farba';

  @override
  String get keepMine => 'Ponechať moju';

  @override
  String get haircut => 'Strih';

  @override
  String get keepMyCut => 'Ponechať môj strih';

  @override
  String get working => 'Pracujem…';

  @override
  String get newColour => 'Nová farba';

  @override
  String get newHaircut => 'Nový strih';

  @override
  String get pickPortrait => 'Vybrať portrét';

  @override
  String get hairBusy =>
      'Pracujem… asi minútu.\nFotka príde aj do tvojho chatu.';

  @override
  String get hairWomen => 'Dámske';

  @override
  String get hairMen => 'Pánske';

  @override
  String get hairCuts => 'Strihy';

  @override
  String get hairBangs => 'Ofina';

  @override
  String get hairTexture => 'Štruktúra';

  @override
  String get hairShort => 'Krátke';

  @override
  String get hairMedium => 'Stredné';

  @override
  String get hairLong => 'Dlhé';

  @override
  String get hairBraids => 'Vrkoče';

  @override
  String get hairUpdos => 'Vyčesané';

  @override
  String get notDownloaded => 'Obrázok ešte nebol stiahnutý';

  @override
  String get savedToGallery => 'Uložené do galérie';

  @override
  String couldNotSave(String error) {
    return 'Nepodarilo sa uložiť: $error';
  }

  @override
  String get result => 'Výsledok';

  @override
  String get saveToGallery => 'Uložiť do galérie';

  @override
  String get copyPrompt => 'Kopírovať prompt';

  @override
  String get promptCopied => 'Prompt skopírovaný';

  @override
  String get imageNotAvailable => 'Obrázok nie je k dispozícii';

  @override
  String get promptUsed => 'Použitý prompt:';

  @override
  String get revisedPrompt => 'Upravený prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Nepodarilo sa načítať: $error';
  }

  @override
  String get generation => 'Generovanie';

  @override
  String get generationWebInfo =>
      'Obrázky generuje bot Tsumiki (ComfyUI). Hotový obrázok sa pošle aj do tvojho chatu s botom.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Generovací backend';

  @override
  String get xaiInfo => 'API kľúč z console.x.ai na generovanie cez Grok.';

  @override
  String get apiKey => 'API kľúč';

  @override
  String get ol1nInfo =>
      'Lokálny AiStack (Flux diffusers API). Zadaj servisný token CF Access, alebo nechaj prázdne, ak je zabudovaný do buildu (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokálny ComfyUI (výber modelu nižšie). Zdieľa token CF Access s llm.ol1n.com.';

  @override
  String get save => 'Uložiť';

  @override
  String get saved => 'Uložené';

  @override
  String get wfAuto => 'Automaticky — podľa zvolenej šablóny';

  @override
  String get wfFlux => 'Flux — maliarske a fotorealistické štýly';

  @override
  String get wfPony => 'Pony Diffusion — anime, tagy Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — rýchly fotorealizmus';

  @override
  String get wfWai => 'WAI Illustrious — anime, novší než Pony';

  @override
  String templateChose(String workflow) {
    return 'Šablóna zvolila: $workflow';
  }

  @override
  String get apiKeySaved => 'API kľúč uložený';

  @override
  String get reposeScreenTitle => 'Repose — tvár v póze';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Tvár';

  @override
  String get stepPose => '2. Póza';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATÍVNY';

  @override
  String get reposePromptHint => 'fotka ženy, celá postava, prirodzené svetlo…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modely sa nepodarilo načítať: $error';
  }

  @override
  String get noModels =>
      'Žiadne modely (skontroluj prihlasovacie údaje CF v Nastaveniach).';

  @override
  String get uploadFace => 'Nahrať tvár';

  @override
  String get changeFace => 'Zmeniť tvár';

  @override
  String get pickFromGallery => 'Vybrať z galérie';

  @override
  String get takePhoto => 'Odfotiť';

  @override
  String get needCfCredentials =>
      'Nastav v Nastaveniach prihlasovacie údaje Cloudflare Access';

  @override
  String get baseImageSelected => 'Základný obrázok vybraný';

  @override
  String get baseImageOptional => 'Základný obrázok (voliteľné)';

  @override
  String get remove => 'Odstrániť';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model zvolený automaticky podľa šablóny.\nMôžeš ho zmeniť v Nastaveniach.';

  @override
  String get modelManualTooltip => 'Model zvolený ručne v Nastaveniach.';

  @override
  String get pickBlocks => 'Vyber bloky a zlož prompt...';
}
