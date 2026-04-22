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

    final tools = await client.call("tools/list", sessionID: sessionID);
    print(tools);

    final result =
        await client.call("tools/call", sessionID: sessionID, params: {
      "name": "evaluate_dart_code",
      "arguments": {
        "code":
            r'''\nvoid main() {\n  // Data from BTC to USD (from previous FX call)\n  List<String> datesUSD = [\n    \"2026-03-23\", \"2026-03-24\", \"2026-03-25\", \"2026-03-26\", \"2026-03-27\", \n    \"2026-03-28\", \"2026-03-29\", \"2026-03-30\", \"2026-03-31\", \"2026-04-01\", \n    \"2026-04-02\", \"2026-04-03\", \"2026-04-04\", \"2026-04-05\", \"2026-04-06\", \n    \"2026-04-07\", \"2026-04-08\", \"2026-04-09\", \"2026-04-10\", \"2026-04-11\", \n    \"2026-04-12\", \"2026-04-13\", \"2026-04-14\", \"2026-04-15\", \"2026-04-16\", \n    \"2026-04-17\", \"2026-04-18\", \"2026-04-19\", \"2026-04-20\", \"2026-04-21\", \"2026-04-22\"\n  ];\n  List<double> ratesUSD = [\n    71428.571429, 71428.571429, 71428.571429, 66666.666667, 66666.666667, \n    66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, \n    66666.666667, 66666.666667, 66666.666667, 66666.666667, 66666.666667, \n    66666.666667, 71428.571429, 71428.571429, 71428.571429, 71428.571429, \n    71428.571429, 71428.571429, 76923.076923, 76923.076923, 76923.076923, \n    76923.076923, 76923.076923, 71428.571429, 76923.076923, 76923.076923\n  ];\n\n  List<double> ratesEUR = [\n    61667.5, 61559.428571, 61746.285714, 57778.4, 57743.266667, \n    57774.066667, 58014.6, 58194.466667, 57636.866667, 57511.466667, \n    57757.666667, 57873.466667, 57874.533333, 57919.4, 57766.533333, \n    61151.785714, 61260.357143, 61081.928571, 60923.5, 60920.928571, \n    61199.428571, 65381, 65198.769231, 65156.538462, 65273.384615, \n    65240, 65339.769231, 60828.571429, 65277.461538, 65516.538462\n  ];\n\n  List<double> ratesBRL = [\n    373796.642857, 373876.214286, 374064.214286, 349252.066667, 349463.4, \n    349458.8, 349274, 350766.733333, 346151.533333, 343726.666667, \n    343902.2, 343910.2, 344840.266667, 343923.066667, 342827.666667, \n    368091, 364361.857143, 363221.357143, 357680.214286, 357534.214286, \n    357649.857143, 384353.846154, 383614.076923, 384123.692308, 383965.461538, \n    382975.615385, 383204.153846\n  ];\n\n  List<double> ratioChangesUSD = [];\n  for (int i = 1; i < datesUSD.length; i++) {\n    double change = ratesUSD[i] - ratesUSD[i-1];\n    ratioChangesUSD.add(change);\n  }\n\n  double avgChangeUSD = 0.0;\n  if (ratioChangesUSD.isNotEmpty) {\n    for (double change in ratioChangesUSD) {\n      avgChangeUSD = avgChangeUSD + change;\n    }\n    avgChangeUSD = avgChangeUSD / ratioChangesUSD.length;\n  }\n\n  double firstRateUSD = ratesUSD[0];\n  double lastRateUSD = ratesUSD[datesUSD.length - 1];\n  double deviationUSD = lastRateUSD - firstRateUSD;\n\n  List<double> ratioChangesEUR = [];\n  for (int i = 1; i < datesUSD.length; i++) {\n    double change = ratesEUR[i] - ratesEUR[i-1];\n    ratioChangesEUR.add(change);\n  }\n\n  double avgChangeEUR = 0.0;\n  if (ratioChangesEUR.isNotEmpty) {\n    for (double change in ratioChangesEUR) {\n      avgChangeEUR = avgChangeEUR + change;\n    }\n    avgChangeEUR = avgChangeEUR / ratioChangesEUR.length;\n  }\n\n  double firstRateEUR = ratesEUR[0];\n  double lastRateEUR = ratesEUR[datesUSD.length - 1];\n  double deviationEUR = lastRateEUR - firstRateEUR;\n\n  List<double> ratioChangesBRL = [];\n  for (int i = 1; i < datesUSD.length; i++) {\n    double change = ratesBRL[i] - ratesBRL[i-1];\n    ratioChangesBRL.add(change);\n  }\n\n  double avgChangeBRL = 0.0;\n  if (ratioChangesBRL.isNotEmpty) {\n    for (double change in ratioChangesBRL) {\n      avgChangeBRL = avgChangeBRL + change;\n    }\n    avgChangeBRL = avgChangeBRL / ratioChangesBRL.length;\n  }\n\n  double firstRateBRL = ratesBRL[0];\n  double lastRateBRL = ratesBRL[datesUSD.length - 1];\n  double deviationBRL = lastRateBRL - firstRateBRL;\n\n  print(\"--- Ratio Changes (Daily) ---\");\n  print(\"USD Change: \");\n  for (int i = 0; i < ratioChangesUSD.length; i++) {\n    print(\"Date ${datesUSD[i]}: ${ratioChangesUSD[i].toStringAsFixed(4)}\");\n  }\n\n  print(\"\\nAverage Ratio Change:\");\n  print(\"USD Average Change: ${avgChangeUSD.toStringAsFixed(4)}\");\n  print(\"EUR Average Change: ${avgChangeEUR.toStringAsFixed(4)}\");\n  print(\"BRL Average Change: ${avgChangeBRL.toStringAsFixed(4)}\");\n\n  print(\"\\nDeviation (Last Rate - First Rate):\");\n  print(\"USD Deviation: ${deviationUSD.toStringAsFixed(4)}\");\n  print(\"EUR Deviation: ${deviationEUR.toStringAsFixed(4)}\");\n  print(\"BRL Deviation: ${deviationBRL.toStringAsFixed(4)}\");\n}'''
      }
    });

    print(result);
  } catch (e, s) {
    print("Error: $e");
    print(s);
  }
}
