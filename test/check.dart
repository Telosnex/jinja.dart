import 'package:jinja/reflection.dart';
import 'package:jinja/src/compiler.dart';
import 'package:jinja/src/context.dart';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/optimizer.dart';
import 'package:jinja/src/visitor.dart';
import 'package:stack_trace/stack_trace.dart';

const String source = '''
{% set ns = namespace(d, self=37) %}
{% set ns.b = 42 %}
{{ ns.a }}|{{ ns.self }}|{{ ns.b }}''';

const Map<String, Object?> context = <String, Object?>{
  'd': {'a': 13}
};

void main() {
  try {
    var environment = Environment(getAttribute: getAttribute);

    var tokens = environment.lex(source);
    // print('tokens:');

    // for (var token in tokens) {
    //   print('${token.type}: ${token.value}');
    // }

    var printer = Printer(environment);

    var body = environment.scan(tokens);
    print('\noriginal nodes:');
    print(printer.visit(body));

    body = body.accept(const Optimizer(), Context(environment));
    print('\noptimized body:');
    print(printer.visit(body));

    var macroses = <String>{};
    body = body.accept(const RuntimeCompiler(), macroses);
    print('\nmacroses: ${macroses.join(', ')}');
    print('\ncompiled body:');
    print(printer.visit(body));

    var template = Template.fromNode(environment, body: body);
    print('\nrender:');
    print(template.render(context));
  } catch (error, trace) {
    print(error);
    print(Trace.format(trace, terse: true));
  }
}

// ignore_for_file: avoid_print, depend_on_referenced_packages
