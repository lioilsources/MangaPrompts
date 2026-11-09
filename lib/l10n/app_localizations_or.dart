// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get screenBuilder => 'ପ୍ରମ୍ପ୍ଟ ବିଲ୍ଡର୍';

  @override
  String get screenRestyle => 'ଫଟୋର ଶୈଳୀ ବଦଳାନ୍ତୁ';

  @override
  String get screenHair => 'ହେୟାରକଟ୍ ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get screenAnimate => 'ଫଟୋକୁ ଆନିମେଟ୍ କରନ୍ତୁ';

  @override
  String get settings => 'ସେଟିଂସ୍';

  @override
  String get shopTooltipVideo => 'ଆନିମେସନ୍ କ୍ରେଡିଟ୍ ଓ ପ୍ୟାକେଜ୍';

  @override
  String get shopTooltip => 'କ୍ରେଡିଟ୍ ଓ ପ୍ୟାକେଜ୍';

  @override
  String get switchCard => 'କାର୍ଡ ବଦଳାନ୍ତୁ';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି ଆନିମେସନ୍ କ୍ରେଡିଟ୍ ଯୋଡ଼ାଗଲା 🎉',
      one: '1 ଆନିମେସନ୍ କ୍ରେଡିଟ୍ ଯୋଡ଼ାଗଲା 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି କ୍ରେଡିଟ୍ ଯୋଡ଼ାଗଲା 🎉',
      one: '1 କ୍ରେଡିଟ୍ ଯୋଡ଼ାଗଲା 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ଦେୟ ବିଫଳ ହେଲା, ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String errorDetail(String error) {
    return 'ତ୍ରୁଟି: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'କ୍ରେଡିଟ୍ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ: $error';
  }

  @override
  String get tryAgain => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get animationsTitle => 'ଆନିମେସନ୍';

  @override
  String get creditsTitle => 'କ୍ରେଡିଟ୍';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'ଆଜିର ମାଗଣା ଆନିମେସନ୍: $limit ମଧ୍ୟରୁ $free · ଆନିମେସନ୍ କ୍ରେଡିଟ୍: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'ଆଜିର ମାଗଣା ଜେନେରେସନ୍: $limit ମଧ୍ୟରୁ $free · କ୍ରେଡିଟ୍: $credits';
  }

  @override
  String get videoPriceNote => '1 କ୍ରେଡିଟ୍ = 1 ଭିଡିଓ, Telegram Stars ରେ ଦେୟ।';

  @override
  String get imagePriceNote => '1 କ୍ରେଡିଟ୍ = 1 ଛବି, Telegram Stars ରେ ଦେୟ।';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count କ୍ରେଡିଟ୍',
      one: '1 କ୍ରେଡିଟ୍',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ଆନିମେସନ୍',
      one: '1 ଆନିମେସନ୍',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'ୱେବ୍‌ରେ Repose ଉପଲବ୍ଧ ନୁହେଁ';

  @override
  String get reposeTooltip => 'Repose (ଭଙ୍ଗୀରେ ମୁହଁ)';

  @override
  String get presets => 'ପ୍ରିସେଟ୍';

  @override
  String get template => 'ଟେମ୍ପଲେଟ୍';

  @override
  String get backToTop => 'ଉପରକୁ ଫେରନ୍ତୁ';

  @override
  String get generating => 'ତିଆରି ହେଉଛି…';

  @override
  String get generate => 'ତିଆରି କରନ୍ତୁ';

  @override
  String get needCredentials => 'ସେଟିଂସ୍‌ରେ API କୀ କିମ୍ବା ପରିଚୟପତ୍ର ଦିଅନ୍ତୁ';

  @override
  String presetLoaded(String name) {
    return 'ପ୍ରିସେଟ୍ “$name” ଲୋଡ୍ ହେଲା';
  }

  @override
  String get connectionLostVideo =>
      'ସଂଯୋଗ ବିଚ୍ଛିନ୍ନ — ବଟ୍ ତଥାପି ଭିଡିଓ ଆପଣଙ୍କ ଚାଟ୍‌କୁ ପଠାଇବ।';

  @override
  String videoServerDown(String error) {
    return 'ଭିଡିଓ ସର୍ଭର୍ ଏବେ ଉପଲବ୍ଧ ନାହିଁ।\n$error';
  }

  @override
  String get scene => 'ଦୃଶ୍ୟ';

  @override
  String get uploading => 'ଅପଲୋଡ୍ ହେଉଛି…';

  @override
  String get animate => 'ଆନିମେଟ୍ କରନ୍ତୁ';

  @override
  String get pickPhoto => 'ଫଟୋ ବାଛନ୍ତୁ';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds ସେ କ୍ଲିପ୍ · ରେଣ୍ଡର୍ ~$minutes ମିନିଟ୍';
  }

  @override
  String queuePosition(int position) {
    return 'ଧାଡ଼ିରେ · ସ୍ଥାନ $position';
  }

  @override
  String get queueWaiting => 'ଧାଡ଼ିରେ…';

  @override
  String get finishing => 'ଶେଷ ହେଉଛି (ଗତି ମସୃଣ କରାଯାଉଛି)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'ବିଟ୍ $beat/$beats · ~$minutes ମିନିଟ୍ ବାକି';
  }

  @override
  String get videoDone => 'ହୋଇଗଲା! ଭିଡିଓ ଆପଣଙ୍କ Telegram ଚାଟ୍‌କୁ ପଠାଯାଇଛି 🎬';

  @override
  String failedDetail(String error) {
    return 'ବିଫଳ: $error';
  }

  @override
  String get unknownError => 'ଅଜଣା ତ୍ରୁଟି';

  @override
  String get starting => 'ଆରମ୍ଭ ହେଉଛି…';

  @override
  String get canCloseApp => 'ଆପଣ ଆପ୍ ବନ୍ଦ କରିପାରିବେ — ଭିଡିଓ ଚାଟ୍‌ରେ ଆସିବ।';

  @override
  String get notCharged => 'ଆପଣଙ୍କ ମାଗଣା ଭିଡିଓ / କ୍ରେଡିଟ୍ ଖର୍ଚ୍ଚ ହୋଇନାହିଁ।';

  @override
  String get animateAnother => 'ଆଉ ଗୋଟିଏ ଆନିମେଟ୍ କରନ୍ତୁ';

  @override
  String get restyleHint =>
      'ଆପଣଙ୍କ ମୁହଁ ଓ ଭଙ୍ଗୀ ରଖେ। ଜଣକର ସ୍ପଷ୍ଟ, ସାମନାରୁ ଉଠାଯାଇଥିବା ଫଟୋରେ ସବୁଠାରୁ ଭଲ କାମ କରେ।';

  @override
  String get medium => 'ମାଧ୍ୟମ';

  @override
  String get mediumPhoto => 'ଫଟୋ';

  @override
  String get mediumIllustration => 'ଚିତ୍ରଣ';

  @override
  String get style => 'ଶୈଳୀ';

  @override
  String get filterStyles => 'ଶୈଳୀ ଫିଲ୍ଟର୍ କରନ୍ତୁ';

  @override
  String get restyling => 'ଶୈଳୀ ବଦଳୁଛି…';

  @override
  String get restyle => 'ଶୈଳୀ ବଦଳାନ୍ତୁ';

  @override
  String get restyleBusy =>
      'ଶୈଳୀ ବଦଳୁଛି… ପ୍ରାୟ ଏକ ମିନିଟ୍।\nଛବି ଆପଣଙ୍କ ଚାଟ୍‌କୁ ମଧ୍ୟ ଆସିବ।';

  @override
  String get groupPopular => 'ଲୋକପ୍ରିୟ';

  @override
  String get groupPainters => 'ଚିତ୍ରକାର';

  @override
  String get groupAsia => 'ଏସିଆ';

  @override
  String get groupEurope => 'ୟୁରୋପ';

  @override
  String get groupAmericasOceania => 'ଆମେରିକା ଓ ଓସେନିଆ';

  @override
  String get groupAfricaNearEast => 'ଆଫ୍ରିକା ଓ ନିକଟ ପୂର୍ବ';

  @override
  String get hairHint =>
      'ଆପଣଙ୍କ ମୁହଁ ଏବଂ, ନୂଆ ରଙ୍ଗ ନବାଛିଲେ, କେଶର ରଙ୍ଗ ରଖେ। ପୂରା କେଶ ଦେଖାଯାଉଥିବା, ଟୋପି ନଥିବା ସାମନାର ପୋର୍ଟ୍ରେଟ୍ ସହ ସବୁଠାରୁ ଭଲ କାମ କରେ।';

  @override
  String get noHairstyles =>
      'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ହେୟାରଷ୍ଟାଇଲ୍ ନାହିଁ — ଶୀଘ୍ର ପୁଣି ଦେଖନ୍ତୁ।';

  @override
  String get colour => 'ରଙ୍ଗ';

  @override
  String get keepMine => 'ମୋର ରଖନ୍ତୁ';

  @override
  String get haircut => 'ହେୟାରକଟ୍';

  @override
  String get keepMyCut => 'ମୋ କଟ୍ ରଖନ୍ତୁ';

  @override
  String get working => 'କାମ ଚାଲିଛି…';

  @override
  String get newColour => 'ନୂଆ ରଙ୍ଗ';

  @override
  String get newHaircut => 'ନୂଆ ହେୟାରକଟ୍';

  @override
  String get pickPortrait => 'ପୋର୍ଟ୍ରେଟ୍ ବାଛନ୍ତୁ';

  @override
  String get hairBusy =>
      'କାମ ଚାଲିଛି… ପ୍ରାୟ ଏକ ମିନିଟ୍।\nଫଟୋ ଆପଣଙ୍କ ଚାଟ୍‌କୁ ମଧ୍ୟ ଆସିବ।';

  @override
  String get hairWomen => 'ମହିଳା';

  @override
  String get hairMen => 'ପୁରୁଷ';

  @override
  String get hairCuts => 'କଟ୍';

  @override
  String get hairBangs => 'ବ୍ୟାଙ୍ଗ୍ସ';

  @override
  String get hairTexture => 'ବୁଣା';

  @override
  String get hairShort => 'ଛୋଟ';

  @override
  String get hairMedium => 'ମଝିରା';

  @override
  String get hairLong => 'ଲମ୍ବା';

  @override
  String get hairBraids => 'ବେଣୀ';

  @override
  String get hairUpdos => 'ଅପଡୁ';

  @override
  String get notDownloaded => 'ଛବି ଏପର୍ଯ୍ୟନ୍ତ ଡାଉନଲୋଡ୍ ହୋଇନାହିଁ';

  @override
  String get savedToGallery => 'ଗ୍ୟାଲେରୀରେ ସେଭ୍ ହେଲା';

  @override
  String couldNotSave(String error) {
    return 'ସେଭ୍ କରିହେଲା ନାହିଁ: $error';
  }

  @override
  String get result => 'ଫଳାଫଳ';

  @override
  String get saveToGallery => 'ଗ୍ୟାଲେରୀରେ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get copyPrompt => 'ପ୍ରମ୍ପ୍ଟ କପି କରନ୍ତୁ';

  @override
  String get promptCopied => 'ପ୍ରମ୍ପ୍ଟ କପି ହେଲା';

  @override
  String get imageNotAvailable => 'ଛବି ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get promptUsed => 'ବ୍ୟବହୃତ ପ୍ରମ୍ପ୍ଟ:';

  @override
  String get revisedPrompt => 'ସଂଶୋଧିତ ପ୍ରମ୍ପ୍ଟ (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'ଲୋଡ୍ କରିହେଲା ନାହିଁ: $error';
  }

  @override
  String get generation => 'ଜେନେରେସନ୍';

  @override
  String get generationWebInfo =>
      'ଛବି Tsumiki ବଟ୍ (ComfyUI) ତିଆରି କରେ। ପ୍ରସ୍ତୁତ ଛବି ବଟ୍ ସହ ଆପଣଙ୍କ ଚାଟ୍‌କୁ ମଧ୍ୟ ପଠାଯାଏ।';

  @override
  String get workflow => 'ୱାର୍କଫ୍ଲୋ';

  @override
  String get generationBackend => 'ଜେନେରେସନ୍ ବ୍ୟାକଏଣ୍ଡ୍';

  @override
  String get xaiInfo => 'Grok ଦ୍ୱାରା ତିଆରି ପାଇଁ console.x.ai ର API କୀ।';

  @override
  String get apiKey => 'API କୀ';

  @override
  String get ol1nInfo =>
      'ସ୍ଥାନୀୟ AiStack (Flux diffusers API)। CF Access ସର୍ଭିସ୍ ଟୋକେନ୍ ଦିଅନ୍ତୁ, କିମ୍ବା ବିଲ୍ଡରେ ଭିତରେ ଥିଲେ (--dart-define) ଖାଲି ଛାଡ଼ନ୍ତୁ।';

  @override
  String get comfyInfo =>
      'ସ୍ଥାନୀୟ ComfyUI (ମଡେଲ୍ ବାଛିବା ତଳେ)। CF Access ଟୋକେନ୍ llm.ol1n.com ସହ ଅଂଶୀଦାର ହୁଏ।';

  @override
  String get save => 'ସେଭ୍ କରନ୍ତୁ';

  @override
  String get saved => 'ସେଭ୍ ହେଲା';

  @override
  String get wfAuto => 'ସ୍ୱୟଂଚାଳିତ — ବାଛିଥିବା ଟେମ୍ପଲେଟ୍ ଅନୁସରଣ';

  @override
  String get wfFlux => 'Flux — ଚିତ୍ରକଳା ଓ ଫଟୋରିଆଲିଷ୍ଟିକ୍ ଶୈଳୀ';

  @override
  String get wfPony => 'Pony Diffusion — ଆନିମେ, Danbooru ଟ୍ୟାଗ୍';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — ଦ୍ରୁତ ଫଟୋରିଆଲ୍';

  @override
  String get wfWai => 'WAI Illustrious — ଆନିମେ, Pony ଠାରୁ ନୂଆ';

  @override
  String templateChose(String workflow) {
    return 'ଟେମ୍ପଲେଟ୍ ବାଛିଲା: $workflow';
  }

  @override
  String get apiKeySaved => 'API କୀ ସେଭ୍ ହେଲା';

  @override
  String get reposeScreenTitle => 'Repose — ଭଙ୍ଗୀରେ ମୁହଁ';

  @override
  String get model => 'ମଡେଲ୍';

  @override
  String get stepFace => '1. ମୁହଁ';

  @override
  String get stepPose => '2. ଭଙ୍ଗୀ';

  @override
  String get stepPrompt => '3. ପ୍ରମ୍ପ୍ଟ';

  @override
  String get negative => 'ନେଗେଟିଭ୍';

  @override
  String get reposePromptHint => 'ଜଣେ ମହିଳାଙ୍କ ଫଟୋ, ପୂରା ଶରୀର, ପ୍ରାକୃତିକ ଆଲୋକ…';

  @override
  String couldNotLoadModels(String error) {
    return 'ମଡେଲ୍ ଲୋଡ୍ କରିହେଲା ନାହିଁ: $error';
  }

  @override
  String get noModels =>
      'କୌଣସି ମଡେଲ୍ ନାହିଁ (ସେଟିଂସ୍‌ରେ CF ପରିଚୟପତ୍ର ଯାଞ୍ଚ କରନ୍ତୁ)।';

  @override
  String get uploadFace => 'ମୁହଁ ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get changeFace => 'ମୁହଁ ବଦଳାନ୍ତୁ';

  @override
  String get pickFromGallery => 'ଗ୍ୟାଲେରୀରୁ ବାଛନ୍ତୁ';

  @override
  String get takePhoto => 'ଫଟୋ ଉଠାନ୍ତୁ';

  @override
  String get needCfCredentials =>
      'ସେଟିଂସ୍‌ରେ Cloudflare Access ପରିଚୟପତ୍ର ଦିଅନ୍ତୁ';

  @override
  String get baseImageSelected => 'ମୂଳ ଛବି ବଛାଗଲା';

  @override
  String get baseImageOptional => 'ମୂଳ ଛବି (ବୈକଳ୍ପିକ)';

  @override
  String get remove => 'ହଟାନ୍ତୁ';

  @override
  String get prompt => 'ପ୍ରମ୍ପ୍ଟ';

  @override
  String get modelAutoTooltip =>
      'ଟେମ୍ପଲେଟ୍ ଅନୁସାରେ ମଡେଲ୍ ସ୍ୱୟଂଚାଳିତ ବଛାଯାଇଛି।\nସେଟିଂସ୍‌ରେ ବଦଳାଇପାରିବେ।';

  @override
  String get modelManualTooltip => 'ସେଟିଂସ୍‌ରେ ହାତରେ ବଛାଯାଇଥିବା ମଡେଲ୍।';

  @override
  String get pickBlocks => 'ପ୍ରମ୍ପ୍ଟ ଗଢ଼ିବାକୁ ବ୍ଲକ୍ ବାଛନ୍ତୁ...';
}
