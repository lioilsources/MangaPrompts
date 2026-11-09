// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get screenBuilder => 'プロンプトビルダー';

  @override
  String get screenRestyle => '写真のスタイル変更';

  @override
  String get screenHair => 'ヘアスタイルを試す';

  @override
  String get screenAnimate => '写真をアニメーション化';

  @override
  String get settings => '設定';

  @override
  String get shopTooltipVideo => 'アニメクレジットとパッケージ';

  @override
  String get shopTooltip => 'クレジットとパッケージ';

  @override
  String get switchCard => 'カードを切り替え';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アニメクレジットを$count追加しました 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'クレジットを$count追加しました 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => '支払いに失敗しました。もう一度お試しください';

  @override
  String errorDetail(String error) {
    return 'エラー: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'クレジットを読み込めませんでした: $error';
  }

  @override
  String get tryAgain => 'もう一度試す';

  @override
  String get animationsTitle => 'アニメーション';

  @override
  String get creditsTitle => 'クレジット';

  @override
  String videoQuota(int free, int limit, int credits) {
    return '今日の無料アニメ: $free/$limit · アニメクレジット: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return '今日の無料生成: $free/$limit · クレジット: $credits';
  }

  @override
  String get videoPriceNote => '1クレジット = 動画1本、Telegram Starsで支払い。';

  @override
  String get imagePriceNote => '1クレジット = 画像1枚、Telegram Starsで支払い。';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countクレジット',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アニメ$count本',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Reposeはウェブでは利用できません';

  @override
  String get reposeTooltip => 'Repose（ポーズ付きの顔）';

  @override
  String get presets => 'プリセット';

  @override
  String get template => 'テンプレート';

  @override
  String get backToTop => 'トップへ戻る';

  @override
  String get generating => '生成中…';

  @override
  String get generate => '生成';

  @override
  String get needCredentials => '設定でAPIキーまたは認証情報を入力してください';

  @override
  String presetLoaded(String name) {
    return 'プリセット「$name」を読み込みました';
  }

  @override
  String get connectionLostVideo => '接続が切れました。ボットが動画をチャットに届けます。';

  @override
  String videoServerDown(String error) {
    return '動画サーバーは現在利用できません。\n$error';
  }

  @override
  String get scene => 'シーン';

  @override
  String get uploading => 'アップロード中…';

  @override
  String get animate => 'アニメーション化';

  @override
  String get pickPhoto => '写真を選択';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '約$seconds秒のクリップ · レンダリング約$minutes分';
  }

  @override
  String queuePosition(int position) {
    return '順番待ち · $position番目';
  }

  @override
  String get queueWaiting => '順番待ち…';

  @override
  String get finishing => '仕上げ中（動きを滑らかにしています）…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'ビート $beat/$beats · 残り約$minutes分';
  }

  @override
  String get videoDone => '完了！動画をTelegramのチャットに送信しました 🎬';

  @override
  String failedDetail(String error) {
    return '失敗しました: $error';
  }

  @override
  String get unknownError => '不明なエラー';

  @override
  String get starting => '開始中…';

  @override
  String get canCloseApp => 'アプリを閉じても大丈夫です。動画はチャットに届きます。';

  @override
  String get notCharged => '無料動画/クレジットは消費されていません。';

  @override
  String get animateAnother => '別の写真をアニメ化';

  @override
  String get restyleHint => '顔とポーズはそのままです。1人が写った鮮明な正面写真が最適です。';

  @override
  String get medium => '表現形式';

  @override
  String get mediumPhoto => '写真';

  @override
  String get mediumIllustration => 'イラスト';

  @override
  String get style => 'スタイル';

  @override
  String get filterStyles => 'スタイルを絞り込む';

  @override
  String get restyling => 'スタイル変更中…';

  @override
  String get restyle => 'スタイル変更';

  @override
  String get restyleBusy => 'スタイル変更中… 約1分。\n画像はチャットにも届きます。';

  @override
  String get groupPopular => '人気';

  @override
  String get groupPainters => '画家';

  @override
  String get groupAsia => 'アジア';

  @override
  String get groupEurope => 'ヨーロッパ';

  @override
  String get groupAmericasOceania => '南北アメリカ・オセアニア';

  @override
  String get groupAfricaNearEast => 'アフリカ・中東';

  @override
  String get hairHint =>
      '顔はそのまま、新しい色を選ばない限り髪色もそのままです。髪全体が見える、帽子なしの正面ポートレートが最適です。';

  @override
  String get noHairstyles => 'ヘアスタイルはまだありません。また後でお試しください。';

  @override
  String get colour => 'カラー';

  @override
  String get keepMine => '今のまま';

  @override
  String get haircut => 'ヘアカット';

  @override
  String get keepMyCut => '今のカットのまま';

  @override
  String get working => '処理中…';

  @override
  String get newColour => '新しいカラー';

  @override
  String get newHaircut => '新しいヘアカット';

  @override
  String get pickPortrait => 'ポートレートを選択';

  @override
  String get hairBusy => '処理中… 約1分。\n写真はチャットにも届きます。';

  @override
  String get hairWomen => 'レディース';

  @override
  String get hairMen => 'メンズ';

  @override
  String get hairCuts => 'カット';

  @override
  String get hairBangs => '前髪';

  @override
  String get hairTexture => '質感';

  @override
  String get hairShort => 'ショート';

  @override
  String get hairMedium => 'ミディアム';

  @override
  String get hairLong => 'ロング';

  @override
  String get hairBraids => '三つ編み';

  @override
  String get hairUpdos => 'アップスタイル';

  @override
  String get notDownloaded => '画像はまだダウンロードされていません';

  @override
  String get savedToGallery => 'ギャラリーに保存しました';

  @override
  String couldNotSave(String error) {
    return '保存できませんでした: $error';
  }

  @override
  String get result => '結果';

  @override
  String get saveToGallery => 'ギャラリーに保存';

  @override
  String get copyPrompt => 'プロンプトをコピー';

  @override
  String get promptCopied => 'プロンプトをコピーしました';

  @override
  String get imageNotAvailable => '画像を表示できません';

  @override
  String get promptUsed => '使用したプロンプト:';

  @override
  String get revisedPrompt => '修正されたプロンプト（Grok）:';

  @override
  String couldNotLoad(String error) {
    return '読み込めませんでした: $error';
  }

  @override
  String get generation => '生成';

  @override
  String get generationWebInfo =>
      '画像はTsumikiボット（ComfyUI）が生成します。完成した画像はボットとのチャットにも送信されます。';

  @override
  String get workflow => 'ワークフロー';

  @override
  String get generationBackend => '生成バックエンド';

  @override
  String get xaiInfo => 'Grokで生成するためのconsole.x.aiのAPIキー。';

  @override
  String get apiKey => 'APIキー';

  @override
  String get ol1nInfo =>
      'ローカルAiStack（Flux diffusers API）。CF Accessサービストークンを入力するか、ビルド時に組み込み済み（--dart-define）なら空欄のままにします。';

  @override
  String get comfyInfo =>
      'ローカルComfyUI（モデルは下で選択）。CF Accessトークンはllm.ol1n.comと共有します。';

  @override
  String get save => '保存';

  @override
  String get saved => '保存しました';

  @override
  String get wfAuto => '自動 — 選択したテンプレートに従う';

  @override
  String get wfFlux => 'Flux — 絵画風・フォトリアル';

  @override
  String get wfPony => 'Pony Diffusion — アニメ、Danbooruタグ';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — 高速フォトリアル';

  @override
  String get wfWai => 'WAI Illustrious — アニメ、Ponyより新しい';

  @override
  String templateChose(String workflow) {
    return 'テンプレートの選択: $workflow';
  }

  @override
  String get apiKeySaved => 'APIキーを保存しました';

  @override
  String get reposeScreenTitle => 'Repose — ポーズ付きの顔';

  @override
  String get model => 'モデル';

  @override
  String get stepFace => '1. 顔';

  @override
  String get stepPose => '2. ポーズ';

  @override
  String get stepPrompt => '3. プロンプト';

  @override
  String get negative => 'ネガティブ';

  @override
  String get reposePromptHint => '女性の写真、全身、自然光…';

  @override
  String couldNotLoadModels(String error) {
    return 'モデルを読み込めませんでした: $error';
  }

  @override
  String get noModels => 'モデルがありません（設定でCFの認証情報を確認してください）。';

  @override
  String get uploadFace => '顔をアップロード';

  @override
  String get changeFace => '顔を変更';

  @override
  String get pickFromGallery => 'ギャラリーから選択';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get needCfCredentials => '設定でCloudflare Accessの認証情報を入力してください';

  @override
  String get baseImageSelected => 'ベース画像を選択しました';

  @override
  String get baseImageOptional => 'ベース画像（任意）';

  @override
  String get remove => '削除';

  @override
  String get prompt => 'プロンプト';

  @override
  String get modelAutoTooltip => 'テンプレートに応じてモデルを自動選択しました。\n設定で変更できます。';

  @override
  String get modelManualTooltip => '設定で手動選択したモデルです。';

  @override
  String get pickBlocks => 'ブロックを選んでプロンプトを組み立てましょう...';
}
