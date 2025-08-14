import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/utils/my_logger.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class AudioMessageWidget extends StatefulWidget {
  const AudioMessageWidget({super.key, required this.url});

  final String url;

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  PlayerController player = PlayerController();
  PlayerState playerState = PlayerState.initialized;
  bool showWaves = false;

  @override
  void initState() {
    super.initState();
    downloadWave();

    player.onPlayerStateChanged.listen((state) {
      Mylogger.print('Player state: $state');
      playerState = state;
      setState(() {});
    });

    player.onCompletion.listen((_) async {
      Mylogger.print('Reproducción completada');
      await player.stopPlayer();
      await _preparePlayer();
    });
  }

  Future<void> _preparePlayer() async {
    final appDirectory = await getApplicationCacheDirectory();
    final file = File('${appDirectory.path}/${widget.url.split('/').last}');
    if (file.existsSync()) {
      await player.preparePlayer(path: file.path);
      if (mounted) {
        setState(() => showWaves = true);
      }
    }
  }

  Future<void> downloadWave() async {
    final response = await get(Uri.parse(widget.url));
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      final appDirectory = await getApplicationCacheDirectory();
      final file = File('${appDirectory.path}/${widget.url.split('/').last}');
      await file.writeAsBytes(bytes);
      await _preparePlayer();
    }
  }

  @override
  void dispose() {
    player.stopPlayer();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          IconButton(
            icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                color: theme),
            onPressed: () async {
              Mylogger.print('State play ${player.playerState}');
              try {
                if (playerState.isPlaying) {
                  await player.pausePlayer();
                } else {
                  // Si el estado es 'stopped', vuelve a preparar el reproductor
                  if (playerState == PlayerState.stopped) {
                    await _preparePlayer();
                  }

                  await player.startPlayer(forceRefresh: true);
                }
              } catch (e) {
                Mylogger.print('Error play $e');
              }
            },
          ),
          Expanded(
            child: showWaves
                ? AudioFileWaveforms(
                    size: Size(200, 50),
                    playerController: player,
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      // backgroundColor: Colors.black,
                      fixedWaveColor: Colors.grey,
                      liveWaveColor: buttonColor,
                    ),
                  )
                : Image.asset(
                    'assets/images/audio_waves.png',
                    height: 32,
                  ),
          ),
        ],
      ),
    );
  }
}
