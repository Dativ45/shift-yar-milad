import \'package:flutter/material.dart\';
import \'package:shamsi_date/shamsi_date.dart\';
import \'chat_screen.dart\';
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final Jalali today = Jalali.now();
  Color getShiftColor(String type){
    switch(type){ case \'morning\': return Color(0xFF2AAFA1); case \'evening\': return Color(0xFFE8A80C); case \'night\': return Color(0xFF0F2A44); case \'off\': return Colors.green; default: return Colors.grey.shade300; }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${today.formatter.mN} ${today.year}"), actions: [IconButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatScreen(wardName:"اورژانس"))), icon: Icon(Icons.chat_bubble_rounded))]),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _dot("صبح", Color(0xFF2AAFA1)), _dot("عصر", Color(0xFFE8A80C)), _dot("شب", Color(0xFF0F2A44)), _dot("آف", Colors.green),])),
        Expanded(child: GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7, mainAxisSpacing:8, crossAxisSpacing:8), itemCount:30, itemBuilder: (c,i){ String type=[\'morning\',\'evening\',\'night\',\'off\',\'\'][i%5]; return Container(decoration: BoxDecoration(color:getShiftColor(type), borderRadius:BorderRadius.circular(16)), child:Center(child:Text("${i+1}", style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold))));})),
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex:0, destinations: [NavigationDestination(icon:Icon(Icons.calendar_month), label:\'تقویم\'), NavigationDestination(icon:Icon(Icons.chat), label:\'چت بخش\'), NavigationDestination(icon:Icon(Icons.person), label:\'پروفایل\')]),
    );
  }
  Widget _dot(String l, Color c)=> Row(children:[CircleAvatar(radius:6, backgroundColor:c), SizedBox(width:4), Text(l, style:TextStyle(fontSize:12))]);
}
