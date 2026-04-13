import 'package:math_expressions/math_expressions.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Evaluates a mathematical expression using math_expressions.
class EvaluateExpressionTool extends BaseTool {
  @override
  String get name => 'evaluate_expression';

  @override
  String get description =>
      'Evaluates a mathematical expression (supports variables and functions)';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'expression': JsonSchema.string(
            description: '''
Mathematical expression to evaluate.

Syntax rules:
- Use standard operators: +, -, *, /, %, ^ (power)
- Use parentheses () to control precedence
- Use dot (.) for decimals (e.g. 3.14)
- Variables are plain names (e.g. x, price, total)
- Functions use standard math names
- Constants available: pi, e

Supported functions (examples):
- Trigonometric: sin(x), cos(x), tan(x)
- Inverse trig: asin(x), acos(x), atan(x)
- Logarithmic: log(x), ln(x)
- Roots: sqrt(x)
- Others: abs(x), exp(x)

Variables:
- Pass variables separately in the "variables" object
- All variables used in the expression must be defined there

Examples:
- "2 + 3 * 4"
- "2 * x + 1" with { "x": 5 }
- "sin(pi / 2)"
- "sqrt(a^2 + b^2)" with { "a": 3, "b": 4 }
- "log(100) / ln(e)"

Notes:
- Use ^ for exponentiation (NOT **)
- Multiplication must be explicit (use 2 * x, not 2x)
- Angles are in radians
''',
          ),
          'variables': JsonSchema.object(
            description: '''
Optional map of variable values.

Rules:
- Keys must match variable names used in the expression
- Values must be numeric

Examples:
{ "x": 5 }
{ "a": 3, "b": 4 }
{ "price": 10.5, "qty": 3 }
''',
          ),
        },
        required: ['expression'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'result': JsonSchema.number(
            description: 'Evaluated result',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
      Map<String, dynamic> args, RequestHandlerExtra? extra) async {
    logger.info("evaluate_expression> $args");

    final expressionStr = args['expression'] as String;
    final variables =
        (args['variables'] as Map?)?.cast<String, dynamic>() ?? {};

    try {
      // Parse expression
      final parser = GrammarParser();
      final expr = parser.parse(expressionStr);

      // Bind variables
      final context = ContextModel();
      for (final entry in variables.entries) {
        context.bindVariable(
          Variable(entry.key),
          Number(entry.value.toDouble()),
        );
      }

      // Evaluate
      final result = RealEvaluator(context).evaluate(expr);

      return CallToolResult.fromStructuredContent({
        'result': result,
      });
    } catch (e) {
      return CallToolResult(
        content: [
          TextContent(text: 'Failed to evaluate expression: $e'),
        ],
        isError: true,
      );
    }
  }
}
