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
          'from':
              JsonSchema.string(description: 'Base currency (USD, EUR, BTC)'),
          'to': JsonSchema.string(description: 'Target currency (optional)'),
          'amount':
              JsonSchema.number(description: 'Amount to convert (default: 1)'),
          'date': JsonSchema.string(
            description: 'Single date (YYYY-MM-DD) or ignored if using range',
          ),
          'dateFrom': JsonSchema.string(description: 'Historical start date'),
          'dateTo': JsonSchema.string(description: 'Historical end date'),
        },
        required: ['from'],
      );

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    final from = (args['from'] as String).toUpperCase();
    final to = (args['to'] as String?)?.toUpperCase();
    final amount = (args['amount'] as num?)?.toDouble() ?? 1.0;

    final date = args['date'] as String?;
    final dateFrom = args['dateFrom'] as String?;
    final dateTo = args['dateTo'] as String?;

    Uri uri;

    // CASE 1: range OR single date (history API)
    if (dateFrom != null && dateTo != null) {
      uri = Uri.https(
        'fxapi.app',
        '/api/history/$from/$to.json',
        {
          'from': dateFrom,
          'to': dateTo,
        },
      );
    } else if (date != null) {
      // single-day historical request
      uri = Uri.https(
        'fxapi.app',
        '/api/history/$from/$to.json',
        {
          'from': date,
          'to': date,
        },
      );
    }

    // CASE 2: direct pair
    else if (to != null) {
      uri = Uri.https(
        'fxapi.app',
        '/api/$from/$to.json',
      );
    }

    // CASE 3: base rates
    else {
      uri = Uri.https(
        'fxapi.app',
        '/api/$from.json',
      );
    }

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('FX API error: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    double? rate;
    String? target = to;

    // direct pair
    if (decoded is Map && decoded['rate'] != null) {
      rate = (decoded['rate'] as num).toDouble();
    }

    // base rates lookup
    else if (decoded is Map && decoded['rates'] is Map && to != null) {
      rate = (decoded['rates'][to] as num?)?.toDouble();
    }

    // base rates list lookup
    else if (decoded is Map && decoded['rates'] is List) {
      rate = ((decoded['rates'] as List).last['rate'] as num?)?.toDouble();
    }

    final result = rate != null ? rate * amount : null;

    return CallToolResult.fromStructuredContent({
      'base': from,
      'target': target,
      'rate': rate,
      'amount': amount,
      'result': result,
      'raw': decoded,
    });
  }
}
