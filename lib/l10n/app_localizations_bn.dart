// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get screenBuilder => 'প্রম্পট বিল্ডার';

  @override
  String get screenRestyle => 'ছবির স্টাইল বদলান';

  @override
  String get screenHair => 'চুলের কাট চেষ্টা করুন';

  @override
  String get screenAnimate => 'ছবি অ্যানিমেট করুন';

  @override
  String get settings => 'সেটিংস';

  @override
  String get shopTooltipVideo => 'অ্যানিমেশন ক্রেডিট ও প্যাকেজ';

  @override
  String get shopTooltip => 'ক্রেডিট ও প্যাকেজ';

  @override
  String get switchCard => 'কার্ড বদলান';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অ্যানিমেশন ক্রেডিট যোগ হয়েছে 🎉',
      one: '১টি অ্যানিমেশন ক্রেডিট যোগ হয়েছে 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ক্রেডিট যোগ হয়েছে 🎉',
      one: '১টি ক্রেডিট যোগ হয়েছে 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'পেমেন্ট ব্যর্থ হয়েছে, আবার চেষ্টা করুন';

  @override
  String errorDetail(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'ক্রেডিট লোড করা যায়নি: $error';
  }

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get animationsTitle => 'অ্যানিমেশন';

  @override
  String get creditsTitle => 'ক্রেডিট';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'আজকের বিনামূল্যে অ্যানিমেশন: $limit-এর মধ্যে $free · অ্যানিমেশন ক্রেডিট: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'আজকের বিনামূল্যে জেনারেশন: $limit-এর মধ্যে $free · ক্রেডিট: $credits';
  }

  @override
  String get videoPriceNote =>
      '১ ক্রেডিট = ১টি ভিডিও, Telegram Stars-এ পরিশোধ।';

  @override
  String get imagePriceNote => '১ ক্রেডিট = ১টি ছবি, Telegram Stars-এ পরিশোধ।';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ক্রেডিট',
      one: '১ ক্রেডিট',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অ্যানিমেশন',
      one: '১টি অ্যানিমেশন',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'ওয়েবে Repose পাওয়া যায় না';

  @override
  String get reposeTooltip => 'Repose (ভঙ্গিতে মুখ)';

  @override
  String get presets => 'প্রিসেট';

  @override
  String get template => 'টেমপ্লেট';

  @override
  String get backToTop => 'উপরে ফিরুন';

  @override
  String get generating => 'তৈরি হচ্ছে…';

  @override
  String get generate => 'তৈরি করুন';

  @override
  String get needCredentials => 'সেটিংসে API কী বা শংসাপত্র দিন';

  @override
  String presetLoaded(String name) {
    return 'প্রিসেট “$name” লোড হয়েছে';
  }

  @override
  String get connectionLostVideo =>
      'সংযোগ বিচ্ছিন্ন — বট তবুও ভিডিওটি আপনার চ্যাটে পৌঁছে দেবে।';

  @override
  String videoServerDown(String error) {
    return 'ভিডিও সার্ভার এই মুহূর্তে পাওয়া যাচ্ছে না।\n$error';
  }

  @override
  String get scene => 'দৃশ্য';

  @override
  String get uploading => 'আপলোড হচ্ছে…';

  @override
  String get animate => 'অ্যানিমেট করুন';

  @override
  String get pickPhoto => 'ছবি বাছুন';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds সেকেন্ডের ক্লিপ · রেন্ডার ~$minutes মিনিট';
  }

  @override
  String queuePosition(int position) {
    return 'সারিতে · অবস্থান $position';
  }

  @override
  String get queueWaiting => 'সারিতে…';

  @override
  String get finishing => 'শেষ হচ্ছে (গতি মসৃণ করা হচ্ছে)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'বিট $beat/$beats · ~$minutes মিনিট বাকি';
  }

  @override
  String get videoDone =>
      'হয়ে গেছে! ভিডিও আপনার Telegram চ্যাটে পাঠানো হয়েছে 🎬';

  @override
  String failedDetail(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get unknownError => 'অজানা ত্রুটি';

  @override
  String get starting => 'শুরু হচ্ছে…';

  @override
  String get canCloseApp => 'আপনি অ্যাপ বন্ধ করতে পারেন — ভিডিও চ্যাটে আসবে।';

  @override
  String get notCharged => 'আপনার বিনামূল্যে ভিডিও / ক্রেডিট খরচ হয়নি।';

  @override
  String get animateAnother => 'আরেকটি অ্যানিমেট করুন';

  @override
  String get restyleHint =>
      'আপনার মুখ ও ভঙ্গি ঠিক রাখে। একজনের পরিষ্কার, সামনে থেকে তোলা ছবিতে সবচেয়ে ভালো কাজ করে।';

  @override
  String get medium => 'মাধ্যম';

  @override
  String get mediumPhoto => 'ছবি';

  @override
  String get mediumIllustration => 'চিত্রাঙ্কন';

  @override
  String get style => 'স্টাইল';

  @override
  String get filterStyles => 'স্টাইল ফিল্টার করুন';

  @override
  String get restyling => 'স্টাইল বদলানো হচ্ছে…';

  @override
  String get restyle => 'স্টাইল বদলান';

  @override
  String get restyleBusy =>
      'স্টাইল বদলানো হচ্ছে… প্রায় এক মিনিট।\nছবিটি আপনার চ্যাটেও আসবে।';

  @override
  String get groupPopular => 'জনপ্রিয়';

  @override
  String get groupPainters => 'চিত্রশিল্পী';

  @override
  String get groupAsia => 'এশিয়া';

  @override
  String get groupEurope => 'ইউরোপ';

  @override
  String get groupAmericasOceania => 'আমেরিকা ও ওশেনিয়া';

  @override
  String get groupAfricaNearEast => 'আফ্রিকা ও নিকট প্রাচ্য';

  @override
  String get hairHint =>
      'আপনার মুখ এবং, নতুন রং না বাছলে, চুলের রং ঠিক রাখে। পুরো চুল দেখা যায় এমন, টুপি ছাড়া সামনে থেকে তোলা পোর্ট্রেটে সবচেয়ে ভালো কাজ করে।';

  @override
  String get noHairstyles => 'এখনও কোনো হেয়ারস্টাইল নেই — শিগগির আবার দেখুন।';

  @override
  String get colour => 'রং';

  @override
  String get keepMine => 'আমারটা রাখুন';

  @override
  String get haircut => 'চুলের কাট';

  @override
  String get keepMyCut => 'আমার কাট রাখুন';

  @override
  String get working => 'কাজ চলছে…';

  @override
  String get newColour => 'নতুন রং';

  @override
  String get newHaircut => 'নতুন কাট';

  @override
  String get pickPortrait => 'পোর্ট্রেট বাছুন';

  @override
  String get hairBusy =>
      'কাজ চলছে… প্রায় এক মিনিট।\nছবিটি আপনার চ্যাটেও আসবে।';

  @override
  String get hairWomen => 'নারী';

  @override
  String get hairMen => 'পুরুষ';

  @override
  String get hairCuts => 'কাট';

  @override
  String get hairBangs => 'ফ্রিঞ্জ';

  @override
  String get hairTexture => 'টেক্সচার';

  @override
  String get hairShort => 'ছোট';

  @override
  String get hairMedium => 'মাঝারি';

  @override
  String get hairLong => 'লম্বা';

  @override
  String get hairBraids => 'বেণি';

  @override
  String get hairUpdos => 'খোঁপা';

  @override
  String get notDownloaded => 'ছবিটি এখনও ডাউনলোড হয়নি';

  @override
  String get savedToGallery => 'গ্যালারিতে সংরক্ষিত হয়েছে';

  @override
  String couldNotSave(String error) {
    return 'সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get result => 'ফলাফল';

  @override
  String get saveToGallery => 'গ্যালারিতে সংরক্ষণ করুন';

  @override
  String get copyPrompt => 'প্রম্পট কপি করুন';

  @override
  String get promptCopied => 'প্রম্পট কপি হয়েছে';

  @override
  String get imageNotAvailable => 'ছবি পাওয়া যাচ্ছে না';

  @override
  String get promptUsed => 'ব্যবহৃত প্রম্পট:';

  @override
  String get revisedPrompt => 'সংশোধিত প্রম্পট (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'লোড করা যায়নি: $error';
  }

  @override
  String get generation => 'জেনারেশন';

  @override
  String get generationWebInfo =>
      'ছবি তৈরি করে Tsumiki বট (ComfyUI)। তৈরি ছবি বটের সঙ্গে আপনার চ্যাটেও পাঠানো হয়।';

  @override
  String get workflow => 'ওয়ার্কফ্লো';

  @override
  String get generationBackend => 'জেনারেশন ব্যাকএন্ড';

  @override
  String get xaiInfo => 'Grok দিয়ে তৈরির জন্য console.x.ai থেকে API কী।';

  @override
  String get apiKey => 'API কী';

  @override
  String get ol1nInfo =>
      'লোকাল AiStack (Flux diffusers API)। CF Access সার্ভিস টোকেন দিন, অথবা বিল্ডে বসানো থাকলে (--dart-define) ফাঁকা রাখুন।';

  @override
  String get comfyInfo =>
      'লোকাল ComfyUI (মডেল নিচে বাছুন)। CF Access টোকেন llm.ol1n.com-এর সঙ্গে ভাগ করা।';

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get saved => 'সংরক্ষিত';

  @override
  String get wfAuto => 'স্বয়ংক্রিয় — বাছাই করা টেমপ্লেট অনুসরণ';

  @override
  String get wfFlux => 'Flux — চিত্রশিল্পসম ও ফটোরিয়ালিস্টিক স্টাইল';

  @override
  String get wfPony => 'Pony Diffusion — অ্যানিমে, Danbooru ট্যাগ';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — দ্রুত ফটোরিয়াল';

  @override
  String get wfWai => 'WAI Illustrious — অ্যানিমে, Pony-র চেয়ে নতুন';

  @override
  String templateChose(String workflow) {
    return 'টেমপ্লেট বেছেছে: $workflow';
  }

  @override
  String get apiKeySaved => 'API কী সংরক্ষিত হয়েছে';

  @override
  String get reposeScreenTitle => 'Repose — ভঙ্গিতে মুখ';

  @override
  String get model => 'মডেল';

  @override
  String get stepFace => '১. মুখ';

  @override
  String get stepPose => '২. ভঙ্গি';

  @override
  String get stepPrompt => '৩. প্রম্পট';

  @override
  String get negative => 'নেগেটিভ';

  @override
  String get reposePromptHint => 'একজন নারীর ছবি, পূর্ণদৈর্ঘ্য, প্রাকৃতিক আলো…';

  @override
  String couldNotLoadModels(String error) {
    return 'মডেল লোড করা যায়নি: $error';
  }

  @override
  String get noModels => 'কোনো মডেল নেই (সেটিংসে CF শংসাপত্র দেখুন)।';

  @override
  String get uploadFace => 'মুখ আপলোড করুন';

  @override
  String get changeFace => 'মুখ বদলান';

  @override
  String get pickFromGallery => 'গ্যালারি থেকে বাছুন';

  @override
  String get takePhoto => 'ছবি তুলুন';

  @override
  String get needCfCredentials => 'সেটিংসে Cloudflare Access শংসাপত্র দিন';

  @override
  String get baseImageSelected => 'ভিত্তি ছবি বাছা হয়েছে';

  @override
  String get baseImageOptional => 'ভিত্তি ছবি (ঐচ্ছিক)';

  @override
  String get remove => 'সরান';

  @override
  String get prompt => 'প্রম্পট';

  @override
  String get modelAutoTooltip =>
      'টেমপ্লেট থেকে মডেল স্বয়ংক্রিয়ভাবে বাছা হয়েছে।\nসেটিংসে বদলাতে পারেন।';

  @override
  String get modelManualTooltip => 'সেটিংসে হাতে বাছা মডেল।';

  @override
  String get pickBlocks => 'প্রম্পট বানাতে ব্লক বাছুন...';
}
