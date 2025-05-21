import 'package:flutter/material.dart';
import 'package:threads/features/new_post/pages/new_post_page.dart';

import '../widgets/emoji_bubble.dart';
import '../widgets/post_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PostCard(
                username: 'Mahtaab',
                time: '17:07',
                postText:
                    'This portfolio is a collection of my digital and conceptual artworks, showcasing a blend of imagination, cinematic atmospheres, and visual storytelling.',
                isThisPicture: true,
                imageUrl: 'assets/images/image.png',
                profilePicUrl: 'assets/images/pfp.png',
                emojis: [
                  EmojiBubble(emoji: '😊'),
                  EmojiBubble(emoji: '😍'),
                  EmojiBubble(emoji: '👍'),
                  EmojiBubble(emoji: '😂'),
                  EmojiBubble(emoji: '🌟'),
                  EmojiBubble(emoji: '🔥'),
                  EmojiBubble(emoji: '💬'),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 2,
                color: Colors.white10,
              ),
              SizedBox(height: 20),
              PostCard(
                username: 'Mahtaab',
                time: '17:07',
                postText:
                    'This is a text-only post, without any image or voice.',
                isThisText: true,
                isThisPicture: false,
                isThisVoice: false,
                profilePicUrl: 'assets/images/pfp.png',
                emojis: [
                  EmojiBubble(emoji: '😊'),
                  EmojiBubble(emoji: '😍'),
                  EmojiBubble(emoji: '👍'),
                  EmojiBubble(emoji: '😂'),
                  EmojiBubble(emoji: '🌟'),
                  EmojiBubble(emoji: '🔥'),
                  EmojiBubble(emoji: '💬'),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 2,
                color: Colors.white10,
              ),
              SizedBox(height: 20),
              PostCard(
                username: 'Mahtaab',
                time: '17:07',
                postText: '',
                isThisText: false,
                isThisPicture: false,
                isThisVoice: true,
                profilePicUrl: 'assets/images/pfp.png',
                emojis: [
                  EmojiBubble(emoji: '😊'),
                  EmojiBubble(emoji: '😍'),
                  EmojiBubble(emoji: '👍'),
                  EmojiBubble(emoji: '😂'),
                  EmojiBubble(emoji: '🌟'),
                  EmojiBubble(emoji: '🔥'),
                  EmojiBubble(emoji: '💬'),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewPostPage(),
            ),
          );
        },
        child: Icon(Icons.add_rounded),
      ),
    );
  }
}
