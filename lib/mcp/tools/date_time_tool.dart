import 'package:mcp_dart/mcp_dart.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/timezone.dart';
import 'base_tool.dart';

/// Returns current or relative date/time for a given location.
class DateTimeTool extends BaseTool {
  @override
  String get name => 'get_datetime';

  @override
  String get description =>
      'Returns the current or relative date/time (today, tomorrow, +/- days) for a given location';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'countryCode': JsonSchema.string(
            description: 'ISO country code (e.g. US, BR, JP)',
          ),
          'stateCode': JsonSchema.string(
            description:
                'Optional state/region code (e.g. CA for US, SP for BR)',
          ),
          'timezone': JsonSchema.string(
            description:
                'Optional IANA timezone (e.g. America/New_York). Overrides country/state',
          ),
          'dayOffset': JsonSchema.number(
            description: '''
Integer offset in days:
0 = today
1 = tomorrow
-1 = yesterday
2 = in 2 days
7 = in 1 week
''',
          ),
          'date': JsonSchema.string(
            description: '''
Optional keyword:
- "now"
- "today"
- "tomorrow"
- "yesterday"

Ignored if dayOffset is provided
''',
          ),
        },
      );

  @override
  ToolOutputSchema get outputSchema => ToolOutputSchema(
        properties: {
          'iso': JsonSchema.string(
            description: 'ISO8601 datetime string',
          ),
          'timezone': JsonSchema.string(
            description: 'Resolved timezone name',
          ),
          'date': JsonSchema.string(
            description: 'Date in YYYY-MM-DD',
          ),
          'offsetMinutes': JsonSchema.number(
            description: 'Timezone offset in minutes',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    try {
      final countryCode = (args['countryCode'] as String?)?.toUpperCase();
      final stateCode = args['stateCode'] as String?;
      final tzName = args['timezone'] as String?;

      final location = resolveLocation(tzName, countryCode, stateCode);

      // Resolve day offset
      var dayOffset = 0;

      if (args.containsKey('dayOffset')) {
        dayOffset = (args['dayOffset'] as num).toInt();
      } else if (args.containsKey('date')) {
        final d = (args['date'] as String).toLowerCase();
        switch (d) {
          case 'tomorrow':
            dayOffset = 1;
            break;
          case 'yesterday':
            dayOffset = -1;
            break;
          case 'today':
          case 'now':
            dayOffset = 0;
            break;
        }
      }

      // Get base time
      var now = tz.TZDateTime.now(location);

      // Apply offset
      if (dayOffset != 0) {
        now = now.add(Duration(days: dayOffset));
      }

      final iso = now.toIso8601StringNoNanoseconds();

      return CallToolResult.fromStructuredContent({
        'iso': iso,
        'timezone': location.name,
        'date': "${now.year}-${_two(now.month)}-${_two(now.day)}",
        'time': "${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}",
        'offsetMinutes': now.timeZone.offset.inMinutes,
      });
    } catch (e) {
      return CallToolResult(
        content: [
          TextContent(text: 'Failed to get date/time: $e'),
        ],
        isError: true,
      );
    }
  }

  tz.Location resolveLocation(
      String? tzName, String? countryCode, String? stateCode) {
    final timeZone = TimeZone();

    if (tzName != null) {
      var tzNameUC = tzName.trim().toUpperCase();
      if (tzNameUC == 'GMT' || tzNameUC == 'UTC') {
        timeZone.getLocationGMT();
      }

      return tz.getLocation(tzName);
    } else if (countryCode != null) {
      return timeZone.getMainLocation(countryCode, stateCode) ??
          (throw tz.LocationNotFoundException(
              'Location for country "$countryCode"'
              '${stateCode != null ? ' and state "$stateCode"' : ''} not found'));
    } else {
      return timeZone.getLocationGMT();
    }
  }

  String _two(int n) => n >= 10 ? '$n' : '0$n';
}
