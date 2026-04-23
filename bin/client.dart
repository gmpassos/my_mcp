import 'dart:convert';

import 'package:http/http.dart' as http;

class McpClient {
  final Uri url;

  McpClient(String baseUrl) : url = Uri.parse('$baseUrl/mcp');

  int _id = 0;

  Future<({dynamic result, dynamic response, String? sessionID, Map headers})?>
      call(String method,
          {Map<String, dynamic>? params, String? sessionID}) async {
    final payload = {
      "jsonrpc": "2.0",
      "id": _id++,
      "method": method,
      "params": params ?? {},
    };

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json, text/event-stream",
        "Content-Type": "application/json",
        if (sessionID != null && sessionID.isNotEmpty)
          "mcp-session-id": sessionID
      },
      body: jsonEncode(payload),
    );

    var headers = res.headers;
    var body = res.body;

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: $body');
    }

    try {
      var bodyTrimmed = body.trim();

      dynamic data;
      if (bodyTrimmed.startsWith("event:") || bodyTrimmed.startsWith("data:")) {
        var idx = bodyTrimmed.indexOf('data:');

        var eventData = bodyTrimmed.substring(idx + 5).trim();

        data = jsonDecode(eventData);
      } else {
        data = jsonDecode(body);
      }

      if (data["error"] != null) {
        throw Exception(data["error"]);
      }

      var sessionID = headers['mcp-session-id'];

      return (
        result: data["result"],
        response: data,
        sessionID: sessionID,
        headers: headers
      );
    } catch (e, s) {
      print("** Error deconding JSON: $e");
      print('<<$body>>');
      print(s);
      return null;
    }
  }
}

void main() async {
  final client = McpClient('http://127.0.0.1:3000');

  try {
    print('** Initializing session...');
    final initialize = await client.call("initialize", params: {
      "protocolVersion": "2024-11-05",
      "clientInfo": {"name": "dart", "version": "0.1"},
      "capabilities": {"tools": {}, "resources": {}, "prompts": {}}
    });

    var sessionID = initialize?.sessionID;
    print('-- sessionID: $sessionID');
    if (sessionID == null) {
      throw StateError("Can't initialize MCP session!");
    }

    // print('=================================================================');
    // final tools = await client.call("tools/list", sessionID: sessionID);
    // print(tools);

    print('=================================================================');

    final result =
        await client.call("tools/call", sessionID: sessionID, params: {
      "name": "evaluate_dart_code",
      "arguments": {
        "code":
            r'''void main() {\n  // Data for BTC/USD (from the first call)\n  List<double> usdRates = [71428.571429, 71428.571429, 71428.571429, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, 71428.571429, 71428.571429, 71428.571429, 76923.076923, 76923.076923, 76923.076923];\n\n  // Data for BTC/EUR (from the second call)\n  List<double> eurRates = [61667.5, 61559.428571, 61746.285714, 57778.4, 57743.266667, 57774.066667, 58014.6, 58194.466667, 57636.866667, 57511.466667, 57757.666667, 57873.466667, 57874.533333, 57919.4, 57766.533333, 61151.785714, 61260.357143, 61081.928571, 60923.5, 60920.928571, 61199.428571, 65381, 65198.769231, 65156.538462, 65273.384615, 65240, 65339.769231, 60828.571429, 65277.461538, 65516.538462, 65518.615385];\n\n  // Data for BTC/BRL (from the third call)\n  List<double> brlRates = [373796.642857, 373876.214286, 374064.214286, 349252.066667, 349463.4, 349458.8, 349274, 350766.733333, 346151.533333, 343726.666667, 343902.2, 343910.2, 344840.266667, 343923.066667, 342827.666667, 368091, 364361.857143, 363221.357143, 357680.214286, 357534.214286, 357649.857143, 384353.846154, 383614.076923, 384123.692308, 383965.461538, 382975.615385, 383204.153846, 356644.428571, 381191.230769, 384182.846154, 384140.461538];\n\n  // --- USD Calculations ---\n  double usdAvgChange = 0.0;\n  List<double> usdDailyChanges = [];\n  for (int i = 1; i < usdRates.length; i++) {\n    double change = (usdRates[i] - usdRates[i-1]) / usdRates[i-1];\n    usdDailyChanges.add(change);\n    usdAvgChange = usdAvgChange + change;\n  }\n\n  double usdAverageRatioChange = usdAvgChange / usdDailyChanges.length;\n  double usdDeviation = 0.0;\n  for (double change : usdDailyChanges) {\n    usdDeviation = usdDeviation + (change - usdAverageRatioChange) * (change - usdAverageRatioChange);\n  }\n  usdDeviation = Math.sqrt(usdDeviation / usdDailyChanges.length);\n\n\n  // --- EUR Calculations ---\n  double eurAvgChange = 0.0;\n  List<double> eurDailyChanges = [];\n  for (int i = 1; i < eurRates.length; i++) {\n    double change = (eurRates[i] - eurRates[i-1]) / eurRates[i-1];\n    eurDailyChanges.add(change);\n    eurAvgChange = eurAvgChange + change;\n  }\n\n  double eurAverageRatioChange = eurAvgChange / eurDailyChanges.length;\n  double eurDeviation = 0.0;\n  for (double change : eurDailyChanges) {\n    eurDeviation = eurDeviation + (change - eurAverageRatioChange) * (change - eurAverageRatioChange);\n  }\n  eurDeviation = Math.sqrt(eurDeviation / eurDailyChanges.length);\n\n\n  // --- BRL Calculations ---\n  double brlAvgChange = 0.0;\n  List<double> brlDailyChanges = [];\n  for (int i = 1; i < brlRates.length; i++) {\n    double change = (brlRates[i] - brlRates[i-1]) / brlRates[i-1];\n    brlDailyChanges.add(change);\n    brlAvgChange = brlAvgChange + change;\n  }\n\n  double brlAverageRatioChange = brlAvgChange / brlDailyChanges.length;\n  double brlDeviation = 0.0;\n  for (double change : brlDailyChanges) {\n    brlDeviation = brlDeviation + (change - brlAverageRatioChange) * (change - brlAverageRatioChange);\n  }\n  brlDeviation = Math.sqrt(brlDeviation / brlDailyChanges.length);\n\n\n  // --- Output Results ---\n  print('--- BTC/USD Analysis ---');\n  print('Average Ratio Change: ' + usdAverageRatioChange);\n  print('Deviation (Std Dev): ' + usdDeviation);\n  print('Daily Changes: ' + usdDailyChanges.toString());\n\n  print('\\\\n--- BTC/EUR Analysis ---');\n  print('Average Ratio Change: ' + eurAverageRatioChange);\n  print('Deviation (Std Dev): ' + eurDeviation);\n  print('Daily Changes: ' + eurDailyChanges.toString());\n\n  print('\\\\n--- BTC/BRL Analysis ---');\n  print('Average Ratio Change: ' + brlAverageRatioChange);\n  print('Deviation (Std Dev): ' + brlDeviation);\n  print('Daily Changes: ' + brlDailyChanges.toString());\n}'''
      }
    });

    print(result);

    print('--------------------------------------------------');
    print(result?.result);
  } catch (e, s) {
    print("Error: $e");
    print(s);
  }
}
