import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
enum TtsState { playing, stopped, paused, continued }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalidGPT',
      theme: ThemeData(
        colorScheme: ColorScheme.light(),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> jokes = [
    "Why don't scientists trust atoms? Because they make up everything!",
    "Did you hear about the mathematician who’s afraid of negative numbers? He'll stop at nothing to avoid them!",
    "Why don't oysters donate to charity? Because they are shellfish!",
    "How do you organize a space party? You planet!",
    "Why did the scarecrow win an award? Because he was outstanding in his field!",
    "Why couldn't the bicycle stand up by itself? Because it was two-tired!",
    "What do you call fake spaghetti? An impasta!",
    "Why did the tomato turn red? Because it saw the salad dressing!",
    "How does a penguin build its house? Igloos it together!",
    "What's a vampire's favorite fruit? A blood orange!"
  ];
  SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  String _text = 'Talk';

  late FlutterTts flutterTts;
  String? _newVoiceText;
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  late AudioPlayer audioPlayer;
  String getRandomJoke() {
  Random random = Random();
  int randomIndex = random.nextInt(jokes.length);
  return jokes[randomIndex];
}

String getDateTime() {
  print(dateTimeToEnglishString(DateTime.now()));
  return dateTimeToEnglishString(DateTime.now());
}

String dateTimeToEnglishString(DateTime dateTime) {

  List<String> monthWords = [
    "", "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  List<String> hourWords = [
    "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    "eleven", "twelve"
  ];

  List<String> minuteWords = [
  "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
  "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen",
  "nineteen", "twenty", "twenty-one", "twenty-two", "twenty-three", "twenty-four", "twenty-five",
  "twenty-six", "twenty-seven", "twenty-eight", "twenty-nine", "thirty", "thirty-one",
  "thirty-two", "thirty-three", "thirty-four", "thirty-five", "thirty-six", "thirty-seven",
  "thirty-eight", "thirty-nine", "forty", "forty-one", "forty-two", "forty-three",
  "forty-four", "forty-five", "forty-six", "forty-seven", "forty-eight", "forty-nine", "fifty",
  "fifty-one", "fifty-two", "fifty-three", "fifty-four", "fifty-five", "fifty-six", "fifty-seven",
  "fifty-eight", "fifty-nine"
];

  // Extract the month, day, year, hour, minute, and period (AM/PM)
  int month = dateTime.month;
  int day = dateTime.day;
  int hour = dateTime.hour;
  int minute = dateTime.minute;
  String period = DateFormat('a').format(dateTime); // AM/PM

  // Convert month to words
  String monthWord = monthWords[month];

  // Convert hour to words
  String hourWord = hourWords[hour % 12];

  // Convert minute to words
  String minuteWord = "";

  if (minute == 0) {
    minuteWord = "o clock";
  }else {
    minuteWord = minuteWords[minute];
  }

  // Compose the final string
  String result = "$monthWord $day";

  if (minuteWord.isNotEmpty) {
    result += ", $hourWord $minuteWord";
  } else {
    result += ", $hourWord";
  }

  result += " $period";

  return result;
}
  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    audioPlayer = AudioPlayer();

  }

  _initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });


    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }


   Future<void> playMusic() async {
    await audioPlayer.play(AssetSource('songs/faded.mp3'));
  }

  void pauseMusic() {
    audioPlayer.pause();
  }

  void stopMusic() {
    audioPlayer.stop();
  }

  bool isPlayingMusic() {
    return audioPlayer.state == PlayerState.playing;
  }
  
  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    _text = 'Lis';
    setState(() {});
    await _speechToText.listen(onResult: _onSpeechResult, partialResults: false, );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    _text = 'TALK';
    setState(() {});
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult (SpeechRecognitionResult result) async{

    _lastWords = result.recognizedWords;
      if (RegExp(r'\b(joke|funny)\b', caseSensitive: false).hasMatch(_lastWords)) {
    _newVoiceText = getRandomJoke();
    _text = 'JOKING';
  } else if (RegExp(r'\b(music|play music)\b', caseSensitive: false).hasMatch(_lastWords)) {
     _text = 'MUSIC';
     setState(() {});
     await playMusic();
    return;
  } else if (RegExp(r'\b(time|current time)\b', caseSensitive: false).hasMatch(_lastWords)) {
    _newVoiceText = getDateTime();
    _text = 'DATETIME';
  }else {
  _text = 'CONFUSED';                                                                                                                                               
    _newVoiceText = "I'm not sure how to respond to that.";
  }
  setState(() {});
  await _speak();
   _text = 'TALK';
  setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Center(child: Text(_text.toUpperCase(), style: TextStyle( fontSize: 30, fontWeight: FontWeight.w300, color: Colors.black),)),
            ),
            ClipOval(
              child: Container(
                decoration: BoxDecoration(color: Colors.blue[50]),
                  child: IconButton(
                    color: Colors.purple,
                    splashColor: Colors.green,
                      icon: Icon(_speechToText.isNotListening
                          ? Icons.mic_off
                          : Icons.mic, size: 100,color:Colors.black45),
                      onPressed: (_speechToText.isNotListening && isStopped
                          ? (){stopMusic();_startListening();}
                          : _stopListening))),
            )
          ],
        ),
      ),
    );
  }

  void dispose() {
    super.dispose();
    flutterTts.stop();
    audioPlayer.dispose();
  }
}
