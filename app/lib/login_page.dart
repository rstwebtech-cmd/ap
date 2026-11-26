part of 'main.dart';

class AuthShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const AuthShell(this.title, this.children, {super.key});
  @override Widget build(BuildContext c) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [_dark, Color(0xFF7C3AED)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Center(child: SingleChildScrollView(child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), margin: const EdgeInsets.all(24), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 46, backgroundColor: const Color(0xFFEDE9FE), backgroundImage: const NetworkImage(photo), onBackgroundImageError: (_, __) {}),
            const SizedBox(height: 8),
            const Text('Janhavi Panwar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Wonder Girl of India'),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 18, color: _blue)),
            const SizedBox(height: 8),
            ...children,
          ]))))),
        ),
      );
}

Widget authField(TextEditingController c, String label, {bool pass = false, TextInputType? type}) =>
    TextField(controller: c, obscureText: pass, keyboardType: type, decoration: InputDecoration(labelText: label));

Future<void> googleLogin(BuildContext c) async {
  final a = await (await GoogleSignIn(scopes: ['email']).signIn())?.authentication;
  if (a?.idToken == null) return;
  final r = await api('POST', '/api/auth/google', {'idToken': a!.idToken});
  if (c.mounted) finishLogin(c, r);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final em = TextEditingController(), pw = TextEditingController();
  bool busy = false;

  Future<void> submit() async {
    setState(() => busy = true);
    final r = await api('POST', '/api/auth/login', {'email': em.text, 'password': pw.text});
    if (!mounted) return;
    setState(() => busy = false);
    finishLogin(context, r);
  }

  @override Widget build(BuildContext c) => AuthShell('Welcome back! Log in to continue', [
        authField(em, 'Email', type: TextInputType.emailAddress),
        authField(pw, 'Password', pass: true),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait...' : 'Log in'))),
        TextButton(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const SignUpPage())), child: const Text('New here? Create an account')),
        OutlinedButton.icon(icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text('Continue with Google'), onPressed: () => googleLogin(c)),
      ]);
}
