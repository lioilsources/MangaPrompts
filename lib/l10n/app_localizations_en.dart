// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get screenBuilder => 'Prompt builder';

  @override
  String get screenRestyle => 'Restyle a photo';

  @override
  String get screenHair => 'Try a haircut';

  @override
  String get screenAnimate => 'Animate a photo';

  @override
  String get settings => 'Settings';

  @override
  String get shopTooltipVideo => 'Animation credits and packages';

  @override
  String get shopTooltip => 'Credits and packages';

  @override
  String get switchCard => 'Switch card';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animation credits added 🎉',
      one: '1 animation credit added 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits added 🎉',
      one: '1 credit added 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Payment failed, please try again';

  @override
  String errorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Could not load credits: $error';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get animationsTitle => 'Animations';

  @override
  String get creditsTitle => 'Credits';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Free animations today: $free of $limit · animation credits: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Free generations today: $free of $limit · credits: $credits';
  }

  @override
  String get videoPriceNote => '1 credit = 1 video, paid in Telegram Stars.';

  @override
  String get imagePriceNote => '1 credit = 1 image, paid in Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
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
  String get reposeWebUnavailable => 'Repose is not available on the web';

  @override
  String get reposeTooltip => 'Repose (face in a pose)';

  @override
  String get presets => 'Presets';

  @override
  String get template => 'Template';

  @override
  String get backToTop => 'Back to top';

  @override
  String get generating => 'Generating…';

  @override
  String get generate => 'Generate';

  @override
  String get needCredentials => 'Set an API key or credentials in Settings';

  @override
  String presetLoaded(String name) {
    return 'Preset \"$name\" loaded';
  }

  @override
  String get connectionLostVideo =>
      'Connection lost — the bot will still deliver the video to your chat.';

  @override
  String videoServerDown(String error) {
    return 'The video server is unavailable right now.\n$error';
  }

  @override
  String get scene => 'Scene';

  @override
  String get uploading => 'Uploading…';

  @override
  String get animate => 'Animate';

  @override
  String get pickPhoto => 'Pick a photo';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds s clip · ~$minutes min render';
  }

  @override
  String queuePosition(int position) {
    return 'In line · position $position';
  }

  @override
  String get queueWaiting => 'In line…';

  @override
  String get finishing => 'Finishing (smoothing the motion)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Beat $beat/$beats · ~$minutes min left';
  }

  @override
  String get videoDone => 'Done! The video was sent to your Telegram chat 🎬';

  @override
  String failedDetail(String error) {
    return 'Failed: $error';
  }

  @override
  String get unknownError => 'unknown error';

  @override
  String get starting => 'Starting…';

  @override
  String get canCloseApp =>
      'You can close the app — the video arrives in the chat.';

  @override
  String get notCharged => 'Your free video / credit was not spent.';

  @override
  String get animateAnother => 'Animate another';

  @override
  String get restyleHint =>
      'Keeps your face and pose. Works best with a clear, front-facing photo of one person.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Photo';

  @override
  String get mediumIllustration => 'Illustration';

  @override
  String get style => 'Style';

  @override
  String get filterStyles => 'Filter styles';

  @override
  String get restyling => 'Restyling…';

  @override
  String get restyle => 'Restyle';

  @override
  String get restyleBusy =>
      'Restyling… about a minute.\nThe image also arrives in your chat.';

  @override
  String get groupPopular => 'Popular';

  @override
  String get groupPainters => 'Painters';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Europe';

  @override
  String get groupAmericasOceania => 'Americas & Oceania';

  @override
  String get groupAfricaNearEast => 'Africa & Near East';

  @override
  String get hairHint =>
      'Keeps your face, and your hair colour unless you pick a new one. Works best with a front-facing portrait, hair fully visible, no hat.';

  @override
  String get noHairstyles => 'No hairstyles yet — check back soon.';

  @override
  String get colour => 'Colour';

  @override
  String get keepMine => 'Keep mine';

  @override
  String get haircut => 'Haircut';

  @override
  String get keepMyCut => 'Keep my cut';

  @override
  String get working => 'Working…';

  @override
  String get newColour => 'New colour';

  @override
  String get newHaircut => 'New haircut';

  @override
  String get pickPortrait => 'Pick a portrait';

  @override
  String get hairBusy =>
      'Working… about a minute.\nThe photo also arrives in your chat.';

  @override
  String get hairWomen => 'Women';

  @override
  String get hairMen => 'Men';

  @override
  String get hairCuts => 'Cuts';

  @override
  String get hairBangs => 'Bangs';

  @override
  String get hairTexture => 'Texture';

  @override
  String get hairShort => 'Short';

  @override
  String get hairMedium => 'Medium';

  @override
  String get hairLong => 'Long';

  @override
  String get hairBraids => 'Braids';

  @override
  String get hairUpdos => 'Updos';

  @override
  String get notDownloaded => 'The image has not been downloaded yet';

  @override
  String get savedToGallery => 'Saved to the gallery';

  @override
  String couldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get result => 'Result';

  @override
  String get saveToGallery => 'Save to gallery';

  @override
  String get copyPrompt => 'Copy prompt';

  @override
  String get promptCopied => 'Prompt copied';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get promptUsed => 'Prompt used:';

  @override
  String get revisedPrompt => 'Revised prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Could not load: $error';
  }

  @override
  String get generation => 'Generation';

  @override
  String get generationWebInfo =>
      'Images are generated by the Tsumiki bot (ComfyUI). The finished image is also sent to your chat with the bot.';

  @override
  String get workflow => 'Workflow';

  @override
  String get generationBackend => 'Generation backend';

  @override
  String get xaiInfo =>
      'API key from console.x.ai for generating through Grok.';

  @override
  String get apiKey => 'API key';

  @override
  String get ol1nInfo =>
      'Local AiStack (Flux diffusers API). Enter a CF Access service token, or leave empty if it is baked in at build time (--dart-define).';

  @override
  String get comfyInfo =>
      'Local ComfyUI (model selection below). Shares the CF Access token with llm.ol1n.com.';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get wfAuto => 'Automatic — follow the chosen template';

  @override
  String get wfFlux => 'Flux — painterly and photorealistic styles';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru tags';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — fast photoreal';

  @override
  String get wfWai => 'WAI Illustrious — anime, newer than Pony';

  @override
  String templateChose(String workflow) {
    return 'Template chose: $workflow';
  }

  @override
  String get apiKeySaved => 'API key saved';

  @override
  String get reposeScreenTitle => 'Repose — face in a pose';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Face';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIVE';

  @override
  String get reposePromptHint => 'photo of a woman, full body, natural light…';

  @override
  String couldNotLoadModels(String error) {
    return 'Could not load models: $error';
  }

  @override
  String get noModels => 'No models (check the CF credentials in Settings).';

  @override
  String get uploadFace => 'Upload a face';

  @override
  String get changeFace => 'Change face';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get needCfCredentials =>
      'Set the Cloudflare Access credentials in Settings';

  @override
  String get baseImageSelected => 'Base image selected';

  @override
  String get baseImageOptional => 'Base image (optional)';

  @override
  String get remove => 'Remove';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model chosen automatically from the template.\nYou can change it in Settings.';

  @override
  String get modelManualTooltip => 'Model chosen manually in Settings.';

  @override
  String get pickBlocks => 'Pick blocks to assemble a prompt...';
}
