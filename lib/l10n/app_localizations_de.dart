// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get screenBuilder => 'Prompt-Baukasten';

  @override
  String get screenRestyle => 'Foto neu stylen';

  @override
  String get screenHair => 'Frisur ausprobieren';

  @override
  String get screenAnimate => 'Foto animieren';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shopTooltipVideo => 'Animationsguthaben und Pakete';

  @override
  String get shopTooltip => 'Guthaben und Pakete';

  @override
  String get switchCard => 'Karte wechseln';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Animationsguthaben hinzugefügt 🎉',
      one: '1 Animationsguthaben hinzugefügt 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Guthaben hinzugefügt 🎉',
      one: '1 Guthaben hinzugefügt 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed =>
      'Zahlung fehlgeschlagen, bitte versuche es erneut';

  @override
  String errorDetail(String error) {
    return 'Fehler: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Guthaben konnte nicht geladen werden: $error';
  }

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get animationsTitle => 'Animationen';

  @override
  String get creditsTitle => 'Guthaben';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Kostenlose Animationen heute: $free von $limit · Animationsguthaben: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Kostenlose Generierungen heute: $free von $limit · Guthaben: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 Guthaben = 1 Video, bezahlt mit Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 Guthaben = 1 Bild, bezahlt mit Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Guthaben',
      one: '1 Guthaben',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Animationen',
      one: '1 Animation',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose ist im Web nicht verfügbar';

  @override
  String get reposeTooltip => 'Repose (Gesicht in einer Pose)';

  @override
  String get presets => 'Voreinstellungen';

  @override
  String get template => 'Vorlage';

  @override
  String get backToTop => 'Nach oben';

  @override
  String get generating => 'Wird generiert…';

  @override
  String get generate => 'Generieren';

  @override
  String get needCredentials =>
      'Lege in den Einstellungen einen API-Schlüssel oder Zugangsdaten fest';

  @override
  String presetLoaded(String name) {
    return 'Voreinstellung „$name“ geladen';
  }

  @override
  String get connectionLostVideo =>
      'Verbindung verloren – der Bot liefert das Video trotzdem in deinen Chat.';

  @override
  String videoServerDown(String error) {
    return 'Der Videoserver ist gerade nicht verfügbar.\n$error';
  }

  @override
  String get scene => 'Szene';

  @override
  String get uploading => 'Wird hochgeladen…';

  @override
  String get animate => 'Animieren';

  @override
  String get pickPhoto => 'Foto auswählen';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds s Clip · ~$minutes Min. Rendern';
  }

  @override
  String queuePosition(int position) {
    return 'In der Warteschlange · Position $position';
  }

  @override
  String get queueWaiting => 'In der Warteschlange…';

  @override
  String get finishing => 'Wird abgeschlossen (Bewegung wird geglättet)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Beat $beat/$beats · noch ~$minutes Min.';
  }

  @override
  String get videoDone =>
      'Fertig! Das Video wurde in deinen Telegram-Chat gesendet 🎬';

  @override
  String failedDetail(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get unknownError => 'unbekannter Fehler';

  @override
  String get starting => 'Startet…';

  @override
  String get canCloseApp =>
      'Du kannst die App schließen – das Video kommt im Chat an.';

  @override
  String get notCharged =>
      'Dein kostenloses Video bzw. Guthaben wurde nicht verbraucht.';

  @override
  String get animateAnother => 'Weiteres animieren';

  @override
  String get restyleHint =>
      'Behält dein Gesicht und deine Pose. Funktioniert am besten mit einem klaren Frontalfoto einer einzelnen Person.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Illustration';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Stile filtern';

  @override
  String get restyling => 'Wird neu gestylt…';

  @override
  String get restyle => 'Neu stylen';

  @override
  String get restyleBusy =>
      'Wird neu gestylt… etwa eine Minute.\nDas Bild kommt auch in deinem Chat an.';

  @override
  String get groupPopular => 'Beliebt';

  @override
  String get groupPainters => 'Maler';

  @override
  String get groupAsia => 'Asien';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Amerika & Ozeanien';

  @override
  String get groupAfricaNearEast => 'Afrika & Naher Osten';

  @override
  String get hairHint =>
      'Behält dein Gesicht und deine Haarfarbe, solange du keine neue wählst. Funktioniert am besten mit einem Frontalporträt, bei dem das Haar vollständig sichtbar ist und keine Mütze getragen wird.';

  @override
  String get noHairstyles => 'Noch keine Frisuren – schau bald wieder vorbei.';

  @override
  String get colour => 'Farbe';

  @override
  String get keepMine => 'Meine behalten';

  @override
  String get haircut => 'Haarschnitt';

  @override
  String get keepMyCut => 'Meinen Schnitt behalten';

  @override
  String get working => 'Wird bearbeitet…';

  @override
  String get newColour => 'Neue Farbe';

  @override
  String get newHaircut => 'Neuer Haarschnitt';

  @override
  String get pickPortrait => 'Porträt auswählen';

  @override
  String get hairBusy =>
      'Wird bearbeitet… etwa eine Minute.\nDas Foto kommt auch in deinem Chat an.';

  @override
  String get hairWomen => 'Damen';

  @override
  String get hairMen => 'Herren';

  @override
  String get hairCuts => 'Schnitte';

  @override
  String get hairBangs => 'Pony';

  @override
  String get hairTexture => 'Struktur';

  @override
  String get hairShort => 'Kurz';

  @override
  String get hairMedium => 'Mittel';

  @override
  String get hairLong => 'Lang';

  @override
  String get hairBraids => 'Zöpfe';

  @override
  String get hairUpdos => 'Hochsteckfrisuren';

  @override
  String get notDownloaded => 'Das Bild wurde noch nicht heruntergeladen';

  @override
  String get savedToGallery => 'In der Galerie gesichert';

  @override
  String couldNotSave(String error) {
    return 'Sichern nicht möglich: $error';
  }

  @override
  String get result => 'Ergebnis';

  @override
  String get saveToGallery => 'In der Galerie sichern';

  @override
  String get copyPrompt => 'Prompt kopieren';

  @override
  String get promptCopied => 'Prompt kopiert';

  @override
  String get imageNotAvailable => 'Bild nicht verfügbar';

  @override
  String get promptUsed => 'Verwendeter Prompt:';

  @override
  String get revisedPrompt => 'Überarbeiteter Prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Laden nicht möglich: $error';
  }

  @override
  String get generation => 'Generierung';

  @override
  String get generationWebInfo =>
      'Die Bilder werden vom Tsumiki-Bot (ComfyUI) generiert. Das fertige Bild wird auch in deinen Chat mit dem Bot gesendet.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Generierungs-Backend';

  @override
  String get xaiInfo =>
      'API-Schlüssel von console.x.ai für die Generierung über Grok.';

  @override
  String get apiKey => 'API-Schlüssel';

  @override
  String get ol1nInfo =>
      'Lokales AiStack (Flux-diffusers-API). Gib ein CF-Access-Service-Token ein oder lass das Feld leer, wenn es beim Build eingebaut ist (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokales ComfyUI (Modellauswahl unten). Teilt das CF-Access-Token mit llm.ol1n.com.';

  @override
  String get save => 'Sichern';

  @override
  String get saved => 'Gesichert';

  @override
  String get wfAuto => 'Automatisch – der gewählten Vorlage folgen';

  @override
  String get wfFlux => 'Flux – malerische und fotorealistische Stile';

  @override
  String get wfPony => 'Pony Diffusion – Anime, Danbooru-Tags';

  @override
  String get wfJuggernaut =>
      'Juggernaut XL Lightning – schneller Fotorealismus';

  @override
  String get wfWai => 'WAI Illustrious – Anime, neuer als Pony';

  @override
  String templateChose(String workflow) {
    return 'Die Vorlage hat gewählt: $workflow';
  }

  @override
  String get apiKeySaved => 'API-Schlüssel gesichert';

  @override
  String get reposeScreenTitle => 'Repose – Gesicht in einer Pose';

  @override
  String get model => 'Modell';

  @override
  String get stepFace => '1. Gesicht';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIV';

  @override
  String get reposePromptHint =>
      'Foto einer Frau, Ganzkörper, natürliches Licht…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modelle konnten nicht geladen werden: $error';
  }

  @override
  String get noModels =>
      'Keine Modelle (prüfe die CF-Zugangsdaten in den Einstellungen).';

  @override
  String get uploadFace => 'Gesicht hochladen';

  @override
  String get changeFace => 'Gesicht ändern';

  @override
  String get pickFromGallery => 'Aus der Galerie wählen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get needCfCredentials =>
      'Lege die Cloudflare-Access-Zugangsdaten in den Einstellungen fest';

  @override
  String get baseImageSelected => 'Basisbild ausgewählt';

  @override
  String get baseImageOptional => 'Basisbild (optional)';

  @override
  String get remove => 'Entfernen';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modell wird automatisch anhand der Vorlage gewählt.\nDu kannst es in den Einstellungen ändern.';

  @override
  String get modelManualTooltip =>
      'Modell manuell in den Einstellungen gewählt.';

  @override
  String get pickBlocks =>
      'Wähle Bausteine, um einen Prompt zusammenzusetzen...';
}
