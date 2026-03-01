import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextHelper {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  bool isListening = false;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  static const bool _onDevice = false;
  double level = 0.0;
  bool dialogShown = false;

  final SpeechListenOptions options = SpeechListenOptions(
    onDevice: _onDevice,
    listenMode: ListenMode.confirmation,
    cancelOnError: true,
    partialResults: true,
    autoPunctuation: true,
    enableHapticFeedback: true,
  );

  Function(String)? onSpeechResultCallback;
  Function()? onDialogDismissedCallback;

  SpeechToTextHelper(
      {this.onSpeechResultCallback, this.onDialogDismissedCallback});

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    debugPrint("$_speechEnabled");
  }

  void startListening(BuildContext context,
      TextEditingController searchController, Widget searchPopup) async {
    if (!_speechToText.isListening && !dialogShown) {
      dialogShown = true;

      showDialog(
        context: context,
        builder: (BuildContext context) => searchPopup,
      ).then((_) {
        _onDialogDismissed();
      });

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_En",
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: soundLevelListener,
        listenOptions: options,
      );

      isListening = true;
    }
  }

  void stopListening() async {
    await _speechToText.stop();
    isListening = false;
    if (_lastWords.isEmpty) {
      dialogShown = false;
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    this.level = level;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    if (_lastWords.isNotEmpty && dialogShown) {
      onSpeechResultCallback?.call(_lastWords);
      dialogShown = false;
    }
  }

  void _onDialogDismissed() {
    dialogShown = false;
    onDialogDismissedCallback?.call();
  }
}
