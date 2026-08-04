import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  const AudioService();

  static const _soundEnabledKey = 'safe_code.sound_enabled';
  static const _musicEnabledKey = 'safe_code.music_enabled';

  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _secondarySfxPlayer = AudioPlayer();
  static final AudioPlayer _musicPlayer = AudioPlayer();
  static bool _musicIsPlaying = false;

  Future<void> playKeyClick() => _playSfx('audio/key_click.wav', volume: 0.34);

  Future<void> playBackspace() => _playSfx('audio/backspace.wav', volume: 0.34);

  Future<void> playError() => _playSfx('audio/error_buzz.wav', volume: 0.34);

  Future<void> playUnlock() =>
      _playSfx('audio/safe_unlock.wav', volume: 0.46, useSecondaryPlayer: true);

  Future<void> playHint() => _playSfx('audio/hint_ping.wav', volume: 0.36);

  Future<void> startAmbient() async {
    if (!await _musicEnabled()) {
      await stopAmbient();
      return;
    }
    if (_musicIsPlaying) {
      return;
    }
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/music_loop.wav'), volume: 0.34);
    _musicIsPlaying = true;
  }

  Future<void> stopAmbient() async {
    if (!_musicIsPlaying) {
      return;
    }
    await _musicPlayer.stop();
    _musicIsPlaying = false;
  }

  Future<void> refreshAmbientPreference() async {
    if (await _musicEnabled()) {
      await startAmbient();
    } else {
      await stopAmbient();
    }
  }

  Future<void> _playSfx(
    String assetPath, {
    required double volume,
    bool useSecondaryPlayer = false,
  }) async {
    if (!await _soundEnabled()) {
      return;
    }
    final player = useSecondaryPlayer ? _secondarySfxPlayer : _sfxPlayer;
    await player.stop();
    await player.play(AssetSource(assetPath), volume: volume);
  }

  Future<bool> _soundEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_soundEnabledKey) ?? true;
  }

  Future<bool> _musicEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_musicEnabledKey) ?? true;
  }
}
