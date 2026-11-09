// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get screenBuilder => 'Pembuat prompt';

  @override
  String get screenRestyle => 'Ubah gaya foto';

  @override
  String get screenHair => 'Coba gaya rambut';

  @override
  String get screenAnimate => 'Animasikan foto';

  @override
  String get settings => 'Pengaturan';

  @override
  String get shopTooltipVideo => 'Kredit animasi dan paket';

  @override
  String get shopTooltip => 'Kredit dan paket';

  @override
  String get switchCard => 'Ganti kartu';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit animasi ditambahkan 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredit ditambahkan 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Pembayaran gagal, silakan coba lagi';

  @override
  String errorDetail(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Gagal memuat kredit: $error';
  }

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get animationsTitle => 'Animasi';

  @override
  String get creditsTitle => 'Kredit';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animasi gratis hari ini: $free dari $limit · kredit animasi: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Pembuatan gratis hari ini: $free dari $limit · kredit: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 kredit = 1 video, dibayar dengan Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 kredit = 1 gambar, dibayar dengan Telegram Stars.';

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
  String get presets => 'Preset';

  @override
  String get template => 'Templat';

  @override
  String get backToTop => 'Kembali ke atas';

  @override
  String get generating => 'Membuat…';

  @override
  String get generate => 'Buat';

  @override
  String get needCredentials => 'Atur kunci API atau kredensial di Pengaturan';

  @override
  String presetLoaded(String name) {
    return 'Preset “$name” dimuat';
  }

  @override
  String get connectionLostVideo =>
      'Koneksi terputus — bot tetap akan mengirim video ke chat Anda.';

  @override
  String videoServerDown(String error) {
    return 'Server video sedang tidak tersedia.\n$error';
  }

  @override
  String get scene => 'Adegan';

  @override
  String get uploading => 'Mengunggah…';

  @override
  String get animate => 'Animasikan';

  @override
  String get pickPhoto => 'Pilih foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'klip ~$seconds dtk · render ~$minutes mnt';
  }

  @override
  String queuePosition(int position) {
    return 'Dalam antrean · posisi $position';
  }

  @override
  String get queueWaiting => 'Dalam antrean…';

  @override
  String get finishing => 'Menyelesaikan (menghaluskan gerakan)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Ketukan $beat/$beats · sisa ~$minutes mnt';
  }

  @override
  String get videoDone => 'Selesai! Video dikirim ke chat Telegram Anda 🎬';

  @override
  String failedDetail(String error) {
    return 'Gagal: $error';
  }

  @override
  String get unknownError => 'kesalahan tidak dikenal';

  @override
  String get starting => 'Memulai…';

  @override
  String get canCloseApp =>
      'Anda bisa menutup aplikasi — video akan tiba di chat.';

  @override
  String get notCharged => 'Video gratis / kredit Anda tidak terpakai.';

  @override
  String get animateAnother => 'Animasikan yang lain';

  @override
  String get restyleHint =>
      'Mempertahankan wajah dan pose Anda. Paling baik dengan foto jelas satu orang dari depan.';

  @override
  String get medium => 'Medium';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Ilustrasi';

  @override
  String get style => 'Gaya';

  @override
  String get filterStyles => 'Saring gaya';

  @override
  String get restyling => 'Mengubah gaya…';

  @override
  String get restyle => 'Ubah gaya';

  @override
  String get restyleBusy =>
      'Mengubah gaya… sekitar satu menit.\nGambar juga tiba di chat Anda.';

  @override
  String get groupPopular => 'Populer';

  @override
  String get groupPainters => 'Pelukis';

  @override
  String get groupAsia => 'Asia';

  @override
  String get groupEurope => 'Eropa';

  @override
  String get groupAmericasOceania => 'Amerika & Oseania';

  @override
  String get groupAfricaNearEast => 'Afrika & Timur Dekat';

  @override
  String get hairHint =>
      'Mempertahankan wajah dan warna rambut Anda, kecuali Anda memilih warna baru. Paling baik dengan potret dari depan, rambut terlihat penuh, tanpa topi.';

  @override
  String get noHairstyles => 'Belum ada gaya rambut — cek lagi nanti.';

  @override
  String get colour => 'Warna';

  @override
  String get keepMine => 'Pertahankan milik saya';

  @override
  String get haircut => 'Potongan rambut';

  @override
  String get keepMyCut => 'Pertahankan potongan saya';

  @override
  String get working => 'Memproses…';

  @override
  String get newColour => 'Warna baru';

  @override
  String get newHaircut => 'Potongan baru';

  @override
  String get pickPortrait => 'Pilih potret';

  @override
  String get hairBusy =>
      'Memproses… sekitar satu menit.\nFoto juga tiba di chat Anda.';

  @override
  String get hairWomen => 'Wanita';

  @override
  String get hairMen => 'Pria';

  @override
  String get hairCuts => 'Potongan';

  @override
  String get hairBangs => 'Poni';

  @override
  String get hairTexture => 'Tekstur';

  @override
  String get hairShort => 'Pendek';

  @override
  String get hairMedium => 'Sedang';

  @override
  String get hairLong => 'Panjang';

  @override
  String get hairBraids => 'Kepang';

  @override
  String get hairUpdos => 'Sanggul';

  @override
  String get notDownloaded => 'Gambar belum diunduh';

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
  String get imageNotAvailable => 'Gambar tidak tersedia';

  @override
  String get promptUsed => 'Prompt yang dipakai:';

  @override
  String get revisedPrompt => 'Prompt yang direvisi (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Tidak dapat memuat: $error';
  }

  @override
  String get generation => 'Pembuatan';

  @override
  String get generationWebInfo =>
      'Gambar dibuat oleh bot Tsumiki (ComfyUI). Gambar yang selesai juga dikirim ke chat Anda dengan bot.';

  @override
  String get workflow => 'Alur kerja';

  @override
  String get generationBackend => 'Backend pembuatan';

  @override
  String get xaiInfo => 'Kunci API dari console.x.ai untuk membuat lewat Grok.';

  @override
  String get apiKey => 'Kunci API';

  @override
  String get ol1nInfo =>
      'AiStack lokal (API Flux diffusers). Masukkan token layanan CF Access, atau kosongkan jika sudah tertanam saat build (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI lokal (pilih model di bawah). Berbagi token CF Access dengan llm.ol1n.com.';

  @override
  String get save => 'Simpan';

  @override
  String get saved => 'Tersimpan';

  @override
  String get wfAuto => 'Otomatis — ikuti templat yang dipilih';

  @override
  String get wfFlux => 'Flux — gaya lukisan dan fotorealistis';

  @override
  String get wfPony => 'Pony Diffusion — anime, tag Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — fotorealistis cepat';

  @override
  String get wfWai => 'WAI Illustrious — anime, lebih baru dari Pony';

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
      'foto seorang wanita, seluruh tubuh, cahaya alami…';

  @override
  String couldNotLoadModels(String error) {
    return 'Tidak dapat memuat model: $error';
  }

  @override
  String get noModels =>
      'Tidak ada model (periksa kredensial CF di Pengaturan).';

  @override
  String get uploadFace => 'Unggah wajah';

  @override
  String get changeFace => 'Ganti wajah';

  @override
  String get pickFromGallery => 'Pilih dari galeri';

  @override
  String get takePhoto => 'Ambil foto';

  @override
  String get needCfCredentials =>
      'Atur kredensial Cloudflare Access di Pengaturan';

  @override
  String get baseImageSelected => 'Gambar dasar dipilih';

  @override
  String get baseImageOptional => 'Gambar dasar (opsional)';

  @override
  String get remove => 'Hapus';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Model dipilih otomatis dari templat.\nAnda bisa mengubahnya di Pengaturan.';

  @override
  String get modelManualTooltip => 'Model dipilih manual di Pengaturan.';

  @override
  String get pickBlocks => 'Pilih blok untuk menyusun prompt...';
}
