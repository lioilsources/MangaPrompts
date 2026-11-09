import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Strings for the current locale. Falls back to English when no
  /// localization delegate is installed (bare MaterialApps in widget tests).
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
}

/// Turns a language tag (BCP 47 or Telegram's `language_code`, e.g. `pt-br`,
/// `zh-hant`, `no`) into a [Locale] the app ships, or null when none fits.
Locale? appLocaleFromTag(String? tag) {
  if (tag == null || tag.trim().isEmpty) return null;
  final parts = tag.trim().replaceAll('_', '-').split('-');
  final lang = parts.first.toLowerCase();
  String? script;
  String? country;
  for (final p in parts.skip(1)) {
    if (p.length == 4) {
      script = p[0].toUpperCase() + p.substring(1).toLowerCase();
    } else if (p.length == 2 || p.length == 3) {
      country = p.toUpperCase();
    }
  }
  return resolveAppLocale(
    Locale.fromSubtags(languageCode: lang, scriptCode: script, countryCode: country),
  );
}

/// Picks the shipped locale for [locale]: exact region variants first
/// (pt-BR), Chinese by script (zh-TW/HK/MO → Traditional), legacy codes
/// (no/nn → nb, iw → he, in → id), then the bare language.
Locale? resolveAppLocale(Locale locale) {
  const aliases = {'no': 'nb', 'nn': 'nb', 'iw': 'he', 'in': 'id'};
  final lang = aliases[locale.languageCode] ?? locale.languageCode;
  const supported = AppLocalizations.supportedLocales;
  if (lang == 'zh') {
    final traditional = locale.scriptCode == 'Hant' ||
        (locale.scriptCode == null &&
            const {'TW', 'HK', 'MO'}.contains(locale.countryCode));
    return traditional
        ? const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
        : const Locale('zh');
  }
  if (lang == 'pt') {
    return locale.countryCode == 'PT' ? const Locale('pt') : const Locale('pt', 'BR');
  }
  for (final s in supported) {
    if (s.languageCode == lang &&
        s.countryCode != null &&
        s.countryCode == locale.countryCode) {
      return s;
    }
  }
  for (final s in supported) {
    if (s.languageCode == lang && s.countryCode == null && s.scriptCode == null) {
      return s;
    }
  }
  return null;
}

/// MaterialApp.localeListResolutionCallback: the first preferred locale the
/// app ships wins, English otherwise.
Locale resolveAppLocaleList(List<Locale>? preferred, Iterable<Locale> _) {
  for (final l in preferred ?? const <Locale>[]) {
    final r = resolveAppLocale(l);
    if (r != null) return r;
  }
  return const Locale('en');
}
