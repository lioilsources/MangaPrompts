import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki/services/telegram_backend_service.dart';
import 'package:tsumiki/ui/screens/web_entry.dart';
import 'package:tsumiki/ui/widgets/tsumiki_app_bar.dart';

/// The card switcher must never stack cards: root + at most one pushed card,
/// and picking the root card from anywhere goes back to it.
const _scene = TgVideoScene(
  id: 'wink',
  label: 'Wink at the camera',
  desc: '',
  beats: 3,
  seconds: 15.1,
  minutesEst: 8,
);

void main() {
  test('root card follows the animation catalog', () {
    expect(webRootScreen(const []), TsumikiScreen.builder);
    expect(webRootScreen(const [_scene]), TsumikiScreen.animate);
  });

  test('going to the root card pops back to it', () {
    expect(
      screenNavFor(
        root: TsumikiScreen.animate,
        canPop: true,
        target: TsumikiScreen.animate,
      ),
      ScreenNav.popToRoot,
    );
  });

  test('from the root card another card is pushed', () {
    expect(
      screenNavFor(
        root: TsumikiScreen.animate,
        canPop: false,
        target: TsumikiScreen.restyle,
      ),
      ScreenNav.push,
    );
  });

  test('from a pushed card another non-root card replaces it', () {
    expect(
      screenNavFor(
        root: TsumikiScreen.animate,
        canPop: true,
        target: TsumikiScreen.restyle,
      ),
      ScreenNav.pushReplacement,
    );
    expect(
      screenNavFor(
        root: TsumikiScreen.builder,
        canPop: true,
        target: TsumikiScreen.animate,
      ),
      ScreenNav.pushReplacement,
    );
  });

  test('only the animate card spends video credits', () {
    expect(TsumikiScreen.animate.video, isTrue);
    expect(TsumikiScreen.restyle.video, isFalse);
    expect(TsumikiScreen.builder.video, isFalse);
  });
}
