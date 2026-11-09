// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get screenBuilder => 'Δημιουργός prompt';

  @override
  String get screenRestyle => 'Αλλαγή στυλ φωτογραφίας';

  @override
  String get screenHair => 'Δοκίμασε ένα κούρεμα';

  @override
  String get screenAnimate => 'Ζωντάνεψε μια φωτογραφία';

  @override
  String get settings => 'Ρυθμίσεις';

  @override
  String get shopTooltipVideo => 'Πιστώσεις κινούμενης εικόνας και πακέτα';

  @override
  String get shopTooltip => 'Πιστώσεις και πακέτα';

  @override
  String get switchCard => 'Αλλαγή κάρτας';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Προστέθηκαν $count πιστώσεις κινούμενης εικόνας 🎉',
      one: 'Προστέθηκε 1 πίστωση κινούμενης εικόνας 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Προστέθηκαν $count πιστώσεις 🎉',
      one: 'Προστέθηκε 1 πίστωση 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Η πληρωμή απέτυχε, δοκίμασε ξανά';

  @override
  String errorDetail(String error) {
    return 'Σφάλμα: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση των πιστώσεων: $error';
  }

  @override
  String get tryAgain => 'Δοκίμασε ξανά';

  @override
  String get animationsTitle => 'Κινούμενες εικόνες';

  @override
  String get creditsTitle => 'Πιστώσεις';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Δωρεάν animation σήμερα: $free από $limit · πιστώσεις animation: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Δωρεάν δημιουργίες σήμερα: $free από $limit · πιστώσεις: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 πίστωση = 1 βίντεο, πληρωμή με Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 πίστωση = 1 εικόνα, πληρωμή με Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count πιστώσεις',
      one: '1 πίστωση',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animation',
      one: '1 animation',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Το Repose δεν είναι διαθέσιμο στο web';

  @override
  String get reposeTooltip => 'Repose (πρόσωπο σε πόζα)';

  @override
  String get presets => 'Προρυθμίσεις';

  @override
  String get template => 'Πρότυπο';

  @override
  String get backToTop => 'Επιστροφή στην κορυφή';

  @override
  String get generating => 'Δημιουργία…';

  @override
  String get generate => 'Δημιουργία';

  @override
  String get needCredentials =>
      'Όρισε κλειδί API ή διαπιστευτήρια στις Ρυθμίσεις';

  @override
  String presetLoaded(String name) {
    return 'Η προρύθμιση «$name» φορτώθηκε';
  }

  @override
  String get connectionLostVideo =>
      'Η σύνδεση χάθηκε — το bot θα παραδώσει το βίντεο στη συνομιλία σου.';

  @override
  String videoServerDown(String error) {
    return 'Ο διακομιστής βίντεο δεν είναι διαθέσιμος αυτή τη στιγμή.\n$error';
  }

  @override
  String get scene => 'Σκηνή';

  @override
  String get uploading => 'Μεταφόρτωση…';

  @override
  String get animate => 'Ζωντάνεψε';

  @override
  String get pickPhoto => 'Επίλεξε φωτογραφία';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'κλιπ ~$seconds δ · επεξεργασία ~$minutes λ';
  }

  @override
  String queuePosition(int position) {
    return 'Σε αναμονή · θέση $position';
  }

  @override
  String get queueWaiting => 'Σε αναμονή…';

  @override
  String get finishing => 'Ολοκλήρωση (εξομάλυνση της κίνησης)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Χρόνος $beat/$beats · απομένουν ~$minutes λ';
  }

  @override
  String get videoDone =>
      'Έτοιμο! Το βίντεο στάλθηκε στη συνομιλία σου στο Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Απέτυχε: $error';
  }

  @override
  String get unknownError => 'άγνωστο σφάλμα';

  @override
  String get starting => 'Εκκίνηση…';

  @override
  String get canCloseApp =>
      'Μπορείς να κλείσεις την εφαρμογή — το βίντεο φτάνει στη συνομιλία.';

  @override
  String get notCharged =>
      'Το δωρεάν βίντεο / η πίστωσή σου δεν χρησιμοποιήθηκε.';

  @override
  String get animateAnother => 'Ζωντάνεψε άλλη';

  @override
  String get restyleHint =>
      'Κρατά το πρόσωπο και την πόζα σου. Λειτουργεί καλύτερα με καθαρή φωτογραφία ενός ατόμου από μπροστά.';

  @override
  String get medium => 'Μέσο';

  @override
  String get mediumPhoto => 'Φωτογραφία';

  @override
  String get mediumIllustration => 'Εικονογράφηση';

  @override
  String get style => 'Στυλ';

  @override
  String get filterStyles => 'Φιλτράρισμα στυλ';

  @override
  String get restyling => 'Αλλαγή στυλ…';

  @override
  String get restyle => 'Αλλαγή στυλ';

  @override
  String get restyleBusy =>
      'Αλλαγή στυλ… περίπου ένα λεπτό.\nΗ εικόνα φτάνει και στη συνομιλία σου.';

  @override
  String get groupPopular => 'Δημοφιλή';

  @override
  String get groupPainters => 'Ζωγράφοι';

  @override
  String get groupAsia => 'Ασία';

  @override
  String get groupEurope => 'Ευρώπη';

  @override
  String get groupAmericasOceania => 'Αμερική και Ωκεανία';

  @override
  String get groupAfricaNearEast => 'Αφρική και Εγγύς Ανατολή';

  @override
  String get hairHint =>
      'Κρατά το πρόσωπό σου και το χρώμα των μαλλιών, εκτός αν διαλέξεις νέο. Λειτουργεί καλύτερα με πορτρέτο από μπροστά, με τα μαλλιά πλήρως ορατά, χωρίς καπέλο.';

  @override
  String get noHairstyles =>
      'Δεν υπάρχουν ακόμη χτενίσματα — ξαναπέρασε σύντομα.';

  @override
  String get colour => 'Χρώμα';

  @override
  String get keepMine => 'Κράτα το δικό μου';

  @override
  String get haircut => 'Κούρεμα';

  @override
  String get keepMyCut => 'Κράτα το κούρεμά μου';

  @override
  String get working => 'Σε εξέλιξη…';

  @override
  String get newColour => 'Νέο χρώμα';

  @override
  String get newHaircut => 'Νέο κούρεμα';

  @override
  String get pickPortrait => 'Επίλεξε πορτρέτο';

  @override
  String get hairBusy =>
      'Σε εξέλιξη… περίπου ένα λεπτό.\nΗ φωτογραφία φτάνει και στη συνομιλία σου.';

  @override
  String get hairWomen => 'Γυναικεία';

  @override
  String get hairMen => 'Ανδρικά';

  @override
  String get hairCuts => 'Κουρέματα';

  @override
  String get hairBangs => 'Αφέλειες';

  @override
  String get hairTexture => 'Υφή';

  @override
  String get hairShort => 'Κοντά';

  @override
  String get hairMedium => 'Μεσαία';

  @override
  String get hairLong => 'Μακριά';

  @override
  String get hairBraids => 'Πλεξούδες';

  @override
  String get hairUpdos => 'Μαζεμένα';

  @override
  String get notDownloaded => 'Η εικόνα δεν έχει ληφθεί ακόμη';

  @override
  String get savedToGallery => 'Αποθηκεύτηκε στη συλλογή';

  @override
  String couldNotSave(String error) {
    return 'Δεν ήταν δυνατή η αποθήκευση: $error';
  }

  @override
  String get result => 'Αποτέλεσμα';

  @override
  String get saveToGallery => 'Αποθήκευση στη συλλογή';

  @override
  String get copyPrompt => 'Αντιγραφή prompt';

  @override
  String get promptCopied => 'Το prompt αντιγράφηκε';

  @override
  String get imageNotAvailable => 'Η εικόνα δεν είναι διαθέσιμη';

  @override
  String get promptUsed => 'Prompt που χρησιμοποιήθηκε:';

  @override
  String get revisedPrompt => 'Αναθεωρημένο prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση: $error';
  }

  @override
  String get generation => 'Δημιουργία';

  @override
  String get generationWebInfo =>
      'Οι εικόνες δημιουργούνται από το bot Tsumiki (ComfyUI). Η έτοιμη εικόνα στέλνεται και στη συνομιλία σου με το bot.';

  @override
  String get workflow => 'Ροή εργασίας';

  @override
  String get generationBackend => 'Backend δημιουργίας';

  @override
  String get xaiInfo =>
      'Κλειδί API από το console.x.ai για δημιουργία μέσω Grok.';

  @override
  String get apiKey => 'Κλειδί API';

  @override
  String get ol1nInfo =>
      'Τοπικό AiStack (API Flux diffusers). Βάλε ένα διακριτικό υπηρεσίας CF Access ή άφησέ το κενό αν είναι ενσωματωμένο στο build (--dart-define).';

  @override
  String get comfyInfo =>
      'Τοπικό ComfyUI (επιλογή μοντέλου παρακάτω). Μοιράζεται το διακριτικό CF Access με το llm.ol1n.com.';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get saved => 'Αποθηκεύτηκε';

  @override
  String get wfAuto => 'Αυτόματο — ακολουθεί το επιλεγμένο πρότυπο';

  @override
  String get wfFlux => 'Flux — ζωγραφικά και φωτορεαλιστικά στυλ';

  @override
  String get wfPony => 'Pony Diffusion — anime, ετικέτες Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — γρήγορος φωτορεαλισμός';

  @override
  String get wfWai => 'WAI Illustrious — anime, νεότερο από το Pony';

  @override
  String templateChose(String workflow) {
    return 'Το πρότυπο επέλεξε: $workflow';
  }

  @override
  String get apiKeySaved => 'Το κλειδί API αποθηκεύτηκε';

  @override
  String get reposeScreenTitle => 'Repose — πρόσωπο σε πόζα';

  @override
  String get model => 'Μοντέλο';

  @override
  String get stepFace => '1. Πρόσωπο';

  @override
  String get stepPose => '2. Πόζα';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'ΑΡΝΗΤΙΚΟ';

  @override
  String get reposePromptHint => 'φωτογραφία γυναίκας, ολόσωμη, φυσικό φως…';

  @override
  String couldNotLoadModels(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση των μοντέλων: $error';
  }

  @override
  String get noModels =>
      'Δεν υπάρχουν μοντέλα (έλεγξε τα διαπιστευτήρια CF στις Ρυθμίσεις).';

  @override
  String get uploadFace => 'Μεταφόρτωση προσώπου';

  @override
  String get changeFace => 'Αλλαγή προσώπου';

  @override
  String get pickFromGallery => 'Επιλογή από τη συλλογή';

  @override
  String get takePhoto => 'Λήψη φωτογραφίας';

  @override
  String get needCfCredentials =>
      'Όρισε τα διαπιστευτήρια Cloudflare Access στις Ρυθμίσεις';

  @override
  String get baseImageSelected => 'Επιλέχθηκε βασική εικόνα';

  @override
  String get baseImageOptional => 'Βασική εικόνα (προαιρετικά)';

  @override
  String get remove => 'Αφαίρεση';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Το μοντέλο επιλέχθηκε αυτόματα από το πρότυπο.\nΜπορείς να το αλλάξεις στις Ρυθμίσεις.';

  @override
  String get modelManualTooltip =>
      'Το μοντέλο επιλέχθηκε χειροκίνητα στις Ρυθμίσεις.';

  @override
  String get pickBlocks => 'Επίλεξε μπλοκ για να συνθέσεις ένα prompt...';
}
