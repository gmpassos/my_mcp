import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Fetches currency exchange rates from fxapi.app (no API key required).
class FxCurrencyTool extends BaseTool {
  @override
  String get name => 'fx_currency';

  @override
  ToolAnnotations? get annotations => ToolAnnotations(
        title: 'FX Currency Rates',
        openWorldHint: true,
        readOnlyHint: true,
      );

  @override
  String get description => 'Fetches currency exchange rates from fxapi.app. '
      'Supports base currency queries (e.g. USD.json) and direct pairs '
      '(e.g. USD/EUR.json). Optional amount conversion and date support.';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'from': JsonSchema.string(
            description: 'Base currency (e.g. USD, EUR, BTC)',
          ),
          'to': JsonSchema.string(
            description: 'Target currency (optional for full rates)',
          ),
          'amount': JsonSchema.number(
            description: 'Optional amount to convert (default: 1)',
          ),
          'date': JsonSchema.string(
            description: 'Optional historical date YYYY-MM-DD',
          ),
        },
        required: ['from'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'base': JsonSchema.string(),
          'target': JsonSchema.string(),
          'rate': JsonSchema.number(),
          'amount': JsonSchema.number(),
          'result': JsonSchema.number(),
          'date': JsonSchema.string(),
          'raw': JsonSchema.object(
            description: 'Raw API response',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    logger.info("fx_currency> $args");

    final from = (args['from'] as String).toLowerCase();
    final to = (args['to'] as String?)?.toLowerCase();
    final amount = (args['amount'] as num?)?.toDouble() ?? 1.0;
    final date = args['date'] as String?;

    Uri uri;

    // Case 1: direct pair USD/EUR.json
    if (to != null && to.isNotEmpty) {
      uri = Uri.https(
        'fxapi.app',
        '/api/$from/$to.json',
        {
          if (date != null) 'date': date,
        },
      );
    }
    // Case 2: base currency USD.json
    else {
      uri = Uri.https(
        'fxapi.app',
        '/api/$from.json',
        {
          if (date != null) 'date': date,
        },
      );
    }

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'FX API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = response.body;

    // NOTE: API may return JSON or simple structure depending on endpoint
    final decoded = data.isNotEmpty ? _tryParseJson(data) : null;

    double? rate;
    String? base;
    String? target;

    if (decoded is Map) {
      base = decoded['base']?.toString();
      target = decoded['target']?.toString();
      rate = (decoded['rate'] as num?)?.toDouble();
    }

    final result = rate != null ? rate * amount : null;

    logger.info("fx_currency.response> rate=$rate");

    return CallToolResult.fromStructuredContent({
      'base': base ?? from.toUpperCase(),
      'target': target ?? to?.toUpperCase(),
      'rate': rate,
      'amount': amount,
      'result': result,
      'date': date ?? DateTime.now().toIso8601String(),
      'raw': decoded,
    });
  }

  dynamic _tryParseJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
