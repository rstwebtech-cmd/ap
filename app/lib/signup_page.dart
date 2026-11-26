part of 'main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final nm = TextEditingController(), em = TextEditingController(), ph = TextEditingController(), pw = TextEditingController(), rf = TextEditingController();
  bool busy = false;

  Future<void> submit() async {
    if (nm.text.trim().isEmpty || em.text.trim().isEmpty || pw.text.length < 6) {
      snack(context, 'Please enter your name, email and a password of at least 6 characters');
      return;
    }
    setState(() => busy = true);
    final r = await api('POST', '/api/auth/register', {'name': nm.text.trim(), 'email': em.text.trim(), 'phone': ph.text.trim(), 'password': pw.text, 'ref': rf.text.trim()});
    if (!mounted) return;
    setState(() => busy = false);
    finishLogin(context, r);
  }

  @override Widget build(BuildContext c) => AuthShell('Create your account', [
        authField(nm, 'Full name'),
        authField(em, 'Email', type: TextInputType.emailAddress),
        authField(ph, 'Mobile number', type: TextInputType.phone),
        authField(pw, 'Password (min 6 characters)', pass: true),
        authField(rf, 'Referral code (optional)'),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait...' : 'Create account'))),
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Already have an account? Log in')),
        OutlinedButton.icon(icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text('Sign up with Google'), onPressed: () => googleLogin(c)),
      ]);
}
