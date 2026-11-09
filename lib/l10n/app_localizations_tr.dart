// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get screenBuilder => 'Prompt oluşturucu';

  @override
  String get screenRestyle => 'Fotoğrafın stilini değiştir';

  @override
  String get screenHair => 'Saç modeli dene';

  @override
  String get screenAnimate => 'Fotoğrafı canlandır';

  @override
  String get settings => 'Ayarlar';

  @override
  String get shopTooltipVideo => 'Animasyon kredileri ve paketler';

  @override
  String get shopTooltip => 'Krediler ve paketler';

  @override
  String get switchCard => 'Kartı değiştir';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animasyon kredisi eklendi 🎉',
      one: '1 animasyon kredisi eklendi 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredi eklendi 🎉',
      one: '1 kredi eklendi 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Ödeme başarısız, lütfen tekrar dene';

  @override
  String errorDetail(String error) {
    return 'Hata: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Krediler yüklenemedi: $error';
  }

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get animationsTitle => 'Animasyonlar';

  @override
  String get creditsTitle => 'Krediler';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Bugünkü ücretsiz animasyonlar: $free / $limit · animasyon kredileri: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Bugünkü ücretsiz üretimler: $free / $limit · krediler: $credits';
  }

  @override
  String get videoPriceNote => '1 kredi = 1 video, Telegram Stars ile ödenir.';

  @override
  String get imagePriceNote => '1 kredi = 1 görsel, Telegram Stars ile ödenir.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredi',
      one: '1 kredi',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animasyon',
      one: '1 animasyon',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose web’de kullanılamıyor';

  @override
  String get reposeTooltip => 'Repose (poz verilmiş yüz)';

  @override
  String get presets => 'Hazır ayarlar';

  @override
  String get template => 'Şablon';

  @override
  String get backToTop => 'Başa dön';

  @override
  String get generating => 'Üretiliyor…';

  @override
  String get generate => 'Üret';

  @override
  String get needCredentials =>
      'Ayarlar’da bir API anahtarı veya kimlik bilgileri belirle';

  @override
  String presetLoaded(String name) {
    return '“$name” hazır ayarı yüklendi';
  }

  @override
  String get connectionLostVideo =>
      'Bağlantı koptu — bot videoyu yine de sohbetine iletecek.';

  @override
  String videoServerDown(String error) {
    return 'Video sunucusu şu anda kullanılamıyor.\n$error';
  }

  @override
  String get scene => 'Sahne';

  @override
  String get uploading => 'Yükleniyor…';

  @override
  String get animate => 'Canlandır';

  @override
  String get pickPhoto => 'Fotoğraf seç';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds sn’lik klip · ~$minutes dk işleme';
  }

  @override
  String queuePosition(int position) {
    return 'Sırada · sıra $position';
  }

  @override
  String get queueWaiting => 'Sırada…';

  @override
  String get finishing => 'Tamamlanıyor (hareket yumuşatılıyor)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Vuruş $beat/$beats · ~$minutes dk kaldı';
  }

  @override
  String get videoDone => 'Bitti! Video Telegram sohbetine gönderildi 🎬';

  @override
  String failedDetail(String error) {
    return 'Başarısız: $error';
  }

  @override
  String get unknownError => 'bilinmeyen hata';

  @override
  String get starting => 'Başlıyor…';

  @override
  String get canCloseApp =>
      'Uygulamayı kapatabilirsin — video sohbete gelecek.';

  @override
  String get notCharged => 'Ücretsiz videon / kredin harcanmadı.';

  @override
  String get animateAnother => 'Bir tane daha canlandır';

  @override
  String get restyleHint =>
      'Yüzünü ve pozunu korur. Tek kişilik net, önden çekilmiş bir fotoğrafla en iyi sonucu verir.';

  @override
  String get medium => 'Ortam';

  @override
  String get mediumPhoto => 'Fotoğraf';

  @override
  String get mediumIllustration => 'İllüstrasyon';

  @override
  String get style => 'Stil';

  @override
  String get filterStyles => 'Stilleri filtrele';

  @override
  String get restyling => 'Stil değiştiriliyor…';

  @override
  String get restyle => 'Stili değiştir';

  @override
  String get restyleBusy =>
      'Stil değiştiriliyor… yaklaşık bir dakika.\nGörsel sohbetine de gelecek.';

  @override
  String get groupPopular => 'Popüler';

  @override
  String get groupPainters => 'Ressamlar';

  @override
  String get groupAsia => 'Asya';

  @override
  String get groupEurope => 'Avrupa';

  @override
  String get groupAmericasOceania => 'Amerika ve Okyanusya';

  @override
  String get groupAfricaNearEast => 'Afrika ve Yakın Doğu';

  @override
  String get hairHint =>
      'Yüzünü ve yeni bir tane seçmezsen saç rengini korur. Saçın tamamen göründüğü, şapkasız, önden çekilmiş bir portreyle en iyi sonucu verir.';

  @override
  String get noHairstyles => 'Henüz saç modeli yok — yakında tekrar bak.';

  @override
  String get colour => 'Renk';

  @override
  String get keepMine => 'Benimkini koru';

  @override
  String get haircut => 'Saç kesimi';

  @override
  String get keepMyCut => 'Kesimimi koru';

  @override
  String get working => 'Çalışıyor…';

  @override
  String get newColour => 'Yeni renk';

  @override
  String get newHaircut => 'Yeni saç kesimi';

  @override
  String get pickPortrait => 'Portre seç';

  @override
  String get hairBusy =>
      'Çalışıyor… yaklaşık bir dakika.\nFotoğraf sohbetine de gelecek.';

  @override
  String get hairWomen => 'Kadın';

  @override
  String get hairMen => 'Erkek';

  @override
  String get hairCuts => 'Kesimler';

  @override
  String get hairBangs => 'Kâkül';

  @override
  String get hairTexture => 'Doku';

  @override
  String get hairShort => 'Kısa';

  @override
  String get hairMedium => 'Orta';

  @override
  String get hairLong => 'Uzun';

  @override
  String get hairBraids => 'Örgüler';

  @override
  String get hairUpdos => 'Topuzlar';

  @override
  String get notDownloaded => 'Görsel henüz indirilmedi';

  @override
  String get savedToGallery => 'Galeriye kaydedildi';

  @override
  String couldNotSave(String error) {
    return 'Kaydedilemedi: $error';
  }

  @override
  String get result => 'Sonuç';

  @override
  String get saveToGallery => 'Galeriye kaydet';

  @override
  String get copyPrompt => 'Prompt’u kopyala';

  @override
  String get promptCopied => 'Prompt kopyalandı';

  @override
  String get imageNotAvailable => 'Görsel kullanılamıyor';

  @override
  String get promptUsed => 'Kullanılan prompt:';

  @override
  String get revisedPrompt => 'Düzenlenmiş prompt (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Yüklenemedi: $error';
  }

  @override
  String get generation => 'Üretim';

  @override
  String get generationWebInfo =>
      'Görselleri Tsumiki botu (ComfyUI) üretir. Hazır görsel botla olan sohbetine de gönderilir.';

  @override
  String get workflow => 'İş akışı';

  @override
  String get generationBackend => 'Üretim arka ucu';

  @override
  String get xaiInfo => 'Grok ile üretim için console.x.ai’den API anahtarı.';

  @override
  String get apiKey => 'API anahtarı';

  @override
  String get ol1nInfo =>
      'Yerel AiStack (Flux diffusers API). Bir CF Access hizmet jetonu gir veya derlemeye gömülüyse boş bırak (--dart-define).';

  @override
  String get comfyInfo =>
      'Yerel ComfyUI (model seçimi aşağıda). CF Access jetonunu llm.ol1n.com ile paylaşır.';

  @override
  String get save => 'Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get wfAuto => 'Otomatik — seçilen şablonu izle';

  @override
  String get wfFlux => 'Flux — resimsel ve fotogerçekçi stiller';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru etiketleri';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — hızlı fotogerçekçilik';

  @override
  String get wfWai => 'WAI Illustrious — anime, Pony’den yeni';

  @override
  String templateChose(String workflow) {
    return 'Şablon şunu seçti: $workflow';
  }

  @override
  String get apiKeySaved => 'API anahtarı kaydedildi';

  @override
  String get reposeScreenTitle => 'Repose — poz verilmiş yüz';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Yüz';

  @override
  String get stepPose => '2. Poz';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATİF';

  @override
  String get reposePromptHint => 'bir kadının fotoğrafı, tam boy, doğal ışık…';

  @override
  String couldNotLoadModels(String error) {
    return 'Modeller yüklenemedi: $error';
  }

  @override
  String get noModels =>
      'Model yok (Ayarlar’daki CF kimlik bilgilerini kontrol et).';

  @override
  String get uploadFace => 'Yüz yükle';

  @override
  String get changeFace => 'Yüzü değiştir';

  @override
  String get pickFromGallery => 'Galeriden seç';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get needCfCredentials =>
      'Ayarlar’da Cloudflare Access kimlik bilgilerini belirle';

  @override
  String get baseImageSelected => 'Temel görsel seçildi';

  @override
  String get baseImageOptional => 'Temel görsel (isteğe bağlı)';

  @override
  String get remove => 'Kaldır';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model şablona göre otomatik seçildi.\nAyarlar’dan değiştirebilirsin.';

  @override
  String get modelManualTooltip => 'Model Ayarlar’dan elle seçildi.';

  @override
  String get pickBlocks => 'Prompt oluşturmak için bloklar seç...';
}
