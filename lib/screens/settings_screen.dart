import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/premium_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/premium_badge_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HiveService _hive = HiveService();
  late TextEditingController _nameController;
  late bool _morningReminder;
  late bool _eveningReminder;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _hive.getUserName());
    _morningReminder = _hive.isMorningReminderOn();
    _eveningReminder = _hive.isEveningReminderOn();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await _hive.setUserName(name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Jina limehifadhiwa!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚠️ Futa Data Yote?'),
        content: const Text(
          'Hatua hii itafuta rekodi ZOTE za mapato na matumizi yako. Haiwezekani kurudisha. Una uhakika?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hapana, Rudi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense),
            child: const Text('Ndiyo, Futa Yote',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _hive.transactionBox.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data yote imefutwa.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('⚙️ Mipangilio',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ━━━ APP INFO CARD ━━━
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('💰', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'v${AppConstants.appVersion}',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ━━━ PREMIUM BADGE ━━━
            PremiumBadgeWidget(
              isPremium: _hive.isPremium(),
              onUpgrade: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const PremiumScreen(),
                );
                if (result == true) setState(() {});
              },
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('👤 Wasifu Wako'),
            _buildCard(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Jina lako',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.primary),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  const Divider(height: 1),
                  TextButton(
                    onPressed: _saveName,
                    child: const Text(
                      'Hifadhi Jina',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ━━━ REMINDERS SECTION ━━━
            _buildSectionHeader('🔔 Vikumbusho'),
            _buildCard(
              child: Column(
                children: [
                  _buildToggle(
                    icon: '🌅',
                    title: 'Ukumbusho wa Asubuhi',
                    subtitle: 'Saa 3 asubuhi — anza kurekodi',
                    value: _morningReminder,
                    onChanged: (v) async {
                      setState(() => _morningReminder = v);
                      await _hive.setMorningReminder(v);
                      final notif = NotificationService();
                      if (v) {
                        await notif.scheduleMorningReminder();
                      } else {
                        await notif.cancelMorningReminder();
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildToggle(
                    icon: '🌙',
                    title: 'Ukumbusho wa Jioni',
                    subtitle: 'Saa 2 usiku — maliza rekodi za leo',
                    value: _eveningReminder,
                    onChanged: (v) async {
                      setState(() => _eveningReminder = v);
                      await _hive.setEveningReminder(v);
                      final notif = NotificationService();
                      if (v) {
                        await notif.scheduleEveningReminder();
                      } else {
                        await notif.cancelEveningReminder();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ━━━ DATA SECTION ━━━
            _buildSectionHeader('📦 Data Yako'),
            _buildCard(
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.delete_outline,
                    iconColor: AppColors.expense,
                    title: 'Futa Data Yote',
                    subtitle: 'Ondoa rekodi zote — haiwezekani kurudisha',
                    onTap: _clearAllData,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.expense),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ━━━ ABOUT SECTION ━━━
            _buildSectionHeader('ℹ️ Kuhusu App'),
            _buildCard(
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.offline_bolt_outlined,
                    iconColor: AppColors.primary,
                    title: 'Inafanya kazi Offline',
                    subtitle: 'Data yako iko salama kwenye simu yako',
                    onTap: null,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.lock_outline,
                    iconColor: AppColors.primary,
                    title: 'Faragha Yako',
                    subtitle: 'Hatutumii data yako wapi',
                    onTap: null,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.star_outline,
                    iconColor: AppColors.secondary,
                    title: 'Piga Kura Play Store',
                    subtitle: 'Tukipata nyota 5 tunafurahi sana! ⭐',
                    onTap: () {
                      // TODO: Open Play Store link
                    },
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            const Center(
              child: Text(
                'Imetengenezwa Tanzania 🇹🇿 kwa ❤️',
                style:
                    TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textMedium,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggle({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(fontSize: 12, color: AppColors.textLight)),
      trailing: trailing,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
