import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Key كتجي من GitHub Secrets وقت الـ Build (الزاير ماكيبقاش يدخلها)
const String kGeminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

const int kDailyLimit = 25; // حد الرسائل فالنهار لكل مستخدم (Free)

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LMSpeaklyApp());
}

class LMSpeaklyApp extends StatelessWidget {
  const LMSpeaklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LM SPEAKLY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        primaryColor: const Color(0xFF58CC02),
        textTheme: GoogleFonts.nunitoTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58CC02),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

// ===================== AUTH CHECK =====================
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (email != null && email.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58CC02),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            Text(
              'LM SPEAKLY',
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const Text(
              'Learn English the fun way',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== LOGIN =====================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  Future<void> _submit() async {
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', emailC.text.trim());
    await prefs.setString(
      'user_name',
      isLogin ? (prefs.getString('user_name') ?? 'Learner') : nameC.text.trim(),
    );
    // init stats
    prefs.getInt('xp') ?? await prefs.setInt('xp', 0);
    prefs.getInt('streak') ?? await prefs.setInt('streak', 0);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('🦉', style: TextStyle(fontSize: 64)),
              Text(
                'LM SPEAKLY',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF58CC02),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin ? 'Welcome back!' : 'Create your free account',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (!isLogin)
                _field(nameC, 'Your name', Icons.person_outline),
              if (!isLogin) const SizedBox(height: 12),
              _field(emailC, 'Email', Icons.email_outlined),
              const SizedBox(height: 12),
              _field(passC, 'Password', Icons.lock_outline, obscure: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _submit,
                  child: Text(
                    isLogin ? 'LOG IN' : 'SIGN UP',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Log in',
                  style: const TextStyle(color: Color(0xFF1CB0F6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF58CC02), width: 2),
        ),
      ),
    );
  }
}

// ===================== MAIN SHELL (Bottom Nav) =====================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    LearnHomePage(),
    FreeChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          selectedItemColor: const Color(0xFF58CC02),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Practice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== LEARN HOME (Duolingo path) =====================
class Lesson {
  final String title;
  final String subtitle;
  final String emoji;
  final String prompt;
  final Color color;

  const Lesson(this.title, this.subtitle, this.emoji, this.prompt, this.color);
}

const lessons = [
  Lesson(
    'Greetings',
    'Say hello & introduce yourself',
    '👋',
    'Roleplay: casual greetings and introductions. Keep it A1-A2 level. Correct mistakes briefly.',
    Color(0xFF58CC02),
  ),
  Lesson(
    'At a Café',
    'Order food & drinks',
    '☕',
    'Roleplay: you are a barista. User orders coffee/food. Correct English mistakes politely.',
    Color(0xFF1CB0F6),
  ),
  Lesson(
    'Shopping',
    'Prices, sizes, clothes',
    '🛍️',
    'Roleplay: clothing store assistant. Help user buy clothes. Correct grammar gently.',
    Color(0xFFFF9600),
  ),
  Lesson(
    'Travel',
    'Airport & hotel English',
    '✈️',
    'Roleplay: airport/hotel staff. Help with check-in and directions. Correct mistakes.',
    Color(0xFFCE82FF),
  ),
  Lesson(
    'Job Interview',
    'Professional conversation',
    '💼',
    'Roleplay: job interviewer for a simple job. Ask common questions. Correct English mistakes.',
    Color(0xFFFF4B4B),
  ),
  Lesson(
    'Daily Life',
    'Talk about your day',
    '🌞',
    'Friendly chat about daily routines. Ask questions. Correct mistakes with short tips.',
    Color(0xFF58CC02),
  ),
];

class LearnHomePage extends StatefulWidget {
  const LearnHomePage({super.key});

  @override
  State<LearnHomePage> createState() => _LearnHomePageState();
}

class _LearnHomePageState extends State<LearnHomePage> {
  int xp = 0;
  int streak = 0;
  String name = 'Learner';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      xp = p.getInt('xp') ?? 0;
      streak = p.getInt('streak') ?? 0;
      name = p.getString('user_name') ?? 'Learner';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar like Duolingo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _stat('🔥', '$streak', const Color(0xFFFF9600)),
                  const SizedBox(width: 12),
                  _stat('⚡', '$xp XP', const Color(0xFFFFC800)),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF58CC02),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'L',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                itemCount: lessons.length,
                itemBuilder: (context, i) {
                  final lesson = lessons[i];
                  final alignLeft = i % 2 == 0;
                  return Align(
                    alignment:
                        alignLeft ? Alignment.centerLeft : Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatSessionPage(
                                title: lesson.title,
                                emoji: lesson.emoji,
                                systemPrompt: lesson.prompt,
                              ),
                            ),
                          ).then((_) => _load());
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: lesson.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: lesson.color.withOpacity(0.4),
                                blurRadius: 0,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lesson.emoji,
                                  style: const TextStyle(fontSize: 32)),
                              Text(
                                lesson.title.split(' ').first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== FREE CHAT =====================
class FreeChatPage extends StatelessWidget {
  const FreeChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Practice Chat',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💬', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                'Free conversation',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Talk about anything. The AI will correct your English like a tutor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatSessionPage(
                          title: 'Free Talk',
                          emoji: '💬',
                          systemPrompt:
                              'You are a friendly English tutor. Chat naturally. If the user makes grammar/vocab mistakes, start with "💡 Correction: ..." then continue. Keep replies short and engaging.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'START CHAT',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== PROFILE =====================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  int xp = 0;
  int streak = 0;
  int usedToday = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDay = p.getString('usage_day') ?? '';
    setState(() {
      name = p.getString('user_name') ?? 'Learner';
      email = p.getString('user_email') ?? '';
      xp = p.getInt('xp') ?? 0;
      streak = p.getInt('streak') ?? 0;
      usedToday = savedDay == today ? (p.getInt('usage_count') ?? 0) : 0;
    });
  }

  Future<void> _logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('user_email');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF58CC02),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'L',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                name,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Center(
              child: Text(email, style: TextStyle(color: Colors.grey.shade600)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _card('🔥 Streak', '$streak days')),
                const SizedBox(width: 12),
                Expanded(child: _card('⚡ Total XP', '$xp')),
              ],
            ),
            const SizedBox(height: 12),
            _card('📨 Messages today', '$usedToday / $kDailyLimit'),
            const SizedBox(height: 24),
            if (kGeminiApiKey.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  '⚠️ Gemini API Key missing in build.\nAdd GEMINI_API_KEY in GitHub Secrets and rebuild.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'LOG OUT',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== CHAT SESSION + GEMINI =====================
class ChatSessionPage extends StatefulWidget {
  final String title;
  final String emoji;
  final String systemPrompt;

  const ChatSessionPage({
    super.key,
    required this.title,
    required this.emoji,
    required this.systemPrompt,
  });

  @override
  State<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends State<ChatSessionPage> {
  final controller = TextEditingController();
  final scroll = ScrollController();
  final messages = <Map<String, String>>[];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    messages.add({
      'role': 'bot',
      'text':
          '${widget.emoji} Welcome to ${widget.title}!\nWrite in English — I will help and correct you. You have up to $kDailyLimit messages/day.',
    });
  }

  Future<bool> _canSend() async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDay = p.getString('usage_day') ?? '';
    int count = p.getInt('usage_count') ?? 0;
    if (savedDay != today) {
      count = 0;
      await p.setString('usage_day', today);
      await p.setInt('usage_count', 0);
    }
    if (count >= kDailyLimit) return false;
    await p.setInt('usage_count', count + 1);
    return true;
  }

  Future<void> _addXp(int amount) async {
    final p = await SharedPreferences.getInstance();
    final xp = (p.getInt('xp') ?? 0) + amount;
    await p.setInt('xp', xp);

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final last = p.getString('last_practice_day') ?? '';
    if (last != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
      int streak = p.getInt('streak') ?? 0;
      streak = (last == yesterday) ? streak + 1 : 1;
      await p.setInt('streak', streak);
      await p.setString('last_practice_day', today);
    }
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty || loading) return;

    if (kGeminiApiKey.isEmpty) {
      setState(() {
        messages.add({
          'role': 'bot',
          'text':
              '⚠️ App was built without API key. Add GEMINI_API_KEY in GitHub → Settings → Secrets, then rebuild APK.',
        });
      });
      return;
    }

    final ok = await _canSend();
    if (!ok) {
      setState(() {
        messages.add({
          'role': 'bot',
          'text':
              '⏳ Daily free limit reached ($kDailyLimit messages). Come back tomorrow!',
        });
      });
      return;
    }

    setState(() {
      messages.add({'role': 'user', 'text': text});
      loading = true;
    });
    controller.clear();
    _scrollToEnd();

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$kGeminiApiKey',
    );

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text':
                    '${widget.systemPrompt}\nAlways reply in English. Be warm like a Duolingo-style tutor. Short answers.'
              }
            ]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': text}
              ]
            }
          ]
        }),
      );

      String reply;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        reply = data['candidates'][0]['content']['parts'][0]['text'] as String;
        await _addXp(10);
      } else {
        reply =
            '❌ Error ${res.statusCode}. Key may be invalid or quota finished. Try again later.';
      }

      setState(() {
        messages.add({'role': 'bot', 'text': reply});
      });
    } catch (_) {
      setState(() {
        messages.add({
          'role': 'bot',
          'text': '❌ Network error. Check internet and try again.',
        });
      });
    } finally {
      setState(() => loading = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF58CC02) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: isUser
                          ? null
                          : Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(
                color: Color(0xFF58CC02),
                backgroundColor: Color(0xFFE5E5E5),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 2),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type in English...',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF58CC02),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
