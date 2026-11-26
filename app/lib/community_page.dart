part of 'main.dart';

class Community extends StatelessWidget {
  const Community({super.key});
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/groups'), builder: (_, s) => Scaffold(
        body: (s.data is List && (s.data as List).isEmpty) ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('You have not been added to any group yet. The admin will add you after you buy a course.', textAlign: TextAlign.center))) : ListView(children: [for (final g in (s.data as List? ?? [])) ListTile(leading: const Icon(Icons.groups), title: Text(g['Name']), onTap: () => go(c, Chat(room: g['ID'], title: g['Name'])))])));
}

class Chat extends StatefulWidget { final String room, title; final String? first; const Chat({super.key, required this.room, required this.title, this.first}); @override State<Chat> createState() => _Ch(); }

class _Ch extends State<Chat> {
  final t = TextEditingController(); List m = []; Timer? tm;
  Future poll() async { final r = await api('GET', '/api/chat?room=${widget.room}&after=0'); if (mounted) setState(() => m = r); }
  @override void initState() { super.initState(); if (widget.first != null) { api('POST', '/api/chat', {'room': widget.room, 'text': widget.first}).then((_) => poll()); } else { poll(); } tm = Timer.periodic(const Duration(seconds: 3), (_) => poll()); }
  @override void dispose() { tm?.cancel(); super.dispose(); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text(widget.title)), body: Column(children: [
        Expanded(child: ListView(children: [for (final x in m) ListTile(dense: true, title: Text(x['Name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(x['Text']))])),
        Row(children: [Expanded(child: Padding(padding: const EdgeInsets.all(8), child: TextField(controller: t))), IconButton(icon: const Icon(Icons.send), onPressed: () async { await api('POST', '/api/chat', {'room': widget.room, 'text': t.text}); t.clear(); poll(); })])]));
}

class ReviewsPage extends StatefulWidget { const ReviewsPage({super.key}); @override State<ReviewsPage> createState() => _Rv(); }

class _Rv extends State<ReviewsPage> {
  final t = TextEditingController();
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/reviews'), builder: (_, s) => ListView(padding: const EdgeInsets.all(12), children: [
        TextField(controller: t, decoration: const InputDecoration(labelText: 'Write your review (visible after approval)')),
        TextButton(onPressed: () async { await api('POST', '/api/reviews', {'text': t.text, 'stars': 5}); t.clear(); snack(c, 'Thanks! Review pending approval'); }, child: const Text('Submit review')),
        for (final r in (s.data as List? ?? [])) Card(child: ListTile(title: Text(r['Name']), subtitle: Text(r['Text']), trailing: Text('⭐${r['Stars']}')))]));
}

class CommunityTab extends StatefulWidget { const CommunityTab({super.key}); @override State<CommunityTab> createState() => _CT(); }

class _CT extends State<CommunityTab> {
  bool feed = true;
  @override Widget build(BuildContext c) => Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(18, 18, 18, 14), decoration: const BoxDecoration(gradient: LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(26))), child: const Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Join Our', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text('Community', style: TextStyle(color: _gold, fontSize: 28, fontWeight: FontWeight.bold)), Text('Learn Together, Grow Together!', style: TextStyle(color: Colors.white70))])),
          Icon(Icons.groups, color: Colors.white, size: 64)])),
        Padding(padding: const EdgeInsets.all(10), child: Row(children: [for (final t in ['Feed', 'My Groups']) Expanded(child: Padding(padding: const EdgeInsets.all(3), child: ChoiceChip(label: SizedBox(width: double.infinity, child: Text(t, textAlign: TextAlign.center)), selected: (t == 'Feed') == feed, onSelected: (_) => setState(() => feed = t == 'Feed'))))])),
        Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: feed ? const FeedView(key: ValueKey(1)) : const Community(key: ValueKey(2))))]);
}

class FeedView extends StatefulWidget { const FeedView({super.key}); @override State<FeedView> createState() => _FV(); }

class _FV extends State<FeedView> {
  final t = TextEditingController(); String kind = 'all'; late Future f = api('GET', '/api/posts');
  void reload() => setState(() => f = api('GET', '/api/posts'));
  @override Widget build(BuildContext c) => Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(child: TextField(controller: t, decoration: InputDecoration(hintText: 'Share your thoughts...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)))), const SizedBox(width: 6), FilledButton(onPressed: () async { if (t.text.trim().isEmpty) return; await api('POST', '/api/posts', {'text': t.text, 'kind': t.text.trim().endsWith('?') ? 'question' : 'post'}); t.clear(); reload(); }, child: const Text('Post'))])),
        SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [for (final k in ['all', 'mine', 'question', 'announcement']) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text({'all': 'All Posts', 'mine': 'My Posts', 'question': 'Questions', 'announcement': 'Announcements'}[k]!), selected: kind == k, onSelected: (_) => setState(() => kind = k)))])),
        Expanded(child: FutureBuilder(future: f, builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final l = (s.data is List ? s.data as List : []).where((p) => kind == 'all' || (kind == 'mine' ? p['Mine'] == true : p['Kind'] == kind)).toList();
          if (l.isEmpty) return const Center(child: Text('No posts yet. Be the first to post!'));
          return ListView(children: [for (var i = 0; i < l.length; i++) Fade(i: i, Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [CircleAvatar(backgroundColor: const Color(0xFFEDE9FE), child: Text(l[i]['Name'].toString().isEmpty ? '?' : l[i]['Name'][0])), const SizedBox(width: 8), Text(l[i]['Name'], style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1), decoration: BoxDecoration(color: l[i]['Role'] == 'Admin' ? Colors.red : _blue, borderRadius: BorderRadius.circular(10)), child: Text(l[i]['Role'], style: const TextStyle(color: Colors.white, fontSize: 11)))]),
            const SizedBox(height: 8), Text(l[i]['Text']),
            Row(children: [TextButton.icon(onPressed: () async { await api('POST', '/api/posts/${l[i]['ID']}/like'); reload(); }, icon: Icon(l[i]['Liked'] == true ? Icons.thumb_up : Icons.thumb_up_outlined, size: 18), label: Text('${l[i]['Likes']}')), if (l[i]['Kind'] != 'post') Text(l[i]['Kind'] == 'question' ? '❓ Question' : '📢 Announcement', style: const TextStyle(fontSize: 12))])]))))]);
        }))]);
}

class LiveChatHome extends StatelessWidget {
  const LiveChatHome({super.key});
  @override Widget build(BuildContext c) {
    final room = 'support-${me['ID']}';
    Widget top(IconData i, Color col, String t, String s, String b, VoidCallback f) => Expanded(child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: col.withOpacity(.12), borderRadius: BorderRadius.circular(18)), child: Column(children: [Icon(i, color: col, size: 54), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(s, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center), const SizedBox(height: 8), FilledButton(style: FilledButton.styleFrom(backgroundColor: col), onPressed: f, child: Text(b))])));
    return Scaffold(appBar: AppBar(title: const Text('Live Chat')), body: ListView(children: [
      Fade(Row(children: [top(Icons.chat_bubble, _blue, 'Chat on App', 'Ask your query inside the app', 'Start Chat →', () => go(c, Chat(room: room, title: 'Live Support'))), top(Icons.phone_in_talk, Colors.green, 'Chat on WhatsApp', 'Talk directly on WhatsApp', 'Chat Now →', () async { final cfg = await api('GET', '/api/config'); final n = (cfg['whatsapp'] ?? '').toString(); if (n.isEmpty) { if (c.mounted) snack(c, 'WhatsApp number is not set yet'); } else { launchUrl(Uri.parse('https://wa.me/$n'), mode: LaunchMode.externalApplication); } })])),
      const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('Quick Help Topics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
      for (var i = 0; i < 5; i++) Fade(i: i, Card(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3), child: ListTile(leading: Icon([Icons.how_to_reg, Icons.payment, Icons.quiz, Icons.card_giftcard, Icons.help][i], color: _blue), title: Text(['Course Enrollment', 'Payment Issues', 'Quiz Related Queries', 'Referral & Commission', 'Other Help'][i]), trailing: const Icon(Icons.chevron_right), onTap: () => go(c, Chat(room: room, title: 'Live Support', first: ['I have a question about course enrollment', 'I have a problem with my payment', 'I have a question about the quiz', 'How does the referral commission work?', 'I want to talk to your team'][i]))))),
      Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('We are here to help!', style: TextStyle(color: _gold, fontSize: 20, fontWeight: FontWeight.bold)), Text('Have a question? Just start a chat.', style: TextStyle(color: Colors.white70))])), Image.network(photo, height: 90, errorBuilder: (_, __, ___) => const SizedBox())]))]));
  }
}
