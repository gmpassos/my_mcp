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
          'start': JsonSchema.string(
              description: 'Historical start date (YYYY-MM-DD)'),
          'end': JsonSchema.string(
              description: 'Historical end date (YYYY-MM-DD)'),
          'date': JsonSchema.string(description: 'Single date (YYYY-MM-DD)'),
        },
        required: ['base'],
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

    // CASE 1: range
    if (start != null && end != null) {
      uri = Uri.https(
        'fxapi.app',
        '/api/history/$base/${target ?? base}.json',
        {'from': start, 'to': end},
      );
    }

    // CASE 2: single date
    else if (date != null) {
      uri = Uri.https(
        'fxapi.app',
        '/api/history/$base/${target ?? base}.json',
        {'from': date, 'to': date},
      );
    }

    // CASE 3: pair
    else if (target != null) {
      uri = Uri.https('fxapi.app', '/api/$base/$target.json');
    }

    // CASE 4: base rates
    else {
      uri = Uri.https(
        'fxapi.app',
        '/api/$base.json',
      );
    }

    logger.info('fx_currency> request url: $uri');
    logger.info('fx_currency> args: $args');

    final response = await http.get(uri);

    logger.info(
      'fx_currency> response status=${response.statusCode}',
    );
    logger.info(
      'fx_currency> response body: ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'FX API error: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    double? rate;

    if (decoded is Map<String, dynamic>) {
      if (decoded['rate'] != null) {
        rate = (decoded['rate'] as num).toDouble();
      } else if (decoded['rates'] is Map && target != null) {
        rate = (decoded['rates'][target] as num?)?.toDouble();
      } else if (decoded['rates'] is List) {
        final list = decoded['rates'] as List;
        if (list.isNotEmpty && list.last is Map) {
          rate = (list.last['rate'] as num?)?.toDouble();
        }
      }
    }

    final result = rate != null ? rate * amount : null;

    logger.info('fx_currency> rate=$rate result=$result');

    return CallToolResult.fromStructuredContent({
      'base': base,
      'target': target,
      'rate': rate,
      'amount': amount,
      'result': result,
      'url': uri.toString(),
      'raw': decoded,
    });
  }
}
