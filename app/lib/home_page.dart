part of 'main.dart';

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _H(); }

class _H extends State<Home> {
  int i = 0;
  @override Widget build(BuildContext c) {
    void jump(int v) => setState(() => i = v);
    final tabs = [HomeTab(jump), const Courses(), const QuizTab(), const CommunityTab(), Profile(jump)];
    return Scaffold(
      body: SafeArea(top: i != 0, child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: KeyedSubtree(key: ValueKey(i), child: tabs[i]))),
      bottomNavigationBar: NavigationBar(selectedIndex: i, onDestinationSelected: jump, destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.play_circle), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Quiz'),
        NavigationDestination(icon: Icon(Icons.groups), label: 'Community'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ]));
  }
}

class HomeTab extends StatelessWidget {
  final void Function(int) jump;
  const HomeTab(this.jump, {super.key});
  Widget head(String t, [VoidCallback? f]) => Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Row(children: [Container(width: 4, height: 22, color: _blue), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))), if (f != null) TextButton(onPressed: f, child: const Text('View All →'))]));
  Widget ico(IconData i, String t, Color col, VoidCallback f) => InkWell(onTap: f, child: Container(width: 76, margin: const EdgeInsets.all(4), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: col.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(i, color: col, size: 28), const SizedBox(height: 4), Text(t, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)])));
  Widget qc(IconData i, String t, String s, Color col, VoidCallback f) => Expanded(child: InkWell(onTap: f, child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), decoration: BoxDecoration(color: col.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(i, color: col), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center), Text(s, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)]))));
  @override Widget build(BuildContext c) => FutureBuilder(future: Future.wait([api('GET', '/api/me'), api('GET', '/api/courses'), api('GET', '/api/live'), api('GET', '/api/reviews')]), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final d = s.data as List; final u = d[0]['user']; final courses = d[1] as List; final live = (d[2] as List? ?? []); final revs = (d[3] as List? ?? []);
        final nm = (u['Name'] ?? '').toString().isEmpty ? 'Student' : u['Name'];
        return ListView(padding: EdgeInsets.zero, children: [
          Container(height: 270, decoration: const BoxDecoration(gradient: LinearGradient(colors: [_dark, Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))), child: Stack(children: [
            Positioned(right: 0, bottom: 0, child: Image.network(photo, height: 240, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox())),
            SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 140, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.network(logo, height: 34, errorBuilder: (_, __, ___) => const Text('Janhavi Panwar', style: TextStyle(color: Colors.white, fontSize: 20))),
              const Spacer(),
              const Text('Dream Big...', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('Learn Beyond Limits!', style: TextStyle(color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Hello, $nm 👋 · v9', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 8),
              FilledButton(style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black), onPressed: () => jump(1), child: const Text('Explore Courses →'))])))])),
          Padding(padding: const EdgeInsets.all(14), child: TextField(decoration: InputDecoration(hintText: 'Search courses, quizzes, or topics...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)), onSubmitted: (v) => page(c, 'Search: $v', Courses(q: v)))),
          SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
            ico(Icons.school, 'Courses', _blue, () => jump(1)), ico(Icons.star, 'Reviews', Colors.orange, () => page(c, 'Reviews', const ReviewsPage())),
            ico(Icons.chat, 'Live Chat', Colors.teal, () => go(c, const LiveChatHome())), ico(Icons.groups, 'Community', Colors.purple, () => jump(3)),
            ico(Icons.quiz, 'Quiz', Colors.indigo, () => jump(2)), ico(Icons.bar_chart, 'Level Check', Colors.green, () => go(c, Quiz({'ID': 'level', 'Title': 'Level Check'})))])),
          head('Featured Courses', () => jump(1)),
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .62, crossAxisSpacing: 10, mainAxisSpacing: 10, padding: const EdgeInsets.symmetric(horizontal: 12), children: [for (var i = 0; i < (courses.length < 4 ? courses.length : 4); i++) Fade(courseCard(c, courses[i]), i: i)]),
          Container(margin: const EdgeInsets.fromLTRB(14, 18, 14, 4), padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(22)), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: Text(live.isEmpty ? 'Coming Soon' : 'Live', style: const TextStyle(color: Colors.white, fontSize: 12))),
              Text(live.isEmpty ? 'Live Classes' : live[0]['Title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(live.isEmpty ? 'Will be scheduled soon' : live[0]['At'], style: const TextStyle(color: Colors.white70)), const SizedBox(height: 8),
              FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _blue), onPressed: () => live.isEmpty ? page(c, 'Live Classes', const LiveTab()) : launchUrl(Uri.parse(live[0]['Link']), mode: LaunchMode.externalApplication), child: const Text('Join Live →'))])),
            const Icon(Icons.podcasts, color: _gold, size: 60)])),
          Padding(padding: const EdgeInsets.fromLTRB(10, 12, 10, 0), child: Row(children: [
            qc(Icons.local_offer, 'Combo Offers', 'Save more', Colors.deepOrange, () => page(c, 'Combo Offers', const Combos())), qc(Icons.card_giftcard, 'Refer & Earn', '10% Commission', Colors.orange, () => go(c, const ReferPage())),
            qc(Icons.workspace_premium, 'Certificates', 'Get Certified', Colors.amber, () => jump(4)), qc(Icons.quiz, 'Take Quiz', 'Test Skills', Colors.indigo, () => jump(2))])),
          head('What Our Learners Say', () => page(c, 'Reviews', const ReviewsPage())),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [
            Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: revs.isEmpty ? const Text('Be the first to write a review! ⭐') : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('⭐' * (revs[0]['Stars'] as int)), Text('"${revs[0]['Text']}"', maxLines: 3, overflow: TextOverflow.ellipsis), Text('— ${revs[0]['Name']}', style: const TextStyle(fontSize: 12, color: Colors.grey))]))),
            const SizedBox(width: 10),
            Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(16)), child: const Column(children: [Icon(Icons.groups, color: _blue), Text('2.27M+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('YouTube Family', style: TextStyle(fontSize: 11), textAlign: TextAlign.center)])))])),
          const SizedBox(height: 24)]);
      });
}
