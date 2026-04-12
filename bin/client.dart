import 'dart:convert';
import 'package:http/http.dart' as http;

class McpClient {
  final Uri url;

  McpClient(String baseUrl) : url = Uri.parse('$baseUrl/mcp');

  int _id = 0;

  Future<dynamic> call(String method, [Map<String, dynamic>? params]) async {
    final payload = {
      "jsonrpc": "2.0",
      "id": _id++,
      "method": method,
      "params": params ?? {},
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);

    if (data["error"] != null) {
      throw Exception(data["error"]);
    }

    return data["result"];
  }
}

void main() async {
  final client = McpClient('http://127.0.0.1:3000');

  try {
    final tools = await client.call("tools/list");
    print(tools);

    final result = await client.call("tools/call", {
      "name": "add",
      "arguments": {"a": 1, "b": 2}
    });

    print(result);
  } catch (e) {
    print("Error: $e");
  }
}
