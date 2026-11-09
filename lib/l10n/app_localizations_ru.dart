// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get screenBuilder => 'Конструктор промптов';

  @override
  String get screenRestyle => 'Сменить стиль фото';

  @override
  String get screenHair => 'Примерить причёску';

  @override
  String get screenAnimate => 'Оживить фото';

  @override
  String get settings => 'Настройки';

  @override
  String get shopTooltipVideo => 'Кредиты на анимацию и пакеты';

  @override
  String get shopTooltip => 'Кредиты и пакеты';

  @override
  String get switchCard => 'Сменить карточку';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count кредита на анимацию 🎉',
      many: 'Добавлено $count кредитов на анимацию 🎉',
      few: 'Добавлено $count кредита на анимацию 🎉',
      one: 'Добавлен $count кредит на анимацию 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count кредита 🎉',
      many: 'Добавлено $count кредитов 🎉',
      few: 'Добавлено $count кредита 🎉',
      one: 'Добавлен $count кредит 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Платёж не прошёл, попробуйте ещё раз';

  @override
  String errorDetail(String error) {
    return 'Ошибка: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Не удалось загрузить кредиты: $error';
  }

  @override
  String get tryAgain => 'Повторить';

  @override
  String get animationsTitle => 'Анимации';

  @override
  String get creditsTitle => 'Кредиты';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Бесплатных анимаций сегодня: $free из $limit · кредиты на анимацию: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Бесплатных генераций сегодня: $free из $limit · кредиты: $credits';
  }

  @override
  String get videoPriceNote => '1 кредит = 1 видео, оплата в Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 кредит = 1 изображение, оплата в Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кредита',
      many: '$count кредитов',
      few: '$count кредита',
      one: '$count кредит',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count анимации',
      many: '$count анимаций',
      few: '$count анимации',
      one: '$count анимация',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose недоступен в веб-версии';

  @override
  String get reposeTooltip => 'Repose (лицо в позе)';

  @override
  String get presets => 'Пресеты';

  @override
  String get template => 'Шаблон';

  @override
  String get backToTop => 'Наверх';

  @override
  String get generating => 'Генерация…';

  @override
  String get generate => 'Сгенерировать';

  @override
  String get needCredentials =>
      'Укажите API-ключ или учётные данные в настройках';

  @override
  String presetLoaded(String name) {
    return 'Пресет «$name» загружен';
  }

  @override
  String get connectionLostVideo =>
      'Соединение потеряно — бот всё равно доставит видео в ваш чат.';

  @override
  String videoServerDown(String error) {
    return 'Видеосервер сейчас недоступен.\n$error';
  }

  @override
  String get scene => 'Сцена';

  @override
  String get uploading => 'Загрузка…';

  @override
  String get animate => 'Оживить';

  @override
  String get pickPhoto => 'Выбрать фото';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'клип ~$seconds с · рендер ~$minutes мин';
  }

  @override
  String queuePosition(int position) {
    return 'В очереди · позиция $position';
  }

  @override
  String get queueWaiting => 'В очереди…';

  @override
  String get finishing => 'Завершение (сглаживание движения)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Такт $beat/$beats · осталось ~$minutes мин';
  }

  @override
  String get videoDone => 'Готово! Видео отправлено в ваш чат Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Не удалось: $error';
  }

  @override
  String get unknownError => 'неизвестная ошибка';

  @override
  String get starting => 'Запуск…';

  @override
  String get canCloseApp => 'Приложение можно закрыть — видео придёт в чат.';

  @override
  String get notCharged => 'Ваше бесплатное видео / кредит не потрачены.';

  @override
  String get animateAnother => 'Оживить ещё';

  @override
  String get restyleHint =>
      'Сохраняет ваше лицо и позу. Лучше всего работает с чётким фото одного человека анфас.';

  @override
  String get medium => 'Техника';

  @override
  String get mediumPhoto => 'Фото';

  @override
  String get mediumIllustration => 'Иллюстрация';

  @override
  String get style => 'Стиль';

  @override
  String get filterStyles => 'Фильтр стилей';

  @override
  String get restyling => 'Смена стиля…';

  @override
  String get restyle => 'Сменить стиль';

  @override
  String get restyleBusy =>
      'Смена стиля… около минуты.\nИзображение также придёт в ваш чат.';

  @override
  String get groupPopular => 'Популярные';

  @override
  String get groupPainters => 'Художники';

  @override
  String get groupAsia => 'Азия';

  @override
  String get groupEurope => 'Европа';

  @override
  String get groupAmericasOceania => 'Америка и Океания';

  @override
  String get groupAfricaNearEast => 'Африка и Ближний Восток';

  @override
  String get hairHint =>
      'Сохраняет ваше лицо и цвет волос, если вы не выберете новый. Лучше всего работает с портретом анфас, где волосы видны полностью, без головного убора.';

  @override
  String get noHairstyles => 'Причёсок пока нет — загляните позже.';

  @override
  String get colour => 'Цвет';

  @override
  String get keepMine => 'Оставить мой';

  @override
  String get haircut => 'Стрижка';

  @override
  String get keepMyCut => 'Оставить мою стрижку';

  @override
  String get working => 'Обработка…';

  @override
  String get newColour => 'Новый цвет';

  @override
  String get newHaircut => 'Новая стрижка';

  @override
  String get pickPortrait => 'Выбрать портрет';

  @override
  String get hairBusy =>
      'Обработка… около минуты.\nФото также придёт в ваш чат.';

  @override
  String get hairWomen => 'Женские';

  @override
  String get hairMen => 'Мужские';

  @override
  String get hairCuts => 'Стрижки';

  @override
  String get hairBangs => 'Чёлка';

  @override
  String get hairTexture => 'Текстура';

  @override
  String get hairShort => 'Короткие';

  @override
  String get hairMedium => 'Средние';

  @override
  String get hairLong => 'Длинные';

  @override
  String get hairBraids => 'Косы';

  @override
  String get hairUpdos => 'Причёски с собранными волосами';

  @override
  String get notDownloaded => 'Изображение ещё не загружено';

  @override
  String get savedToGallery => 'Сохранено в галерею';

  @override
  String couldNotSave(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get result => 'Результат';

  @override
  String get saveToGallery => 'Сохранить в галерею';

  @override
  String get copyPrompt => 'Копировать промпт';

  @override
  String get promptCopied => 'Промпт скопирован';

  @override
  String get imageNotAvailable => 'Изображение недоступно';

  @override
  String get promptUsed => 'Использованный промпт:';

  @override
  String get revisedPrompt => 'Переработанный промпт (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get generation => 'Генерация';

  @override
  String get generationWebInfo =>
      'Изображения генерирует бот Tsumiki (ComfyUI). Готовое изображение также отправляется в ваш чат с ботом.';

  @override
  String get workflow => 'Рабочий процесс';

  @override
  String get generationBackend => 'Бэкенд генерации';

  @override
  String get xaiInfo => 'API-ключ с console.x.ai для генерации через Grok.';

  @override
  String get apiKey => 'API-ключ';

  @override
  String get ol1nInfo =>
      'Локальный AiStack (API Flux diffusers). Введите сервисный токен CF Access или оставьте пустым, если он встроен в сборку (--dart-define).';

  @override
  String get comfyInfo =>
      'Локальный ComfyUI (выбор модели ниже). Использует общий токен CF Access с llm.ol1n.com.';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get wfAuto => 'Автоматически — по выбранному шаблону';

  @override
  String get wfFlux => 'Flux — живописные и фотореалистичные стили';

  @override
  String get wfPony => 'Pony Diffusion — аниме, теги Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — быстрый фотореализм';

  @override
  String get wfWai => 'WAI Illustrious — аниме, новее Pony';

  @override
  String templateChose(String workflow) {
    return 'Шаблон выбрал: $workflow';
  }

  @override
  String get apiKeySaved => 'API-ключ сохранён';

  @override
  String get reposeScreenTitle => 'Repose — лицо в позе';

  @override
  String get model => 'Модель';

  @override
  String get stepFace => '1. Лицо';

  @override
  String get stepPose => '2. Поза';

  @override
  String get stepPrompt => '3. Промпт';

  @override
  String get negative => 'НЕГАТИВ';

  @override
  String get reposePromptHint =>
      'фото женщины, в полный рост, естественный свет…';

  @override
  String couldNotLoadModels(String error) {
    return 'Не удалось загрузить модели: $error';
  }

  @override
  String get noModels =>
      'Нет моделей (проверьте учётные данные CF в настройках).';

  @override
  String get uploadFace => 'Загрузить лицо';

  @override
  String get changeFace => 'Сменить лицо';

  @override
  String get pickFromGallery => 'Выбрать из галереи';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get needCfCredentials =>
      'Укажите учётные данные Cloudflare Access в настройках';

  @override
  String get baseImageSelected => 'Базовое изображение выбрано';

  @override
  String get baseImageOptional => 'Базовое изображение (необязательно)';

  @override
  String get remove => 'Удалить';

  @override
  String get prompt => 'Промпт';

  @override
  String get modelAutoTooltip =>
      'Модель выбрана автоматически по шаблону.\nЕё можно изменить в настройках.';

  @override
  String get modelManualTooltip => 'Модель выбрана вручную в настройках.';

  @override
  String get pickBlocks => 'Выберите блоки, чтобы собрать промпт...';
}
