// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get screenBuilder => 'Constructor de prompts';

  @override
  String get screenRestyle => 'Restilizar una foto';

  @override
  String get screenHair => 'Probar un corte de pelo';

  @override
  String get screenAnimate => 'Animar una foto';

  @override
  String get settings => 'Ajustes';

  @override
  String get shopTooltipVideo => 'Créditos de animación y paquetes';

  @override
  String get shopTooltip => 'Créditos y paquetes';

  @override
  String get switchCard => 'Cambiar de tarjeta';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos de animación añadidos 🎉',
      one: '1 crédito de animación añadido 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos añadidos 🎉',
      one: '1 crédito añadido 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'El pago falló, inténtalo de nuevo';

  @override
  String errorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'No se pudieron cargar los créditos: $error';
  }

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get animationsTitle => 'Animaciones';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animaciones gratis hoy: $free de $limit · créditos de animación: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Generaciones gratis hoy: $free de $limit · créditos: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 crédito = 1 vídeo, pagado con Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 crédito = 1 imagen, pagado con Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos',
      one: '1 crédito',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animaciones',
      one: '1 animación',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose no está disponible en la web';

  @override
  String get reposeTooltip => 'Repose (rostro en una pose)';

  @override
  String get presets => 'Ajustes preestablecidos';

  @override
  String get template => 'Plantilla';

  @override
  String get backToTop => 'Volver arriba';

  @override
  String get generating => 'Generando…';

  @override
  String get generate => 'Generar';

  @override
  String get needCredentials =>
      'Configura una clave de API o credenciales en Ajustes';

  @override
  String presetLoaded(String name) {
    return 'Ajuste «$name» cargado';
  }

  @override
  String get connectionLostVideo =>
      'Conexión perdida: el bot entregará el vídeo en tu chat igualmente.';

  @override
  String videoServerDown(String error) {
    return 'El servidor de vídeo no está disponible ahora.\n$error';
  }

  @override
  String get scene => 'Escena';

  @override
  String get uploading => 'Subiendo…';

  @override
  String get animate => 'Animar';

  @override
  String get pickPhoto => 'Elegir una foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip de ~$seconds s · ~$minutes min de renderizado';
  }

  @override
  String queuePosition(int position) {
    return 'En cola · posición $position';
  }

  @override
  String get queueWaiting => 'En cola…';

  @override
  String get finishing => 'Terminando (suavizando el movimiento)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Tiempo $beat/$beats · quedan ~$minutes min';
  }

  @override
  String get videoDone => '¡Listo! El vídeo se envió a tu chat de Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Falló: $error';
  }

  @override
  String get unknownError => 'error desconocido';

  @override
  String get starting => 'Iniciando…';

  @override
  String get canCloseApp => 'Puedes cerrar la app: el vídeo llegará al chat.';

  @override
  String get notCharged => 'No se gastó tu vídeo gratis ni tu crédito.';

  @override
  String get animateAnother => 'Animar otra';

  @override
  String get restyleHint =>
      'Conserva tu rostro y tu pose. Funciona mejor con una foto nítida y de frente de una sola persona.';

  @override
  String get medium => 'Medio';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Ilustración';

  @override
  String get style => 'Estilo';

  @override
  String get filterStyles => 'Filtrar estilos';

  @override
  String get restyling => 'Restilizando…';

  @override
  String get restyle => 'Restilizar';

  @override
  String get restyleBusy =>
      'Restilizando… aproximadamente un minuto.\nLa imagen también llega a tu chat.';

  @override
  String get groupPopular => 'Populares';

  @override
  String get groupPainters => 'Pintores';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'América y Oceanía';

  @override
  String get groupAfricaNearEast => 'África y Oriente Próximo';

  @override
  String get hairHint =>
      'Conserva tu rostro y tu color de pelo, salvo que elijas uno nuevo. Funciona mejor con un retrato de frente, con el pelo totalmente visible y sin gorra.';

  @override
  String get noHairstyles => 'Aún no hay peinados: vuelve pronto.';

  @override
  String get colour => 'Color';

  @override
  String get keepMine => 'Conservar el mío';

  @override
  String get haircut => 'Corte';

  @override
  String get keepMyCut => 'Conservar mi corte';

  @override
  String get working => 'Trabajando…';

  @override
  String get newColour => 'Color nuevo';

  @override
  String get newHaircut => 'Corte nuevo';

  @override
  String get pickPortrait => 'Elegir un retrato';

  @override
  String get hairBusy =>
      'Trabajando… aproximadamente un minuto.\nLa foto también llega a tu chat.';

  @override
  String get hairWomen => 'Mujer';

  @override
  String get hairMen => 'Hombre';

  @override
  String get hairCuts => 'Cortes';

  @override
  String get hairBangs => 'Flequillo';

  @override
  String get hairTexture => 'Textura';

  @override
  String get hairShort => 'Corto';

  @override
  String get hairMedium => 'Medio';

  @override
  String get hairLong => 'Largo';

  @override
  String get hairBraids => 'Trenzas';

  @override
  String get hairUpdos => 'Recogidos';

  @override
  String get notDownloaded => 'La imagen aún no se ha descargado';

  @override
  String get savedToGallery => 'Guardado en la galería';

  @override
  String couldNotSave(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get result => 'Resultado';

  @override
  String get saveToGallery => 'Guardar en la galería';

  @override
  String get copyPrompt => 'Copiar prompt';

  @override
  String get promptCopied => 'Prompt copiado';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String get promptUsed => 'Prompt usado:';

  @override
  String get revisedPrompt => 'Prompt revisado (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'No se pudo cargar: $error';
  }

  @override
  String get generation => 'Generación';

  @override
  String get generationWebInfo =>
      'Las imágenes las genera el bot de Tsumiki (ComfyUI). La imagen terminada también se envía a tu chat con el bot.';

  @override
  String get workflow => 'Flujo de trabajo';

  @override
  String get generationBackend => 'Backend de generación';

  @override
  String get xaiInfo => 'Clave de API de console.x.ai para generar con Grok.';

  @override
  String get apiKey => 'Clave de API';

  @override
  String get ol1nInfo =>
      'AiStack local (API Flux diffusers). Introduce un token de servicio de CF Access, o déjalo vacío si va incluido en la compilación (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI local (elección de modelo abajo). Comparte el token de CF Access con llm.ol1n.com.';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get wfAuto => 'Automático: según la plantilla elegida';

  @override
  String get wfFlux => 'Flux: estilos pictóricos y fotorrealistas';

  @override
  String get wfPony => 'Pony Diffusion: anime, etiquetas Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning: fotorrealismo rápido';

  @override
  String get wfWai => 'WAI Illustrious: anime, más reciente que Pony';

  @override
  String templateChose(String workflow) {
    return 'La plantilla eligió: $workflow';
  }

  @override
  String get apiKeySaved => 'Clave de API guardada';

  @override
  String get reposeScreenTitle => 'Repose: rostro en una pose';

  @override
  String get model => 'Modelo';

  @override
  String get stepFace => '1. Rostro';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIVO';

  @override
  String get reposePromptHint =>
      'foto de una mujer, cuerpo entero, luz natural…';

  @override
  String couldNotLoadModels(String error) {
    return 'No se pudieron cargar los modelos: $error';
  }

  @override
  String get noModels =>
      'Sin modelos (comprueba las credenciales de CF en Ajustes).';

  @override
  String get uploadFace => 'Subir un rostro';

  @override
  String get changeFace => 'Cambiar rostro';

  @override
  String get pickFromGallery => 'Elegir de la galería';

  @override
  String get takePhoto => 'Hacer una foto';

  @override
  String get needCfCredentials =>
      'Configura las credenciales de Cloudflare Access en Ajustes';

  @override
  String get baseImageSelected => 'Imagen base seleccionada';

  @override
  String get baseImageOptional => 'Imagen base (opcional)';

  @override
  String get remove => 'Quitar';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modelo elegido automáticamente según la plantilla.\nPuedes cambiarlo en Ajustes.';

  @override
  String get modelManualTooltip => 'Modelo elegido manualmente en Ajustes.';

  @override
  String get pickBlocks => 'Elige bloques para montar un prompt...';
}
