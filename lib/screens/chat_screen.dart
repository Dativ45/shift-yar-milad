import \'package:flutter/material.dart\';
import \'package:supabase_flutter/supabase_flutter.dart\';
class ChatScreen extends StatefulWidget { final String wardName; const ChatScreen({super.key, required this.wardName}); @override State<ChatScreen> createState()=> _ChatScreenState(); }
class _ChatScreenState extends State<ChatScreen> {
  final ctrl=TextEditingController();
  final supabase=Supabase.instance.client;
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title:Text("چت بخش ${widget.wardName}")), body:Column(children:[
      Expanded(child: StreamBuilder(stream: supabase.from(\'messages\').stream(primaryKey:[\'id\']).order(\'created_at\'), builder:(c,s){ if(!s.hasData) return Center(child:CircularProgressIndicator()); final m=s.data as List; return ListView.builder(itemCount:m.length, itemBuilder:(c,i){ return Align(alignment:Alignment.centerRight, child:Container(margin:EdgeInsets.all(8), padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Color(0xFFE3F2FD), borderRadius:BorderRadius.circular(16)), child:Text(m[i][\'text\']??\'\')));});})),
      Padding(padding:EdgeInsets.all(8), child:Row(children:[ Expanded(child:TextField(controller:ctrl, decoration:InputDecoration(hintText:"پیام بنویس...", border:OutlineInputBorder(borderRadius:BorderRadius.circular(24))))), IconButton(onPressed:() async { if(ctrl.text.isEmpty) return; await supabase.from(\'messages\').insert({\'ward_id\':1, \'text\':ctrl.text}); ctrl.clear();}, icon:Icon(Icons.send_rounded, color:Color(0xFF2AAFA1))) ]))
    ]));
  }
}
