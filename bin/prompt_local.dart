import 'dart:io';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run bin/prompt_local.dart "Your prompt here"');
    exit(1);
  }

  final prompt = args.join(' ');

  final llm = ChatOpenAI(
    baseUrl: 'http://localhost:8080/v1',
    apiKey: 'not-needed',
    defaultOptions: const ChatOpenAIOptions(
      model: 'local-model',
      temperature: 0.7,
      maxTokens: 128,
    ),
  );

  try {
    final response = await llm.invoke(PromptValue.chat([
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.human(ChatMessageContent.text(prompt)),
    ]));

    final content = response.outputAsString.trim();
    stdout.writeln(content);
  } catch (e) {
    stderr.writeln('** ERROR: $e');
    exit(2);
  }
}
