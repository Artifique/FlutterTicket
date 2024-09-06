import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final List<Map<String, String>> messages = []; // Liste des messages avec l'expéditeur
  final TextEditingController _controller = TextEditingController(); // Contrôleur pour le champ de texte

  void _sendMessage() {
    final String message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        // Ajoute le message avec une étiquette d'expéditeur (par exemple, "Moi")
        messages.add({
          'text': message,
          'sender': 'Moi',
        });
        _controller.clear(); // Efface le champ de texte après envoi
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('images/billet.png'), // Remplace par l'image souhaitée
              radius: 20,
            ),
            SizedBox(width: 8),
            Text('Cheick'),
          ],
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Affiche les derniers messages en bas
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isMe = message['sender'] == 'Moi'; // Détermine si le message est envoyé par "Moi"
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2C3E50) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: MessageBubblePainter(isMe: isMe),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C3E50),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubblePainter extends CustomPainter {
  final bool isMe;

  MessageBubblePainter({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isMe ? const Color(0xFF2C3E50) : Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    if (isMe) {
      path.moveTo(size.width * 0.75, size.height);
      path.lineTo(size.width * 0.8, size.height + 10);
      path.lineTo(size.width * 0.85, size.height);
    } else {
      path.moveTo(size.width * 0.1, 0);
      path.lineTo(size.width * 0.2, -10);
      path.lineTo(size.width * 0.3, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
