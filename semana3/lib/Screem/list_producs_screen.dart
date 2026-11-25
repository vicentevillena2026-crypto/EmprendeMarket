import 'package:flutter/material.dart';

void main() => runApp(const ListProducsScreen());

const orange = Color(0xFFE8590C);
const cream = Color(0xFFF4F1EC);
const ink = Color(0xFF1D1B18);
const muted = Color(0xFF6F6A62);

class Product {
  final String name;
  final double price;
  final String image;
  const Product(this.name, this.price, this.image);
}

const products = [
  Product('Polera algodón pima', 45, 'images/product_0.jpg'),
  Product('Casaca jean artesanal', 120, 'images/product_1.jpg'),
  Product('Collar de plata', 65, 'images/product_2.jpg'),
  Product('Mochila tejida', 90, 'images/product_3.jpg'),
  Product('Audífonos Bluetooth', 79, 'images/product_4.jpg'),
  Product('Vela aromática', 30, 'images/product_5.jpg'),
];

String money(num n) => 'S/ ${n.toStringAsFixed(2)}';
String stamp() { final d = DateTime.now(); return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'; }

class Order {
  final int id;
  final Map<int, int> items;
  final double total;
  final String date;
  final bool paid;
  Order(this.id, this.items, this.total, this.date, this.paid);
}

class Review {
  final int product;
  final int stars;
  final String comment;
  final String date;
  Review(this.product, this.stars, this.comment, this.date);
}

class Entry {
  final String title;
  final String date;
  final double? amount;
  bool unread;
  final String? message;
  Entry(this.title, this.date, {this.amount, this.message, this.unread = false});
}

class ListProducsScreen extends StatelessWidget {
  const ListProducsScreen({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'EmprendeMarket', debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: orange, primary: orange),
        filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: ink, minimumSize: const Size.fromHeight(43), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13)),
      ), home: const MarketPage());
}

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});
  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int tab = 0;
  String view = 'menu';
  String userName = '', business = '';
  Map<int, int> cart = {};
  final List<Order> orders = [];
  final List<Review> reviews = [];
  final List<Entry> history = [Entry('Te uniste a EmprendeMarket', stamp())];
  final List<Entry> messages = [Entry('EmprendeMarket', stamp(), message: 'Te damos la bienvenida. Aquí recibirás avisos de tus pedidos y de los vendedores.', unread: true)];
  final List<Entry> movements = [];
  double credit = 0;
  int nextOrder = 1000;
  int get cartCount => cart.values.fold(0, (a, b) => a + b);
  double get cartTotal => cart.entries.fold(0, (double a, e) => a + products[e.key].price * e.value);
  List<int> get pendingProducts {
    final purchased = <int>{};
    for (final o in orders) { purchased.addAll(o.items.keys); }
    return purchased.where((i) => !reviews.any((r) => r.product == i)).toList();
  }
  void notify(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  void go(String destination) => setState(() { tab = 1; view = destination; if (destination == 'msgs') { for (final m in messages) { m.unread = false; } } });
  void add(int i) {
    setState(() { cart[i] = (cart[i] ?? 0) + 1; history.insert(0, Entry('Agregaste ${products[i].name} al carrito', stamp())); });
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Icon(Icons.check_circle, color: orange, size: 48),
      content: Text('${products[i].name}\n\nSu producto fue llevado a su carrito exitosamente', textAlign: TextAlign.center),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Seguir comprando')),
        FilledButton(onPressed: () { Navigator.pop(ctx); showCart(); }, child: const Text('Ver carrito'))],
    ));
  }
  void showCart() => showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => Padding(
    padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 30),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Mi carrito', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 14),
      if (cart.isEmpty) const Text('Tu carrito está vacío'),
      ...cart.entries.map((e) => ListTile(contentPadding: EdgeInsets.zero, title: Text(products[e.key].name), subtitle: Text('${e.value} × ${money(products[e.key].price)}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { setState(() { if (e.value <= 1) { cart.remove(e.key); } else { cart[e.key] = e.value - 1; } }); refresh(() {}); }),
        Text(money(products[e.key].price * e.value)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () { setState(() { cart[e.key] = e.value + 1; }); refresh(() {}); }),
      ]))),
      const Divider(), Text('Total: ${money(cartTotal)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      FilledButton(onPressed: cart.isEmpty ? null : () { Navigator.pop(ctx); buy(); }, child: const Text('Comprar ahora')),
    ]),
  )));
  void buy() {
    if (cart.isEmpty) return;
    final total = cartTotal;
    final paid = credit >= total;
    final id = ++nextOrder;
    setState(() {
      if (paid) { credit = double.parse((credit - total).toStringAsFixed(2)); movements.insert(0, Entry('Pago del pedido #$id', stamp(), amount: -total)); }
      orders.insert(0, Order(id, Map.of(cart), total, stamp(), paid));
      messages.insert(0, Entry('Pedido #$id', stamp(), message: 'Recibimos tu pedido. El vendedor lo está preparando y te avisará cuando salga.', unread: true));
      history.insert(0, Entry('Compraste ${cart.length} producto(s) por ${money(total)} (pedido #$id)', stamp()));
      cart.clear();
    });
    notify('¡Pedido enviado! ✅');
  }
  Widget panel(Widget child, {EdgeInsets padding = const EdgeInsets.all(12)}) => Container(
      padding: padding, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE6E0D8)), borderRadius: BorderRadius.circular(16)), child: child);
  Widget heading(String title) => Row(children: [IconButton(onPressed: () => setState(() => view = 'menu'), icon: const Icon(Icons.arrow_back_ios_new)), Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)))]);
  Widget section(String s) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 9), child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600, color: muted)));
  Widget empty(String s) => Padding(padding: const EdgeInsets.symmetric(vertical: 30), child: Center(child: Text(s, textAlign: TextAlign.center, style: const TextStyle(color: muted))));
  Widget productPhoto(int i, double size) => ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(products[i].image, width: size, height: size, fit: BoxFit.cover));
  Widget home() => ListView(padding: const EdgeInsets.all(16), children: [
    RichText(text: const TextSpan(style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ink), children: [TextSpan(text: 'Emprende'), TextSpan(text: 'Market', style: TextStyle(color: orange)), TextSpan(text: ' 🛍️')])),
    const SizedBox(height: 5), Text(userName.isEmpty ? 'Compra y vende local' : 'Hola, $userName 👋', style: const TextStyle(color: muted)), const SizedBox(height: 15),
    GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 258),
      itemBuilder: (context, i) => panel(Column(children: [Expanded(child: SizedBox(width: double.infinity, child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(products[i].image, fit: BoxFit.cover)))),
        const SizedBox(height: 8), Text(products[i].name, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(money(products[i].price), style: const TextStyle(fontWeight: FontWeight.bold, color: orange)),
        const SizedBox(height: 6), FilledButton(onPressed: () => add(i), child: const Text('Agregar'))])),
    ),
    if (cart.isNotEmpty) ...[const SizedBox(height: 20), panel(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...cart.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text('${e.value} × ${products[e.key].name}')), Text(money(products[e.key].price * e.value))]))),
      const Divider(), Text('Total: ${money(cartTotal)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      FilledButton(onPressed: showCart, child: const Text('Ver carrito / Comprar ahora')),
    ]))],
  ]);
  Widget profile() {
    if (view != 'menu') return subview();
    final unread = messages.where((m) => m.unread).length;
    final initials = userName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).take(2).map((s) => s[0].toUpperCase()).join();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(child: CircleAvatar(radius: 36, backgroundColor: orange, child: Text(initials.isEmpty ? '👤' : initials, style: const TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 10), Center(child: Text(userName.isEmpty ? 'Tu nombre' : userName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
      Center(child: Text(business.isEmpty ? 'Sin emprendimiento' : business, style: const TextStyle(color: muted))), const SizedBox(height: 14),
      InkWell(onTap: () => go('credit'), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(18)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Saldo de crédito'), Text(money(credit), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))])), const Text('Recargar  ›', style: TextStyle(fontWeight: FontWeight.bold))]))),
      const SizedBox(height: 12), Row(children: [stat('$cartCount', 'En carrito'), const SizedBox(width: 8), stat('${orders.length}', 'Pedidos'), const SizedBox(width: 8), stat('${reviews.length}', 'Reseñas')]), const SizedBox(height: 10),
      menuRow(Icons.inventory_2_outlined, 'Mis pedidos', 'orders', '${orders.length}'),
      menuRow(Icons.chat_bubble_outline, 'Mensajes', 'msgs', unread == 0 ? '' : '$unread'),
      menuRow(Icons.star_outline, 'Reseñas', 'reviews', pendingProducts.isEmpty ? '' : '${pendingProducts.length} por hacer'),
      menuRow(Icons.history, 'Historial', 'hist', ''),
      menuRow(Icons.credit_card, 'Saldo de crédito', 'credit', money(credit)),
      menuRow(Icons.person_outline, 'Editar perfil', 'edit', ''),
    ]);
  }
  Widget stat(String number, String label) => Expanded(child: panel(Column(children: [Text(number, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: orange)), Text(label, style: const TextStyle(fontSize: 11, color: muted))]), padding: const EdgeInsets.all(8)));
  Widget menuRow(IconData icon, String title, String destination, String badge) => Padding(padding: const EdgeInsets.only(top: 8), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE6E0D8))), leading: Icon(icon, color: orange), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (badge.isNotEmpty) Text(badge, style: const TextStyle(color: muted, fontSize: 12)), const Icon(Icons.chevron_right)]), onTap: () => go(destination))));
  Widget subview() {
    switch (view) {
      case 'orders': return ListView(padding: const EdgeInsets.all(16), children: [heading('Mis pedidos'), if (orders.isEmpty) empty('Aún no tienes pedidos. Agrega productos en Inicio y toca Comprar ahora.'), ...orders.map((o) => Padding(padding: const EdgeInsets.only(top: 10), child: panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text('Pedido #${o.id}', style: const TextStyle(fontWeight: FontWeight.bold))), const Chip(label: Text('En preparación'))]), Text(o.date, style: const TextStyle(color: muted, fontSize: 12)), const SizedBox(height: 7), Wrap(spacing: 5, children: o.items.keys.map((i) => productPhoto(i, 40)).toList()), ...o.items.entries.map((e) => ListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text('${e.value} × ${products[e.key].name}'), trailing: Text(money(products[e.key].price * e.value)))), const Divider(), Text('Total: ${money(o.total)}', style: const TextStyle(fontWeight: FontWeight.bold)), Text(o.paid ? 'Pagado con tu saldo' : 'Pago al recibir', style: const TextStyle(color: muted, fontSize: 12))]))))]);
      case 'msgs': return ListView(padding: const EdgeInsets.all(16), children: [heading('Mensajes'), ...messages.map((m) => Padding(padding: const EdgeInsets.only(top: 10), child: panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(m.date, style: const TextStyle(color: muted, fontSize: 12)), const SizedBox(height: 8), Text(m.message ?? '')]))))]);
      case 'reviews': return reviewsView();
      case 'hist': return ListView(padding: const EdgeInsets.all(16), children: [heading('Historial'), ...history.take(40).map((e) => ListTile(leading: const Icon(Icons.circle, size: 10, color: orange), title: Text(e.title), subtitle: Text(e.date)))]);
      case 'credit': return creditView();
      case 'edit': return editView();
      default: return const SizedBox.shrink();
    }
  }
  Widget reviewsView() => ListView(padding: const EdgeInsets.all(16), children: [heading('Reseñas'), if (pendingProducts.isNotEmpty) section('Por reseñar'), ...pendingProducts.map((i) => ReviewForm(key: ValueKey('review_$i'), product: products[i], onPublish: (stars, comment) { setState(() { reviews.insert(0, Review(i, stars, comment, stamp())); history.insert(0, Entry('Reseñaste ${products[i].name}', stamp())); }); notify('Reseña publicada'); })), section('Mis reseñas'), if (reviews.isEmpty) empty(orders.isEmpty ? 'Cuando hagas un pedido podrás reseñar tus productos aquí.' : 'Aún no publicaste reseñas.'), ...reviews.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [productPhoto(r.product, 44), const SizedBox(width: 10), Expanded(child: Text(products[r.product].name, style: const TextStyle(fontWeight: FontWeight.bold)))]), Text('★' * r.stars + '☆' * (5 - r.stars), style: const TextStyle(color: orange, fontSize: 22)), if (r.comment.isNotEmpty) Text(r.comment), Text(r.date, style: const TextStyle(color: muted, fontSize: 12))]))))]);
  Widget creditView() {
    final ctrl = TextEditingController();
    return ListView(padding: const EdgeInsets.all(16), children: [heading('Saldo de crédito'), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Saldo disponible'), Text(money(credit), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))])), section('Recargar saldo'), const Text('Monto a recargar (mínimo S/ 20.00)'), const SizedBox(height: 8), TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'Ej: 45.39')), const SizedBox(height: 10), FilledButton(onPressed: () { final raw = ctrl.text.trim().replaceAll(',', '.'); final valid = RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(raw); final value = valid ? double.tryParse(raw) : null; if (value == null || value < 20) { notify('Escribe un monto válido de al menos S/ 20.00 (máximo 2 decimales)'); return; } setState(() { credit = double.parse((credit + value).toStringAsFixed(2)); movements.insert(0, Entry('Recarga de saldo', stamp(), amount: value)); history.insert(0, Entry('Recargaste ${money(value)} de saldo', stamp())); }); notify('Saldo recargado'); }, child: const Text('Recargar saldo')), const SizedBox(height: 8), const Text('Si tu saldo cubre el total de la compra, se usa automáticamente.', style: TextStyle(color: muted, fontSize: 12)), section('Movimientos'), if (movements.isEmpty) empty('Todavía no tienes movimientos. Recarga saldo para pagar más rápido.'), ...movements.map((m) => Padding(padding: const EdgeInsets.only(bottom: 8), child: panel(Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(m.date, style: const TextStyle(fontSize: 12, color: muted))])), Text('${m.amount! < 0 ? '-' : '+'}${money(m.amount!.abs())}', style: TextStyle(color: m.amount! < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))]))))]);
  }
  Widget editView() {
    final name = TextEditingController(text: userName);
    final biz = TextEditingController(text: business);
    return ListView(padding: const EdgeInsets.all(16), children: [heading('Editar perfil'), section('Tu nombre'), TextField(controller: name, decoration: const InputDecoration(hintText: 'Ej: María Quispe')), section('Tu emprendimiento'), TextField(controller: biz, decoration: const InputDecoration(hintText: 'Ej: Cuero Real')), const SizedBox(height: 16), FilledButton(onPressed: () { setState(() { userName = name.text.trim(); business = biz.text.trim(); history.insert(0, Entry('Actualizaste tu perfil', stamp())); }); notify('Perfil guardado ✅'); }, child: const Text('Guardar perfil'))]);
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: tab == 0 ? home() : profile()))), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() { tab = i; view = 'menu'; }), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Mi perfil')]));
}

class ReviewForm extends StatefulWidget {
  final Product product;
  final void Function(int, String) onPublish;
  const ReviewForm({super.key, required this.product, required this.onPublish});
  @override State<ReviewForm> createState() => _ReviewFormState();
}
class _ReviewFormState extends State<ReviewForm> {
  int stars = 0;
  final comment = TextEditingController();
  @override void dispose() { comment.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)), Row(children: List.generate(5, (i) => IconButton(onPressed: () => setState(() => stars = i + 1), icon: Icon(i < stars ? Icons.star : Icons.star_border, color: orange)))), TextField(controller: comment, decoration: const InputDecoration(hintText: 'Cuéntanos qué te pareció (opcional)')), const SizedBox(height: 8), FilledButton(onPressed: () { if (stars == 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Elige de 1 a 5 estrellas'))); return; } widget.onPublish(stars, comment.text.trim()); }, child: const Text('Publicar reseña'))])));
}
