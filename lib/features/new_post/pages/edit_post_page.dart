import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:threads/core/models/post.dart';

import '../../../core/data/fake_data.dart';
import '../../../core/providers/post_provider.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../../core/widgets/video_player.dart';
import '../../../core/widgets/voice_player.dart';
import 'image_editor_page.dart';
import 'video_editor_page.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({Key? key, required this.post}) : super(key: key);

  final Post post;

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  File? _selectedImage;
  File? _selectedVideo;
  File? _recordedAudio;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  final RecorderController recorderController = RecorderController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedImage = widget.post.image;
    _selectedVideo = widget.post.video;
    _recordedAudio = widget.post.audio;
    _textController.text = widget.post.text ?? '';
  }

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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoEditorPage(
            video: File(video.path),
            onVideoEdited: (video) {
              setState(() {
                _selectedVideo = video;
                _selectedImage = null;
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageEditorPage(
            image: File(image.path),
            onImageEdited: (image) {
              setState(() {
                _selectedImage = image;
                _selectedVideo = null;
              });
            },
          ),
        ),
      );
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
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
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
                    contentPadding: EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(FakeData.currentUser.profilePicUrl),
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Text(
                          FakeData.currentUser.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        Expanded(
                          flex: 10,
                          child: TextField(
                            controller: _textController,
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
                      onClosePressed: () => setState(
                        () {
                          _selectedVideo = null;
                        },
                      ),
                    ),
                  if (_selectedImage != null)
                    ImageViewer(
                      image: Image.file(
                        _selectedImage!,
                        width: screenSize.width,
                      ),
                      onClosePressed: () => setState(
                        () {
                          _selectedImage = null;
                        },
                      ),
                    ),
                  /* ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      width: screenSize.width,
                    ),
                  ), */
                  if (_recordedAudio != null) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: VoicePlayer(
                        audioFile: _recordedAudio!,
                        onClosePressed: () => setState(
                          () {
                            _recordedAudio = null;
                          },
                        ),
                      ),
                    ),
                  ],
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
                            _recordedAudio == null &&
                            _textController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('محتوای ادعا را وارد کنید.'),
                            ),
                          );
                          return;
                        }

                        print('here1');
                        print(
                            '-------------------_textController.text:${_textController.text}');
                        Provider.of<PostProvider>(context, listen: false)
                            .updatePost(
                          widget.post.id,
                          Post.fromFile(
                            image: _selectedImage,
                            video: _selectedVideo,
                            audio: _recordedAudio,
                            text: _textController.text,
                            user: FakeData.currentUser,
                            createdAt: widget.post.createdAt,
                          ),
                        );
                        print('here1-2');

                        Navigator.of(context).pop();
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
