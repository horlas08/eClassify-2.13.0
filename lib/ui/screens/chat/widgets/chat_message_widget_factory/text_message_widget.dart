import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class TextMessageWidget extends StatelessWidget {
  const TextMessageWidget({required this.message, super.key});

  final TextChatMessage message;

  @override
  Widget build(BuildContext context) {
    return SelectableText(message.message, style: context.labelLarge);
  }
}
