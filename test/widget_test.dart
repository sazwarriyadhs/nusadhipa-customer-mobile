import 'package:flutter_test/flutter_test.dart';
import 'package:nusadhipa_business_mobile/main.dart';

void main() {
  testWidgets('NUSA-DHIPA Business Mobile dapat dibuka', (tester) async {
    await tester.pumpWidget(const NusadhipaBusinessApp());
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Kirim'), findsOneWidget);
    expect(find.text('Toko'), findsOneWidget);
  });
}