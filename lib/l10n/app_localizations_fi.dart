// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get screenBuilder => 'Kehoterakentaja';

  @override
  String get screenRestyle => 'Muuta kuvan tyyliä';

  @override
  String get screenHair => 'Kokeile kampausta';

  @override
  String get screenAnimate => 'Animoi kuva';

  @override
  String get settings => 'Asetukset';

  @override
  String get shopTooltipVideo => 'Animaatiokrediitit ja paketit';

  @override
  String get shopTooltip => 'Krediitit ja paketit';

  @override
  String get switchCard => 'Vaihda kortti';

  @override
  String paidVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animaatiokrediittiä lisätty 🎉',
      one: '1 animaatiokrediitti lisätty 🎉',
    );
    return '$_temp0';
  }

  @override
  String paidImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count krediittiä lisätty 🎉',
      one: '1 krediitti lisätty 🎉',
    );
    return '$_temp0';
  }

  @override
  String get paymentFailed => 'Maksu epäonnistui, yritä uudelleen';

  @override
  String errorDetail(String error) {
    return 'Virhe: $error';
  }

  @override
  String creditsLoadFailed(String error) {
    return 'Krediittien lataus epäonnistui: $error';
  }

  @override
  String get tryAgain => 'Yritä uudelleen';

  @override
  String get animationsTitle => 'Animaatiot';

  @override
  String get creditsTitle => 'Krediitit';

  @override
  String videoQuota(int free, int limit, int credits) {
    return 'Ilmaisia animaatioita tänään: $free / $limit · animaatiokrediitit: $credits';
  }

  @override
  String imageQuota(int free, int limit, int credits) {
    return 'Ilmaisia luomisia tänään: $free / $limit · krediitit: $credits';
  }

  @override
  String get videoPriceNote =>
      '1 krediitti = 1 video, maksetaan Telegram Starsilla.';

  @override
  String get imagePriceNote =>
      '1 krediitti = 1 kuva, maksetaan Telegram Starsilla.';

  @override
  String packageImages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count krediittiä',
      one: '1 krediitti',
    );
    return '$_temp0';
  }

  @override
  String packageVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animaatiota',
      one: '1 animaatio',
    );
    return '$_temp0';
  }

  @override
  String get reposeTitle => 'Repose';

  @override
  String get reposeWebUnavailable => 'Repose ei ole käytettävissä verkossa';

  @override
  String get reposeTooltip => 'Repose (kasvot asennossa)';

  @override
  String get presets => 'Esiasetukset';

  @override
  String get template => 'Malli';

  @override
  String get backToTop => 'Takaisin ylös';

  @override
  String get generating => 'Luodaan…';

  @override
  String get generate => 'Luo';

  @override
  String get needCredentials => 'Aseta API-avain tai tunnukset Asetuksissa';

  @override
  String presetLoaded(String name) {
    return 'Esiasetus ”$name” ladattu';
  }

  @override
  String get connectionLostVideo =>
      'Yhteys katkesi — botti toimittaa videon silti keskusteluusi.';

  @override
  String videoServerDown(String error) {
    return 'Videopalvelin ei ole nyt käytettävissä.\n$error';
  }

  @override
  String get scene => 'Kohtaus';

  @override
  String get uploading => 'Ladataan…';

  @override
  String get animate => 'Animoi';

  @override
  String get pickPhoto => 'Valitse kuva';

  @override
  String sceneInfo(int seconds, int minutes) {
    return '~$seconds s klippi · ~$minutes min renderöinti';
  }

  @override
  String queuePosition(int position) {
    return 'Jonossa · sija $position';
  }

  @override
  String get queueWaiting => 'Jonossa…';

  @override
  String get finishing => 'Viimeistellään (tasoitetaan liikettä)…';

  @override
  String beatProgress(int beat, int beats, int minutes) {
    return 'Isku $beat/$beats · ~$minutes min jäljellä';
  }

  @override
  String get videoDone => 'Valmis! Video lähetettiin Telegram-keskusteluusi 🎬';

  @override
  String failedDetail(String error) {
    return 'Epäonnistui: $error';
  }

  @override
  String get unknownError => 'tuntematon virhe';

  @override
  String get starting => 'Käynnistyy…';

  @override
  String get canCloseApp =>
      'Voit sulkea sovelluksen — video tulee keskusteluun.';

  @override
  String get notCharged => 'Ilmaista videotasi / krediittiäsi ei käytetty.';

  @override
  String get animateAnother => 'Animoi toinen';

  @override
  String get restyleHint =>
      'Säilyttää kasvosi ja asentosi. Toimii parhaiten selkeällä, edestä otetulla kuvalla yhdestä henkilöstä.';

  @override
  String get medium => 'Väline';

  @override
  String get mediumPhoto => 'Valokuva';

  @override
  String get mediumIllustration => 'Piirros';

  @override
  String get style => 'Tyyli';

  @override
  String get filterStyles => 'Suodata tyylejä';

  @override
  String get restyling => 'Muutetaan tyyliä…';

  @override
  String get restyle => 'Muuta tyyliä';

  @override
  String get restyleBusy =>
      'Muutetaan tyyliä… noin minuutti.\nKuva tulee myös keskusteluusi.';

  @override
  String get groupPopular => 'Suositut';

  @override
  String get groupPainters => 'Taidemaalarit';

  @override
  String get groupAsia => 'Aasia';

  @override
  String get groupEurope => 'Eurooppa';

  @override
  String get groupAmericasOceania => 'Amerikka ja Oseania';

  @override
  String get groupAfricaNearEast => 'Afrikka ja Lähi-itä';

  @override
  String get hairHint =>
      'Säilyttää kasvosi ja hiustesi värin, ellet valitse uutta. Toimii parhaiten edestä otetulla muotokuvalla, jossa hiukset näkyvät kokonaan eikä ole lakkia.';

  @override
  String get noHairstyles => 'Ei vielä kampauksia — tule pian takaisin.';

  @override
  String get colour => 'Väri';

  @override
  String get keepMine => 'Säilytä omani';

  @override
  String get haircut => 'Kampaus';

  @override
  String get keepMyCut => 'Säilytä oma kampaukseni';

  @override
  String get working => 'Työstetään…';

  @override
  String get newColour => 'Uusi väri';

  @override
  String get newHaircut => 'Uusi kampaus';

  @override
  String get pickPortrait => 'Valitse muotokuva';

  @override
  String get hairBusy =>
      'Työstetään… noin minuutti.\nKuva tulee myös keskusteluusi.';

  @override
  String get hairWomen => 'Naiset';

  @override
  String get hairMen => 'Miehet';

  @override
  String get hairCuts => 'Leikkaukset';

  @override
  String get hairBangs => 'Otsatukka';

  @override
  String get hairTexture => 'Rakenne';

  @override
  String get hairShort => 'Lyhyt';

  @override
  String get hairMedium => 'Keskipitkä';

  @override
  String get hairLong => 'Pitkä';

  @override
  String get hairBraids => 'Letit';

  @override
  String get hairUpdos => 'Kiinnitetyt kampaukset';

  @override
  String get notDownloaded => 'Kuvaa ei ole vielä ladattu';

  @override
  String get savedToGallery => 'Tallennettu galleriaan';

  @override
  String couldNotSave(String error) {
    return 'Tallennus epäonnistui: $error';
  }

  @override
  String get result => 'Tulos';

  @override
  String get saveToGallery => 'Tallenna galleriaan';

  @override
  String get copyPrompt => 'Kopioi kehote';

  @override
  String get promptCopied => 'Kehote kopioitu';

  @override
  String get imageNotAvailable => 'Kuva ei ole saatavilla';

  @override
  String get promptUsed => 'Käytetty kehote:';

  @override
  String get revisedPrompt => 'Muokattu kehote (Grok):';

  @override
  String couldNotLoad(String error) {
    return 'Lataus epäonnistui: $error';
  }

  @override
  String get generation => 'Luominen';

  @override
  String get generationWebInfo =>
      'Kuvat luo Tsumiki-botti (ComfyUI). Valmis kuva lähetetään myös keskusteluusi botin kanssa.';

  @override
  String get workflow => 'Työnkulku';

  @override
  String get generationBackend => 'Luomisen taustajärjestelmä';

  @override
  String get xaiInfo =>
      'API-avain osoitteesta console.x.ai luomiseen Grokilla.';

  @override
  String get apiKey => 'API-avain';

  @override
  String get ol1nInfo =>
      'Paikallinen AiStack (Flux diffusers -rajapinta). Syötä CF Access -palvelutunniste tai jätä tyhjäksi, jos se on sisäänrakennettu (--dart-define).';

  @override
  String get comfyInfo =>
      'Paikallinen ComfyUI (mallin valinta alla). Jakaa CF Access -tunnisteen osoitteen llm.ol1n.com kanssa.';

  @override
  String get save => 'Tallenna';

  @override
  String get saved => 'Tallennettu';

  @override
  String get wfAuto => 'Automaattinen — seuraa valittua mallia';

  @override
  String get wfFlux => 'Flux — maalauksellisia ja valokuvamaisia tyylejä';

  @override
  String get wfPony => 'Pony Diffusion — anime, Danbooru-tunnisteet';

  @override
  String get wfJuggernaut => 'Juggernaut XL Lightning — nopea valokuvarealismi';

  @override
  String get wfWai => 'WAI Illustrious — anime, Ponya uudempi';

  @override
  String templateChose(String workflow) {
    return 'Malli valitsi: $workflow';
  }

  @override
  String get apiKeySaved => 'API-avain tallennettu';

  @override
  String get reposeScreenTitle => 'Repose — kasvot asennossa';

  @override
  String get model => 'Malli';

  @override
  String get stepFace => '1. Kasvot';

  @override
  String get stepPose => '2. Asento';

  @override
  String get stepPrompt => '3. Kehote';

  @override
  String get negative => 'NEGATIIVINEN';

  @override
  String get reposePromptHint =>
      'valokuva naisesta, koko vartalo, luonnonvalo…';

  @override
  String couldNotLoadModels(String error) {
    return 'Mallien lataus epäonnistui: $error';
  }

  @override
  String get noModels => 'Ei malleja (tarkista CF-tunnukset Asetuksissa).';

  @override
  String get uploadFace => 'Lataa kasvot';

  @override
  String get changeFace => 'Vaihda kasvot';

  @override
  String get pickFromGallery => 'Valitse galleriasta';

  @override
  String get takePhoto => 'Ota kuva';

  @override
  String get needCfCredentials =>
      'Aseta Cloudflare Access -tunnukset Asetuksissa';

  @override
  String get baseImageSelected => 'Pohjakuva valittu';

  @override
  String get baseImageOptional => 'Pohjakuva (valinnainen)';

  @override
  String get remove => 'Poista';

  @override
  String get prompt => 'Kehote';

  @override
  String get modelAutoTooltip =>
      'Malli valittu automaattisesti mallipohjasta.\nVoit vaihtaa sen Asetuksissa.';

  @override
  String get modelManualTooltip => 'Malli valittu käsin Asetuksissa.';

  @override
  String get pickBlocks => 'Valitse palikoita kehotteen kokoamiseksi...';
}
