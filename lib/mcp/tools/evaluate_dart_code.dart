import 'package:apollovm/apollovm.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Executes Dart code using ApolloVM.
class EvaluateDartCodeTool extends BaseTool {
  @override
  String get name => 'evaluate_dart_code';

  @override
  String get description =>
      'Executes Dart code dynamically using Apollo VM and returns the evaluated result of the code';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'code': JsonSchema.string(
            description: """
Dart code to execute.

Rules:
- Must be valid Dart code
- No imports or dependencies
- Should return a value (last expression or explicit return)
- Can define variables, functions, classes

Examples:

- Simple expression:
  "1 + 2"

- Using variables and statements:
  "int x = 5; x *= 2; x;"

- Defining and calling a function with conditional logic:
'''
int sumOrDouble(int a, int b) {
  if (a > b) {
    return a + b;
  } else {
    return (a + b) * 2;
  }
}
'''

""",
          ),
          'function': JsonSchema.string(
            description: """
Function name to invoke after loading the code.

- Defaults to `main` if not provided
- Must match a function defined in the code

Example:
- "sumOrDouble"
""",
            defaultValue: 'main',
          ),
          'parameters': JsonSchema.array(
            description: """
Parameters to pass to the invoked function.

- Must match the function signature
- Order matters

Example:
- [3, 4]
""",
          ),
        },
        required: ['code'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'invokedFunction': JsonSchema.string(
            description: 'Name of the function that was invoked.',
          ),
          'result': JsonSchema.anyOf(
            [
              JsonSchema.string(),
              JsonSchema.number(),
              JsonSchema.integer(),
              JsonSchema.boolean(),
              JsonSchema.array(),
              JsonSchema.object(),
              JsonSchema.nullValue(),
            ],
            description: 'Execution result',
          ),
          'output': JsonSchema.array(
            items: JsonSchema.string(),
            description:
                'Captured stdout: one entry per print() call, in order',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
      Map<String, dynamic> args, RequestHandlerExtra? extra) async {
    logger.info("evaluate_dart_code> $args");

    final code = args['code'] as String;
    var function = (args['function'] as String?)?.trim();
    final parameters = args['parameters'] as List?;

    try {
      // Create VM
      final vm = ApolloVM();

      var codeUnit = SourceCodeUnit('dart', code);

      try {
        var loadOK = await vm.loadCodeUnit(codeUnit);

        if (!loadOK) {
          return CallToolResult(
            content: [
              TextContent(text: "Can't load code!"),
            ],
            isError: true,
          );
        }
      } catch (e) {
        return CallToolResult(
          content: [
            TextContent(text: 'Error loading code: $e'),
          ],
          isError: true,
        );
      }

      if (function == null || function.isEmpty) {
        var namespace = vm.getNamespace('dart', '');
        var loadedFunctions = namespace?.functions ?? [];

        logger.info(
            "evaluate_dart_code> Function variable was empty or null. Checking namespace loaded functions: $loadedFunctions");

        if (loadedFunctions.isEmpty) {
          function = 'main';
          logger.info(
              "evaluate_dart_code> No functions found in 'dart' namespace. Setting function to default 'main'.");
        } else if (loadedFunctions.length == 1) {
          function = loadedFunctions.first;
          logger.info(
              "evaluate_dart_code> Single function found in 'dart' namespace. Setting function to: $function");
        } else {
          // Log which function was chosen when multiple exist
          function = loadedFunctions.last;
          logger.info(
              "evaluate_dart_code> Multiple functions found (count: ${loadedFunctions.length}). Setting function to the last loaded: $function");
        }
      }

      final dartRunner = vm.createRunner('dart')!;

      final output = <String>[];

      // Map the `print` function in the VM:
      dartRunner.externalPrintFunction = (o) => output.add('$o');

      logger.info(
          "evaluate_dart_code> executing function: $function( ${parameters != null ? parameters.join(', ') : ''} )");

      final astValue = await dartRunner.executeFunction(
        '',
        function,
        positionalParameters: parameters,
      );

      final value = astValue.getValueNoContext();

      logger.info("evaluate_dart_code> result: $value");

      final result = toJsonType(value) ?? value;

      logger.info("evaluate_dart_code> result as json: $result");

      logger.info("evaluate_dart_code> output: <<<\n${output.join('\n')}\n>>>");

      return CallToolResult.fromStructuredContent({
        'invokedFunction': function,
        'result': result,
        'output': output,
      });
    } catch (e, st) {
      return CallToolResult(
        content: [
          TextContent(text: 'Failed to execute Dart code: $e\n$st'),
        ],
        isError: true,
      );
    }
  }
}
