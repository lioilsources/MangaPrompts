// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get screenBuilder => 'പ്രോംപ്റ്റ് ബിൽഡർ';

  @override
  String get screenRestyle => 'ഫോട്ടോയുടെ ശൈലി മാറ്റൂ';

  @override
  String get screenHair => 'ഹെയർകട്ട് പരീക്ഷിക്കൂ';

  @override
  String get screenAnimate => 'ഫോട്ടോ ആനിമേറ്റ് ചെയ്യൂ';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get shopTooltipVideo => 'ആനിമേഷൻ ക്രെഡിറ്റുകളും പാക്കേജുകളും';

  @override
  String get shopTooltip => 'ക്രെഡിറ്റുകളും പാക്കേജുകളും';

  @override
  String get switchCard => 'കാർഡ് മാറ്റൂ';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ആനിമേഷൻ ക്രെഡിറ്റുകൾ ചേർത്തു 🎉',
      one: '1 ആനിമേഷൻ ക്രെഡിറ്റ് ചേർത്തു 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ക്രെഡിറ്റുകൾ ചേർത്തു 🎉',
      one: '1 ക്രെഡിറ്റ് ചേർത്തു 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'പേയ്‌മെന്റ് പരാജയപ്പെട്ടു, വീണ്ടും ശ്രമിക്കൂ';

  @override
  String errorDetail(String error) {
    return 'പിശക്: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'ക്രെഡിറ്റുകൾ ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കൂ';

  @override
  String get animationsTitle => 'ആനിമേഷനുകൾ';

  @override
  String get creditsTitle => 'ക്രെഡിറ്റുകൾ';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'ഇന്നത്തെ സൗജന്യ ആനിമേഷനുകൾ: $limit ൽ $free · ആനിമേഷൻ ക്രെഡിറ്റുകൾ: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'ഇന്നത്തെ സൗജന്യ ജനറേഷനുകൾ: $limit ൽ $free · ക്രെഡിറ്റുകൾ: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 ക്രെഡിറ്റ് = 1 വീഡിയോ, Telegram Stars-ൽ പണമടയ്ക്കണം.';

  @override
  String get imagePriceNote =>
      '1 ക്രെഡിറ്റ് = 1 ചിത്രം, Telegram Stars-ൽ പണമടയ്ക്കണം.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ക്രെഡിറ്റുകൾ',
      one: '1 ക്രെഡിറ്റ്',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ആനിമേഷനുകൾ',
      one: '1 ആനിമേഷൻ',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose വെബിൽ ലഭ്യമല്ല';

  @override
  String get reposeTooltip => 'Repose (പോസിലുള്ള മുഖം)';

  @override
  String get presets => 'പ്രീസെറ്റുകൾ';

  @override
  String get template => 'ടെംപ്ലേറ്റ്';

  @override
  String get backToTop => 'മുകളിലേക്ക് മടങ്ങൂ';

  @override
  String get generating => 'സൃഷ്ടിക്കുന്നു…';

  @override
  String get generate => 'സൃഷ്ടിക്കൂ';

  @override
  String get needCredentials =>
      'ക്രമീകരണങ്ങളിൽ API കീ അല്ലെങ്കിൽ ക്രെഡൻഷ്യലുകൾ സജ്ജമാക്കൂ';

  @override
  String presetLoaded(String name) {
    return 'പ്രീസെറ്റ് “$name” ലോഡ് ചെയ്തു';
  }

  @override
  String get connectionLostVideo =>
      'കണക്ഷൻ നഷ്ടപ്പെട്ടു — ബോട്ട് എന്നിട്ടും വീഡിയോ നിങ്ങളുടെ ചാറ്റിൽ എത്തിക്കും.';

  @override
  String videoServerDown(String error) {
    return 'വീഡിയോ സെർവർ ഇപ്പോൾ ലഭ്യമല്ല.\n$error';
  }

  @override
  String get scene => 'രംഗം';

  @override
  String get uploading => 'അപ്‌ലോഡ് ചെയ്യുന്നു…';

  @override
  String get animate => 'ആനിമേറ്റ് ചെയ്യൂ';

  @override
  String get pickPhoto => 'ഫോട്ടോ തിരഞ്ഞെടുക്കൂ';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds സെ ക്ലിപ്പ് · റെൻഡർ ~$minutes മിനിറ്റ്';
  }

  @override
  String queuePosition(int position) {
    return 'ക്യൂവിൽ · സ്ഥാനം $position';
  }

  @override
  String get queueWaiting => 'ക്യൂവിൽ…';

  @override
  String get finishing => 'പൂർത്തിയാക്കുന്നു (ചലനം മിനുസപ്പെടുത്തുന്നു)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'ബീറ്റ് $beat/$beats · ~$minutes മിനിറ്റ് ബാക്കി';
  }

  @override
  String get videoDone =>
      'കഴിഞ്ഞു! വീഡിയോ നിങ്ങളുടെ Telegram ചാറ്റിലേക്ക് അയച്ചു 🎬';

  @override
  String failedDetail(String error) {
    return 'പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get unknownError => 'അജ്ഞാത പിശക്';

  @override
  String get starting => 'തുടങ്ങുന്നു…';

  @override
  String get canCloseApp =>
      'നിങ്ങൾക്ക് ആപ്പ് അടയ്ക്കാം — വീഡിയോ ചാറ്റിൽ എത്തും.';

  @override
  String get notCharged =>
      'നിങ്ങളുടെ സൗജന്യ വീഡിയോ / ക്രെഡിറ്റ് ഉപയോഗിച്ചിട്ടില്ല.';

  @override
  String get animateAnother => 'മറ്റൊന്ന് ആനിമേറ്റ് ചെയ്യൂ';

  @override
  String get restyleHint =>
      'നിങ്ങളുടെ മുഖവും പോസും നിലനിർത്തുന്നു. ഒരാളുടെ വ്യക്തമായ, മുന്നിൽ നിന്നുള്ള ഫോട്ടോയിൽ ഏറ്റവും നന്നായി പ്രവർത്തിക്കും.';

  @override
  String get medium => 'മാധ്യമം';

  @override
  String get mediumPhoto => 'ഫോട്ടോ';

  @override
  String get mediumIllustration => 'ചിത്രീകരണം';

  @override
  String get style => 'ശൈലി';

  @override
  String get filterStyles => 'ശൈലികൾ ഫിൽട്ടർ ചെയ്യൂ';

  @override
  String get restyling => 'ശൈലി മാറ്റുന്നു…';

  @override
  String get restyle => 'ശൈലി മാറ്റൂ';

  @override
  String get restyleBusy =>
      'ശൈലി മാറ്റുന്നു… ഏകദേശം ഒരു മിനിറ്റ്.\nചിത്രം നിങ്ങളുടെ ചാറ്റിലും എത്തും.';

  @override
  String get groupPopular => 'ജനപ്രിയം';

  @override
  String get groupPainters => 'ചിത്രകാരന്മാർ';

  @override
  String get groupAsia => 'ഏഷ്യ';

  @override
  String get groupEurope => 'യൂറോപ്പ്';

  @override
  String get groupAmericasOceania => 'അമേരിക്കകളും ഓഷ്യാനിയയും';

  @override
  String get groupAfricaNearEast => 'ആഫ്രിക്കയും സമീപ പൗരസ്ത്യവും';

  @override
  String get hairHint =>
      'നിങ്ങളുടെ മുഖവും, പുതിയ നിറം തിരഞ്ഞെടുത്തില്ലെങ്കിൽ, മുടിയുടെ നിറവും നിലനിർത്തുന്നു. മുടി പൂർണ്ണമായി കാണുന്ന, തൊപ്പിയില്ലാത്ത മുൻവശത്തെ പോർട്രെയ്റ്റിൽ ഏറ്റവും നന്നായി പ്രവർത്തിക്കും.';

  @override
  String get noHairstyles => 'ഇതുവരെ ഹെയർസ്റ്റൈലുകളില്ല — ഉടൻ വീണ്ടും നോക്കൂ.';

  @override
  String get colour => 'നിറം';

  @override
  String get keepMine => 'എന്റേത് നിലനിർത്തൂ';

  @override
  String get haircut => 'ഹെയർകട്ട്';

  @override
  String get keepMyCut => 'എന്റെ കട്ട് നിലനിർത്തൂ';

  @override
  String get working => 'പ്രവർത്തിക്കുന്നു…';

  @override
  String get newColour => 'പുതിയ നിറം';

  @override
  String get newHaircut => 'പുതിയ ഹെയർകട്ട്';

  @override
  String get pickPortrait => 'പോർട്രെയ്റ്റ് തിരഞ്ഞെടുക്കൂ';

  @override
  String get hairBusy =>
      'പ്രവർത്തിക്കുന്നു… ഏകദേശം ഒരു മിനിറ്റ്.\nഫോട്ടോ നിങ്ങളുടെ ചാറ്റിലും എത്തും.';

  @override
  String get hairWomen => 'സ്ത്രീകൾ';

  @override
  String get hairMen => 'പുരുഷന്മാർ';

  @override
  String get hairCuts => 'കട്ടുകൾ';

  @override
  String get hairBangs => 'ബാങ്സ്';

  @override
  String get hairTexture => 'ഘടന';

  @override
  String get hairShort => 'ചെറുത്';

  @override
  String get hairMedium => 'ഇടത്തരം';

  @override
  String get hairLong => 'നീളമുള്ളത്';

  @override
  String get hairBraids => 'പിന്നലുകൾ';

  @override
  String get hairUpdos => 'അപ്‌ഡോകൾ';

  @override
  String get notDownloaded => 'ചിത്രം ഇതുവരെ ഡൗൺലോഡ് ചെയ്തിട്ടില്ല';

  @override
  String get savedToGallery => 'ഗാലറിയിൽ സേവ് ചെയ്തു';

  @override
  String couldNotSave(String error) {
    return 'സേവ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get result => 'ഫലം';

  @override
  String get saveToGallery => 'ഗാലറിയിൽ സേവ് ചെയ്യൂ';

  @override
  String get copyPrompt => 'പ്രോംപ്റ്റ് പകർത്തൂ';

  @override
  String get promptCopied => 'പ്രോംപ്റ്റ് പകർത്തി';

  @override
  String get imageNotAvailable => 'ചിത്രം ലഭ്യമല്ല';

  @override
  String get promptUsed => 'ഉപയോഗിച്ച പ്രോംപ്റ്റ്:';

  @override
  String get revisedPrompt => 'പരിഷ്കരിച്ച പ്രോംപ്റ്റ് (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get generation => 'ജനറേഷൻ';

  @override
  String get generationWebInfo =>
      'ചിത്രങ്ങൾ Tsumiki ബോട്ട് (ComfyUI) സൃഷ്ടിക്കുന്നു. പൂർത്തിയായ ചിത്രം ബോട്ടുമായുള്ള നിങ്ങളുടെ ചാറ്റിലേക്കും അയയ്ക്കും.';

  @override
  String get workflow => 'വർക്ക്ഫ്ലോ';

  @override
  String get generationBackend => 'ജനറേഷൻ ബാക്കെൻഡ്';

  @override
  String get xaiInfo => 'Grok വഴി സൃഷ്ടിക്കാൻ console.x.ai-ൽ നിന്നുള്ള API കീ.';

  @override
  String get apiKey => 'API കീ';

  @override
  String get ol1nInfo =>
      'ലോക്കൽ AiStack (Flux diffusers API). CF Access സർവീസ് ടോക്കൺ നൽകൂ, അല്ലെങ്കിൽ ബിൽഡിൽ ഉൾപ്പെടുത്തിയിട്ടുണ്ടെങ്കിൽ (--dart-define) ശൂന്യമാക്കൂ.';

  @override
  String get comfyInfo =>
      'ലോക്കൽ ComfyUI (മോഡൽ തിരഞ്ഞെടുപ്പ് താഴെ). CF Access ടോക്കൺ llm.ol1n.com-മായി പങ്കിടുന്നു.';

  @override
  String get save => 'സേവ് ചെയ്യൂ';

  @override
  String get saved => 'സേവ് ചെയ്തു';

  @override
  String get wfAuto => 'ഓട്ടോമാറ്റിക് — തിരഞ്ഞെടുത്ത ടെംപ്ലേറ്റ് പിന്തുടരൂ';

  @override
  String get wfFlux => 'Flux — ചിത്രകലാ, ഫോട്ടോറിയലിസ്റ്റിക് ശൈലികൾ';

  @override
  String get wfPony => 'Pony Diffusion — ആനിമേ, Danbooru ടാഗുകൾ';

  @override
  String get wfJuggernaut =>
      'Juggernaut XL Lightning — വേഗത്തിലുള്ള ഫോട്ടോറിയൽ';

  @override
  String get wfWai => 'WAI Illustrious — ആനിമേ, Pony-യെക്കാൾ പുതിയത്';

  @override
  String templateChose(String workflow) {
    return 'ടെംപ്ലേറ്റ് തിരഞ്ഞെടുത്തത്: $workflow';
  }

  @override
  String get apiKeySaved => 'API കീ സേവ് ചെയ്തു';

  @override
  String get reposeScreenTitle => 'Repose — പോസിലുള്ള മുഖം';

  @override
  String get model => 'മോഡൽ';

  @override
  String get stepFace => '1. മുഖം';

  @override
  String get stepPose => '2. പോസ്';

  @override
  String get stepPrompt => '3. പ്രോംപ്റ്റ്';

  @override
  String get negative => 'നെഗറ്റീവ്';

  @override
  String get reposePromptHint =>
      'ഒരു സ്ത്രീയുടെ ഫോട്ടോ, പൂർണ്ണശരീരം, സ്വാഭാവിക വെളിച്ചം…';

  @override
  String couldNotLoadModels(String error) {
    return 'മോഡലുകൾ ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get noModels =>
      'മോഡലുകളില്ല (ക്രമീകരണങ്ങളിൽ CF ക്രെഡൻഷ്യലുകൾ പരിശോധിക്കൂ).';

  @override
  String get uploadFace => 'മുഖം അപ്‌ലോഡ് ചെയ്യൂ';

  @override
  String get changeFace => 'മുഖം മാറ്റൂ';

  @override
  String get pickFromGallery => 'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കൂ';

  @override
  String get takePhoto => 'ഫോട്ടോ എടുക്കൂ';

  @override
  String get needCfCredentials =>
      'ക്രമീകരണങ്ങളിൽ Cloudflare Access ക്രെഡൻഷ്യലുകൾ സജ്ജമാക്കൂ';

  @override
  String get baseImageSelected => 'അടിസ്ഥാന ചിത്രം തിരഞ്ഞെടുത്തു';

  @override
  String get baseImageOptional => 'അടിസ്ഥാന ചിത്രം (ഓപ്ഷണൽ)';

  @override
  String get remove => 'നീക്കം ചെയ്യൂ';

  @override
  String get prompt => 'പ്രോംപ്റ്റ്';

  @override
  String get modelAutoTooltip =>
      'ടെംപ്ലേറ്റിൽ നിന്ന് മോഡൽ സ്വയമേവ തിരഞ്ഞെടുത്തു.\nക്രമീകരണങ്ങളിൽ മാറ്റാം.';

  @override
  String get modelManualTooltip => 'ക്രമീകരണങ്ങളിൽ കൈകൊണ്ട് തിരഞ്ഞെടുത്ത മോഡൽ.';

  @override
  String get pickBlocks => 'പ്രോംപ്റ്റ് ഉണ്ടാക്കാൻ ബ്ലോക്കുകൾ തിരഞ്ഞെടുക്കൂ...';
}
