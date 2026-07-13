import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:async'; 
import 'package:url_launcher/url_launcher.dart';
import 'terms_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreed = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer; 

  final List<Map<String, String>> _tutorialSteps = [
    {
      "title": "Just 'Place' it",
      "subTitle": "そっと「置く」",
      "desc": "List small tasks you'd appreciate help with.",
      "subDesc": "頼むほどでもない事や、やってくれたら嬉しい事を置きましょう。",
      "icon": "🌊",
    },
    {
      "title": "Freely 'Pick up'",
      "subTitle": "自由に「拾う」",
      "desc": "Pick a task from the market to your space.",
      "subDesc": "気が向いたときに市場からタスクを拾いましょう。",
      "icon": "⛱️",
    },
    {
      "title": "Collect 'Joy'",
      "subTitle": "「喜び」を貯める",
      "desc": "Your contributions accumulate as points.",
      "subDesc": "完了した貢献がポイントとして蓄積されます。",
      "icon": "✨",
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _tutorialSteps.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; 
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              SizedBox(
                height: 340, 
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) => setState(() => _currentPage = page),
                  itemCount: _tutorialSteps.length,
                  itemBuilder: (context, index) {
                    return _buildTutorialPage(
                      _tutorialSteps[index]["title"]!,
                      _tutorialSteps[index]["subTitle"]!,
                      _tutorialSteps[index]["desc"]!,
                      _tutorialSteps[index]["subDesc"]!,
                      _tutorialSteps[index]["icon"]!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Icon(Icons.grid_view_rounded, size: 50, color: Color(0xFF1B263B)),
              const Text("marcheZ", style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 4, color: Color(0xFF1B263B))),
              Column(
                children: [
                  const Text("From a place to manage, to a 'Market'.", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("管理する場所から、助け合う「市場」へ。", style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 10)),
                ],
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(activeColor: const Color(0xFF1B263B), value: _agreed, onChanged: (v) => setState(() => _agreed = v!)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsPage())),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Agree to Terms and Privacy Policy", style: TextStyle(decoration: TextDecoration.underline, fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                            Text("利用規約とプライバシーポリシーに同意する", style: TextStyle(fontSize: 9, color: Colors.blueGrey.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse('tokushoho.html'), webOnlyWindowName: '_blank'),
                    child: Column(
                      children: [
                        const Text("Legal Compliance", style: TextStyle(decoration: TextDecoration.underline, fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                        Text("特定商取引法に基づく表記", style: TextStyle(fontSize: 8, color: Colors.blueGrey.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B263B), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _agreed ? () => auth.FirebaseAuth.instance.signInWithPopup(auth.GoogleAuthProvider()) : null,
                child: Column(
                  children: [
                    const Text("Start with Google Login", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Googleログインして開始", style: TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialPage(String title, String subTitle, String desc, String subDesc, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 50)),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
          Text(subTitle, style: TextStyle(fontSize: 12, color: const Color(0xFF1B263B).withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          Text(subDesc, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.blueGrey.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}