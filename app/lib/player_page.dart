part of 'main.dart';

bool isDirectVideo(String u) {
  final l = u.toLowerCase();
  return l.contains('.mp4') || l.contains('.m3u8') || l.contains('.webm') || l.contains('b-cdn.net');
}

void playLesson(BuildContext c, Map x) {
  final u = (x['URL'] ?? '').toString();
  if (u.isEmpty) {
    snack(c, 'This lesson unlocks after you buy the course');
    return;
  }
  if (isDirectVideo(u)) {
    go(c, LessonPlayer(x['Title'] ?? 'Lesson', u));
  } else {
    launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
  }
}

class LessonPlayer extends StatefulWidget {
  final String title, url;
  const LessonPlayer(this.title, this.url, {super.key});
  @override State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  late final VideoPlayerController vc = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  ChewieController? cc;
  String? err;

  @override void initState() {
    super.initState();
    vc.initialize().then((_) {
      if (!mounted) return;
      setState(() => cc = ChewieController(videoPlayerController: vc, autoPlay: true, aspectRatio: vc.value.aspectRatio));
    }).catchError((e) {
      if (mounted) setState(() => err = 'This video could not be played.');
    });
  }

  @override void dispose() {
    cc?.dispose();
    vc.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext c) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
        body: Center(child: err != null ? Text(err!, style: const TextStyle(color: Colors.white)) : cc == null ? const CircularProgressIndicator() : Chewie(controller: cc!)),
      );
}
