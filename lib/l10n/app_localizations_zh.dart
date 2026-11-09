// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get screenBuilder => '提示词构建器';

  @override
  String get screenRestyle => '更换照片风格';

  @override
  String get screenHair => '试试发型';

  @override
  String get screenAnimate => '让照片动起来';

  @override
  String get settings => '设置';

  @override
  String get shopTooltipVideo => '动画额度与套餐';

  @override
  String get shopTooltip => '额度与套餐';

  @override
  String get switchCard => '切换卡片';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个动画额度 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个额度 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => '支付失败，请重试';

  @override
  String errorDetail(String error) {
    return '错误：$error';
  }

  @override
  String creditsLoadFailed(String error) {
    return '无法加载额度：$error';
  }

  @override
  String get tryAgain => '重试';

  @override
  String get animationsTitle => '动画';

  @override
  String get creditsTitle => '额度';

  @override
  String videoQuota(int free, int limit, int credits) {
    return '今日免费动画：$free/$limit · 动画额度：$credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return '今日免费生成：$free/$limit · 额度：$credits';
  }

  @override
  String get videoPriceNote => '1 个额度 = 1 个视频，使用 Telegram Stars 支付。';

  @override
  String get imagePriceNote => '1 个额度 = 1 张图片，使用 Telegram Stars 支付。';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个额度',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个动画',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose 在网页版中不可用';

  @override
  String get reposeTooltip => 'Repose（摆姿势的脸）';

  @override
  String get presets => '预设';

  @override
  String get template => '模板';

  @override
  String get backToTop => '回到顶部';

  @override
  String get generating => '生成中…';

  @override
  String get generate => '生成';

  @override
  String get needCredentials => '请在设置中填写 API 密钥或凭据';

  @override
  String presetLoaded(String name) {
    return '已加载预设“$name”';
  }

  @override
  String get connectionLostVideo => '连接已断开——机器人仍会把视频送到你的聊天。';

  @override
  String videoServerDown(String error) {
    return '视频服务器暂时不可用。\n$error';
  }

  @override
  String get scene => '场景';

  @override
  String get uploading => '上传中…';

  @override
  String get animate => '动起来';

  @override
  String get pickPhoto => '选择照片';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '约 $seconds 秒片段 · 渲染约 $minutes 分钟';
  }

  @override
  String queuePosition(int position) {
    return '排队中 · 第 $position 位';
  }

  @override
  String get queueWaiting => '排队中…';

  @override
  String get finishing => '收尾中（平滑动作）…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return '节拍 $beat/$beats · 约剩 $minutes 分钟';
  }

  @override
  String get videoDone => '完成！视频已发送到你的 Telegram 聊天 🎬';

  @override
  String failedDetail(String error) {
    return '失败：$error';
  }

  @override
  String get unknownError => '未知错误';

  @override
  String get starting => '启动中…';

  @override
  String get canCloseApp => '可以关闭应用——视频会发到聊天里。';

  @override
  String get notCharged => '你的免费视频/额度没有被扣除。';

  @override
  String get animateAnother => '再来一个';

  @override
  String get restyleHint => '保留你的脸和姿势。使用清晰的单人正面照片效果最佳。';

  @override
  String get medium => '媒介';

  @override
  String get mediumPhoto => '照片';

  @override
  String get mediumIllustration => '插画';

  @override
  String get style => '风格';

  @override
  String get filterStyles => '筛选风格';

  @override
  String get restyling => '更换风格中…';

  @override
  String get restyle => '更换风格';

  @override
  String get restyleBusy => '更换风格中…约一分钟。\n图片也会发到你的聊天。';

  @override
  String get groupPopular => '热门';

  @override
  String get groupPainters => '画家';

  @override
  String get groupAsia => '亚洲';

  @override
  String get groupEurope => '欧洲';

  @override
  String get groupAmericasOceania => '美洲与大洋洲';

  @override
  String get groupAfricaNearEast => '非洲与近东';

  @override
  String get hairHint => '保留你的脸，除非你选择新颜色，否则发色也保持不变。最适合头发完整可见、不戴帽子的正面人像。';

  @override
  String get noHairstyles => '暂无发型——请稍后再来。';

  @override
  String get colour => '颜色';

  @override
  String get keepMine => '保持原样';

  @override
  String get haircut => '发型';

  @override
  String get keepMyCut => '保持我的发型';

  @override
  String get working => '处理中…';

  @override
  String get newColour => '新颜色';

  @override
  String get newHaircut => '新发型';

  @override
  String get pickPortrait => '选择人像';

  @override
  String get hairBusy => '处理中…约一分钟。\n照片也会发到你的聊天。';

  @override
  String get hairWomen => '女士';

  @override
  String get hairMen => '男士';

  @override
  String get hairCuts => '剪裁';

  @override
  String get hairBangs => '刘海';

  @override
  String get hairTexture => '发质纹理';

  @override
  String get hairShort => '短发';

  @override
  String get hairMedium => '中发';

  @override
  String get hairLong => '长发';

  @override
  String get hairBraids => '辫子';

  @override
  String get hairUpdos => '盘发';

  @override
  String get notDownloaded => '图片尚未下载';

  @override
  String get savedToGallery => '已保存到相册';

  @override
  String couldNotSave(String error) {
    return '无法保存：$error';
  }

  @override
  String get result => '结果';

  @override
  String get saveToGallery => '保存到相册';

  @override
  String get copyPrompt => '复制提示词';

  @override
  String get promptCopied => '提示词已复制';

  @override
  String get imageNotAvailable => '图片不可用';

  @override
  String get promptUsed => '使用的提示词：';

  @override
  String get revisedPrompt => '改写后的提示词（Grok）：';

  @override
  String couldNotLoad(String error) {
    return '无法加载：$error';
  }

  @override
  String get generation => '生成';

  @override
  String get generationWebInfo =>
      '图片由 Tsumiki 机器人（ComfyUI）生成。完成的图片也会发送到你与机器人的聊天。';

  @override
  String get workflow => '工作流';

  @override
  String get generationBackend => '生成后端';

  @override
  String get xaiInfo => '来自 console.x.ai 的 API 密钥，用于通过 Grok 生成。';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get ol1nInfo =>
      '本地 AiStack（Flux diffusers API）。输入 CF Access 服务令牌；若已在构建时内置（--dart-define），可留空。';

  @override
  String get comfyInfo => '本地 ComfyUI（下方选择模型）。与 llm.ol1n.com 共用 CF Access 令牌。';

  @override
  String get save => '保存';

  @override
  String get saved => '已保存';

  @override
  String get wfAuto => '自动——跟随所选模板';

  @override
  String get wfFlux => 'Flux——绘画风与写实风格';

  @override
  String get wfPony => 'Pony Diffusion——动漫，Danbooru 标签';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning——快速写实';

  @override
  String get wfWai => 'WAI Illustrious——动漫，比 Pony 更新';

  @override
  String templateChose(String workflow) {
    return '模板选择了：$workflow';
  }

  @override
  String get apiKeySaved => 'API 密钥已保存';

  @override
  String get reposeScreenTitle => 'Repose——摆姿势的脸';

  @override
  String get model => '模型';

  @override
  String get stepFace => '1. 脸';

  @override
  String get stepPose => '2. 姿势';

  @override
  String get stepPrompt => '3. 提示词';

  @override
  String get negative => '负面';

  @override
  String get reposePromptHint => '一位女性的照片，全身，自然光…';

  @override
  String couldNotLoadModels(String error) {
    return '无法加载模型：$error';
  }

  @override
  String get noModels => '没有模型（请在设置中检查 CF 凭据）。';

  @override
  String get uploadFace => '上传人脸';

  @override
  String get changeFace => '更换人脸';

  @override
  String get pickFromGallery => '从相册选择';

  @override
  String get takePhoto => '拍照';

  @override
  String get needCfCredentials => '请在设置中填写 Cloudflare Access 凭据';

  @override
  String get baseImageSelected => '已选择底图';

  @override
  String get baseImageOptional => '底图（可选）';

  @override
  String get remove => '移除';

  @override
  String get prompt => '提示词';

  @override
  String get modelAutoTooltip => '模型已根据模板自动选择。\n可在设置中更改。';

  @override
  String get modelManualTooltip => '在设置中手动选择的模型。';

  @override
  String get pickBlocks => '选择积木以组合提示词...';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get screenBuilder => '提示詞建構器';

  @override
  String get screenRestyle => '更換照片風格';

  @override
  String get screenHair => '試試髮型';

  @override
  String get screenAnimate => '讓照片動起來';

  @override
  String get settings => '設定';

  @override
  String get shopTooltipVideo => '動畫額度與方案';

  @override
  String get shopTooltip => '額度與方案';

  @override
  String get switchCard => '切換卡片';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已新增 $count 個動畫額度 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已新增 $count 個額度 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => '付款失敗，請重試';

  @override
  String errorDetail(String error) {
    return '錯誤：$error';
  }

  @override
  String creditsLoadFailed(String error) {
    return '無法載入額度：$error';
  }

  @override
  String get tryAgain => '重試';

  @override
  String get animationsTitle => '動畫';

  @override
  String get creditsTitle => '額度';

  @override
  String videoQuota(int free, int limit, int credits) {
    return '今日免費動畫：$free/$limit · 動畫額度：$credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return '今日免費生成：$free/$limit · 額度：$credits';
  }

  @override
  String get videoPriceNote => '1 個額度 = 1 部影片，以 Telegram Stars 付款。';

  @override
  String get imagePriceNote => '1 個額度 = 1 張圖片，以 Telegram Stars 付款。';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個額度',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個動畫',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose 在網頁版無法使用';

  @override
  String get reposeTooltip => 'Repose（擺姿勢的臉）';

  @override
  String get presets => '預設';

  @override
  String get template => '範本';

  @override
  String get backToTop => '回到頂端';

  @override
  String get generating => '生成中…';

  @override
  String get generate => '生成';

  @override
  String get needCredentials => '請在設定中填寫 API 金鑰或憑證';

  @override
  String presetLoaded(String name) {
    return '已載入預設「$name」';
  }

  @override
  String get connectionLostVideo => '連線中斷——機器人仍會把影片送到你的聊天。';

  @override
  String videoServerDown(String error) {
    return '影片伺服器目前無法使用。\n$error';
  }

  @override
  String get scene => '場景';

  @override
  String get uploading => '上傳中…';

  @override
  String get animate => '動起來';

  @override
  String get pickPhoto => '選擇照片';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '約 $seconds 秒片段 · 算圖約 $minutes 分鐘';
  }

  @override
  String queuePosition(int position) {
    return '排隊中 · 第 $position 位';
  }

  @override
  String get queueWaiting => '排隊中…';

  @override
  String get finishing => '收尾中（平滑動作）…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return '節拍 $beat/$beats · 約剩 $minutes 分鐘';
  }

  @override
  String get videoDone => '完成！影片已傳送到你的 Telegram 聊天 🎬';

  @override
  String failedDetail(String error) {
    return '失敗：$error';
  }

  @override
  String get unknownError => '未知錯誤';

  @override
  String get starting => '啟動中…';

  @override
  String get canCloseApp => '可以關閉 App——影片會送到聊天裡。';

  @override
  String get notCharged => '你的免費影片/額度沒有被扣除。';

  @override
  String get animateAnother => '再來一個';

  @override
  String get restyleHint => '保留你的臉和姿勢。使用清晰的單人正面照片效果最佳。';

  @override
  String get medium => '媒介';

  @override
  String get mediumPhoto => '照片';

  @override
  String get mediumIllustration => '插畫';

  @override
  String get style => '風格';

  @override
  String get filterStyles => '篩選風格';

  @override
  String get restyling => '更換風格中…';

  @override
  String get restyle => '更換風格';

  @override
  String get restyleBusy => '更換風格中…約一分鐘。\n圖片也會傳到你的聊天。';

  @override
  String get groupPopular => '熱門';

  @override
  String get groupPainters => '畫家';

  @override
  String get groupAsia => '亞洲';

  @override
  String get groupEurope => '歐洲';

  @override
  String get groupAmericasOceania => '美洲與大洋洲';

  @override
  String get groupAfricaNearEast => '非洲與近東';

  @override
  String get hairHint => '保留你的臉，除非你選擇新顏色，否則髮色也維持不變。最適合頭髮完整可見、不戴帽子的正面人像。';

  @override
  String get noHairstyles => '暫無髮型——請稍後再來。';

  @override
  String get colour => '顏色';

  @override
  String get keepMine => '保持原樣';

  @override
  String get haircut => '髮型';

  @override
  String get keepMyCut => '保持我的髮型';

  @override
  String get working => '處理中…';

  @override
  String get newColour => '新顏色';

  @override
  String get newHaircut => '新髮型';

  @override
  String get pickPortrait => '選擇人像';

  @override
  String get hairBusy => '處理中…約一分鐘。\n照片也會傳到你的聊天。';

  @override
  String get hairWomen => '女士';

  @override
  String get hairMen => '男士';

  @override
  String get hairCuts => '剪裁';

  @override
  String get hairBangs => '瀏海';

  @override
  String get hairTexture => '髮質紋理';

  @override
  String get hairShort => '短髮';

  @override
  String get hairMedium => '中長髮';

  @override
  String get hairLong => '長髮';

  @override
  String get hairBraids => '辮子';

  @override
  String get hairUpdos => '盤髮';

  @override
  String get notDownloaded => '圖片尚未下載';

  @override
  String get savedToGallery => '已儲存到相簿';

  @override
  String couldNotSave(String error) {
    return '無法儲存：$error';
  }

  @override
  String get result => '結果';

  @override
  String get saveToGallery => '儲存到相簿';

  @override
  String get copyPrompt => '拷貝提示詞';

  @override
  String get promptCopied => '提示詞已拷貝';

  @override
  String get imageNotAvailable => '圖片無法使用';

  @override
  String get promptUsed => '使用的提示詞：';

  @override
  String get revisedPrompt => '改寫後的提示詞（Grok）：';

  @override
  String couldNotLoad(String error) {
    return '無法載入：$error';
  }

  @override
  String get generation => '生成';

  @override
  String get generationWebInfo =>
      '圖片由 Tsumiki 機器人（ComfyUI）生成。完成的圖片也會傳送到你與機器人的聊天。';

  @override
  String get workflow => '工作流程';

  @override
  String get generationBackend => '生成後端';

  @override
  String get xaiInfo => '來自 console.x.ai 的 API 金鑰，用於透過 Grok 生成。';

  @override
  String get apiKey => 'API 金鑰';

  @override
  String get ol1nInfo =>
      '本機 AiStack（Flux diffusers API）。輸入 CF Access 服務權杖；若已在建置時內建（--dart-define），可留空。';

  @override
  String get comfyInfo => '本機 ComfyUI（下方選擇模型）。與 llm.ol1n.com 共用 CF Access 權杖。';

  @override
  String get save => '儲存';

  @override
  String get saved => '已儲存';

  @override
  String get wfAuto => '自動——跟隨所選範本';

  @override
  String get wfFlux => 'Flux——繪畫風與寫實風格';

  @override
  String get wfPony => 'Pony Diffusion——動漫，Danbooru 標籤';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning——快速寫實';

  @override
  String get wfWai => 'WAI Illustrious——動漫，比 Pony 更新';

  @override
  String templateChose(String workflow) {
    return '範本選擇了：$workflow';
  }

  @override
  String get apiKeySaved => 'API 金鑰已儲存';

  @override
  String get reposeScreenTitle => 'Repose——擺姿勢的臉';

  @override
  String get model => '模型';

  @override
  String get stepFace => '1. 臉';

  @override
  String get stepPose => '2. 姿勢';

  @override
  String get stepPrompt => '3. 提示詞';

  @override
  String get negative => '負面';

  @override
  String get reposePromptHint => '一位女性的照片，全身，自然光…';

  @override
  String couldNotLoadModels(String error) {
    return '無法載入模型：$error';
  }

  @override
  String get noModels => '沒有模型（請在設定中檢查 CF 憑證）。';

  @override
  String get uploadFace => '上傳人臉';

  @override
  String get changeFace => '更換人臉';

  @override
  String get pickFromGallery => '從相簿選擇';

  @override
  String get takePhoto => '拍照';

  @override
  String get needCfCredentials => '請在設定中填寫 Cloudflare Access 憑證';

  @override
  String get baseImageSelected => '已選擇底圖';

  @override
  String get baseImageOptional => '底圖（選填）';

  @override
  String get remove => '移除';

  @override
  String get prompt => '提示詞';

  @override
  String get modelAutoTooltip => '模型已根據範本自動選擇。\n可在設定中變更。';

  @override
  String get modelManualTooltip => '在設定中手動選擇的模型。';

  @override
  String get pickBlocks => '選擇積木以組合提示詞...';
}
