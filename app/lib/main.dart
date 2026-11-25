import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

const base = String.fromEnvironment('API', defaultValue: 'http://10.0.2.2:8080');
String token = '';
Map me = {};
Future api(String m, String p, [Map? b]) async {
  final h = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  final u = Uri.parse(base + p);
  final r = m == 'GET' ? await http.get(u, headers: h) : await http.post(u, headers: h, body: jsonEncode(b ?? {}));
  return jsonDecode(r.body);
}

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF6A1B9A), useMaterial3: true),
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
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4A148C), Color(0xFFAB47BC)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Center(child: Card(margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('👑 Janhavi Panwar', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
    final tabs = [const Courses(), const Combos(), const Community(), const Profile()];
    return Scaffold(
      appBar: AppBar(title: const Text('Janhavi Panwar'), actions: [IconButton(icon: const Icon(Icons.support_agent), tooltip: 'Live chat', onPressed: () => go(c, const Chat(room: 'support', title: 'Live Support')))]),
      body: tabs[i],
      bottomNavigationBar: NavigationBar(selectedIndex: i, onDestinationSelected: (v) => setState(() => i = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.local_offer), label: 'Combo'),
        NavigationDestination(icon: Icon(Icons.groups), label: 'Community'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Me'),
      ]));
  }
}

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
      FilledButton(onPressed: () async { // TODO: Razorpay payment first
        await api('POST', '/api/enroll', {'courseId': k['ID']}); snack(c, 'Enrolled!'); }, child: const Text('Buy / Enroll Now')),
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
          FilledButton(onPressed: () async { for (final id in b['Items']) { await api('POST', '/api/enroll', {'courseId': id}); } snack(c, 'Combo enrolled!'); }, child: const Text('Get Offer'))])))]);
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

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/me'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final d = s.data as Map;
        return ListView(children: [ListTile(title: Text(d['user']['Name'] ?? ''), subtitle: Text('${d['user']['Phone']} ${d['user']['Email']}')),
          const ListTile(title: Text('My Certificates', style: TextStyle(fontWeight: FontWeight.bold))),
          for (final x in (d['certs'] as List? ?? [])) ListTile(leading: const Icon(Icons.workspace_premium), title: Text(x['CourseTitle']), subtitle: Text('$base/certificate/${x['ID']}'))]);
      });
}
