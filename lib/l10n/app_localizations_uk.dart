// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get screenBuilder => 'Конструктор промптів';

  @override
  String get screenRestyle => 'Змінити стиль фото';

  @override
  String get screenHair => 'Приміряти зачіску';

  @override
  String get screenAnimate => 'Оживити фото';

  @override
  String get settings => 'Налаштування';

  @override
  String get shopTooltipVideo => 'Кредити на анімацію та пакети';

  @override
  String get shopTooltip => 'Кредити та пакети';

  @override
  String get switchCard => 'Змінити картку';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додано $count кредиту на анімацію 🎉',
      many: 'Додано $count кредитів на анімацію 🎉',
      few: 'Додано $count кредити на анімацію 🎉',
      one: 'Додано $count кредит на анімацію 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додано $count кредиту 🎉',
      many: 'Додано $count кредитів 🎉',
      few: 'Додано $count кредити 🎉',
      one: 'Додано $count кредит 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Платіж не пройшов, спробуйте ще раз';

  @override
  String errorDetail(String error) {
    return 'Помилка: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Не вдалося завантажити кредити: $error';
  }

  @override
  String get tryAgain => 'Повторити';

  @override
  String get animationsTitle => 'Анімації';

  @override
  String get creditsTitle => 'Кредити';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Безкоштовних анімацій сьогодні: $free із $limit · кредити на анімацію: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Безкоштовних генерацій сьогодні: $free із $limit · кредити: $credits';
  }

  @override
  String get videoPriceNote => '1 кредит = 1 відео, оплата в Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 кредит = 1 зображення, оплата в Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кредиту',
      many: '$count кредитів',
      few: '$count кредити',
      one: '$count кредит',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count анімації',
      many: '$count анімацій',
      few: '$count анімації',
      one: '$count анімація',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose недоступний у веб-версії';

  @override
  String get reposeTooltip => 'Repose (обличчя в позі)';

  @override
  String get presets => 'Пресети';

  @override
  String get template => 'Шаблон';

  @override
  String get backToTop => 'Нагору';

  @override
  String get generating => 'Генерація…';

  @override
  String get generate => 'Згенерувати';

  @override
  String get needCredentials =>
      'Вкажіть API-ключ або облікові дані в налаштуваннях';

  @override
  String presetLoaded(String name) {
    return 'Пресет «$name» завантажено';
  }

  @override
  String get connectionLostVideo =>
      'З’єднання втрачено — бот усе одно доставить відео у ваш чат.';

  @override
  String videoServerDown(String error) {
    return 'Відеосервер зараз недоступний.\n$error';
  }

  @override
  String get scene => 'Сцена';

  @override
  String get uploading => 'Завантаження…';

  @override
  String get animate => 'Оживити';

  @override
  String get pickPhoto => 'Вибрати фото';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'кліп ~$seconds с · рендер ~$minutes хв';
  }

  @override
  String queuePosition(int position) {
    return 'У черзі · позиція $position';
  }

  @override
  String get queueWaiting => 'У черзі…';

  @override
  String get finishing => 'Завершення (згладжування руху)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Такт $beat/$beats · залишилося ~$minutes хв';
  }

  @override
  String get videoDone => 'Готово! Відео надіслано у ваш чат Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Не вдалося: $error';
  }

  @override
  String get unknownError => 'невідома помилка';

  @override
  String get starting => 'Запуск…';

  @override
  String get canCloseApp => 'Застосунок можна закрити — відео прийде в чат.';

  @override
  String get notCharged => 'Ваше безкоштовне відео / кредит не витрачено.';

  @override
  String get animateAnother => 'Оживити ще';

  @override
  String get restyleHint =>
      'Зберігає ваше обличчя та позу. Найкраще працює з чітким фото однієї людини анфас.';

  @override
  String get medium => 'Техніка';

  @override
  String get mediumPhoto => 'Фото';

  @override
  String get mediumIllustration => 'Ілюстрація';

  @override
  String get style => 'Стиль';

  @override
  String get filterStyles => 'Фільтр стилів';

  @override
  String get restyling => 'Зміна стилю…';

  @override
  String get restyle => 'Змінити стиль';

  @override
  String get restyleBusy =>
      'Зміна стилю… близько хвилини.\nЗображення також прийде у ваш чат.';

  @override
  String get groupPopular => 'Популярні';

  @override
  String get groupPainters => 'Художники';

  @override
  String get groupAsia => 'Азія';

  @override
  String get groupEurope => 'Європа';

  @override
  String get groupAmericasOceania => 'Америка й Океанія';

  @override
  String get groupAfricaNearEast => 'Африка й Близький Схід';

  @override
  String get hairHint =>
      'Зберігає ваше обличчя й колір волосся, якщо ви не виберете новий. Найкраще працює з портретом анфас, де волосся видно повністю, без головного убору.';

  @override
  String get noHairstyles => 'Зачісок поки немає — зазирніть згодом.';

  @override
  String get colour => 'Колір';

  @override
  String get keepMine => 'Залишити мій';

  @override
  String get haircut => 'Стрижка';

  @override
  String get keepMyCut => 'Залишити мою стрижку';

  @override
  String get working => 'Обробка…';

  @override
  String get newColour => 'Новий колір';

  @override
  String get newHaircut => 'Нова стрижка';

  @override
  String get pickPortrait => 'Вибрати портрет';

  @override
  String get hairBusy =>
      'Обробка… близько хвилини.\nФото також прийде у ваш чат.';

  @override
  String get hairWomen => 'Жіночі';

  @override
  String get hairMen => 'Чоловічі';

  @override
  String get hairCuts => 'Стрижки';

  @override
  String get hairBangs => 'Чубчик';

  @override
  String get hairTexture => 'Текстура';

  @override
  String get hairShort => 'Короткі';

  @override
  String get hairMedium => 'Середні';

  @override
  String get hairLong => 'Довгі';

  @override
  String get hairBraids => 'Коси';

  @override
  String get hairUpdos => 'Зачіски зі зібраним волоссям';

  @override
  String get notDownloaded => 'Зображення ще не завантажено';

  @override
  String get savedToGallery => 'Збережено в галерею';

  @override
  String couldNotSave(String error) {
    return 'Не вдалося зберегти: $error';
  }

  @override
  String get result => 'Результат';

  @override
  String get saveToGallery => 'Зберегти в галерею';

  @override
  String get copyPrompt => 'Копіювати промпт';

  @override
  String get promptCopied => 'Промпт скопійовано';

  @override
  String get imageNotAvailable => 'Зображення недоступне';

  @override
  String get promptUsed => 'Використаний промпт:';

  @override
  String get revisedPrompt => 'Перероблений промпт (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Не вдалося завантажити: $error';
  }

  @override
  String get generation => 'Генерація';

  @override
  String get generationWebInfo =>
      'Зображення генерує бот Tsumiki (ComfyUI). Готове зображення також надсилається у ваш чат із ботом.';

  @override
  String get workflow => 'Робочий процес';

  @override
  String get generationBackend => 'Бекенд генерації';

  @override
  String get xaiInfo => 'API-ключ із console.x.ai для генерації через Grok.';

  @override
  String get apiKey => 'API-ключ';

  @override
  String get ol1nInfo =>
      'Локальний AiStack (API Flux diffusers). Введіть сервісний токен CF Access або залиште порожнім, якщо він вбудований у збірку (--dart-define).';

  @override
  String get comfyInfo =>
      'Локальний ComfyUI (вибір моделі нижче). Використовує спільний токен CF Access з llm.ol1n.com.';

  @override
  String get save => 'Зберегти';

  @override
  String get saved => 'Збережено';

  @override
  String get wfAuto => 'Автоматично — за вибраним шаблоном';

  @override
  String get wfFlux => 'Flux — живописні та фотореалістичні стилі';

  @override
  String get wfPony => 'Pony Diffusion — аніме, теги Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — швидкий фотореалізм';

  @override
  String get wfWai => 'WAI Illustrious — аніме, новіший за Pony';

  @override
  String templateChose(String workflow) {
    return 'Шаблон вибрав: $workflow';
  }

  @override
  String get apiKeySaved => 'API-ключ збережено';

  @override
  String get reposeScreenTitle => 'Repose — обличчя в позі';

  @override
  String get model => 'Модель';

  @override
  String get stepFace => '1. Обличчя';

  @override
  String get stepPose => '2. Поза';

  @override
  String get stepPrompt => '3. Промпт';

  @override
  String get negative => 'НЕГАТИВ';

  @override
  String get reposePromptHint =>
      'фото жінки, на повний зріст, природне світло…';

  @override
  String couldNotLoadModels(String error) {
    return 'Не вдалося завантажити моделі: $error';
  }

  @override
  String get noModels =>
      'Немає моделей (перевірте облікові дані CF у налаштуваннях).';

  @override
  String get uploadFace => 'Завантажити обличчя';

  @override
  String get changeFace => 'Змінити обличчя';

  @override
  String get pickFromGallery => 'Вибрати з галереї';

  @override
  String get takePhoto => 'Зробити фото';

  @override
  String get needCfCredentials =>
      'Вкажіть облікові дані Cloudflare Access у налаштуваннях';

  @override
  String get baseImageSelected => 'Базове зображення вибрано';

  @override
  String get baseImageOptional => 'Базове зображення (необов’язково)';

  @override
  String get remove => 'Видалити';

  @override
  String get prompt => 'Промпт';

  @override
  String get modelAutoTooltip =>
      'Модель вибрано автоматично за шаблоном.\nЇї можна змінити в налаштуваннях.';

  @override
  String get modelManualTooltip => 'Модель вибрано вручну в налаштуваннях.';

  @override
  String get pickBlocks => 'Виберіть блоки, щоб скласти промпт...';
}
