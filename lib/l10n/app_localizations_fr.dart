// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get screenBuilder => 'Constructeur de prompts';

  @override
  String get screenRestyle => 'Restyler une photo';

  @override
  String get screenHair => 'Essayer une coupe';

  @override
  String get screenAnimate => 'Animer une photo';

  @override
  String get settings => 'Réglages';

  @override
  String get shopTooltipVideo => 'Crédits d’animation et forfaits';

  @override
  String get shopTooltip => 'Crédits et forfaits';

  @override
  String get switchCard => 'Changer de carte';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crédits d’animation ajoutés 🎉',
      one: '1 crédit d’animation ajouté 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crédits ajoutés 🎉',
      one: '1 crédit ajouté 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Le paiement a échoué, réessaie';

  @override
  String errorDetail(String error) {
    return 'Erreur : $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Impossible de charger les crédits : $error';
  }

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get animationsTitle => 'Animations';

  @override
  String get creditsTitle => 'Crédits';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animations gratuites aujourd’hui : $free sur $limit · crédits d’animation : $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Générations gratuites aujourd’hui : $free sur $limit · crédits : $credits';
  }

  @override
  String get videoPriceNote => '1 crédit = 1 vidéo, payé en Telegram Stars.';

  @override
  String get imagePriceNote => '1 crédit = 1 image, payé en Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crédits',
      one: '1 crédit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animations',
      one: '1 animation',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose n’est pas disponible sur le web';

  @override
  String get reposeTooltip => 'Repose (visage dans une pose)';

  @override
  String get presets => 'Préréglages';

  @override
  String get template => 'Modèle';

  @override
  String get backToTop => 'Retour en haut';

  @override
  String get generating => 'Génération…';

  @override
  String get generate => 'Générer';

  @override
  String get needCredentials =>
      'Définis une clé API ou des identifiants dans les réglages';

  @override
  String presetLoaded(String name) {
    return 'Préréglage « $name » chargé';
  }

  @override
  String get connectionLostVideo =>
      'Connexion perdue — le bot livrera quand même la vidéo dans ton chat.';

  @override
  String videoServerDown(String error) {
    return 'Le serveur vidéo est indisponible pour le moment.\n$error';
  }

  @override
  String get scene => 'Scène';

  @override
  String get uploading => 'Envoi…';

  @override
  String get animate => 'Animer';

  @override
  String get pickPhoto => 'Choisir une photo';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip d’env. $seconds s · env. $minutes min de rendu';
  }

  @override
  String queuePosition(int position) {
    return 'En file d’attente · position $position';
  }

  @override
  String get queueWaiting => 'En file d’attente…';

  @override
  String get finishing => 'Finalisation (lissage du mouvement)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Temps $beat/$beats · encore ~$minutes min';
  }

  @override
  String get videoDone =>
      'Terminé ! La vidéo a été envoyée dans ton chat Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Échec : $error';
  }

  @override
  String get unknownError => 'erreur inconnue';

  @override
  String get starting => 'Démarrage…';

  @override
  String get canCloseApp =>
      'Tu peux fermer l’app — la vidéo arrive dans le chat.';

  @override
  String get notCharged =>
      'Ta vidéo gratuite / ton crédit n’a pas été utilisé.';

  @override
  String get animateAnother => 'Animer une autre';

  @override
  String get restyleHint =>
      'Garde ton visage et ta pose. Fonctionne mieux avec une photo nette de face d’une seule personne.';

  @override
  String get medium => 'Support';

  @override
  String get mediumPhoto => 'Photo';

  @override
  String get mediumIllustration => 'Illustration';

  @override
  String get style => 'Style';

  @override
  String get filterStyles => 'Filtrer les styles';

  @override
  String get restyling => 'Restylage…';

  @override
  String get restyle => 'Restyler';

  @override
  String get restyleBusy =>
      'Restylage… environ une minute.\nL’image arrive aussi dans ton chat.';

  @override
  String get groupPopular => 'Populaires';

  @override
  String get groupPainters => 'Peintres';

  @override
  String get groupAsia => 'Asie';

  @override
  String get groupEurope => 'Europe';

  @override
  String get groupAmericasOceania => 'Amériques et Océanie';

  @override
  String get groupAfricaNearEast => 'Afrique et Proche-Orient';

  @override
  String get hairHint =>
      'Garde ton visage, et ta couleur de cheveux sauf si tu en choisis une nouvelle. Fonctionne mieux avec un portrait de face, cheveux entièrement visibles, sans chapeau.';

  @override
  String get noHairstyles => 'Pas encore de coiffures — reviens bientôt.';

  @override
  String get colour => 'Couleur';

  @override
  String get keepMine => 'Garder la mienne';

  @override
  String get haircut => 'Coupe';

  @override
  String get keepMyCut => 'Garder ma coupe';

  @override
  String get working => 'En cours…';

  @override
  String get newColour => 'Nouvelle couleur';

  @override
  String get newHaircut => 'Nouvelle coupe';

  @override
  String get pickPortrait => 'Choisir un portrait';

  @override
  String get hairBusy =>
      'En cours… environ une minute.\nLa photo arrive aussi dans ton chat.';

  @override
  String get hairWomen => 'Femmes';

  @override
  String get hairMen => 'Hommes';

  @override
  String get hairCuts => 'Coupes';

  @override
  String get hairBangs => 'Frange';

  @override
  String get hairTexture => 'Texture';

  @override
  String get hairShort => 'Courts';

  @override
  String get hairMedium => 'Mi-longs';

  @override
  String get hairLong => 'Longs';

  @override
  String get hairBraids => 'Tresses';

  @override
  String get hairUpdos => 'Chignons';

  @override
  String get notDownloaded => 'L’image n’a pas encore été téléchargée';

  @override
  String get savedToGallery => 'Enregistré dans la galerie';

  @override
  String couldNotSave(String error) {
    return 'Impossible d’enregistrer : $error';
  }

  @override
  String get result => 'Résultat';

  @override
  String get saveToGallery => 'Enregistrer dans la galerie';

  @override
  String get copyPrompt => 'Copier le prompt';

  @override
  String get promptCopied => 'Prompt copié';

  @override
  String get imageNotAvailable => 'Image indisponible';

  @override
  String get promptUsed => 'Prompt utilisé :';

  @override
  String get revisedPrompt => 'Prompt révisé (Grok) :';

  @override
  String couldNotLoad(String error) {
    return 'Impossible de charger : $error';
  }

  @override
  String get generation => 'Génération';

  @override
  String get generationWebInfo =>
      'Les images sont générées par le bot Tsumiki (ComfyUI). L’image terminée est aussi envoyée dans ton chat avec le bot.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Backend de génération';

  @override
  String get xaiInfo => 'Clé API de console.x.ai pour générer via Grok.';

  @override
  String get apiKey => 'Clé API';

  @override
  String get ol1nInfo =>
      'AiStack local (API Flux diffusers). Saisis un jeton de service CF Access, ou laisse vide s’il est intégré au build (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI local (choix du modèle ci-dessous). Partage le jeton CF Access avec llm.ol1n.com.';

  @override
  String get save => 'Enregistrer';

  @override
  String get saved => 'Enregistré';

  @override
  String get wfAuto => 'Automatique — suivre le modèle choisi';

  @override
  String get wfFlux => 'Flux — styles picturaux et photoréalistes';

  @override
  String get wfPony => 'Pony Diffusion — anime, tags Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — photoréalisme rapide';

  @override
  String get wfWai => 'WAI Illustrious — anime, plus récent que Pony';

  @override
  String templateChose(String workflow) {
    return 'Le modèle a choisi : $workflow';
  }

  @override
  String get apiKeySaved => 'Clé API enregistrée';

  @override
  String get reposeScreenTitle => 'Repose — visage dans une pose';

  @override
  String get model => 'Modèle';

  @override
  String get stepFace => '1. Visage';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NÉGATIF';

  @override
  String get reposePromptHint =>
      'photo d’une femme, en pied, lumière naturelle…';

  @override
  String couldNotLoadModels(String error) {
    return 'Impossible de charger les modèles : $error';
  }

  @override
  String get noModels =>
      'Aucun modèle (vérifie les identifiants CF dans les réglages).';

  @override
  String get uploadFace => 'Importer un visage';

  @override
  String get changeFace => 'Changer de visage';

  @override
  String get pickFromGallery => 'Choisir dans la galerie';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get needCfCredentials =>
      'Définis les identifiants Cloudflare Access dans les réglages';

  @override
  String get baseImageSelected => 'Image de base sélectionnée';

  @override
  String get baseImageOptional => 'Image de base (facultatif)';

  @override
  String get remove => 'Retirer';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modèle choisi automatiquement d’après le modèle de prompt.\nTu peux le changer dans les réglages.';

  @override
  String get modelManualTooltip =>
      'Modèle choisi manuellement dans les réglages.';

  @override
  String get pickBlocks => 'Choisis des blocs pour assembler un prompt...';
}
