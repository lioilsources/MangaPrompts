// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get screenBuilder => 'ตัวสร้างพรอมต์';

  @override
  String get screenRestyle => 'เปลี่ยนสไตล์รูปภาพ';

  @override
  String get screenHair => 'ลองทรงผม';

  @override
  String get screenAnimate => 'ทำให้รูปภาพเคลื่อนไหว';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get shopTooltipVideo => 'เครดิตแอนิเมชันและแพ็กเกจ';

  @override
  String get shopTooltip => 'เครดิตและแพ็กเกจ';

  @override
  String get switchCard => 'สลับการ์ด';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เพิ่มเครดิตแอนิเมชัน $count รายการแล้ว 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เพิ่มเครดิต $count รายการแล้ว 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'ชำระเงินไม่สำเร็จ โปรดลองอีกครั้ง';

  @override
  String errorDetail(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'โหลดเครดิตไม่สำเร็จ: $error';
  }

  @override
  String get tryAgain => 'ลองอีกครั้ง';

  @override
  String get animationsTitle => 'แอนิเมชัน';

  @override
  String get creditsTitle => 'เครดิต';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'แอนิเมชันฟรีวันนี้: $free จาก $limit · เครดิตแอนิเมชัน: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'การสร้างฟรีวันนี้: $free จาก $limit · เครดิต: $credits';
  }

  @override
  String get videoPriceNote => '1 เครดิต = 1 วิดีโอ ชำระด้วย Telegram Stars';

  @override
  String get imagePriceNote => '1 เครดิต = 1 รูปภาพ ชำระด้วย Telegram Stars';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เครดิต',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'แอนิเมชัน $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'ไม่มี Repose บนเว็บ';

  @override
  String get reposeTooltip => 'Repose (ใบหน้าในท่าทาง)';

  @override
  String get presets => 'ค่าที่ตั้งไว้ล่วงหน้า';

  @override
  String get template => 'เทมเพลต';

  @override
  String get backToTop => 'กลับไปด้านบน';

  @override
  String get generating => 'กำลังสร้าง…';

  @override
  String get generate => 'สร้าง';

  @override
  String get needCredentials => 'ตั้งค่าคีย์ API หรือข้อมูลรับรองในการตั้งค่า';

  @override
  String presetLoaded(String name) {
    return 'โหลดค่าที่ตั้งไว้ “$name” แล้ว';
  }

  @override
  String get connectionLostVideo =>
      'การเชื่อมต่อหลุด — บอตจะยังส่งวิดีโอเข้าแชทของคุณ';

  @override
  String videoServerDown(String error) {
    return 'เซิร์ฟเวอร์วิดีโอไม่พร้อมใช้งานในขณะนี้\n$error';
  }

  @override
  String get scene => 'ฉาก';

  @override
  String get uploading => 'กำลังอัปโหลด…';

  @override
  String get animate => 'ทำให้เคลื่อนไหว';

  @override
  String get pickPhoto => 'เลือกรูปภาพ';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'คลิป ~$seconds วิ · เรนเดอร์ ~$minutes นาที';
  }

  @override
  String queuePosition(int position) {
    return 'อยู่ในคิว · ลำดับที่ $position';
  }

  @override
  String get queueWaiting => 'อยู่ในคิว…';

  @override
  String get finishing => 'กำลังเสร็จสิ้น (ปรับการเคลื่อนไหวให้นุ่มนวล)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'บีต $beat/$beats · เหลือ ~$minutes นาที';
  }

  @override
  String get videoDone => 'เสร็จแล้ว! ส่งวิดีโอไปยังแชท Telegram ของคุณแล้ว 🎬';

  @override
  String failedDetail(String error) {
    return 'ล้มเหลว: $error';
  }

  @override
  String get unknownError => 'ข้อผิดพลาดที่ไม่ทราบสาเหตุ';

  @override
  String get starting => 'กำลังเริ่ม…';

  @override
  String get canCloseApp => 'ปิดแอปได้เลย — วิดีโอจะส่งมาที่แชท';

  @override
  String get notCharged => 'วิดีโอฟรี / เครดิตของคุณยังไม่ถูกใช้';

  @override
  String get animateAnother => 'ทำอีกรูป';

  @override
  String get restyleHint =>
      'คงใบหน้าและท่าทางของคุณไว้ ใช้ได้ดีที่สุดกับรูปคนเดียวที่ชัดเจนถ่ายจากด้านหน้า';

  @override
  String get medium => 'สื่อ';

  @override
  String get mediumPhoto => 'รูปถ่าย';

  @override
  String get mediumIllustration => 'ภาพประกอบ';

  @override
  String get style => 'สไตล์';

  @override
  String get filterStyles => 'กรองสไตล์';

  @override
  String get restyling => 'กำลังเปลี่ยนสไตล์…';

  @override
  String get restyle => 'เปลี่ยนสไตล์';

  @override
  String get restyleBusy =>
      'กำลังเปลี่ยนสไตล์… ประมาณหนึ่งนาที\nรูปจะส่งไปที่แชทของคุณด้วย';

  @override
  String get groupPopular => 'ยอดนิยม';

  @override
  String get groupPainters => 'จิตรกร';

  @override
  String get groupAsia => 'เอเชีย';

  @override
  String get groupEurope => 'ยุโรป';

  @override
  String get groupAmericasOceania => 'อเมริกาและโอเชียเนีย';

  @override
  String get groupAfricaNearEast => 'แอฟริกาและตะวันออกใกล้';

  @override
  String get hairHint =>
      'คงใบหน้าและสีผมของคุณไว้ เว้นแต่คุณเลือกสีใหม่ ใช้ได้ดีที่สุดกับภาพถ่ายด้านหน้าที่เห็นผมครบ ไม่สวมหมวก';

  @override
  String get noHairstyles => 'ยังไม่มีทรงผม — กลับมาดูใหม่เร็วๆ นี้';

  @override
  String get colour => 'สี';

  @override
  String get keepMine => 'ใช้สีเดิม';

  @override
  String get haircut => 'ทรงผม';

  @override
  String get keepMyCut => 'ใช้ทรงเดิม';

  @override
  String get working => 'กำลังทำงาน…';

  @override
  String get newColour => 'สีใหม่';

  @override
  String get newHaircut => 'ทรงผมใหม่';

  @override
  String get pickPortrait => 'เลือกภาพถ่ายบุคคล';

  @override
  String get hairBusy =>
      'กำลังทำงาน… ประมาณหนึ่งนาที\nรูปจะส่งไปที่แชทของคุณด้วย';

  @override
  String get hairWomen => 'ผู้หญิง';

  @override
  String get hairMen => 'ผู้ชาย';

  @override
  String get hairCuts => 'ทรงตัด';

  @override
  String get hairBangs => 'ผมหน้าม้า';

  @override
  String get hairTexture => 'เนื้อผม';

  @override
  String get hairShort => 'สั้น';

  @override
  String get hairMedium => 'ปานกลาง';

  @override
  String get hairLong => 'ยาว';

  @override
  String get hairBraids => 'ถักเปีย';

  @override
  String get hairUpdos => 'ทรงเกล้า';

  @override
  String get notDownloaded => 'ยังไม่ได้ดาวน์โหลดรูปภาพ';

  @override
  String get savedToGallery => 'บันทึกลงแกลเลอรีแล้ว';

  @override
  String couldNotSave(String error) {
    return 'บันทึกไม่สำเร็จ: $error';
  }

  @override
  String get result => 'ผลลัพธ์';

  @override
  String get saveToGallery => 'บันทึกลงแกลเลอรี';

  @override
  String get copyPrompt => 'คัดลอกพรอมต์';

  @override
  String get promptCopied => 'คัดลอกพรอมต์แล้ว';

  @override
  String get imageNotAvailable => 'ไม่มีรูปภาพ';

  @override
  String get promptUsed => 'พรอมต์ที่ใช้:';

  @override
  String get revisedPrompt => 'พรอมต์ที่ปรับแล้ว (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'โหลดไม่สำเร็จ: $error';
  }

  @override
  String get generation => 'การสร้าง';

  @override
  String get generationWebInfo =>
      'รูปภาพสร้างโดยบอต Tsumiki (ComfyUI) รูปที่เสร็จแล้วจะส่งไปที่แชทกับบอตด้วย';

  @override
  String get workflow => 'เวิร์กโฟลว์';

  @override
  String get generationBackend => 'แบ็กเอนด์การสร้าง';

  @override
  String get xaiInfo => 'คีย์ API จาก console.x.ai สำหรับสร้างผ่าน Grok';

  @override
  String get apiKey => 'คีย์ API';

  @override
  String get ol1nInfo =>
      'AiStack ในเครื่อง (Flux diffusers API) ใส่โทเคนบริการ CF Access หรือเว้นว่างหากฝังไว้ตอนบิลด์แล้ว (--dart-define)';

  @override
  String get comfyInfo =>
      'ComfyUI ในเครื่อง (เลือกโมเดลด้านล่าง) ใช้โทเคน CF Access ร่วมกับ llm.ol1n.com';

  @override
  String get save => 'บันทึก';

  @override
  String get saved => 'บันทึกแล้ว';

  @override
  String get wfAuto => 'อัตโนมัติ — ตามเทมเพลตที่เลือก';

  @override
  String get wfFlux => 'Flux — สไตล์ภาพวาดและสมจริงแบบภาพถ่าย';

  @override
  String get wfPony => 'Pony Diffusion — อนิเมะ แท็ก Danbooru';

  @override
  String get wfJuggernaut =>
      'Juggernaut XL Lightning — สมจริงแบบภาพถ่ายที่เร็ว';

  @override
  String get wfWai => 'WAI Illustrious — อนิเมะ ใหม่กว่า Pony';

  @override
  String templateChose(String workflow) {
    return 'เทมเพลตเลือก: $workflow';
  }

  @override
  String get apiKeySaved => 'บันทึกคีย์ API แล้ว';

  @override
  String get reposeScreenTitle => 'Repose — ใบหน้าในท่าทาง';

  @override
  String get model => 'โมเดล';

  @override
  String get stepFace => '1. ใบหน้า';

  @override
  String get stepPose => '2. ท่าทาง';

  @override
  String get stepPrompt => '3. พรอมต์';

  @override
  String get negative => 'เชิงลบ';

  @override
  String get reposePromptHint => 'ภาพถ่ายผู้หญิง เต็มตัว แสงธรรมชาติ…';

  @override
  String couldNotLoadModels(String error) {
    return 'โหลดโมเดลไม่สำเร็จ: $error';
  }

  @override
  String get noModels => 'ไม่มีโมเดล (ตรวจสอบข้อมูลรับรอง CF ในการตั้งค่า)';

  @override
  String get uploadFace => 'อัปโหลดใบหน้า';

  @override
  String get changeFace => 'เปลี่ยนใบหน้า';

  @override
  String get pickFromGallery => 'เลือกจากแกลเลอรี';

  @override
  String get takePhoto => 'ถ่ายรูป';

  @override
  String get needCfCredentials =>
      'ตั้งค่าข้อมูลรับรอง Cloudflare Access ในการตั้งค่า';

  @override
  String get baseImageSelected => 'เลือกภาพฐานแล้ว';

  @override
  String get baseImageOptional => 'ภาพฐาน (ไม่บังคับ)';

  @override
  String get remove => 'ลบ';

  @override
  String get prompt => 'พรอมต์';

  @override
  String get modelAutoTooltip =>
      'โมเดลถูกเลือกอัตโนมัติจากเทมเพลต\nคุณเปลี่ยนได้ในการตั้งค่า';

  @override
  String get modelManualTooltip => 'โมเดลที่เลือกเองในการตั้งค่า';

  @override
  String get pickBlocks => 'เลือกบล็อกเพื่อประกอบพรอมต์...';
}
