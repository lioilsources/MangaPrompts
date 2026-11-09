// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get screenBuilder => '프롬프트 빌더';

  @override
  String get screenRestyle => '사진 스타일 바꾸기';

  @override
  String get screenHair => '헤어스타일 체험';

  @override
  String get screenAnimate => '사진 움직이기';

  @override
  String get settings => '설정';

  @override
  String get shopTooltipVideo => '애니메이션 크레딧 및 패키지';

  @override
  String get shopTooltip => '크레딧 및 패키지';

  @override
  String get switchCard => '카드 전환';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '애니메이션 크레딧 $count개가 추가되었습니다 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '크레딧 $count개가 추가되었습니다 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => '결제에 실패했습니다. 다시 시도해 주세요';

  @override
  String errorDetail(String error) {
    return '오류: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return '크레딧을 불러오지 못했습니다: $error';
  }

  @override
  String get tryAgain => '다시 시도';

  @override
  String get animationsTitle => '애니메이션';

  @override
  String get creditsTitle => '크레딧';

  @override
  String videoQuota(int free, int limit, int credits) {
    return '오늘 무료 애니메이션: $free/$limit · 애니메이션 크레딧: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return '오늘 무료 생성: $free/$limit · 크레딧: $credits';
  }

  @override
  String get videoPriceNote => '1크레딧 = 동영상 1개, Telegram Stars로 결제합니다.';

  @override
  String get imagePriceNote => '1크레딧 = 이미지 1장, Telegram Stars로 결제합니다.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '크레딧 $count개',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '애니메이션 $count개',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose는 웹에서 사용할 수 없습니다';

  @override
  String get reposeTooltip => 'Repose (포즈를 취한 얼굴)';

  @override
  String get presets => '프리셋';

  @override
  String get template => '템플릿';

  @override
  String get backToTop => '맨 위로';

  @override
  String get generating => '생성 중…';

  @override
  String get generate => '생성';

  @override
  String get needCredentials => '설정에서 API 키 또는 인증 정보를 입력하세요';

  @override
  String presetLoaded(String name) {
    return '프리셋 “$name”을(를) 불러왔습니다';
  }

  @override
  String get connectionLostVideo => '연결이 끊겼습니다. 봇이 동영상을 채팅으로 보내드립니다.';

  @override
  String videoServerDown(String error) {
    return '동영상 서버를 지금 사용할 수 없습니다.\n$error';
  }

  @override
  String get scene => '장면';

  @override
  String get uploading => '업로드 중…';

  @override
  String get animate => '움직이기';

  @override
  String get pickPhoto => '사진 선택';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '약 $seconds초 클립 · 렌더링 약 $minutes분';
  }

  @override
  String queuePosition(int position) {
    return '대기 중 · $position번째';
  }

  @override
  String get queueWaiting => '대기 중…';

  @override
  String get finishing => '마무리 중 (움직임을 부드럽게 다듬는 중)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return '비트 $beat/$beats · 약 $minutes분 남음';
  }

  @override
  String get videoDone => '완료! 동영상을 Telegram 채팅으로 보냈습니다 🎬';

  @override
  String failedDetail(String error) {
    return '실패: $error';
  }

  @override
  String get unknownError => '알 수 없는 오류';

  @override
  String get starting => '시작하는 중…';

  @override
  String get canCloseApp => '앱을 닫아도 됩니다. 동영상은 채팅으로 도착합니다.';

  @override
  String get notCharged => '무료 동영상/크레딧이 차감되지 않았습니다.';

  @override
  String get animateAnother => '다른 사진 움직이기';

  @override
  String get restyleHint =>
      '얼굴과 포즈는 그대로 유지합니다. 한 사람이 선명하게 나온 정면 사진에서 가장 잘 작동합니다.';

  @override
  String get medium => '표현 방식';

  @override
  String get mediumPhoto => '사진';

  @override
  String get mediumIllustration => '일러스트';

  @override
  String get style => '스타일';

  @override
  String get filterStyles => '스타일 필터';

  @override
  String get restyling => '스타일 변경 중…';

  @override
  String get restyle => '스타일 바꾸기';

  @override
  String get restyleBusy => '스타일 변경 중… 약 1분.\n이미지는 채팅으로도 도착합니다.';

  @override
  String get groupPopular => '인기';

  @override
  String get groupPainters => '화가';

  @override
  String get groupAsia => '아시아';

  @override
  String get groupEurope => '유럽';

  @override
  String get groupAmericasOceania => '아메리카·오세아니아';

  @override
  String get groupAfricaNearEast => '아프리카·중동';

  @override
  String get hairHint =>
      '얼굴은 그대로이고, 새 색상을 고르지 않으면 머리색도 그대로입니다. 머리카락이 모두 보이는 모자 없는 정면 인물 사진이 가장 좋습니다.';

  @override
  String get noHairstyles => '아직 헤어스타일이 없습니다. 곧 다시 확인해 주세요.';

  @override
  String get colour => '색상';

  @override
  String get keepMine => '내 색 유지';

  @override
  String get haircut => '헤어컷';

  @override
  String get keepMyCut => '내 컷 유지';

  @override
  String get working => '처리 중…';

  @override
  String get newColour => '새 색상';

  @override
  String get newHaircut => '새 헤어컷';

  @override
  String get pickPortrait => '인물 사진 선택';

  @override
  String get hairBusy => '처리 중… 약 1분.\n사진은 채팅으로도 도착합니다.';

  @override
  String get hairWomen => '여성';

  @override
  String get hairMen => '남성';

  @override
  String get hairCuts => '컷';

  @override
  String get hairBangs => '앞머리';

  @override
  String get hairTexture => '질감';

  @override
  String get hairShort => '짧은 머리';

  @override
  String get hairMedium => '중간 길이';

  @override
  String get hairLong => '긴 머리';

  @override
  String get hairBraids => '땋은 머리';

  @override
  String get hairUpdos => '올림머리';

  @override
  String get notDownloaded => '이미지가 아직 다운로드되지 않았습니다';

  @override
  String get savedToGallery => '갤러리에 저장했습니다';

  @override
  String couldNotSave(String error) {
    return '저장할 수 없습니다: $error';
  }

  @override
  String get result => '결과';

  @override
  String get saveToGallery => '갤러리에 저장';

  @override
  String get copyPrompt => '프롬프트 복사';

  @override
  String get promptCopied => '프롬프트를 복사했습니다';

  @override
  String get imageNotAvailable => '이미지를 사용할 수 없습니다';

  @override
  String get promptUsed => '사용한 프롬프트:';

  @override
  String get revisedPrompt => '수정된 프롬프트 (Grok):';

  @override
  String couldNotLoad(String error) {
    return '불러올 수 없습니다: $error';
  }

  @override
  String get generation => '생성';

  @override
  String get generationWebInfo =>
      '이미지는 Tsumiki 봇(ComfyUI)이 생성합니다. 완성된 이미지는 봇과의 채팅으로도 전송됩니다.';

  @override
  String get workflow => '워크플로';

  @override
  String get generationBackend => '생성 백엔드';

  @override
  String get xaiInfo => 'Grok으로 생성하기 위한 console.x.ai의 API 키.';

  @override
  String get apiKey => 'API 키';

  @override
  String get ol1nInfo =>
      '로컬 AiStack (Flux diffusers API). CF Access 서비스 토큰을 입력하거나, 빌드에 포함되어 있으면(--dart-define) 비워 두세요.';

  @override
  String get comfyInfo =>
      '로컬 ComfyUI (모델은 아래에서 선택). CF Access 토큰은 llm.ol1n.com과 공유합니다.';

  @override
  String get save => '저장';

  @override
  String get saved => '저장됨';

  @override
  String get wfAuto => '자동 — 선택한 템플릿을 따름';

  @override
  String get wfFlux => 'Flux — 회화풍 및 사실적인 스타일';

  @override
  String get wfPony => 'Pony Diffusion — 애니메이션, Danbooru 태그';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — 빠른 실사';

  @override
  String get wfWai => 'WAI Illustrious — 애니메이션, Pony보다 최신';

  @override
  String templateChose(String workflow) {
    return '템플릿이 선택함: $workflow';
  }

  @override
  String get apiKeySaved => 'API 키를 저장했습니다';

  @override
  String get reposeScreenTitle => 'Repose — 포즈를 취한 얼굴';

  @override
  String get model => '모델';

  @override
  String get stepFace => '1. 얼굴';

  @override
  String get stepPose => '2. 포즈';

  @override
  String get stepPrompt => '3. 프롬프트';

  @override
  String get negative => '네거티브';

  @override
  String get reposePromptHint => '여성 사진, 전신, 자연광…';

  @override
  String couldNotLoadModels(String error) {
    return '모델을 불러올 수 없습니다: $error';
  }

  @override
  String get noModels => '모델이 없습니다 (설정에서 CF 인증 정보를 확인하세요).';

  @override
  String get uploadFace => '얼굴 업로드';

  @override
  String get changeFace => '얼굴 바꾸기';

  @override
  String get pickFromGallery => '갤러리에서 선택';

  @override
  String get takePhoto => '사진 촬영';

  @override
  String get needCfCredentials => '설정에서 Cloudflare Access 인증 정보를 입력하세요';

  @override
  String get baseImageSelected => '기준 이미지를 선택했습니다';

  @override
  String get baseImageOptional => '기준 이미지 (선택)';

  @override
  String get remove => '제거';

  @override
  String get prompt => '프롬프트';

  @override
  String get modelAutoTooltip => '템플릿에 따라 모델이 자동 선택되었습니다.\n설정에서 변경할 수 있습니다.';

  @override
  String get modelManualTooltip => '설정에서 직접 선택한 모델입니다.';

  @override
  String get pickBlocks => '블록을 골라 프롬프트를 조립하세요...';
}
