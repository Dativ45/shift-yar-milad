import \'package:flutter/material.dart\';
import \'home_screen.dart\';
class LoginScreen extends StatelessWidget {
  final codeCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]), child: const Icon(Icons.health_and_safety_rounded, size: 48, color: Color(0xFF2AAFA1))),
      const SizedBox(height:16), const Text("شیفت‌یار", style: TextStyle(fontSize:32, fontWeight:FontWeight.bold, color:Color(0xFF0F2A44))), const Text("بیمارستان میلاد تهران", style: TextStyle(color: Colors.grey)),
      const SizedBox(height:32),
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)), child: Column(children: [
        TextField(controller: codeCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText:"کد پرسنلی", prefixIcon: Icon(Icons.badge_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled:true, fillColor: Color(0xFFFDF8F0))),
        const SizedBox(height:16),
        TextField(controller: passCtrl, obscureText:true, maxLength:4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText:"رمز 4 رقمی", prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled:true, fillColor: Color(0xFFFDF8F0))),
        const SizedBox(height:24),
        SizedBox(width:double.infinity, child: FilledButton(onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen())), child: const Text("ورود", style: TextStyle(fontSize:18)))),
      ]))
    ]))));
  }
}
