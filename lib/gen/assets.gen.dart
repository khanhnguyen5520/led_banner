// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsAudioGen {
  const $AssetsAudioGen();

  /// File path: assets/audio/birthday_chime.wav
  String get birthdayChime => 'assets/audio/birthday_chime.wav';

  /// File path: assets/audio/concert_pulse.wav
  String get concertPulse => 'assets/audio/concert_pulse.wav';

  /// File path: assets/audio/festive_bells.wav
  String get festiveBells => 'assets/audio/festive_bells.wav';

  /// File path: assets/audio/neon_chill.wav
  String get neonChill => 'assets/audio/neon_chill.wav';

  /// List of all assets
  List<String> get values => [
    birthdayChime,
    concertPulse,
    festiveBells,
    neonChill,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/a-large-small.svg
  SvgGenImage get aLargeSmall =>
      const SvgGenImage('assets/icons/a-large-small.svg');

  /// File path: assets/icons/activity.svg
  SvgGenImage get activity => const SvgGenImage('assets/icons/activity.svg');

  /// File path: assets/icons/audio-waveform.svg
  SvgGenImage get audioWaveform =>
      const SvgGenImage('assets/icons/audio-waveform.svg');

  /// File path: assets/icons/chevron-left.svg
  SvgGenImage get chevronLeft =>
      const SvgGenImage('assets/icons/chevron-left.svg');

  /// File path: assets/icons/chevron-right.svg
  SvgGenImage get chevronRight =>
      const SvgGenImage('assets/icons/chevron-right.svg');

  /// File path: assets/icons/circle-pause.svg
  SvgGenImage get circlePause =>
      const SvgGenImage('assets/icons/circle-pause.svg');

  /// File path: assets/icons/clock-fading.svg
  SvgGenImage get clockFading =>
      const SvgGenImage('assets/icons/clock-fading.svg');

  /// File path: assets/icons/dices.svg
  SvgGenImage get dices => const SvgGenImage('assets/icons/dices.svg');

  /// File path: assets/icons/file-music.svg
  SvgGenImage get fileMusic => const SvgGenImage('assets/icons/file-music.svg');

  /// File path: assets/icons/flip-horizontal.svg
  SvgGenImage get flipHorizontal =>
      const SvgGenImage('assets/icons/flip-horizontal.svg');

  /// File path: assets/icons/image-play.svg
  SvgGenImage get imagePlay => const SvgGenImage('assets/icons/image-play.svg');

  /// File path: assets/icons/image.svg
  SvgGenImage get image => const SvgGenImage('assets/icons/image.svg');

  /// File path: assets/icons/lightbulb.svg
  SvgGenImage get lightbulb => const SvgGenImage('assets/icons/lightbulb.svg');

  /// File path: assets/icons/lock.svg
  SvgGenImage get lock => const SvgGenImage('assets/icons/lock.svg');

  /// File path: assets/icons/music-4.svg
  SvgGenImage get music4 => const SvgGenImage('assets/icons/music-4.svg');

  /// File path: assets/icons/pause.svg
  SvgGenImage get pause => const SvgGenImage('assets/icons/pause.svg');

  /// File path: assets/icons/pencil.svg
  SvgGenImage get pencil => const SvgGenImage('assets/icons/pencil.svg');

  /// File path: assets/icons/play.svg
  SvgGenImage get play => const SvgGenImage('assets/icons/play.svg');

  /// File path: assets/icons/repeat-2.svg
  SvgGenImage get repeat2 => const SvgGenImage('assets/icons/repeat-2.svg');

  /// File path: assets/icons/settings-2.svg
  SvgGenImage get settings2 => const SvgGenImage('assets/icons/settings-2.svg');

  /// File path: assets/icons/share.svg
  SvgGenImage get share => const SvgGenImage('assets/icons/share.svg');

  /// File path: assets/icons/trash.svg
  SvgGenImage get trash => const SvgGenImage('assets/icons/trash.svg');

  /// File path: assets/icons/wand-sparkles.svg
  SvgGenImage get wandSparkles =>
      const SvgGenImage('assets/icons/wand-sparkles.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    aLargeSmall,
    activity,
    audioWaveform,
    chevronLeft,
    chevronRight,
    circlePause,
    clockFading,
    dices,
    fileMusic,
    flipHorizontal,
    imagePlay,
    image,
    lightbulb,
    lock,
    music4,
    pause,
    pencil,
    play,
    repeat2,
    settings2,
    share,
    trash,
    wandSparkles,
  ];
}

abstract final class Assets {
  static const $AssetsAudioGen audio = $AssetsAudioGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
