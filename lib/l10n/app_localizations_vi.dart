// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get screenBuilder => 'Trình tạo prompt';

  @override
  String get screenRestyle => 'Đổi phong cách ảnh';

  @override
  String get screenHair => 'Thử kiểu tóc';

  @override
  String get screenAnimate => 'Làm ảnh chuyển động';

  @override
  String get settings => 'Cài đặt';

  @override
  String get shopTooltipVideo => 'Tín dụng hoạt ảnh và gói';

  @override
  String get shopTooltip => 'Tín dụng và gói';

  @override
  String get switchCard => 'Chuyển thẻ';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã thêm $count tín dụng hoạt ảnh 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã thêm $count tín dụng 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Thanh toán thất bại, vui lòng thử lại';

  @override
  String errorDetail(String error) {
    return 'Lỗi: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Không thể tải tín dụng: $error';
  }

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get animationsTitle => 'Hoạt ảnh';

  @override
  String get creditsTitle => 'Tín dụng';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Hoạt ảnh miễn phí hôm nay: $free/$limit · tín dụng hoạt ảnh: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Lượt tạo miễn phí hôm nay: $free/$limit · tín dụng: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 tín dụng = 1 video, thanh toán bằng Telegram Stars.';

  @override
  String get imagePriceNote =>
      '1 tín dụng = 1 ảnh, thanh toán bằng Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tín dụng',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hoạt ảnh',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose không khả dụng trên web';

  @override
  String get reposeTooltip => 'Repose (khuôn mặt trong một tư thế)';

  @override
  String get presets => 'Cài đặt sẵn';

  @override
  String get template => 'Mẫu';

  @override
  String get backToTop => 'Lên đầu trang';

  @override
  String get generating => 'Đang tạo…';

  @override
  String get generate => 'Tạo';

  @override
  String get needCredentials =>
      'Đặt khóa API hoặc thông tin xác thực trong Cài đặt';

  @override
  String presetLoaded(String name) {
    return 'Đã tải cài đặt sẵn “$name”';
  }

  @override
  String get connectionLostVideo =>
      'Mất kết nối — bot vẫn sẽ gửi video vào cuộc trò chuyện của bạn.';

  @override
  String videoServerDown(String error) {
    return 'Máy chủ video hiện không khả dụng.\n$error';
  }

  @override
  String get scene => 'Cảnh';

  @override
  String get uploading => 'Đang tải lên…';

  @override
  String get animate => 'Làm chuyển động';

  @override
  String get pickPhoto => 'Chọn ảnh';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clip ~$seconds giây · kết xuất ~$minutes phút';
  }

  @override
  String queuePosition(int position) {
    return 'Đang xếp hàng · vị trí $position';
  }

  @override
  String get queueWaiting => 'Đang xếp hàng…';

  @override
  String get finishing => 'Đang hoàn tất (làm mượt chuyển động)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Nhịp $beat/$beats · còn ~$minutes phút';
  }

  @override
  String get videoDone =>
      'Xong! Video đã được gửi vào cuộc trò chuyện Telegram của bạn 🎬';

  @override
  String failedDetail(String error) {
    return 'Thất bại: $error';
  }

  @override
  String get unknownError => 'lỗi không xác định';

  @override
  String get starting => 'Đang bắt đầu…';

  @override
  String get canCloseApp =>
      'Bạn có thể đóng ứng dụng — video sẽ đến trong cuộc trò chuyện.';

  @override
  String get notCharged => 'Video miễn phí / tín dụng của bạn chưa bị trừ.';

  @override
  String get animateAnother => 'Làm thêm một ảnh';

  @override
  String get restyleHint =>
      'Giữ khuôn mặt và tư thế của bạn. Hiệu quả nhất với ảnh chính diện rõ nét của một người.';

  @override
  String get medium => 'Chất liệu';

  @override
  String get mediumPhoto => 'Ảnh chụp';

  @override
  String get mediumIllustration => 'Tranh minh họa';

  @override
  String get style => 'Phong cách';

  @override
  String get filterStyles => 'Lọc phong cách';

  @override
  String get restyling => 'Đang đổi phong cách…';

  @override
  String get restyle => 'Đổi phong cách';

  @override
  String get restyleBusy =>
      'Đang đổi phong cách… khoảng một phút.\nẢnh cũng sẽ đến cuộc trò chuyện của bạn.';

  @override
  String get groupPopular => 'Phổ biến';

  @override
  String get groupPainters => 'Họa sĩ';

  @override
  String get groupAsia => 'Châu Á';

  @override
  String get groupEurope => 'Châu Âu';

  @override
  String get groupAmericasOceania => 'Châu Mỹ & Châu Đại Dương';

  @override
  String get groupAfricaNearEast => 'Châu Phi & Cận Đông';

  @override
  String get hairHint =>
      'Giữ khuôn mặt và màu tóc của bạn, trừ khi bạn chọn màu mới. Hiệu quả nhất với ảnh chân dung chính diện, thấy rõ toàn bộ mái tóc, không đội mũ.';

  @override
  String get noHairstyles => 'Chưa có kiểu tóc nào — hãy quay lại sau.';

  @override
  String get colour => 'Màu';

  @override
  String get keepMine => 'Giữ màu của tôi';

  @override
  String get haircut => 'Kiểu tóc';

  @override
  String get keepMyCut => 'Giữ kiểu tóc của tôi';

  @override
  String get working => 'Đang xử lý…';

  @override
  String get newColour => 'Màu mới';

  @override
  String get newHaircut => 'Kiểu tóc mới';

  @override
  String get pickPortrait => 'Chọn ảnh chân dung';

  @override
  String get hairBusy =>
      'Đang xử lý… khoảng một phút.\nẢnh cũng sẽ đến cuộc trò chuyện của bạn.';

  @override
  String get hairWomen => 'Nữ';

  @override
  String get hairMen => 'Nam';

  @override
  String get hairCuts => 'Kiểu cắt';

  @override
  String get hairBangs => 'Tóc mái';

  @override
  String get hairTexture => 'Kết cấu';

  @override
  String get hairShort => 'Ngắn';

  @override
  String get hairMedium => 'Trung bình';

  @override
  String get hairLong => 'Dài';

  @override
  String get hairBraids => 'Tóc tết';

  @override
  String get hairUpdos => 'Tóc búi';

  @override
  String get notDownloaded => 'Ảnh chưa được tải xuống';

  @override
  String get savedToGallery => 'Đã lưu vào thư viện';

  @override
  String couldNotSave(String error) {
    return 'Không thể lưu: $error';
  }

  @override
  String get result => 'Kết quả';

  @override
  String get saveToGallery => 'Lưu vào thư viện';

  @override
  String get copyPrompt => 'Sao chép prompt';

  @override
  String get promptCopied => 'Đã sao chép prompt';

  @override
  String get imageNotAvailable => 'Ảnh không khả dụng';

  @override
  String get promptUsed => 'Prompt đã dùng:';

  @override
  String get revisedPrompt => 'Prompt đã chỉnh sửa (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Không thể tải: $error';
  }

  @override
  String get generation => 'Tạo ảnh';

  @override
  String get generationWebInfo =>
      'Ảnh do bot Tsumiki (ComfyUI) tạo. Ảnh hoàn chỉnh cũng được gửi vào cuộc trò chuyện của bạn với bot.';

  @override
  String get workflow => 'Quy trình';

  @override
  String get generationBackend => 'Backend tạo ảnh';

  @override
  String get xaiInfo => 'Khóa API từ console.x.ai để tạo qua Grok.';

  @override
  String get apiKey => 'Khóa API';

  @override
  String get ol1nInfo =>
      'AiStack cục bộ (API Flux diffusers). Nhập token dịch vụ CF Access, hoặc để trống nếu đã nhúng sẵn khi build (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI cục bộ (chọn mô hình bên dưới). Dùng chung token CF Access với llm.ol1n.com.';

  @override
  String get save => 'Lưu';

  @override
  String get saved => 'Đã lưu';

  @override
  String get wfAuto => 'Tự động — theo mẫu đã chọn';

  @override
  String get wfFlux => 'Flux — phong cách hội họa và chân thực như ảnh';

  @override
  String get wfPony => 'Pony Diffusion — anime, thẻ Danbooru';

  @override
  String get wfJuggernaut =>
      'Juggernaut XL Lightning — chân thực như ảnh, nhanh';

  @override
  String get wfWai => 'WAI Illustrious — anime, mới hơn Pony';

  @override
  String templateChose(String workflow) {
    return 'Mẫu đã chọn: $workflow';
  }

  @override
  String get apiKeySaved => 'Đã lưu khóa API';

  @override
  String get reposeScreenTitle => 'Repose — khuôn mặt trong một tư thế';

  @override
  String get model => 'Mô hình';

  @override
  String get stepFace => '1. Khuôn mặt';

  @override
  String get stepPose => '2. Tư thế';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'PHỦ ĐỊNH';

  @override
  String get reposePromptHint =>
      'ảnh một người phụ nữ, toàn thân, ánh sáng tự nhiên…';

  @override
  String couldNotLoadModels(String error) {
    return 'Không thể tải mô hình: $error';
  }

  @override
  String get noModels =>
      'Không có mô hình (kiểm tra thông tin xác thực CF trong Cài đặt).';

  @override
  String get uploadFace => 'Tải khuôn mặt lên';

  @override
  String get changeFace => 'Đổi khuôn mặt';

  @override
  String get pickFromGallery => 'Chọn từ thư viện';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get needCfCredentials =>
      'Đặt thông tin xác thực Cloudflare Access trong Cài đặt';

  @override
  String get baseImageSelected => 'Đã chọn ảnh gốc';

  @override
  String get baseImageOptional => 'Ảnh gốc (tùy chọn)';

  @override
  String get remove => 'Xóa';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Mô hình được chọn tự động theo mẫu.\nBạn có thể đổi trong Cài đặt.';

  @override
  String get modelManualTooltip => 'Mô hình được chọn thủ công trong Cài đặt.';

  @override
  String get pickBlocks => 'Chọn các khối để ghép thành prompt...';
}
