// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get screenBuilder => 'Pembina prompt';

  @override
  String get screenRestyle => 'Ubah gaya foto';

  @override
  String get screenHair => 'Cuba gaya rambut';

  @override
  String get screenAnimate => 'Animasikan foto';

  @override
  String get settings => 'Tetapan';

  @override
  String get shopTooltipVideo => 'Kredit animasi dan pakej';

  @override
  String get shopTooltip => 'Kredit dan pakej';

  @override
  String get switchCard => 'Tukar kad';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit animasi ditambah 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit ditambah 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Pembayaran gagal, sila cuba lagi';

  @override
  String errorDetail(String error) {
    return 'Ralat: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Tidak dapat memuatkan kredit: $error';
  }

  @override
  String get tryAgain => 'Cuba lagi';

  @override
  String get animationsTitle => 'Animasi';

  @override
  String get creditsTitle => 'Kredit';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animasi percuma hari ini: $free daripada $limit · kredit animasi: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Penjanaan percuma hari ini: $free daripada $limit · kredit: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 kredit = 1 video, dibayar dengan Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 kredit = 1 imej, dibayar dengan Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animasi',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose tidak tersedia di web';

  @override
  String get reposeTooltip => 'Repose (wajah dalam pose)';

  @override
  String get presets => 'Pratetap';

  @override
  String get template => 'Templat';

  @override
  String get backToTop => 'Kembali ke atas';

  @override
  String get generating => 'Menjana…';

  @override
  String get generate => 'Jana';

  @override
  String get needCredentials =>
      'Tetapkan kunci API atau bukti kelayakan dalam Tetapan';

  @override
  String presetLoaded(String name) {
    return 'Pratetap “$name” dimuatkan';
  }

  @override
  String get connectionLostVideo =>
      'Sambungan terputus — bot tetap akan menghantar video ke sembang anda.';

  @override
  String videoServerDown(String error) {
    return 'Pelayan video tidak tersedia buat masa ini.\n$error';
  }

  @override
  String get scene => 'Babak';

  @override
  String get uploading => 'Memuat naik…';

  @override
  String get animate => 'Animasikan';

  @override
  String get pickPhoto => 'Pilih foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'klip ~$seconds s · pemaparan ~$minutes min';
  }

  @override
  String queuePosition(int position) {
    return 'Dalam giliran · kedudukan $position';
  }

  @override
  String get queueWaiting => 'Dalam giliran…';

  @override
  String get finishing => 'Menyudahkan (melicinkan pergerakan)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Ketukan $beat/$beats · baki ~$minutes min';
  }

  @override
  String get videoDone => 'Siap! Video dihantar ke sembang Telegram anda 🎬';

  @override
  String failedDetail(String error) {
    return 'Gagal: $error';
  }

  @override
  String get unknownError => 'ralat tidak diketahui';

  @override
  String get starting => 'Bermula…';

  @override
  String get canCloseApp =>
      'Anda boleh menutup aplikasi — video akan tiba dalam sembang.';

  @override
  String get notCharged => 'Video percuma / kredit anda tidak digunakan.';

  @override
  String get animateAnother => 'Animasikan yang lain';

  @override
  String get restyleHint =>
      'Mengekalkan wajah dan pose anda. Paling baik dengan foto jelas seorang dari hadapan.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Ilustrasi';

  @override
  String get style => 'Gaya';

  @override
  String get filterStyles => 'Tapis gaya';

  @override
  String get restyling => 'Menukar gaya…';

  @override
  String get restyle => 'Tukar gaya';

  @override
  String get restyleBusy =>
      'Menukar gaya… kira-kira seminit.\nImej turut tiba dalam sembang anda.';

  @override
  String get groupPopular => 'Popular';

  @override
  String get groupPainters => 'Pelukis';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Eropah';

  @override
  String get groupAmericasOceania => 'Amerika & Oseania';

  @override
  String get groupAfricaNearEast => 'Afrika & Timur Dekat';

  @override
  String get hairHint =>
      'Mengekalkan wajah dan warna rambut anda, kecuali anda memilih warna baharu. Paling baik dengan potret dari hadapan, rambut kelihatan sepenuhnya, tanpa topi.';

  @override
  String get noHairstyles => 'Belum ada gaya rambut — semak semula nanti.';

  @override
  String get colour => 'Warna';

  @override
  String get keepMine => 'Kekalkan milik saya';

  @override
  String get haircut => 'Potongan rambut';

  @override
  String get keepMyCut => 'Kekalkan potongan saya';

  @override
  String get working => 'Memproses…';

  @override
  String get newColour => 'Warna baharu';

  @override
  String get newHaircut => 'Potongan baharu';

  @override
  String get pickPortrait => 'Pilih potret';

  @override
  String get hairBusy =>
      'Memproses… kira-kira seminit.\nFoto turut tiba dalam sembang anda.';

  @override
  String get hairWomen => 'Wanita';

  @override
  String get hairMen => 'Lelaki';

  @override
  String get hairCuts => 'Potongan';

  @override
  String get hairBangs => 'Poni';

  @override
  String get hairTexture => 'Tekstur';

  @override
  String get hairShort => 'Pendek';

  @override
  String get hairMedium => 'Sederhana';

  @override
  String get hairLong => 'Panjang';

  @override
  String get hairBraids => 'Kepang';

  @override
  String get hairUpdos => 'Sanggul';

  @override
  String get notDownloaded => 'Imej belum dimuat turun';

  @override
  String get savedToGallery => 'Disimpan ke galeri';

  @override
  String couldNotSave(String error) {
    return 'Tidak dapat menyimpan: $error';
  }

  @override
  String get result => 'Hasil';

  @override
  String get saveToGallery => 'Simpan ke galeri';

  @override
  String get copyPrompt => 'Salin prompt';

  @override
  String get promptCopied => 'Prompt disalin';

  @override
  String get imageNotAvailable => 'Imej tidak tersedia';

  @override
  String get promptUsed => 'Prompt yang digunakan:';

  @override
  String get revisedPrompt => 'Prompt yang disemak (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Tidak dapat memuatkan: $error';
  }

  @override
  String get generation => 'Penjanaan';

  @override
  String get generationWebInfo =>
      'Imej dijana oleh bot Tsumiki (ComfyUI). Imej yang siap turut dihantar ke sembang anda dengan bot.';

  @override
  String get workflow => 'Aliran kerja';

  @override
  String get generationBackend => 'Bahagian belakang penjanaan';

  @override
  String get xaiInfo =>
      'Kunci API daripada console.x.ai untuk menjana melalui Grok.';

  @override
  String get apiKey => 'Kunci API';

  @override
  String get ol1nInfo =>
      'AiStack tempatan (API Flux diffusers). Masukkan token perkhidmatan CF Access, atau biarkan kosong jika sudah tertanam semasa binaan (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI tempatan (pilih model di bawah). Berkongsi token CF Access dengan llm.ol1n.com.';

  @override
  String get save => 'Simpan';

  @override
  String get saved => 'Disimpan';

  @override
  String get wfAuto => 'Automatik — ikut templat yang dipilih';

  @override
  String get wfFlux => 'Flux — gaya lukisan dan fotorealistik';

  @override
  String get wfPony => 'Pony Diffusion — anime, teg Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — fotorealistik pantas';

  @override
  String get wfWai => 'WAI Illustrious — anime, lebih baharu daripada Pony';

  @override
  String templateChose(String workflow) {
    return 'Templat memilih: $workflow';
  }

  @override
  String get apiKeySaved => 'Kunci API disimpan';

  @override
  String get reposeScreenTitle => 'Repose — wajah dalam pose';

  @override
  String get model => 'Model';

  @override
  String get stepFace => '1. Wajah';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIF';

  @override
  String get reposePromptHint =>
      'foto seorang wanita, seluruh badan, cahaya semula jadi…';

  @override
  String couldNotLoadModels(String error) {
    return 'Tidak dapat memuatkan model: $error';
  }

  @override
  String get noModels =>
      'Tiada model (semak bukti kelayakan CF dalam Tetapan).';

  @override
  String get uploadFace => 'Muat naik wajah';

  @override
  String get changeFace => 'Tukar wajah';

  @override
  String get pickFromGallery => 'Pilih daripada galeri';

  @override
  String get takePhoto => 'Ambil foto';

  @override
  String get needCfCredentials =>
      'Tetapkan bukti kelayakan Cloudflare Access dalam Tetapan';

  @override
  String get baseImageSelected => 'Imej asas dipilih';

  @override
  String get baseImageOptional => 'Imej asas (pilihan)';

  @override
  String get remove => 'Alih keluar';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model dipilih secara automatik daripada templat.\nAnda boleh mengubahnya dalam Tetapan.';

  @override
  String get modelManualTooltip => 'Model dipilih secara manual dalam Tetapan.';

  @override
  String get pickBlocks => 'Pilih blok untuk menyusun prompt...';
}
