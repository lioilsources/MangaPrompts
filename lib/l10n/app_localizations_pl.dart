// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get screenBuilder => 'Kreator promptów';

  @override
  String get screenRestyle => 'Zmień styl zdjęcia';

  @override
  String get screenHair => 'Wypróbuj fryzurę';

  @override
  String get screenAnimate => 'Animuj zdjęcie';

  @override
  String get settings => 'Ustawienia';

  @override
  String get shopTooltipVideo => 'Kredyty animacji i pakiety';

  @override
  String get shopTooltip => 'Kredyty i pakiety';

  @override
  String get switchCard => 'Przełącz kartę';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano $count kredytu animacji 🎉',
      many: 'Dodano $count kredytów animacji 🎉',
      few: 'Dodano $count kredyty animacji 🎉',
      one: 'Dodano $count kredyt animacji 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano $count kredytu 🎉',
      many: 'Dodano $count kredytów 🎉',
      few: 'Dodano $count kredyty 🎉',
      one: 'Dodano $count kredyt 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Płatność nie powiodła się, spróbuj ponownie';

  @override
  String errorDetail(String error) {
    return 'Błąd: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Nie udało się wczytać kredytów: $error';
  }

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get animationsTitle => 'Animacje';

  @override
  String get creditsTitle => 'Kredyty';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Darmowe animacje dziś: $free z $limit · kredyty animacji: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Darmowe generowania dziś: $free z $limit · kredyty: $credits';
  }

  @override
  String get videoPriceNote => '1 kredyt = 1 film, płatne w Telegram Stars.';

  @override
  String get imagePriceNote => '1 kredyt = 1 obraz, płatne w Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredytu',
      many: '$count kredytów',
      few: '$count kredyty',
      one: '$count kredyt',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animacji',
      many: '$count animacji',
      few: '$count animacje',
      one: '$count animacja',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable =>
      'Repose nie jest dostępne w wersji webowej';

  @override
  String get reposeTooltip => 'Repose (twarz w pozie)';

  @override
  String get presets => 'Ustawienia wstępne';

  @override
  String get template => 'Szablon';

  @override
  String get backToTop => 'Do góry';

  @override
  String get generating => 'Generowanie…';

  @override
  String get generate => 'Generuj';

  @override
  String get needCredentials =>
      'Ustaw klucz API lub dane logowania w Ustawieniach';

  @override
  String presetLoaded(String name) {
    return 'Wczytano ustawienie „$name”';
  }

  @override
  String get connectionLostVideo =>
      'Utracono połączenie — bot i tak dostarczy film na twój czat.';

  @override
  String videoServerDown(String error) {
    return 'Serwer wideo jest teraz niedostępny.\n$error';
  }

  @override
  String get scene => 'Scena';

  @override
  String get uploading => 'Przesyłanie…';

  @override
  String get animate => 'Animuj';

  @override
  String get pickPhoto => 'Wybierz zdjęcie';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'klip ~$seconds s · renderowanie ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'W kolejce · pozycja $position';
  }

  @override
  String get queueWaiting => 'W kolejce…';

  @override
  String get finishing => 'Kończenie (wygładzanie ruchu)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Takt $beat/$beats · zostało ~$minutes min';
  }

  @override
  String get videoDone => 'Gotowe! Film wysłano na twój czat w Telegramie 🎬';

  @override
  String failedDetail(String error) {
    return 'Niepowodzenie: $error';
  }

  @override
  String get unknownError => 'nieznany błąd';

  @override
  String get starting => 'Uruchamianie…';

  @override
  String get canCloseApp => 'Możesz zamknąć aplikację — film dotrze na czat.';

  @override
  String get notCharged => 'Twój darmowy film / kredyt nie został zużyty.';

  @override
  String get animateAnother => 'Animuj kolejne';

  @override
  String get restyleHint =>
      'Zachowuje twoją twarz i pozę. Najlepiej działa z wyraźnym zdjęciem jednej osoby en face.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Zdjęcie';

  @override
  String get mediumIllustration => 'Ilustracja';

  @override
  String get style => 'Styl';

  @override
  String get filterStyles => 'Filtruj style';

  @override
  String get restyling => 'Zmiana stylu…';

  @override
  String get restyle => 'Zmień styl';

  @override
  String get restyleBusy =>
      'Zmiana stylu… około minuty.\nObraz trafi też na twój czat.';

  @override
  String get groupPopular => 'Popularne';

  @override
  String get groupPainters => 'Malarze';

  @override
  String get groupAsia => 'Azja';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Ameryki i Oceania';

  @override
  String get groupAfricaNearEast => 'Afryka i Bliski Wschód';

  @override
  String get hairHint =>
      'Zachowuje twoją twarz i kolor włosów, chyba że wybierzesz nowy. Najlepiej działa z portretem en face, z w pełni widocznymi włosami, bez czapki.';

  @override
  String get noHairstyles => 'Brak fryzur — zajrzyj wkrótce.';

  @override
  String get colour => 'Kolor';

  @override
  String get keepMine => 'Zachowaj mój';

  @override
  String get haircut => 'Fryzura';

  @override
  String get keepMyCut => 'Zachowaj moją fryzurę';

  @override
  String get working => 'Pracuję…';

  @override
  String get newColour => 'Nowy kolor';

  @override
  String get newHaircut => 'Nowa fryzura';

  @override
  String get pickPortrait => 'Wybierz portret';

  @override
  String get hairBusy =>
      'Pracuję… około minuty.\nZdjęcie trafi też na twój czat.';

  @override
  String get hairWomen => 'Damskie';

  @override
  String get hairMen => 'Męskie';

  @override
  String get hairCuts => 'Cięcia';

  @override
  String get hairBangs => 'Grzywki';

  @override
  String get hairTexture => 'Struktura';

  @override
  String get hairShort => 'Krótkie';

  @override
  String get hairMedium => 'Średnie';

  @override
  String get hairLong => 'Długie';

  @override
  String get hairBraids => 'Warkocze';

  @override
  String get hairUpdos => 'Upięcia';

  @override
  String get notDownloaded => 'Obraz nie został jeszcze pobrany';

  @override
  String get savedToGallery => 'Zapisano w galerii';

  @override
  String couldNotSave(String error) {
    return 'Nie udało się zapisać: $error';
  }

  @override
  String get result => 'Wynik';

  @override
  String get saveToGallery => 'Zapisz w galerii';

  @override
  String get copyPrompt => 'Kopiuj prompt';

  @override
  String get promptCopied => 'Skopiowano prompt';

  @override
  String get imageNotAvailable => 'Obraz niedostępny';

  @override
  String get promptUsed => 'Użyty prompt:';

  @override
  String get revisedPrompt => 'Poprawiony prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Nie udało się wczytać: $error';
  }

  @override
  String get generation => 'Generowanie';

  @override
  String get generationWebInfo =>
      'Obrazy generuje bot Tsumiki (ComfyUI). Gotowy obraz trafia też na twój czat z botem.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Backend generowania';

  @override
  String get xaiInfo => 'Klucz API z console.x.ai do generowania przez Grok.';

  @override
  String get apiKey => 'Klucz API';

  @override
  String get ol1nInfo =>
      'Lokalny AiStack (API Flux diffusers). Podaj token usługi CF Access lub zostaw puste, jeśli jest wbudowany w kompilację (--dart-define).';

  @override
  String get comfyInfo =>
      'Lokalny ComfyUI (wybór modelu poniżej). Współdzieli token CF Access z llm.ol1n.com.';

  @override
  String get save => 'Zapisz';

  @override
  String get saved => 'Zapisano';

  @override
  String get wfAuto => 'Automatycznie — według wybranego szablonu';

  @override
  String get wfFlux => 'Flux — style malarskie i fotorealistyczne';

  @override
  String get wfPony => 'Pony Diffusion — anime, tagi Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — szybki fotorealizm';

  @override
  String get wfWai => 'WAI Illustrious — anime, nowszy od Pony';

  @override
  String templateChose(String workflow) {
    return 'Szablon wybrał: $workflow';
  }

  @override
  String get apiKeySaved => 'Zapisano klucz API';

  @override
  String get reposeScreenTitle => 'Repose — twarz w pozie';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Twarz';

  @override
  String get stepPose => '2. Poza';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATYWNY';

  @override
  String get reposePromptHint =>
      'zdjęcie kobiety, całe ciało, naturalne światło…';

  @override
  String couldNotLoadModels(String error) {
    return 'Nie udało się wczytać modeli: $error';
  }

  @override
  String get noModels =>
      'Brak modeli (sprawdź dane logowania CF w Ustawieniach).';

  @override
  String get uploadFace => 'Prześlij twarz';

  @override
  String get changeFace => 'Zmień twarz';

  @override
  String get pickFromGallery => 'Wybierz z galerii';

  @override
  String get takePhoto => 'Zrób zdjęcie';

  @override
  String get needCfCredentials =>
      'Ustaw dane logowania Cloudflare Access w Ustawieniach';

  @override
  String get baseImageSelected => 'Wybrano obraz bazowy';

  @override
  String get baseImageOptional => 'Obraz bazowy (opcjonalnie)';

  @override
  String get remove => 'Usuń';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model wybrany automatycznie na podstawie szablonu.\nMożesz go zmienić w Ustawieniach.';

  @override
  String get modelManualTooltip => 'Model wybrany ręcznie w Ustawieniach.';

  @override
  String get pickBlocks => 'Wybierz klocki, aby złożyć prompt...';
}
