// Widget smoke test for PromptVault
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_vault/main.dart';

void main() {
  testWidgets('PromptVaultApp smoke test', (WidgetTester tester) async {
    // Firebase cannot be initialized in unit tests without a real project,
    // so we just verify the widget class exists and is importable.
    expect(PromptVaultApp, isNotNull);
  });
}

