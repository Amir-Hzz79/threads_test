import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class VoicePlayer extends StatefulWidget {
  final File audioFile;
  final void Function()? onClosePressed;

  const VoicePlayer({super.key, required this.audioFile, this.onClosePressed});

  @override
  _VoicePlayerState createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  late PlayerController _playerController;

  @override
  void initState() {
    super.initState();

    _playerController = PlayerController();
    _initializePlayer();
  }

  void _initializePlayer() async {
    String path = widget.audioFile.path;
    await _playerController.preparePlayer(path: path);

    _playerController.onCompletion.listen((_) async {
      await _playerController.stopPlayer();
      _playerController.seekTo(0);
      setState(() {});
    });
  }

  void _togglePlayback() async {
    if (_playerController.playerState == PlayerState.playing) {
      await _playerController.stopPlayer();
    } else {
      if (_playerController.playerState == PlayerState.stopped) {
        await _playerController.preparePlayer(path: widget.audioFile.path);
      }

      await _playerController.startPlayer().then((value) {
        setState(() {});
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
                onPressed: widget.onClosePressed,
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              AudioFileWaveforms(
                playerController: _playerController,
                size: Size(MediaQuery.of(context).size.width - 130, 50),
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: PlayerWaveStyle(
                  seekLineThickness: 3,
                  waveThickness: 5,
                  spacing: 6,
                  waveCap: StrokeCap.round,
                  liveWaveColor: Theme.of(context).colorScheme.primary,
                  scaleFactor: 120,
                ),
              ),
              IconButton(
                icon: Icon(
                  _playerController.playerState == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                onPressed: _togglePlayback,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _playerController.stopPlayer();
    _playerController.dispose();
    super.dispose();
  }
}
