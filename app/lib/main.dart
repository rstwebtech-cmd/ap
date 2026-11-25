import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

const base = String.fromEnvironment('API', defaultValue: 'http://10.0.2.2:8080');
const photo = 'https://janhavipanwar.com/frontend/jp-about/assets/uploads/img_d8724e3aa2.jpg';
const logo = 'https://janhavipanwar.com/frontend/jp-about/assets/uploads/img_238145b020.png';
String token = '';
Future buy(BuildContext c, String id) async {
  final r = await api('POST', '/api/pay/order', {'itemId': id});
  if (r['url'] == null) return snack(c, r['error'] ?? 'Payment error');
  await launchUrl(Uri.parse(r['url']), mode: LaunchMode.externalApplication);
}
Map me = {};
Future api(String m, String p, [Map? b]) async {
  final h = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  final u = Uri.parse(base + p);
  final r = m == 'GET' ? await http.get(u, headers: h) : await http.post(u, headers: h, body: jsonEncode(b ?? {}));
  return jsonDecode(r.body);
}

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF1D4ED8), scaffoldBackgroundColor: const Color(0xFFEEF2FF), useMaterial3: true),
    home: const Login()));

void go(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));
void snack(BuildContext c, String s) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(s)));

class Login extends StatefulWidget { const Login({super.key}); @override State<Login> createState() => _L(); }
class _L extends State<Login> {
  final ph = TextEditingController(), otp = TextEditingController(), nm = TextEditingController();
  bool sent = false;
  void done(r) {
    if (r['token'] == null) return snack(context, r['error'] ?? 'Failed');
    token = r['token']; me = r['user'];
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
  }
  @override Widget build(BuildContext c) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Center(child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 50, backgroundImage: const NetworkImage(photo), onBackgroundImageError: (_, __) {}), const SizedBox(height: 8),
            const Text('Janhavi Panwar', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Text('Wonder Girl of India'), const SizedBox(height: 16),
            TextField(controller: nm, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: ph, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile (+91...)')),
            if (sent) TextField(controller: otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 12),
            FilledButton(onPressed: () async {
              if (!sent) { await api('POST', '/api/auth/otp/send', {'phone': ph.text}); setState(() => sent = true); }
              else { done(await api('POST', '/api/auth/otp/verify', {'phone': ph.text, 'code': otp.text, 'name': nm.text})); }
            }, child: Text(sent ? 'Verify OTP' : 'Send OTP')),
            OutlinedButton.icon(icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text('Continue with Google'), onPressed: () async {
              final a = await (await GoogleSignIn(scopes: ['email']).signIn())?.authentication;
              if (a?.idToken != null) done(await api('POST', '/api/auth/google', {'idToken': a!.idToken}));
            }),
          ])))),
        ),
      );
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _H(); }
class _H extends State<Home> {
  int i = 0;
  @override Widget build(BuildContext c) {
    final tabs = [HomeTab((v) => setState(() => i = v)), const Courses(), const LiveTab(), const QuizTab(), const Profile()];
    return Scaffold(
      appBar: i == 0 ? AppBar(backgroundColor: Colors.transparent, title: Image.network(logo, height: 36, errorBuilder: (_, __, ___) => const Text('Janhavi Panwar LMS')), actions: [IconButton(icon: const Icon(Icons.support_agent), onPressed: () => go(c, const Chat(room: 'support', title: 'Live Support')))]) : null,
      body: SafeArea(child: tabs[i]),
      bottomNavigationBar: NavigationBar(selectedIndex: i, onDestinationSelected: (v) => setState(() => i = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.menu_book), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.videocam), label: 'Live'),
        NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Quiz'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ]));
  }
}
void page(BuildContext c, String t, Widget w) => go(c, Scaffold(appBar: AppBar(title: Text(t)), body: w));

class Pulse extends StatefulWidget { final Widget child; const Pulse(this.child, {super.key}); @override State<Pulse> createState() => _P(); }
class _P extends State<Pulse> with SingleTickerProviderStateMixin {
  late final a = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override void dispose() { a.dispose(); super.dispose(); }
  @override Widget build(BuildContext c) => ScaleTransition(scale: Tween(begin: 0.92, end: 1.08).animate(a), child: widget.child);
}
Widget priceRow(num p, num mrp) => Row(children: [
      Text('₹$p', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)), const SizedBox(width: 8),
      Text('₹$mrp', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)), const SizedBox(width: 8),
      Pulse(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
          child: Text('${((mrp - p) * 100 / mrp).round()}% OFF', style: const TextStyle(color: Colors.white, fontSize: 12)))),
    ]);

class Courses extends StatelessWidget {
  const Courses({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/courses'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final l = s.data as List;
        return ListView.builder(itemCount: l.length, itemBuilder: (_, i) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 300 + i * 120),
            builder: (_, v, ch) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: ch)),
            child: Card(margin: const EdgeInsets.all(10), child: ListTile(
              title: Text(l[i]['Title']), subtitle: priceRow(l[i]['Price'], l[i]['MRP']),
              trailing: const Icon(Icons.chevron_right), onTap: () => go(c, CourseScreen(l[i]))))));
      });
}

class CourseScreen extends StatefulWidget { final Map k; const CourseScreen(this.k, {super.key}); @override State<CourseScreen> createState() => _C(); }
class _C extends State<CourseScreen> {
  final rv = TextEditingController();
  @override Widget build(BuildContext c) {
    final k = widget.k;
    return Scaffold(appBar: AppBar(title: Text(k['Title'])), body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('${k['Category']} · ${k['Duration']}'), priceRow(k['Price'], k['MRP']), const SizedBox(height: 12),
      FilledButton(onPressed: () => buy(c, k['ID']), child: Text('Buy Now ₹${k['Price']}')),
      OutlinedButton(onPressed: () => go(c, Quiz(k)), child: const Text('Take Final Quiz → Get Certificate')),
      const Divider(), const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
      FutureBuilder(future: api('GET', '/api/reviews'), builder: (_, s) => Column(children: [
        for (final r in (s.data as List? ?? [])) ListTile(title: Text(r['Name']), subtitle: Text(r['Text']), trailing: Text('⭐${r['Stars']}'))])),
      TextField(controller: rv, decoration: const InputDecoration(labelText: 'Write a review (shown after approval)')),
      TextButton(onPressed: () async { await api('POST', '/api/reviews', {'courseId': k['ID'], 'text': rv.text, 'stars': 5}); rv.clear(); snack(c, 'Thanks! Review pending approval'); }, child: const Text('Submit review')),
    ]));
  }
}

class Combos extends StatelessWidget {
  const Combos({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/combos'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(children: [for (final b in s.data as List) Card(color: Colors.amber.shade50, margin: const EdgeInsets.all(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🔥 SPECIAL COMBO OFFER'), Text(b['Title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), priceRow(b['Price'], b['MRP']),
          FilledButton(onPressed: () => buy(c, b['ID']), child: const Text('Get Offer'))])))]);
      });
}

class Community extends StatelessWidget {
  const Community({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/groups'), builder: (_, s) => Scaffold(
        floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: () async {
          await api('POST', '/api/groups', {'name': 'Group ${DateTime.now().minute}${DateTime.now().second}'}); snack(c, 'Group created - reopen tab'); }),
        body: ListView(children: [for (final g in (s.data as List? ?? [])) ListTile(leading: const Icon(Icons.groups), title: Text(g['Name']), onTap: () => go(c, Chat(room: g['ID'], title: g['Name'])))])));
}

class Chat extends StatefulWidget { final String room, title; const Chat({super.key, required this.room, required this.title}); @override State<Chat> createState() => _Ch(); }
class _Ch extends State<Chat> {
  final t = TextEditingController(); List m = []; Timer? tm;
  Future poll() async { final r = await api('GET', '/api/chat?room=${widget.room}&after=0'); if (mounted) setState(() => m = r); }
  @override void initState() { super.initState(); poll(); tm = Timer.periodic(const Duration(seconds: 3), (_) => poll()); }
  @override void dispose() { tm?.cancel(); super.dispose(); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(widget.title)), body: Column(children: [
        Expanded(child: ListView(children: [for (final x in m) ListTile(dense: true, title: Text(x['Name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(x['Text']))])),
        Row(children: [Expanded(child: Padding(padding: const EdgeInsets.all(8), child: TextField(controller: t))), IconButton(icon: const Icon(Icons.send), onPressed: () async { await api('POST', '/api/chat', {'room': widget.room, 'text': t.text}); t.clear(); poll(); })])]));
}

class Quiz extends StatefulWidget { final Map k; const Quiz(this.k, {super.key}); @override State<Quiz> createState() => _Q(); }
class _Q extends State<Quiz> {
  List qs = []; Map<int, int> a = {};
  @override void initState() { super.initState(); api('GET', '/api/quiz/${widget.k['ID']}').then((v) => setState(() => qs = v)); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text('Final Quiz')), body: ListView(padding: const EdgeInsets.all(12), children: [
        for (var i = 0; i < qs.length; i++) Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('${i + 1}. ${qs[i]['Q']}', style: const TextStyle(fontWeight: FontWeight.bold))),
          for (var j = 0; j < qs[i]['Options'].length; j++) RadioListTile<int>(value: j, groupValue: a[i], title: Text(qs[i]['Options'][j]), onChanged: (v) => setState(() => a[i] = v!))])),
        FilledButton(onPressed: () async {
          final r = await api('POST', '/api/quiz/${widget.k['ID']}', {'answers': [for (var i = 0; i < qs.length; i++) a[i] ?? -1]});
          if (!mounted) return;
          showDialog(context: c, builder: (_) => AlertDialog(title: Text(r['passed'] ? '🎉 Passed ${r['score']}/${r['total']}' : 'Score ${r['score']}/${r['total']} - try again'),
              content: Text(r['passed'] ? 'Certificate: $base/certificate/${r['certificate']}' : 'Need 60% to pass')));
        }, child: const Text('Submit')),
      ]));
}

const _blue = Color(0xFF1D4ED8);
class HomeTab extends StatelessWidget {
  final void Function(int) jump;
  const HomeTab(this.jump, {super.key});
  Widget tile(IconData i, String t, String s, Color col) => Expanded(child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: col.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(i, color: col), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(s, style: const TextStyle(fontSize: 12))])));
  Widget big(String t, String s, IconData i, Color col, VoidCallback f) => Expanded(child: InkWell(onTap: f, child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(i, color: Colors.white, size: 32), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(s, style: const TextStyle(color: Colors.white70, fontSize: 12))]))]))));
  Widget head(String t) => Padding(padding: const EdgeInsets.fromLTRB(14, 16, 14, 6), child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
  Widget quick(IconData i, String t, VoidCallback f) => Expanded(child: InkWell(onTap: f, child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [Icon(i, color: _blue), Text(t, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)]))));
  @override Widget build(BuildContext c) => FutureBuilder(future: Future.wait([api('GET', '/api/me'), api('GET', '/api/courses'), api('GET', '/api/live')]), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final d = s.data as List; final u = d[0]['user']; final ids = (u['Courses'] as List? ?? []);
        final mine = (d[1] as List).where((x) => ids.contains(x['ID'])).toList(); final live = (d[2] as List? ?? []);
        final nm = (u['Name'] ?? '').toString().isEmpty ? 'Student' : u['Name'];
        return ListView(children: [
          Container(margin: const EdgeInsets.all(12), height: 150, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC7D2FE), Color(0xFF93C5FD)]), borderRadius: BorderRadius.circular(24)), child: Row(children: [
            Expanded(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('Hello, $nm! 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))), const Text("Let's learn something new today!")]))),
            ClipRRect(borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)), child: Image.network(photo, width: 120, height: 150, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 120)))])),
          Row(children: [tile(Icons.school, '${mine.length}', 'Courses Enrolled', Colors.green), tile(Icons.workspace_premium, '${(d[0]['certs'] as List? ?? []).length}', 'Certificates', Colors.orange), tile(Icons.videocam, '${live.length}', 'Live Classes', _blue)]),
          Row(children: [big('Live Classes', 'Join Now →', Icons.play_circle, _blue, () => jump(2)), big('Daily Quiz', 'Test Your Knowledge', Icons.quiz, Colors.purple, () => jump(3))]),
          head('My Learning'),
          if (mine.isEmpty) const Padding(padding: EdgeInsets.all(14), child: Text('Abhi koi course nahi liya. Courses tab se shuru karo!')),
          for (final k in mine) Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(leading: const Icon(Icons.menu_book, color: _blue), title: Text(k['Title']), subtitle: Text('${k['Category']} · ${k['Duration']}'), trailing: const Icon(Icons.play_circle, color: _blue), onTap: () => go(c, CourseScreen(k)))),
          head('Upcoming Classes'),
          if (live.isEmpty) const Padding(padding: EdgeInsets.all(14), child: Text('Koi live class scheduled nahi.')),
          for (final l in live.take(2)) Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(leading: const Icon(Icons.videocam, color: _blue), title: Text(l['Title']), subtitle: Text(l['At']), trailing: FilledButton(onPressed: () => launchUrl(Uri.parse(l['Link']), mode: LaunchMode.externalApplication), child: const Text('Join Now')))),
          head('Quick Access'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
            quick(Icons.local_offer, 'Combo Offers', () => page(c, 'Combo Offers', const Combos())),
            quick(Icons.groups, 'Community', () => page(c, 'Community', const Community())),
            quick(Icons.workspace_premium, 'Certificates', () => jump(4)),
            quick(Icons.headset_mic, 'Help & Support', () => go(c, const Chat(room: 'support', title: 'Live Support')))])),
          const SizedBox(height: 20)]);
      });
}

class LiveTab extends StatelessWidget {
  const LiveTab({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/live'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final l = s.data as List;
        if (l.isEmpty) return const Center(child: Text('Koi live class scheduled nahi'));
        return ListView(children: [for (final x in l) Card(margin: const EdgeInsets.all(10), child: ListTile(leading: const Icon(Icons.videocam, color: _blue), title: Text(x['Title']), subtitle: Text(x['At']), trailing: FilledButton(onPressed: () => launchUrl(Uri.parse(x['Link']), mode: LaunchMode.externalApplication), child: const Text('Join Now'))))]);
      });
}

class QuizTab extends StatelessWidget {
  const QuizTab({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/courses'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(children: [const Padding(padding: EdgeInsets.all(14), child: Text('Quiz do aur certificate pao 🏆', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          for (final k in s.data as List) Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(leading: const Icon(Icons.quiz, color: Colors.purple), title: Text(k['Title']), trailing: const Icon(Icons.chevron_right), onTap: () => go(c, Quiz(k))))]);
      });
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/me'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final d = s.data as Map; final u = d['user']; final certs = (d['certs'] as List? ?? []);
        final nm = (u['Name'] ?? '').toString(); final ini = nm.isEmpty ? 'S' : nm[0].toUpperCase();
        Widget item(IconData i, String t, VoidCallback f, [Color? col]) => Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(leading: Icon(i, color: col ?? _blue), title: Text(t, style: TextStyle(color: col)), trailing: const Icon(Icons.chevron_right), onTap: f));
        return ListView(children: [
          Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))), child: Column(children: [
            CircleAvatar(radius: 46, backgroundColor: Colors.white, child: Text(ini, style: const TextStyle(fontSize: 36, color: _blue))), const SizedBox(height: 8),
            Text(nm.isEmpty ? 'Student' : nm, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${u['Email'] ?? ''} ${u['Phone'] ?? ''}', style: const TextStyle(color: Colors.white70))])),
          const SizedBox(height: 12),
          item(Icons.workspace_premium, 'My Certificates (${certs.length})', () => page(c, 'My Certificates', ListView(children: [for (final x in certs) ListTile(leading: const Icon(Icons.workspace_premium, color: Colors.orange), title: Text(x['CourseTitle']), subtitle: Text(x['Date']), onTap: () => launchUrl(Uri.parse('$base/certificate/${x['ID']}'), mode: LaunchMode.externalApplication))]))),
          item(Icons.groups, 'Community', () => page(c, 'Community', const Community())),
          item(Icons.headset_mic, 'Help & Support', () => go(c, const Chat(room: 'support', title: 'Live Support'))),
          item(Icons.logout, 'Logout', () { token = ''; Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const Login()), (_) => false); }, Colors.red)]);
      });
}
