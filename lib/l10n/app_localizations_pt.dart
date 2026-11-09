// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get screenBuilder => 'Construtor de prompts';

  @override
  String get screenRestyle => 'Mudar o estilo de uma foto';

  @override
  String get screenHair => 'Experimentar um corte de cabelo';

  @override
  String get screenAnimate => 'Animar uma foto';

  @override
  String get settings => 'Ajustes';

  @override
  String get shopTooltipVideo => 'Créditos de animação e pacotes';

  @override
  String get shopTooltip => 'Créditos e pacotes';

  @override
  String get switchCard => 'Trocar de cartão';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos de animação adicionados 🎉',
      one: '1 crédito de animação adicionado 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos adicionados 🎉',
      one: '1 crédito adicionado 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'O pagamento falhou, tente novamente';

  @override
  String errorDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Não foi possível carregar os créditos: $error';
  }

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get animationsTitle => 'Animações';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animações grátis hoje: $free de $limit · créditos de animação: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Gerações grátis hoje: $free de $limit · créditos: $credits';
  }

  @override
  String get videoPriceNote => '1 crédito = 1 vídeo, pago com Telegram Stars.';

  @override
  String get imagePriceNote => '1 crédito = 1 imagem, paga com Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos',
      one: '1 crédito',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animações',
      one: '1 animação',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'O Repose não está disponível na web';

  @override
  String get reposeTooltip => 'Repose (rosto em uma pose)';

  @override
  String get presets => 'Predefinições';

  @override
  String get template => 'Modelo';

  @override
  String get backToTop => 'Voltar ao topo';

  @override
  String get generating => 'Gerando…';

  @override
  String get generate => 'Gerar';

  @override
  String get needCredentials =>
      'Defina uma chave de API ou credenciais nos Ajustes';

  @override
  String presetLoaded(String name) {
    return 'Predefinição “$name” carregada';
  }

  @override
  String get connectionLostVideo =>
      'Conexão perdida — o bot ainda entregará o vídeo no seu chat.';

  @override
  String videoServerDown(String error) {
    return 'O servidor de vídeo está indisponível no momento.\n$error';
  }

  @override
  String get scene => 'Cena';

  @override
  String get uploading => 'Enviando…';

  @override
  String get animate => 'Animar';

  @override
  String get pickPhoto => 'Escolher uma foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clipe de ~$seconds s · ~$minutes min de renderização';
  }

  @override
  String queuePosition(int position) {
    return 'Na fila · posição $position';
  }

  @override
  String get queueWaiting => 'Na fila…';

  @override
  String get finishing => 'Finalizando (suavizando o movimento)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Tempo $beat/$beats · faltam ~$minutes min';
  }

  @override
  String get videoDone =>
      'Pronto! O vídeo foi enviado ao seu chat do Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Falhou: $error';
  }

  @override
  String get unknownError => 'erro desconhecido';

  @override
  String get starting => 'Iniciando…';

  @override
  String get canCloseApp => 'Você pode fechar o app — o vídeo chega no chat.';

  @override
  String get notCharged => 'Seu vídeo grátis / crédito não foi gasto.';

  @override
  String get animateAnother => 'Animar outra';

  @override
  String get restyleHint =>
      'Mantém seu rosto e sua pose. Funciona melhor com uma foto nítida, de frente, de uma única pessoa.';

  @override
  String get medium => 'Meio';

  @override
  String get mediumPhoto => 'Foto';

  @override
  String get mediumIllustration => 'Ilustração';

  @override
  String get style => 'Estilo';

  @override
  String get filterStyles => 'Filtrar estilos';

  @override
  String get restyling => 'Mudando o estilo…';

  @override
  String get restyle => 'Mudar o estilo';

  @override
  String get restyleBusy =>
      'Mudando o estilo… cerca de um minuto.\nA imagem também chega ao seu chat.';

  @override
  String get groupPopular => 'Populares';

  @override
  String get groupPainters => 'Pintores';

  @override
  String get groupAsia => 'Ásia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Américas e Oceania';

  @override
  String get groupAfricaNearEast => 'África e Oriente Próximo';

  @override
  String get hairHint =>
      'Mantém seu rosto e a cor do cabelo, a menos que você escolha outra. Funciona melhor com um retrato de frente, cabelo totalmente visível, sem boné.';

  @override
  String get noHairstyles => 'Ainda não há penteados — volte em breve.';

  @override
  String get colour => 'Cor';

  @override
  String get keepMine => 'Manter a minha';

  @override
  String get haircut => 'Corte';

  @override
  String get keepMyCut => 'Manter meu corte';

  @override
  String get working => 'Processando…';

  @override
  String get newColour => 'Nova cor';

  @override
  String get newHaircut => 'Novo corte';

  @override
  String get pickPortrait => 'Escolher um retrato';

  @override
  String get hairBusy =>
      'Processando… cerca de um minuto.\nA foto também chega ao seu chat.';

  @override
  String get hairWomen => 'Feminino';

  @override
  String get hairMen => 'Masculino';

  @override
  String get hairCuts => 'Cortes';

  @override
  String get hairBangs => 'Franja';

  @override
  String get hairTexture => 'Textura';

  @override
  String get hairShort => 'Curto';

  @override
  String get hairMedium => 'Médio';

  @override
  String get hairLong => 'Longo';

  @override
  String get hairBraids => 'Tranças';

  @override
  String get hairUpdos => 'Penteados presos';

  @override
  String get notDownloaded => 'A imagem ainda não foi baixada';

  @override
  String get savedToGallery => 'Salva na galeria';

  @override
  String couldNotSave(String error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get result => 'Resultado';

  @override
  String get saveToGallery => 'Salvar na galeria';

  @override
  String get copyPrompt => 'Copiar prompt';

  @override
  String get promptCopied => 'Prompt copiado';

  @override
  String get imageNotAvailable => 'Imagem indisponível';

  @override
  String get promptUsed => 'Prompt usado:';

  @override
  String get revisedPrompt => 'Prompt revisado (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Não foi possível carregar: $error';
  }

  @override
  String get generation => 'Geração';

  @override
  String get generationWebInfo =>
      'As imagens são geradas pelo bot Tsumiki (ComfyUI). A imagem pronta também é enviada ao seu chat com o bot.';

  @override
  String get workflow => 'Fluxo de trabalho';

  @override
  String get generationBackend => 'Backend de geração';

  @override
  String get xaiInfo => 'Chave de API de console.x.ai para gerar com o Grok.';

  @override
  String get apiKey => 'Chave de API';

  @override
  String get ol1nInfo =>
      'AiStack local (API Flux diffusers). Informe um token de serviço do CF Access ou deixe vazio se ele estiver embutido no build (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI local (escolha do modelo abaixo). Compartilha o token do CF Access com llm.ol1n.com.';

  @override
  String get save => 'Salvar';

  @override
  String get saved => 'Salvo';

  @override
  String get wfAuto => 'Automático — seguir o modelo escolhido';

  @override
  String get wfFlux => 'Flux — estilos pictóricos e fotorrealistas';

  @override
  String get wfPony => 'Pony Diffusion — anime, tags Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — fotorrealismo rápido';

  @override
  String get wfWai => 'WAI Illustrious — anime, mais novo que o Pony';

  @override
  String templateChose(String workflow) {
    return 'O modelo escolheu: $workflow';
  }

  @override
  String get apiKeySaved => 'Chave de API salva';

  @override
  String get reposeScreenTitle => 'Repose — rosto em uma pose';

  @override
  String get model => 'Modelo';

  @override
  String get stepFace => '1. Rosto';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIVO';

  @override
  String get reposePromptHint =>
      'foto de uma mulher, corpo inteiro, luz natural…';

  @override
  String couldNotLoadModels(String error) {
    return 'Não foi possível carregar os modelos: $error';
  }

  @override
  String get noModels =>
      'Nenhum modelo (verifique as credenciais do CF nos Ajustes).';

  @override
  String get uploadFace => 'Enviar um rosto';

  @override
  String get changeFace => 'Trocar rosto';

  @override
  String get pickFromGallery => 'Escolher da galeria';

  @override
  String get takePhoto => 'Tirar uma foto';

  @override
  String get needCfCredentials =>
      'Defina as credenciais do Cloudflare Access nos Ajustes';

  @override
  String get baseImageSelected => 'Imagem base selecionada';

  @override
  String get baseImageOptional => 'Imagem base (opcional)';

  @override
  String get remove => 'Remover';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modelo escolhido automaticamente pelo modelo de prompt.\nVocê pode mudar nos Ajustes.';

  @override
  String get modelManualTooltip => 'Modelo escolhido manualmente nos Ajustes.';

  @override
  String get pickBlocks => 'Escolha blocos para montar um prompt...';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get screenBuilder => 'Construtor de prompts';

  @override
  String get screenRestyle => 'Mudar o estilo de uma foto';

  @override
  String get screenHair => 'Experimentar um corte de cabelo';

  @override
  String get screenAnimate => 'Animar uma foto';

  @override
  String get settings => 'Definições';

  @override
  String get shopTooltipVideo => 'Créditos de animação e pacotes';

  @override
  String get shopTooltip => 'Créditos e pacotes';

  @override
  String get switchCard => 'Mudar de cartão';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos de animação adicionados 🎉',
      one: '1 crédito de animação adicionado 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos adicionados 🎉',
      one: '1 crédito adicionado 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'O pagamento falhou, tenta novamente';

  @override
  String errorDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Não foi possível carregar os créditos: $error';
  }

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get animationsTitle => 'Animações';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Animações grátis hoje: $free de $limit · créditos de animação: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Gerações grátis hoje: $free de $limit · créditos: $credits';
  }

  @override
  String get videoPriceNote => '1 crédito = 1 vídeo, pago com Telegram Stars.';

  @override
  String get imagePriceNote => '1 crédito = 1 imagem, paga com Telegram Stars.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos',
      one: '1 crédito',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animações',
      one: '1 animação',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'O Repose não está disponível na web';

  @override
  String get reposeTooltip => 'Repose (rosto numa pose)';

  @override
  String get presets => 'Predefinições';

  @override
  String get template => 'Modelo';

  @override
  String get backToTop => 'Voltar ao topo';

  @override
  String get generating => 'A gerar…';

  @override
  String get generate => 'Gerar';

  @override
  String get needCredentials =>
      'Define uma chave de API ou credenciais nas Definições';

  @override
  String presetLoaded(String name) {
    return 'Predefinição «$name» carregada';
  }

  @override
  String get connectionLostVideo =>
      'Ligação perdida — o bot ainda entregará o vídeo no teu chat.';

  @override
  String videoServerDown(String error) {
    return 'O servidor de vídeo está indisponível neste momento.\n$error';
  }

  @override
  String get scene => 'Cena';

  @override
  String get uploading => 'A enviar…';

  @override
  String get animate => 'Animar';

  @override
  String get pickPhoto => 'Escolher uma foto';

  @override
  String sceneInfo(int seconds, int minutes) {
    return 'clipe de ~$seconds s · ~$minutes min de renderização';
  }

  @override
  String queuePosition(int position) {
    return 'Na fila · posição $position';
  }

  @override
  String get queueWaiting => 'Na fila…';

  @override
  String get finishing => 'A finalizar (a suavizar o movimento)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Tempo $beat/$beats · faltam ~$minutes min';
  }

  @override
  String get videoDone =>
      'Pronto! O vídeo foi enviado para o teu chat do Telegram 🎬';

  @override
  String failedDetail(String error) {
    return 'Falhou: $error';
  }

  @override
  String get unknownError => 'erro desconhecido';

  @override
  String get starting => 'A iniciar…';

  @override
  String get canCloseApp => 'Podes fechar a app — o vídeo chega ao chat.';

  @override
  String get notCharged => 'O teu vídeo grátis / crédito não foi gasto.';

  @override
  String get animateAnother => 'Animar outra';

  @override
  String get restyleHint =>
      'Mantém o teu rosto e a tua pose. Funciona melhor com uma fotografia nítida, de frente, de uma só pessoa.';

  @override
  String get medium => 'Meio';

  @override
  String get mediumPhoto => 'Fotografia';

  @override
  String get mediumIllustration => 'Ilustração';

  @override
  String get style => 'Estilo';

  @override
  String get filterStyles => 'Filtrar estilos';

  @override
  String get restyling => 'A mudar o estilo…';

  @override
  String get restyle => 'Mudar o estilo';

  @override
  String get restyleBusy =>
      'A mudar o estilo… cerca de um minuto.\nA imagem também chega ao teu chat.';

  @override
  String get groupPopular => 'Populares';

  @override
  String get groupPainters => 'Pintores';

  @override
  String get groupAsia => 'Ásia';

  @override
  String get groupEurope => 'Europa';

  @override
  String get groupAmericasOceania => 'Américas e Oceânia';

  @override
  String get groupAfricaNearEast => 'África e Médio Oriente';

  @override
  String get hairHint =>
      'Mantém o teu rosto e a cor do cabelo, a menos que escolhas outra. Funciona melhor com um retrato de frente, cabelo totalmente visível, sem boné.';

  @override
  String get noHairstyles => 'Ainda não há penteados — volta em breve.';

  @override
  String get colour => 'Cor';

  @override
  String get keepMine => 'Manter a minha';

  @override
  String get haircut => 'Corte';

  @override
  String get keepMyCut => 'Manter o meu corte';

  @override
  String get working => 'A processar…';

  @override
  String get newColour => 'Nova cor';

  @override
  String get newHaircut => 'Novo corte';

  @override
  String get pickPortrait => 'Escolher um retrato';

  @override
  String get hairBusy =>
      'A processar… cerca de um minuto.\nA fotografia também chega ao teu chat.';

  @override
  String get hairWomen => 'Mulher';

  @override
  String get hairMen => 'Homem';

  @override
  String get hairCuts => 'Cortes';

  @override
  String get hairBangs => 'Franja';

  @override
  String get hairTexture => 'Textura';

  @override
  String get hairShort => 'Curto';

  @override
  String get hairMedium => 'Médio';

  @override
  String get hairLong => 'Longo';

  @override
  String get hairBraids => 'Tranças';

  @override
  String get hairUpdos => 'Apanhados';

  @override
  String get notDownloaded => 'A imagem ainda não foi transferida';

  @override
  String get savedToGallery => 'Guardada na galeria';

  @override
  String couldNotSave(String error) {
    return 'Não foi possível guardar: $error';
  }

  @override
  String get result => 'Resultado';

  @override
  String get saveToGallery => 'Guardar na galeria';

  @override
  String get copyPrompt => 'Copiar prompt';

  @override
  String get promptCopied => 'Prompt copiado';

  @override
  String get imageNotAvailable => 'Imagem indisponível';

  @override
  String get promptUsed => 'Prompt usado:';

  @override
  String get revisedPrompt => 'Prompt revisto (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Não foi possível carregar: $error';
  }

  @override
  String get generation => 'Geração';

  @override
  String get generationWebInfo =>
      'As imagens são geradas pelo bot Tsumiki (ComfyUI). A imagem pronta também é enviada para o teu chat com o bot.';

  @override
  String get workflow => 'Fluxo de trabalho';

  @override
  String get generationBackend => 'Backend de geração';

  @override
  String get xaiInfo => 'Chave de API de console.x.ai para gerar com o Grok.';

  @override
  String get apiKey => 'Chave de API';

  @override
  String get ol1nInfo =>
      'AiStack local (API Flux diffusers). Introduz um token de serviço do CF Access ou deixa vazio se estiver incluído na compilação (--dart-define).';

  @override
  String get comfyInfo =>
      'ComfyUI local (escolha do modelo abaixo). Partilha o token do CF Access com llm.ol1n.com.';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get wfAuto => 'Automático — seguir o modelo escolhido';

  @override
  String get wfFlux => 'Flux — estilos pictóricos e fotorrealistas';

  @override
  String get wfPony => 'Pony Diffusion — anime, etiquetas Danbooru';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — fotorrealismo rápido';

  @override
  String get wfWai => 'WAI Illustrious — anime, mais recente que o Pony';

  @override
  String templateChose(String workflow) {
    return 'O modelo escolheu: $workflow';
  }

  @override
  String get apiKeySaved => 'Chave de API guardada';

  @override
  String get reposeScreenTitle => 'Repose — rosto numa pose';

  @override
  String get model => 'Modelo';

  @override
  String get stepFace => '1. Rosto';

  @override
  String get stepPose => '2. Pose';

  @override
  String get stepPrompt => '3. Prompt';

  @override
  String get negative => 'NEGATIVO';

  @override
  String get reposePromptHint =>
      'fotografia de uma mulher, corpo inteiro, luz natural…';

  @override
  String couldNotLoadModels(String error) {
    return 'Não foi possível carregar os modelos: $error';
  }

  @override
  String get noModels =>
      'Sem modelos (verifica as credenciais do CF nas Definições).';

  @override
  String get uploadFace => 'Enviar um rosto';

  @override
  String get changeFace => 'Mudar de rosto';

  @override
  String get pickFromGallery => 'Escolher da galeria';

  @override
  String get takePhoto => 'Tirar uma fotografia';

  @override
  String get needCfCredentials =>
      'Define as credenciais do Cloudflare Access nas Definições';

  @override
  String get baseImageSelected => 'Imagem base selecionada';

  @override
  String get baseImageOptional => 'Imagem base (opcional)';

  @override
  String get remove => 'Remover';

  @override
  String get prompt => 'Prompt';

  @override
  String get modelAutoTooltip =>
      'Modelo escolhido automaticamente pelo modelo de prompt.\nPodes mudá-lo nas Definições.';

  @override
  String get modelManualTooltip =>
      'Modelo escolhido manualmente nas Definições.';

  @override
  String get pickBlocks => 'Escolhe blocos para montar um prompt...';
}
