import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main()=> runApp(App());
class App extends StatelessWidget{ @override Widget build(BuildContext c)=> MaterialApp(debugShowCheckedModeBanner:false, theme:ThemeData.dark(), home:Splash());}

// ===== الساعة =====
class LiveClock extends StatefulWidget{ const LiveClock({super.key}); @override State<LiveClock> createState()=>_C();}
class _C extends State<LiveClock>{ late Timer t; DateTime n=DateTime.now(); @override void initState(){super.initState(); t=Timer.periodic(Duration(seconds:1),(_)=>setState(()=>n=DateTime.now()));} @override void dispose(){t.cancel(); super.dispose();} @override Widget build(BuildContext c){ String p(int v)=>v.toString().padLeft(2,'0'); return Text("${p(n.hour)}:${p(n.minute)}:${p(n.second)}", style:TextStyle(fontSize:13, color:Colors.white));}}

// ===== بيانات =====
class MyUser{ String name,email,pass; int followers,following,likes; Set<String> followed; List<String> inbox; MyUser(this.name,this.email,this.pass,{this.followers=0,this.following=0,this.likes=0,Set<String>? f,List<String>? ib}):followed=f??{}, inbox=ib??[];}
class Auth{
  static List<MyUser> users=[
    MyUser("goals_sa","g@g.com","123",followers:15000,following:200,likes:120000),
    MyUser("sarah","s@s.com","123",followers:12000,following:340,likes:45000),
    MyUser("tech","t@t.com","123",followers:50000,following:10,likes:200000),
  ];
  static MyUser? cur;
  static bool login(String e,String p){ for(var u in users){ if(u.email==e&&u.pass==p){cur=u; return true;}} return false;}
}
class Comment{ String user,text; DateTime t; int likes; bool liked; Comment(this.user,this.text,this.t,{this.likes=0,this.liked=false});}
class Video{ String id,user,desc,music; int likes,coms,shares,books; bool liked,booked; Color color; List<Comment> comments; Video({required this.id,required this.user,required this.desc,required this.music,required this.color,required this.likes,required this.coms,required this.shares,required this.books,this.liked=false,this.booked=false,List<Comment>? comments}):comments=comments??[];}
class DB{
  static List<Video> vids=[
    Video(id:"1", user:"goals_sa", desc:"هدف اليوم خرافي ⚽️🔥 #كورة", music:"تعليق المباراة", color:Color(0xFF009688), likes:120000, coms:4500, shares:8000, books:2000, comments:[Comment("ahmed","هدف عالمي",DateTime.now(),likes:50), Comment("sara","🔥🔥",DateTime.now(),likes:12)]),
    Video(id:"2", user:"sarah", desc:"يومياتي كمصممة ✨ #fyp", music:"الصوت الاصلي - sarah", color:Color(0xFF6C5CE7), likes:45200, coms:320, shares:1200, books:800),
    Video(id:"3", user:"tech", desc:"شرح Klencod بدون اخطاء", music:"شرح تقني", color:Color(0xFFE17055), likes:89100, coms:900, shares:5000, books:3000),
  ];
}

class Splash extends StatefulWidget{ @override State<Splash> createState()=>_S();}
class _S extends State<Splash>{ @override void initState(){super.initState(); Future.delayed(Duration(seconds:1),(){Auth.cur=Auth.users[0]; Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>TikHome()));});} @override Widget build(BuildContext c)=> Scaffold(backgroundColor:Colors.black, body:Center(child:Text("TikTok", style:TextStyle(fontSize:30, fontWeight:FontWeight.w900)))));}

class TikHome extends StatefulWidget{ @override State<TikHome> createState()=>_H();}
class _H extends State<TikHome>{
  int tab=0; int topTab=0; // 0=متابعون 1=For You
  List<Video> get filtered{
    if(topTab==0){
      var f=Auth.cur!.followed;
      var list=DB.vids.where((v)=> f.contains(v.user)).toList();
      return list.isEmpty? DB.vids : list;
    }
    return DB.vids;
  }

  // وظائف الازرار
  void _search(){ showModalBottomSheet(context:context, backgroundColor:Color(0xFF121212), builder:(_){ String q=""; return StatefulBuilder(builder:(c,set){ var res=DB.vids.where((v)=> v.desc.contains(q) || v.user.contains(q)).toList(); return Padding(padding:EdgeInsets.all(16), child:Column(children:[TextField(onChanged:(v)=>set(()=>q=v), decoration:InputDecoration(hintText:"بحث...", prefixIcon:Icon(Icons.search), filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))), SizedBox(height:10), Expanded(child:ListView(children: res.map((v)=> ListTile(title:Text(v.desc), subtitle:Text("@${v.user}"), onTap:(){ Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("فتح @${v.user}")));})).toList()))]));});});}

  void _addVideo(){ String d=""; var col=Colors.primaries[DateTime.now().second%Colors.primaries.length]; showModalBottomSheet(context:context, isScrollControlled:true, backgroundColor:Color(0xFF1E1E1E), builder:(_)=> Padding(padding:EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom, left:16,right:16,top:16), child:Column(mainAxisSize:MainAxisSize.min, children:[Text("اضافة فيديو / ريلز +", style:TextStyle(fontWeight:FontWeight.bold)), SizedBox(height:10), Container(height:140, decoration:BoxDecoration(color:col, borderRadius:BorderRadius.circular(14)), child:Center(child:Icon(Icons.videocam,size:50))), SizedBox(height:10), TextField(maxLines:3, onChanged:(v)=>d=v, decoration:InputDecoration(hintText:"الوصف... #كورة #fyp", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))), SizedBox(height:10), SizedBox(width:double.infinity, child: FilledButton(onPressed:(){ if(d.isNotEmpty){ setState(()=> DB.vids.insert(0,Video(id:DateTime.now().millisecondsSinceEpoch.toString(), user:Auth.cur!.name, desc:d, music:"الصوت الاصلي - ${Auth.cur!.name}", color:col, likes:0, coms:0, shares:0, books:0))); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("تم نشر الفيديو ✅")));}}, child:Text("نشر"))), SizedBox(height:20)])));}

  void _openFriends(){ showModalBottomSheet(context:context, backgroundColor:Color(0xFF121212), builder:(_)=> Padding(padding:EdgeInsets.all(16), child:Column(children:[Text("اصدقاء - متابعون", style:TextStyle(fontWeight:FontWeight.bold, fontSize:18)), SizedBox(height:10), Expanded(child:ListView(children: Auth.cur!.followed.map((u)=> ListTile(leading:CircleAvatar(child:Text(u[0].toUpperCase())), title:Text("@$u"), trailing: FilledButton(onPressed:(){ setState(()=> Auth.cur!.followed.remove(u)); Navigator.pop(context);}, child:Text("الغاء المتابعة"))))).toList()))])));}

  void _openInbox(){ showModalBottomSheet(context:context, backgroundColor:Color(0xFF121212), builder:(_)=> Padding(padding:EdgeInsets.all(16), child:Column(children:[Text("صندوق الوارد", style:TextStyle(fontWeight:FontWeight.bold, fontSize:18)), SizedBox(height:10), Expanded(child:ListView(children: Auth.cur!.inbox.isEmpty? [ListTile(title:Text("لا يوجد اشعارات"))] : Auth.cur!.inbox.map((m)=> ListTile(leading:Icon(Icons.favorite, color:Colors.red), title:Text(m))).toList()))])));}

  @override Widget build(BuildContext c)=> Scaffold(
    body: tab==0? Stack(children:[
      PageView.builder(scrollDirection:Axis.vertical, itemCount:filtered.length, itemBuilder:(_,i)=> VideoItem(video:filtered[i], onRefresh:()=>setState((){}), onSearch:_search)),
      SafeArea(child: Padding(padding:EdgeInsets.symmetric(horizontal:16, vertical:6), child: Row(children:[
        LiveClock(),
        Spacer(),
        GestureDetector(onTap:()=>setState(()=>topTab=0), child:Text("متابعون", style:TextStyle(fontWeight:topTab==0?FontWeight.w900:FontWeight.normal, fontSize:16, color:topTab==0?Colors.white:Colors.white54))),
        SizedBox(width:16),
        GestureDetector(onTap:()=>setState(()=>topTab=1), child:Text("For You لك", style:TextStyle(fontWeight:topTab==1?FontWeight.w900:FontWeight.normal, fontSize:16, color:topTab==1?Colors.white:Colors.white54))),
        Spacer(),
        GestureDetector(onTap:_search, child:Icon(Icons.search, size:28)),
      ]))),
    ]) : tab==1? FriendsPage(onBack:()=>setState(()=>tab=0)) : tab==3? InboxPage() : ProfilePage(),
    bottomNavigationBar: BottomNavigationBar(backgroundColor:Colors.black, selectedItemColor:Colors.white, unselectedItemColor:Colors.white54, type:BottomNavigationBarType.fixed, currentIndex: tab>2? (tab==4?4:0) : tab, onTap:(i){
      if(i==2){ _addVideo(); }
      else if(i==1){ setState(()=>tab=1); }
      else if(i==3){ setState(()=>tab=3); _openInbox(); }
      else if(i==4){ setState(()=>tab=4); }
      else { setState(()=>tab=0); }
    }, items:[
      BottomNavigationBarItem(icon:Icon(Icons.home_filled), label:"الرئيسية"),
      BottomNavigationBarItem(icon:Icon(Icons.people), label:"اصدقاء"),
      BottomNavigationBarItem(icon:Container(padding:EdgeInsets.symmetric(horizontal:18, vertical:4), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(8), border:Border.all(color:Color(0xFFFE2C55), width:2)), child:Icon(Icons.add, color:Colors.black, size:22)), label:""),
      BottomNavigationBarItem(icon:Icon(Icons.inbox_outlined), label:"صندوق"),
      BottomNavigationBarItem(icon:Icon(Icons.person_outline), label:"حسابي"),
    ]),
  );
}

class VideoItem extends StatelessWidget{
  final Video video; final VoidCallback onRefresh; final VoidCallback onSearch;
  const VideoItem({required this.video, required this.onRefresh, required this.onSearch});

  void _follow(BuildContext c){
    bool isF=Auth.cur!.followed.contains(video.user);
    if(isF){
      Auth.cur!.followed.remove(video.user);
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("تم الغاء متابعة @${video.user}")));
    }else{
      Auth.cur!.followed.add(video.user);
      Auth.cur!.inbox.add("بدأت متابعة @${video.user}");
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("تابعت @${video.user} ✅")));
    }
    onRefresh();
  }
  void _like(BuildContext c){
    video.liked=!video.liked;
    video.likes+= video.liked?1:-1;
    if(video.liked) Auth.cur!.inbox.add("اعجبت بفيديو @${video.user}");
    onRefresh();
  }
  void _bookmark(BuildContext c){
    video.booked=!video.booked;
    video.books+= video.booked?1:-1;
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(video.booked?"تم الحفظ في المفضلة 🔖":"تم ازالة الحفظ")));
    onRefresh();
  }
  void _share(BuildContext c){
    video.shares++;
    showModalBottomSheet(context:c, backgroundColor:Color(0xFF1E1E1E), builder:(_)=> Padding(padding:EdgeInsets.all(16), child:Column(mainAxisSize:MainAxisSize.min, children:[
      Text("مشاركة", style:TextStyle(fontWeight:FontWeight.bold)), SizedBox(height:12),
      Row(mainAxisAlignment:MainAxisAlignment.spaceAround, children:[
        _shareOpt(Icons.link, "نسخ الرابط", (){ Clipboard.setData(ClipboardData(text:"https://tiktok.com/@${video.user}/video/${video.id}")); Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("تم نسخ الرابط")));}),
        _shareOpt(Icons.chat, "واتساب", (){ Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("مشاركة واتساب")));}),
        _shareOpt(Icons.telegram, "تيليجرام", (){ Navigator.pop(c);}),
      ]),
      SizedBox(height:10),
    ])));
    onRefresh();
  }
  static Widget _shareOpt(IconData ic,String t,VoidCallback f)=> GestureDetector(onTap:f, child:Column(children:[CircleAvatar(radius:26, child:Icon(ic)), SizedBox(height:4), Text(t, style:TextStyle(fontSize:11))]));

  void _comment(BuildContext c){
    String inp="";
    showModalBottomSheet(context:c, isScrollControlled:true, backgroundColor:Color(0xFF121212), builder:(_)=> DraggableScrollableSheet(initialChildSize:0.75, maxChildSize:0.92, expand:false, builder:(_,sc)=> Column(children:[
      Padding(padding:EdgeInsets.all(12), child:Text("${video.coms} تعليق", style:TextStyle(fontWeight:FontWeight.bold))), Divider(height:1),
      Expanded(child:ListView.builder(controller:sc, itemCount:video.comments.length, itemBuilder:(_,i){
        var cm=video.comments[i];
        return ListTile(
          leading:CircleAvatar(radius:16, child:Text(cm.user[0])),
          title:Row(children:[Text(cm.user, style:TextStyle(fontSize:12, fontWeight:FontWeight.bold)), SizedBox(width:8), Text("${cm.t.hour}:${cm.t.minute}", style:TextStyle(fontSize:10, color:Colors.white54))]),
          subtitle:Text(cm.text),
          trailing:GestureDetector(onTap:(){ cm.liked=!cm.liked; cm.likes+= cm.liked?1:-1; onRefresh(); Navigator.pop(c); _comment(c);}, child:Column(children:[Icon(cm.liked?Icons.favorite:Icons.favorite_border, size:18, color:cm.liked?Colors.red:Colors.white54), Text("${cm.likes}", style:TextStyle(fontSize:10))])),
        );
      })),
      Padding(padding:EdgeInsets.all(8), child:Row(children:[Expanded(child:TextField(onChanged:(v)=>inp=v, decoration:InputDecoration(hintText:"اضف تعليق...", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(20),borderSide:BorderSide.none)))), IconButton(onPressed:(){ if(inp.isNotEmpty){ video.comments.insert(0,Comment(Auth.cur!.name, inp, DateTime.now())); video.coms++; onRefresh(); Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("تم اضافة التعليق")));}}, icon:Icon(Icons.send, color:Color(0xFFFE2C55)))]))
    ])));
  }
  void _more(BuildContext c){
    showModalBottomSheet(context:c, backgroundColor:Color(0xFF1E1E1E), builder:(_)=> Column(mainAxisSize:MainAxisSize.min, children:[
      ListTile(leading:Icon(Icons.report), title:Text("ابلاغ"), onTap:(){ Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("تم الابلاغ")));}),
      ListTile(leading:Icon(Icons.not_interested), title:Text("غير مهتم"), onTap:(){ Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("لن نعرض لك هذا النوع")));}),
      ListTile(leading:Icon(Icons.save_alt), title:Text("حفظ الفيديو"), onTap:(){ Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("تم حفظ الفيديو في الاستوديو")));}),
      SizedBox(height:10),
    ]));
  }

  @override Widget build(BuildContext c){
    bool isFollowed=Auth.cur!.followed.contains(video.user);
    return Stack(children:[
      Container(color:video.color, child:Center(child:Icon(Icons.play_arrow,size:80,color:Colors.black26))),
      Positioned(left:12,right:80,bottom:16, child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text("@${video.user}", style:TextStyle(fontWeight:FontWeight.w900, fontSize:16)),
        SizedBox(height:4), Text(video.desc, style:TextStyle(fontSize:13)),
        SizedBox(height:6), Row(children:[Icon(Icons.music_note,size:14), SizedBox(width:4), Expanded(child:Text(video.music, overflow:TextOverflow.ellipsis, style:TextStyle(fontSize:11, color:Colors.white70)))])
      ])),
      Positioned(right:8, bottom:90, child:Column(children:[
        // زر المتابعة
        GestureDetector(onTap:()=>_follow(c), child:Stack(children:[
          CircleAvatar(radius:28, backgroundColor:Colors.white, child:Text(video.user[0].toUpperCase(), style:TextStyle(color:Colors.black, fontWeight:FontWeight.bold, fontSize:22))),
          Positioned(bottom:0, left:0, right:0, child:Container(decoration:BoxDecoration(color:isFollowed?Colors.white:Color(0xFFFE2C55), shape:BoxShape.circle, border:Border.all(color:Colors.black, width:1.5)), child:Icon(isFollowed?Icons.check:Icons.add, size:16, color:isFollowed?Colors.black:Colors.white))),
        ])),
        SizedBox(height:18),
        GestureDetector(onTap:()=>_like(c), child:Column(children:[Icon(video.liked?Icons.favorite:Icons.favorite_border, color:video.liked?Colors.red:Colors.white, size:36), SizedBox(height:2), Text(video.likes>=1000?"${(video.likes/1000).toStringAsFixed(1)}K":"${video.likes}", style:TextStyle(fontSize:12, fontWeight:FontWeight.bold))])),
        SizedBox(height:14),
        GestureDetector(onTap:()=>_comment(c), child:Column(children:[Icon(Icons.chat_bubble, size:32), Text("${video.coms}", style:TextStyle(fontSize:12, fontWeight:FontWeight.bold))])),
        SizedBox(height:14),
        GestureDetector(onTap:()=>_bookmark(c), child:Column(children:[Icon(video.booked?Icons.bookmark:Icons.bookmark_border, color:video.booked?Colors.yellow:Colors.white, size:32), Text("${video.books}", style:TextStyle(fontSize:12, fontWeight:FontWeight.bold))])),
        SizedBox(height:14),
        GestureDetector(onTap:()=>_share(c), child:Column(children:[Icon(Icons.share, size:32), Text("${video.shares}", style:TextStyle(fontSize:12, fontWeight:FontWeight.bold))])),
        SizedBox(height:14),
        GestureDetector(onTap:()=>_more(c), child:Icon(Icons.more_horiz, size:26)),
      ])),
    ]);
  }
}

class FriendsPage extends StatelessWidget{ final VoidCallback onBack; const FriendsPage({required this.onBack}); @override Widget build(BuildContext c)=> Scaffold(appBar:AppBar(title:Text("اصدقاء")), body:ListView(children: Auth.cur!.followed.isEmpty? [Center(child:Padding(padding:EdgeInsets.all(30), child:Text("لا تتابع احد بعد - تابع من زر + في الفيديو")))] : Auth.cur!.followed.map((u)=> ListTile(leading:CircleAvatar(child:Text(u[0])), title:Text("@$u"), subtitle:Text("يتابعك"), trailing: FilledButton(onPressed:(){}, child:Text("رسالة")))).toList()));}
class InboxPage extends StatelessWidget{ @override Widget build(BuildContext c)=> Scaffold(appBar:AppBar(title:Text("صندوق الوارد")), body:ListView(children: Auth.cur!.inbox.reversed.map((m)=> ListTile(leading:Icon(Icons.notifications, color:Colors.pink), title:Text(m), subtitle:Text("الان", style:TextStyle(fontSize:10)))).toList()));}
class ProfilePage extends StatelessWidget{
  @override Widget build(BuildContext c){
    var mine=DB.vids.where((v)=>v.user==Auth.cur!.name).toList();
    var saved=DB.vids.where((v)=>v.booked).toList();
    return DefaultTabController(length:2, child: Scaffold(appBar:AppBar(title:Text("@${Auth.cur!.name}"), bottom:TabBar(tabs:[Tab(text:"فيديوهاتي"), Tab(text:"المحفوظات 🔖")])), body:Column(children:[
      SizedBox(height:10), CircleAvatar(radius:40, child:Text(Auth.cur!.name[0], style:TextStyle(fontSize:30))), Text("@${Auth.cur!.name}", style:TextStyle(fontWeight:FontWeight.bold)), SizedBox(height:8),
      Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly, children:[_s("${Auth.cur!.following}","متابَع"), _s("${Auth.cur!.followed.length}","متابعين"), _s("${DB.vids.fold(0,(a,b)=>a+b.likes)}","اعجابات")]),
      SizedBox(height:10), Divider(height:1),
      Expanded(child: TabBarView(children:[
        GridView.builder(gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3, crossAxisSpacing:2, mainAxisSpacing:2), itemCount:mine.length, itemBuilder:(_,i)=> Container(color:mine[i].color, child:Center(child:Text(mine[i].likes.toString())))),
        GridView.builder(gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3, crossAxisSpacing:2, mainAxisSpacing:2), itemCount:saved.length, itemBuilder:(_,i)=> Container(color:saved[i].color, child:Icon(Icons.bookmark))),
      ]))
    ])));
  }
  Widget _s(String n,String t)=> Column(children:[Text(n, style:TextStyle(fontWeight:FontWeight.bold)), Text(t, style:TextStyle(fontSize:11, color:Colors.white54))]);
}