import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;

  // ignore: use_key_in_widget_constructors
  const MessageTextField(this.currentId, this.friendId);

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  // ignore: prefer_final_fields
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () async {}, icon: const Icon(Icons.photo)),
                  labelText: 'Type your Message',
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 0),
                      gapPadding: 10,
                      borderRadius: BorderRadius.circular(25))),
            )),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
                onTap: () async {
                  String message = _controller.text;
                  _controller.clear();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.currentId)
                      .collection('messages')
                      .doc(widget.friendId)
                      .collection('chats')
                      .add({
                    "senderId": widget.currentId,
                    "receiver": widget.friendId,
                    "message": message,
                    "type": "text",
                    "date": DateTime.now(),
                  }).then((value) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.currentId)
                        .collection('messages')
                        .doc(widget.friendId)
                        .set({
                      'last_msg': message,
                    });
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.friendId)
                      .collection('messages')
                      .doc(widget.currentId)
                      .collection('chats')
                      .add({
                    'senderId': widget.currentId,
                    'receiverId': widget.friendId,
                    'message': message,
                    'type': 'text',
                    'date': DateTime.now(),
                  }).then((value) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.friendId)
                        .collection('messages')
                        .doc(widget.currentId)
                        .set({'last_msg': message});
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ))
          ],
        ));
  }
}
