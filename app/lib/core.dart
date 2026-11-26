part of 'main.dart';

const base = String.fromEnvironment('API', defaultValue: 'http://10.0.2.2:8080');

const photo = '$base/static/janhavi.png';

const logo = '$base/static/logo.png';

String token = '';

Future buy(BuildContext c, String id, [String coupon = '']) async {
  final r = await api('POST', '/api/pay/order', {'itemId': id, 'coupon': coupon});
  if (r['url'] == null) return snack(c, r['error'] ?? 'Payment error');
  await launchUrl(Uri.parse(r['url']), mode: LaunchMode.externalApplication);
}

Map me = {};

Future api(String m, String p, [Map? b]) async {
  final root = base.replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/api$'), '');
  try {
    final h = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    final u = Uri.parse(root + p);
    final f = m == 'GET' ? http.get(u, headers: h) : http.post(u, headers: h, body: jsonEncode(b ?? {}));
    final r = await f.timeout(const Duration(seconds: 70));
    try {
      return jsonDecode(r.body);
    } catch (_) {
      final t = r.body.length > 80 ? r.body.substring(0, 80) : r.body;
      return {'error': 'Unexpected server response (code ${r.statusCode}): $t | URL: $root'};
    }
  } catch (e) {
    final t = e.toString();
    return {'error': 'Could not connect: ${t.length > 90 ? t.substring(0, 90) : t} | URL: $root'};
  }
}

void go(BuildContext c, Widget w) => Navigator.push(c, PageRouteBuilder(transitionDuration: const Duration(milliseconds: 350), pageBuilder: (_, __, ___) => w, transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)), child: child))));

void snack(BuildContext c, String s) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(s)));

void page(BuildContext c, String t, Widget w) => go(c, Scaffold(appBar: AppBar(title: Text(t)), body: w));

class Pulse extends StatefulWidget { final Widget child; const Pulse(this.child, {super.key}); @override State<Pulse> createState() => _P(); }

class _P extends State<Pulse> with SingleTickerProviderStateMixin {
  late final a = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override void dispose() { a.dispose(); super.dispose(); }
  @override Widget build(BuildContext c) => ScaleTransition(scale: Tween(begin: 0.92, end: 1.08).animate(a), child: widget.child);
}

Widget cimg(Map k, double h) => ClipRRect(borderRadius: BorderRadius.circular(14), child: (k['Image'] ?? '').toString().isEmpty ? Container(height: h, width: double.infinity, color: const Color(0xFFDDD6FE), child: const Icon(Icons.menu_book, size: 36, color: Color(0xFF6D28D9))) : Image.network(k['Image'].toString().startsWith('http') ? k['Image'] : base + k['Image'], height: h, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: h, color: const Color(0xFFDDD6FE))));

Widget priceRow(num p, num mrp) => Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 4, children: [
      Text('₹$p', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)), const SizedBox(width: 8),
      Text('₹$mrp', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)), const SizedBox(width: 8),
      Pulse(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
          child: Text('${((mrp - p) * 100 / mrp).round()}% OFF', style: const TextStyle(color: Colors.white, fontSize: 12)))),
    ]);

const _blue = Color(0xFF6D28D9);

const _dark = Color(0xFF2E1065);

const _gold = Color(0xFFFBBF24);

class Fade extends StatelessWidget {
  final Widget child; final int i;
  const Fade(this.child, {super.key, this.i = 0});
  @override Widget build(BuildContext c) => TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 350 + i * 90), curve: Curves.easeOut, builder: (_, v, ch) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: ch)), child: child);
}

String dateStr(int secs) {
  final d = DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

void finishLogin(BuildContext c, dynamic r) {
  if (r is! Map || r['token'] == null) {
    snack(c, (r is Map ? r['error'] : null) ?? 'Login failed');
    return;
  }
  token = r['token'];
  me = r['user'];
  Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const Home()), (_) => false);
}
