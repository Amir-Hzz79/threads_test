import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/widgets/video_player.dart';
import '../../../core/widgets/voice_player.dart';
import 'image_editor_page.dart';
import 'video_editor_page.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  File? _selectedImage;
  File? _selectedVideo;
  File? _recordedAudio;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  final RecorderController recorderController = RecorderController();

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _selectedImage = null;
      });
    }
  }

  /* Future<void> _pickMedia() async {
    final XFile? media = await _picker.pickMedia();
    if (media == null) {
      return;
    }

    if (media.mimeType!.startsWith('video')) {
      setState(() {
        _selectedVideo = File(media.path);
        _selectedImage = null;
      });
    } else {
      setState(() {
        _selectedImage = File(media.path);
        _selectedVideo = null;
      });
    }
  } */

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedVideo = null;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _recordedAudio = path != null ? File(path) : null;
        _isRecording = false;
      });
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/my_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.black,
          /* appBar: AppBar(
            title: Text('ایجاد ادعای جدید'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.close_rounded),
              ),
            ],
          ), */
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ایجاد ادعای جدید',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close_rounded),
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/pfp.png'),
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mahtaab',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 10,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'افزودن موضوع',
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'ادعای خودتو اضافه کن ...',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      /* Container(
                        width: 2,
                        height: 50,
                        color: Colors.grey,
                      ), */
                      const SizedBox(width: 25),
                      IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.photo_library_rounded,
                            color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: _pickVideo,
                        icon: Icon(Icons.video_library_rounded,
                            color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: _takePhoto,
                        icon:
                            Icon(Icons.camera_alt_rounded, color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: _toggleRecording,
                        icon: Icon(
                          _isRecording
                              ? Icons.stop_circle
                              : Icons.keyboard_voice_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (_selectedVideo != null)
                    VideoPreviewPlayer(
                      videoFile: _selectedVideo!,
                      maxHeight: double.infinity,
                    ),
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      width: screenSize.width,
                    ),
                  if (_recordedAudio != null)
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: VoicePlayer(
                          audioFile: _recordedAudio!,
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: SizedBox(
            width: screenSize.width,
            child: Container(
              width: screenSize.width - 30,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                              'هر کسی میتواند ادعای شما رو ببیند و شما رو دوئل دعوت کند.',
                          hintStyle:
                              TextStyle(fontSize: 11, color: Colors.grey[300]),
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (_selectedImage == null &&
                            _selectedVideo == null &&
                            _recordedAudio == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('محتوای ادعا را اضافه کنید'),
                            ),
                          );

                          return;
                        }

                        if (_selectedImage != null || _selectedVideo != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _selectedImage != null
                                  ? ImageEditorPage(
                                      image: _selectedImage!,
                                    )
                                  : VideoEditorPage(
                                      video: _selectedVideo!,
                                    ),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            width: 1,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                      child: Text(
                        'پست',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
