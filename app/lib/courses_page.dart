part of 'main.dart';

Widget courseCard(BuildContext c, Map k) => InkWell(onTap: () => go(c, CourseScreen(k)), child: Card(clipBehavior: Clip.antiAlias, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [cimg(k, 96), Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(10)), child: Text(k['Category'], style: const TextStyle(color: Colors.white, fontSize: 11)))), const Positioned(bottom: 6, left: 6, child: CircleAvatar(radius: 14, backgroundColor: Colors.black54, child: Icon(Icons.play_arrow, color: Colors.white, size: 18)))]),
      Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k['Title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [const Icon(Icons.access_time, size: 13), Text(' ${k['DurText']}', style: const TextStyle(fontSize: 12))]),
        priceRow(k['Price'], k['MRP']),
        SizedBox(width: double.infinity, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: _blue), onPressed: () => go(c, CourseScreen(k)), child: const Text('Enroll Now')))]))])));

class Courses extends StatefulWidget { final String q; const Courses({super.key, this.q = ''}); @override State<Courses> createState() => _Cs(); }

class _Cs extends State<Courses> {
  String cat = 'All';
  static const cats = ['All', 'English', 'Accent', 'Languages', 'Career'];
  @override Widget build(BuildContext c) => FutureBuilder(future: api('GET', '/api/courses'), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final l = (s.data as List).where((x) => (cat == 'All' || x['Category'] == cat) && x['Title'].toString().toLowerCase().contains(widget.q.toLowerCase())).toList();
        return Column(children: [
          SizedBox(height: 56, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [for (final t in cats) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(t), selected: cat == t, onSelected: (_) => setState(() => cat = t)))])),
          Expanded(child: GridView.count(crossAxisCount: 2, childAspectRatio: .62, crossAxisSpacing: 10, mainAxisSpacing: 10, padding: const EdgeInsets.all(10), children: [for (var i = 0; i < l.length; i++) Fade(courseCard(c, l[i]), i: i)]))]);
      });
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
