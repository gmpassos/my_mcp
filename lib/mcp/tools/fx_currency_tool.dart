import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

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
  String get description =>
      'Fetch FX rates from fxapi.app. Supports pairs, base rates, and historical dates.';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'base':
              JsonSchema.string(description: 'Base currency (USD, EUR, BTC)'),
          'target':
              JsonSchema.string(description: 'Target currency (optional)'),
          'amount':
              JsonSchema.number(description: 'Amount to convert (default: 1)'),
          'start': JsonSchema.string(description: 'Historical start date'),
          'end': JsonSchema.string(description: 'Historical end date'),
          'date': JsonSchema.string(
            description: 'Single date (YYYY-MM-DD) or ignored if using range',
          ),
        },
        required: ['from'],
      );

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    final base = (args['base'] as String).toUpperCase();
    final target = (args['target'] as String?)?.toUpperCase();
    final amount = (args['amount'] as num?)?.toDouble() ?? 1.0;

    final date = args['date'] as String?;
    final start = args['start'] as String?;
    final end = args['end'] as String?;

    Uri uri;

    // CASE 1: range OR single date (history API)
    if (start != null && end != null) {
      uri = Uri.https(
        'fxapi.app',
        '/api/history/$base/$target.json',
        {
          'from': start,
          'to': end,
        },
      );
    } else if (date != null) {
      // single-day historical request
      uri = Uri.https(
        'fxapi.app',
        '/api/history/$base/$target.json',
        {
          'from': date,
          'to': date,
        },
      );
    }

    // CASE 2: direct pair
    else if (target != null) {
      uri = Uri.https(
        'fxapi.app',
        '/api/$base/$target.json',
      );
    }

    // CASE 3: base rates
    else {
      uri = Uri.https(
        'fxapi.app',
        '/api/$base.json',
      );
    }

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('FX API error: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    double? rate;

    // direct pair
    if (decoded is Map && decoded['rate'] != null) {
      rate = (decoded['rate'] as num).toDouble();
    }

    // base rates lookup
    else if (decoded is Map && decoded['rates'] is Map && target != null) {
      rate = (decoded['rates'][target] as num?)?.toDouble();
    }

    // base rates list lookup
    else if (decoded is Map && decoded['rates'] is List) {
      rate = ((decoded['rates'] as List).last['rate'] as num?)?.toDouble();
    }

    final result = rate != null ? rate * amount : null;

    return CallToolResult.fromStructuredContent({
      'base': base,
      'target': target,
      'rate': rate,
      'amount': amount,
      'result': result,
      'raw': decoded,
    });
  }
}
