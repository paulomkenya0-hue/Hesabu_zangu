import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../utils/colors.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': '💰',
      'title': 'Karibu Hesabu Zangu!',
      'subtitle':
          'App yako ya kusimamia mapato na matumizi kila siku — rahisi, ya haraka, bila internet!',
      'color': AppColors.primary,
    },
    {
      'icon': '📊',
      'title': 'Rekodi Kila Siku',
      'subtitle':
          'Weka mapato na matumizi yako kila siku. App itakuhesabia faida, hasara, na salio lako moja kwa moja.',
      'color': Color(0xFF1565C0),
    },
    {
      'icon': '📄',
      'title': 'Ripoti & Download',
      'subtitle':
          'Pakua ripoti yako kama PDF au Excel wakati wowote. Ona jinsi unavyotumia pesa zako kwa wiki au mwezi.',
      'color': Color(0xFF6A1B9A),
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    final hive = HiveService();
    await hive.setUserName(name.isEmpty ? 'Rafiki' : name);
    await hive.setOnboardingDone();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ━━━ PAGES ━━━
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length + 1, // +1 kwa name input page
            itemBuilder: (context, index) {
              if (index < _pages.length) {
                return _buildInfoPage(_pages[index]);
              }
              return _buildNamePage();
            },
          ),

          // ━━━ DOTS & BUTTON ━━━
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots
                Row(
                  children: List.generate(
                    _pages.length + 1,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Button
                _currentPage < _pages.length
                    ? FloatingActionButton(
                        onPressed: _nextPage,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                      )
                    : ElevatedButton(
                        onPressed: _finish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Anza Sasa! 🚀',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage(Map<String, dynamic> page) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (page['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page['icon'],
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page['title'],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page['subtitle'],
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👋', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          const Text(
            'Jina lako ni nani?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'App itakusalimia kwa jina lako kila siku',
            style: TextStyle(fontSize: 15, color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Mfano: Juma, Fatuma, Boss...',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
