part of 'main.dart';

class CourseScreen extends StatefulWidget {
  final Map k;
  const CourseScreen(this.k, {super.key});
  @override State<CourseScreen> createState() => _CourseState();
}

class _CourseState extends State<CourseScreen> {
  final cp = TextEditingController(), rv = TextEditingController();
  int tab = 0;
  late Future cur = api('GET', '/api/course/${widget.k['ID']}/lessons');
  late Future revs = api('GET', '/api/reviews');
  static const tabs = ['Overview', 'Curriculum', 'Reviews'];

  Widget info(IconData i, String t, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [Icon(i, size: 18, color: Colors.grey), const SizedBox(width: 8), Text(t), const Spacer(), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))]));

  @override Widget build(BuildContext c) {
    final k = widget.k;
    final lv = (k['Level'] ?? '').toString().isEmpty ? 'All levels' : k['Level'];
    final lang = (k['Language'] ?? '').toString().isEmpty ? 'English' : k['Language'];
    final vd = (k['ValidDays'] ?? 0) == 0 ? 365 : k['ValidDays'];
    final quiz = (k['QuizQs'] ?? 0) > 0;
    return Scaffold(
      appBar: AppBar(title: Text(k['Title'], maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: FutureBuilder(future: cur, builder: (_, s) {
        final d = s.data is Map ? s.data as Map : {};
        final secs = (d['sections'] as List? ?? []);
        final access = d['access'] == true;
        final exp = (d['expires'] ?? 0) as int;
        final expired = !access && exp > 0;
        return ListView(padding: const EdgeInsets.all(14), children: [
          cimg(k, 190),
          const SizedBox(height: 10),
          Row(children: [Chip(label: Text(k['Category'])), const SizedBox(width: 8), const Expanded(child: Text('By Janhavi Panwar')), const Icon(Icons.school, size: 16), Text(' ${k['Students'] ?? 0} students')]),
          Text(k['Title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
            if (access)
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: Text('✅ You have access · valid till ${dateStr(exp)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)))
            else ...[
              if (expired) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('Your access expired on ${dateStr(exp)}. Renew to continue.', style: const TextStyle(color: Colors.red))),
              Align(alignment: Alignment.centerLeft, child: priceRow(k['Price'], k['MRP'])),
              TextField(controller: cp, decoration: const InputDecoration(labelText: 'Coupon code (if you have one)')),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => buy(c, k['ID'], cp.text.trim()), child: Text(expired ? 'Renew ₹${k['Price']}' : 'Buy Now ₹${k['Price']}'))),
            ],
            const Divider(),
            info(Icons.signal_cellular_alt, 'Level', '$lv'),
            info(Icons.schedule, 'Duration', '${k['DurText']}'),
            info(Icons.menu_book, 'Lessons', '${k['LessonCount'] ?? 0}'),
            info(Icons.quiz, 'Quiz', quiz ? 'Yes' : 'No'),
            info(Icons.workspace_premium, 'Certificate', quiz ? 'Yes' : 'No'),
            info(Icons.language, 'Language', '$lang'),
            info(Icons.event, 'Access', vd == 365 ? '1 year' : '$vd days'),
          ]))),
          Row(children: [for (var i = 0; i < tabs.length; i++) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(tabs[i]), selected: tab == i, onSelected: (_) => setState(() => tab = i)))]),
          const SizedBox(height: 8),
          if (tab == 0) Text((k['Description'] ?? '').toString().isEmpty ? 'Course description coming soon.' : '${k['Description']}'),
          if (tab == 1) ...[
            if (secs.isEmpty) const Text('Curriculum coming soon.'),
            for (final sec in secs)
              Card(child: ExpansionTile(
                title: Text('${sec['Title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${(sec['Lessons'] as List? ?? []).length} lessons'),
                children: [
                  for (final x in (sec['Lessons'] as List? ?? []))
                    ListTile(dense: true, leading: Icon((x['URL'] ?? '').toString().isEmpty ? Icons.lock_outline : Icons.play_circle_fill, color: _blue), title: Text('${x['Title'] ?? ''}'), trailing: Text((x['Mins'] ?? 0) > 0 ? '${x['Mins']} min' : '', style: const TextStyle(fontSize: 12)), onTap: () => playLesson(c, x)),
                ],
              )),
          ],
          if (tab == 2)
            FutureBuilder(future: revs, builder: (_, rs) {
              final l = (rs.data is List ? rs.data as List : []).where((r) => r['CourseID'] == k['ID']).toList();
              return Column(children: [
                TextField(controller: rv, decoration: const InputDecoration(labelText: 'Write a review (visible after approval)')),
                TextButton(onPressed: () async {
                  await api('POST', '/api/reviews', {'courseId': k['ID'], 'text': rv.text, 'stars': 5});
                  rv.clear();
                  if (c.mounted) snack(c, 'Thanks! Your review is pending approval');
                }, child: const Text('Submit review')),
                if (l.isEmpty) const Text('No reviews yet.'),
                for (final r in l) ListTile(title: Text('${r['Name']}'), subtitle: Text('${r['Text']}'), trailing: Text('⭐${r['Stars']}')),
              ]);
            }),
          if (quiz) OutlinedButton(onPressed: () => go(c, Quiz(k)), child: const Text('Take Final Quiz → Get Certificate')),
          const SizedBox(height: 20),
        ]);
      }),
    );
  }
}
