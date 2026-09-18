import \'package:flutter/material.dart\';
import \'package:supabase_flutter/supabase_flutter.dart\';
import \'theme/milad_theme.dart\';
import \'screens/login_screen.dart\';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: \'https://YOUR_PROJECT.supabase.co\', anonKey: \'YOUR_ANON_KEY\');
  runApp(const ShiftYarMiladApp());
}
class ShiftYarMiladApp extends StatelessWidget {
  const ShiftYarMiladApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, locale: const Locale(\'fa\'), theme: MiladTheme.light, home: LoginScreen());
  }
}
