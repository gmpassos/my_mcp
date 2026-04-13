import 'dart:convert';
import 'dart:io';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

Future<void> main(List<String> args) async {
  final startTime = DateTime.now();

  if (args.isEmpty) {
    stderr.writeln('[ERROR] Missing prompt');
    stderr.writeln('Usage: dart run bin/prompt_local.dart "Your prompt here"');
    exit(1);
  }

  final prompt = args.join(' ');
  stdout.writeln('[INFO] Prompt: $prompt');

  const llmServerURL = 'http://localhost:8080/v1';

  final llm = ChatOpenAI(
    baseUrl: llmServerURL,
    defaultOptions: const ChatOpenAIOptions(
      temperature: 0.7,
    ),
  );

  final messages = [
    ChatMessage.system('You are a helpful assistant.'),
    ChatMessage.human(ChatMessageContent.text(prompt)),
  ];

  stdout.writeln('[DEBUG] Messages:');
  for (final m in messages) {
    stdout.writeln('  - ${m.runtimeType}: ${m.contentAsString}');
  }

  try {
    stdout.writeln('[INFO] Sending request to $llmServerURL...');

    final response = await llm.invoke(PromptValue.chat(messages));

    stdout.writeln('[INFO] Response received (${response.finishReason.name})');

    // Raw response (best effort)
    stdout.writeln(
        '[DEBUG] Raw response: ${tryJsonDecode(response.outputAsString)}');

    final content = response.outputAsString.trim();

    stdout.writeln('[RESULT]');
    stdout.writeln(content);

    final duration = DateTime.now().difference(startTime);
    stdout.writeln('[INFO] Duration: ${duration.inMilliseconds} ms');
  } catch (e, stack) {
    stderr.writeln('[ERROR] Exception: $e');
    stderr.writeln('[ERROR] Stacktrace:\n$stack');
    exit(2);
  }
}

String tryJsonDecode(String j) {
  try {
    return jsonEncode(j);
  } catch (_) {
    return j;
  }
}
