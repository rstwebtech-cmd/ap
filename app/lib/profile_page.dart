part of 'main.dart';

class LiveTab extends StatelessWidget {
  const LiveTab({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/live'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final l = s.data as List;
        if (l.isEmpty) return const Center(child: Text('No live classes scheduled'));
        return ListView(children: [for (final x in l) Card(margin: const EdgeInsets.all(10), child: ListTile(leading: const Icon(Icons.videocam, color: _blue), title: Text(x['Title']), subtitle: Text(x['At']), trailing: FilledButton(onPressed: () => launchUrl(Uri.parse(x['Link']), mode: LaunchMode.externalApplication), child: const Text('Join Now'))))]);
      });
}

class ReferPage extends StatelessWidget {
  const ReferPage({super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text('Refer & Earn')), body: FutureBuilder(future: api('GET', '/api/me'), builder: (_, s) {
        if (!s.hasData || s.data is! Map || (s.data as Map)['user'] == null) return const Center(child: CircularProgressIndicator());
        final d = s.data as Map; final u = d['user']; final code = '${u['Roll']}'; final earned = (u['Earned'] ?? 0) as int, paid = (u['Paid'] ?? 0) as int;
        Widget st(IconData i, num v, String t, {bool rs = false}) => Expanded(child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [Icon(i, color: _blue), TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: v.toDouble()), duration: const Duration(milliseconds: 900), builder: (_, x, __) => Text('${rs ? '₹' : ''}${x.round()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))), Text(t, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)])));
        return ListView(children: [
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(22)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Refer & Earn', style: TextStyle(color: _gold, fontSize: 30, fontWeight: FontWeight.bold)), Text('Refer courses to your friends and earn 10% commission!', style: TextStyle(color: Colors.white))])), Pulse(Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle), child: const Text('10%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))))])),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Your Referral Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.only(left: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: Text(code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2))), FilledButton(onPressed: () { Clipboard.setData(ClipboardData(text: code)); snack(c, 'Code copied'); }, child: const Text('Copy'))])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: FilledButton.icon(icon: const Icon(Icons.share), label: const Text('Share on WhatsApp'), onPressed: () => launchUrl(Uri.parse('https://wa.me/?text=${Uri.encodeComponent('Join Janhavi Panwar courses! Use my referral code when you register: $code')}'), mode: LaunchMode.externalApplication))),
          const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('Your Referral Stats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(children: [st(Icons.people, (d['refCount'] ?? 0) as num, 'Total Referrals'), st(Icons.shopping_cart, (d['refSales'] ?? 0) as num, 'Successful Sales'), st(Icons.schedule, earned - paid, 'Pending', rs: true), st(Icons.emoji_events, earned, 'Total Earnings', rs: true)])),
          const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('How It Works', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(padding: const EdgeInsets.all(10), child: Row(children: [for (final t in [[Icons.link, 'Share Your Code'], [Icons.shopping_cart, 'Friend Buys a Course'], [Icons.card_giftcard, 'Earn 10% Commission']]) Expanded(child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [Icon(t[0] as IconData, color: _blue), Text(t[1] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))])))]))]);
      }));
}

class Profile extends StatelessWidget {
  final void Function(int) jump;
  const Profile(this.jump, {super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/me'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final d = s.data as Map; final u = d['user']; final certs = (d['certs'] as List? ?? []);
        final nm = (u['Name'] ?? '').toString(); final ini = nm.isEmpty ? 'S' : nm[0].toUpperCase();
        final enr = ((u['Courses'] as List? ?? [])).toSet().length;
        final pts = enr * 100 + certs.length * 500; final lvl = 1 + pts ~/ 500; final pct = (pts % 500) / 500;
        final lname = lvl < 3 ? 'Beginner' : lvl < 5 ? 'Intermediate' : 'Advanced Learner';
        Widget stat(IconData i, String v, String t) => Expanded(child: Column(children: [Icon(i, color: _blue), Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(t, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)]));
        Widget item(IconData i, String t, String sub, VoidCallback f, [Color? col]) => Container(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDDD6FE))), child: ListTile(leading: Icon(i, color: col ?? _blue, size: 30), title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(sub), trailing: Icon(Icons.chevron_right, color: col ?? _blue), onTap: f));
        Widget badge(IconData i, String t, bool on) => Expanded(child: Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(i, size: 30, color: on ? _gold : Colors.grey.shade400), Text(t, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)])));
        return ListView(padding: EdgeInsets.zero, children: [
          Container(padding: const EdgeInsets.fromLTRB(16, 40, 16, 40), decoration: const BoxDecoration(gradient: LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))), child: Row(children: [
            CircleAvatar(radius: 46, backgroundColor: _gold, child: CircleAvatar(radius: 42, backgroundColor: Colors.white, child: Text(ini, style: const TextStyle(fontSize: 36, color: _blue)))), const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nm.isEmpty ? 'Student' : nm, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${u['Email'] ?? ''}${u['Phone'] ?? ''}', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold)), child: Text(enr > 0 ? '💎 Premium Member' : 'Free Member', style: const TextStyle(color: Colors.white, fontSize: 12)))]))])),
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [stat(Icons.play_circle, '$enr', 'Courses Enrolled'), stat(Icons.military_tech, '$lvl', 'Level'), stat(Icons.star, '$pts', 'Points'), stat(Icons.workspace_premium, '${certs.length}', 'Certificates')])),
          Container(margin: const EdgeInsets.symmetric(horizontal: 14), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [
            SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [SizedBox(width: 90, height: 90, child: CircularProgressIndicator(value: pct == 0 ? 0.02 : pct, strokeWidth: 9, color: _gold, backgroundColor: Colors.white24)), Text('${(pct * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))])), const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Your Learning Progress', style: TextStyle(color: Colors.white70, fontSize: 12)), Text('👑 Level $lvl', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text(lname, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 6), LinearProgressIndicator(value: pct, color: _gold, backgroundColor: Colors.white24), const SizedBox(height: 4), Text('⭐ $pts Points', style: const TextStyle(color: Colors.white))])),
            const Icon(Icons.emoji_events, color: _gold, size: 54)])),
          const SizedBox(height: 10),
          item(Icons.play_circle, 'My Courses', 'Continue learning and see your access validity', () => page(c, 'My Courses', const MyCoursesPage())),
          item(Icons.receipt_long, 'My Purchases', 'Invoices for your orders', () => page(c, 'My Purchases', const OrdersPage())),
          item(Icons.quiz, 'My Quizzes', 'Check your quiz performance', () => jump(2)),
          item(Icons.workspace_premium, 'My Certificates', 'Download your certificates', () => page(c, 'My Certificates', ListView(children: [for (final x in certs) ListTile(leading: const Icon(Icons.workspace_premium, color: _gold), title: Text(x['CourseTitle']), subtitle: Text(x['Date']), onTap: () => launchUrl(Uri.parse('$base/certificate/${x['ID']}'), mode: LaunchMode.externalApplication))]))),
          item(Icons.star, 'My Reviews', 'Share your feedback', () => page(c, 'Reviews', const ReviewsPage())),
          item(Icons.groups, 'My Community', 'Connect with learners', () => jump(3)),
          item(Icons.chat, 'Live Chat', 'Chat with our support team', () => go(c, const LiveChatHome())),
          InkWell(onTap: () => go(c, const ReferPage()), child: Container(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('🎁 Refer & Earn 10%', style: TextStyle(fontWeight: FontWeight.bold)), Text('Your code: ${u['Roll']}  (tap for details)'), Text('Earned: ₹${u['Earned'] ?? 0}  |  Paid: ₹${u['Paid'] ?? 0}')]))),
          item(Icons.logout, 'Logout', 'Sign out from your account', () { token = ''; Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false); }, Colors.red),
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('⭐ Your Achievements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8),
            Row(children: [badge(Icons.school, 'First Course', enr >= 1), badge(Icons.verified, 'Quiz Master', certs.isNotEmpty), badge(Icons.emoji_events, 'Course Champion', certs.length >= 3), badge(Icons.military_tech, 'Level 3+', lvl >= 3)])]))]);
      });
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/orders'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final l = s.data is List ? s.data as List : [];
        if (l.isEmpty) return const Center(child: Text('No purchases yet'));
        return ListView(children: [
          for (final o in l)
            Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
              leading: const Icon(Icons.receipt_long, color: _blue),
              title: Text('${o['Title']}'),
              subtitle: Text('${o['InvNo']} · ₹${o['Amount']} · ${dateStr(o['At'] as int)}'),
              trailing: TextButton(onPressed: () => launchUrl(Uri.parse('$base${o['InvURL']}'), mode: LaunchMode.externalApplication), child: const Text('Invoice')),
            )),
        ]);
      });
}

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: Future.wait([api('GET', '/api/me'), api('GET', '/api/courses')]), builder: (_, s) {
        if (!s.hasData || s.data is! List || (s.data as List)[0] is! Map || (s.data as List)[0]['user'] == null) return const Center(child: CircularProgressIndicator());
        final d = s.data as List;
        final u = d[0]['user'];
        final ids = (u['Courses'] as List? ?? []);
        final acc = (u['Access'] as Map? ?? {});
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final mine = ((d[1] is List ? d[1] as List : [])).where((x) => ids.contains(x['ID'])).toList();
        if (mine.isEmpty) return const Center(child: Text('You have not enrolled in any course yet.'));
        Widget row(Map k, int i) {
          final e = (acc[k['ID']] ?? 0) as int;
          final expired = e > 0 && e < now;
          return Fade(i: i, Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
            leading: SizedBox(width: 80, child: cimg(k, 50)),
            title: Text('${k['Title']}'),
            subtitle: Text(e == 0 ? 'Lifetime access' : expired ? 'Expired on ${dateStr(e)} · tap to renew' : 'Valid till ${dateStr(e)}', style: TextStyle(color: expired ? Colors.red : Colors.green)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => go(c, CourseScreen(k)),
          )));
        }
        return ListView(children: [for (var i = 0; i < mine.length; i++) row(mine[i], i)]);
      });
}
