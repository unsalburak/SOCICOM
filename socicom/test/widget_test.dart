
import 'package:flutter_test/flutter_test.dart';

import 'package:socicom/main.dart'; // SocicomApp sınıfının olduğu dosyayı import et

void main() {
  testWidgets('SocicomApp smoke test', (WidgetTester tester) async {
    // Uygulamayı yükle ve bir frame tetikle
    await tester.pumpWidget(const SocicomApp());

    // Başlangıçta iki butonun ekran üzerinde göründüğünü doğrula.
    expect(find.text('Müşteri Giriş'), findsOneWidget);
    expect(find.text('İşletme Giriş'), findsOneWidget);

    // "Müşteri Giriş" butonuna tıkla ve bir frame tetikle.
    await tester.tap(find.text('Müşteri Giriş'));
    await tester.pumpAndSettle(); // Sayfa değişiminde animasyon varsa onun tamamlanmasını bekler.

    // Giriş ekranına yönlendirme olduğunu doğrula.
    // Örneğin giriş ekranında 'Müşteri Girişi' başlığını bul.
    expect(find.text('Müşteri Girişi'), findsOneWidget);
  });
}
