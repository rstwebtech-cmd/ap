part of 'main.dart';

class Quiz extends StatefulWidget { final Map k; const Quiz(this.k, {super.key}); @override State<Quiz> createState() => _Q(); }

class _Q extends State<Quiz> {
  final sw = Stopwatch()..start();
  List qs = []; Map<int, int> a = {};
  @override void initState() { super.initState(); api('GET', '/api/quiz/${widget.k['ID']}').then((v) => setState(() => qs = v)); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text('Final Quiz')), body: ListView(padding: const EdgeInsets.all(12), children: [
        for (var i = 0; i < qs.length; i++) Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('${i + 1}. ${qs[i]['Q']}', style: const TextStyle(fontWeight: FontWeight.bold))),
          for (var j = 0; j < qs[i]['Options'].length; j++) RadioListTile<int>(value: j, groupValue: a[i], title: Text(qs[i]['Options'][j]), onChanged: (v) => setState(() => a[i] = v!))])),
        FilledButton(onPressed: () async {
          final r = await api('POST', '/api/quiz/${widget.k['ID']}', {'answers': [for (var i = 0; i < qs.length; i++) a[i] ?? -1]});
          if (!mounted) return;
          Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => QuizResult(widget.k, qs, [for (var i = 0; i < qs.length; i++) a[i] ?? -1], r is Map ? r : {}, sw.elapsed.inSeconds)));
        }, child: const Text('Submit')),
      ]));
}

class QuizTab extends StatefulWidget { const QuizTab({super.key}); @override State<QuizTab> createState() => _QT(); }

class _QT extends State<QuizTab> {
  bool hist = false;
  @override Widget build(BuildContext c) => FutureBuilder(future: Future.wait([api('GET', '/api/quizzes'), api('GET', '/api/attempts'), api('GET', '/api/me')]), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final d = s.data as List; final qz = d[0] is List ? d[0] as List : []; final at = d[1] is List ? d[1] as List : []; final m2 = d[2] is Map ? d[2] as Map : {};
        Widget st(IconData i, num v, String t, String suf) => Expanded(child: Column(children: [Icon(i, color: _blue), TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: v.toDouble()), duration: const Duration(milliseconds: 900), builder: (_, x, __) => Text('${x.round()}$suf', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), Text(t, style: const TextStyle(fontSize: 11))]));
        return ListView(padding: EdgeInsets.zero, children: [
          Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(gradient: LinearGradient(colors: [_dark, Color(0xFF7C3AED)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(26))), child: const Row(children: [Expanded(child: Text('Test Your Knowledge\n& Track Your Progress', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))), Icon(Icons.emoji_events, color: _gold, size: 70)])),
          Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [st(Icons.quiz, at.length, 'Attempts', ''), st(Icons.star, (m2['avgScore'] ?? 0) as num, 'Avg Score', '%'), st(Icons.workspace_premium, (m2['certs'] as List? ?? []).length, 'Certificates', '')])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [Expanded(child: ChoiceChip(label: const SizedBox(width: double.infinity, child: Text('Available Quizzes', textAlign: TextAlign.center)), selected: !hist, onSelected: (_) => setState(() => hist = false))), const SizedBox(width: 8), Expanded(child: ChoiceChip(label: const SizedBox(width: double.infinity, child: Text('My History', textAlign: TextAlign.center)), selected: hist, onSelected: (_) => setState(() => hist = true)))])),
          if (!hist) ...[
            Fade(Card(color: Colors.green.shade50, margin: const EdgeInsets.fromLTRB(14, 10, 14, 4), child: ListTile(leading: const Icon(Icons.bar_chart, color: Colors.green, size: 34), title: const Text('Level Check (A1 → C1)', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Find out your English level'), trailing: FilledButton(onPressed: () => go(c, Quiz({'ID': 'level', 'Title': 'Level Check'})), child: const Text('Start →'))))),
            for (var i = 0; i < qz.length; i++) Fade(i: i + 1, Card(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), child: ListTile(leading: const Icon(Icons.assignment, color: _blue, size: 34), title: Text(qz[i]['Title'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${qz[i]['Questions']} Questions'), trailing: FilledButton(onPressed: () => go(c, Quiz({'ID': qz[i]['ID'], 'Title': qz[i]['Title']})), child: const Text('Start →')))))
          ] else ...[
            if (at.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No quiz attempts yet'))),
            for (var i = 0; i < at.length; i++) Fade(i: i, Card(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), child: ListTile(leading: const Icon(Icons.history, color: _blue), title: Text(at[i]['Title']), subtitle: Text(DateTime.fromMillisecondsSinceEpoch((at[i]['At'] as int) * 1000).toString().substring(0, 16)), trailing: Text('${at[i]['Score']}/${at[i]['Total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))))
          ],
          const SizedBox(height: 20)]);
      });
}

class QuizResult extends StatelessWidget {
  final Map k; final List qs; final List ans; final Map r; final int secs;
  const QuizResult(this.k, this.qs, this.ans, this.r, this.secs, {super.key});
  @override Widget build(BuildContext c) {
    if (r['score'] == null) return Scaffold(appBar: AppBar(), body: Center(child: Text('${r['error'] ?? 'Something went wrong'}')));
    final total = r['total'] as int, sc = r['score'] as int; final pct = total == 0 ? 0.0 : sc / total; final lvl = r['level'];
    final key = (r['answers'] as List? ?? []);
    return Scaffold(appBar: AppBar(title: const Text('Quiz Result')), body: ListView(padding: const EdgeInsets.all(16), children: [
      const Icon(Icons.emoji_events, color: _gold, size: 90),
      Center(child: Text(lvl != null ? 'Your Level: $lvl 🎯' : pct >= .6 ? 'Great Attempt! 🎉' : 'Keep Practicing 💪', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _dark))),
      Center(child: Text('You scored $sc out of $total', style: const TextStyle(color: Colors.red, fontSize: 16))), const SizedBox(height: 16),
      Row(children: [
        SizedBox(width: 130, height: 130, child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: pct), duration: const Duration(milliseconds: 1200), curve: Curves.easeOut, builder: (_, v, __) => Stack(alignment: Alignment.center, children: [SizedBox(width: 130, height: 130, child: CircularProgressIndicator(value: v, strokeWidth: 12, color: Colors.green, backgroundColor: Colors.grey.shade300)), Text('${(v * 100).round()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))]))),
        const SizedBox(width: 20),
        Expanded(child: Column(children: [ListTile(dense: true, leading: const Icon(Icons.check_circle, color: Colors.green), title: const Text('Correct'), trailing: Text('$sc')), ListTile(dense: true, leading: const Icon(Icons.cancel, color: Colors.red), title: const Text('Wrong'), trailing: Text('${total - sc}')), ListTile(dense: true, leading: const Icon(Icons.timer, color: _blue), title: const Text('Time'), trailing: Text('${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}'))]))]),
      const SizedBox(height: 12),
      FilledButton(onPressed: () => page(c, 'Answer Sheet', ListView(children: [for (var i = 0; i < qs.length && i < key.length; i++) Card(margin: const EdgeInsets.all(8), child: ListTile(isThreeLine: true, title: Text('${i + 1}. ${qs[i]['Q']}'), subtitle: Text('Your answer: ${ans[i] >= 0 ? qs[i]['Options'][ans[i]] : '-'}\nCorrect answer: ${qs[i]['Options'][key[i]]}', style: TextStyle(color: ans[i] == key[i] ? Colors.green : Colors.red))))])), child: const Text('View Answer Sheet')),
      OutlinedButton(onPressed: () => Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => Quiz(k))), child: const Text('Try Again')),
      if (r['certificate'] != null) FilledButton(style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black), onPressed: () => launchUrl(Uri.parse('$base/certificate/${r['certificate']}'), mode: LaunchMode.externalApplication), child: const Text('🏆 Download Certificate')),
      Container(margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(16)), child: Row(children: [const Icon(Icons.emoji_events, color: _gold, size: 40), const SizedBox(width: 10), const Expanded(child: Text('Your Rank on Leaderboard')), Text('#${r['rank']}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), Text(' / ${r['players']}')]))]));
  }
}
