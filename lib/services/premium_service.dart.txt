import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hive_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM SERVICE
// Inasimamia unlock ya premium
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PremiumService {
  static final HiveService _hive = HiveService();

  // Check kama premium
  static bool isPremium() => _hive.isPremium();

  // Unlock premium (baada ya malipo kuthibitishwa)
  static Future<void> unlockPremium() async {
    await _hive.setPremium(true);
  }

  // Revoke premium (kwa testing)
  static Future<void> revokePremium() async {
    await _hive.setPremium(false);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // VERIFY M-PESA PAYMENT CODE
  // Mtumiaji analipa → anapata code
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Kwa sasa tunatumia manual verification
  // (Code ya kweli ingehitaji backend)
  // Hii ni approach ya MVP bila server:
  // 1. Mtumiaji analipa M-Pesa kwa namba yako
  // 2. Anapata transaction ID (k.m. SI47XXXXXX)
  // 3. Unatuma code ya unlock kwa WhatsApp/SMS
  // 4. Mtumiaji anapaste code hapa → unlocked

  // Codes za valid (encrypted) — change hizi mara kwa mara
  // Kwa production, hizi ziwe different kila mtumiaji
  static final List<String> _validMonthlyCode = [
    'HZ-MONTH-2026-A7X', // Juni 2026
    'HZ-MONTH-2026-B3K', // Backup code
  ];

  static final List<String> _validLifetimeCode = [
    'HZ-LIFE-GOLD-X9Z', // Lifetime code
    'HZ-LIFE-GOLD-Y4M', // Backup
  ];

  static PremiumVerifyResult verifyCode(String code) {
    final cleaned = code.trim().toUpperCase();

    if (_validMonthlyCode.contains(cleaned)) {
      return PremiumVerifyResult(
        isValid: true,
        type: PremiumType.monthly,
        message: '✅ Code nzuri! Premium ya mwezi mmoja imewashwa.',
      );
    }

    if (_validLifetimeCode.contains(cleaned)) {
      return PremiumVerifyResult(
        isValid: true,
        type: PremiumType.lifetime,
        message: '🎉 Code nzuri! Premium ya Milele imewashwa!',
      );
    }

    return PremiumVerifyResult(
      isValid: false,
      type: PremiumType.none,
      message: '❌ Code si sahihi. Angalia tena au wasiliana nasi.',
    );
  }
}

// ━━━━━━━━━━━━━━━━
// MODELS
// ━━━━━━━━━━━━━━━━
enum PremiumType { none, monthly, lifetime }

class PremiumVerifyResult {
  final bool isValid;
  final PremiumType type;
  final String message;

  PremiumVerifyResult({
    required this.isValid,
    required this.type,
    required this.message,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM SCREEN — Bottom Sheet
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _showCodeInput = false;
  String _selectedPlan = 'monthly';

  // M-Pesa number ya kupokea malipo
  static const String _mpesaNumber = '0712000000'; // Badilisha na namba yako
  static const String _whatsappNumber = '255712000000';

  void _copyNumber() {
    Clipboard.setData(const ClipboardData(text: _mpesaNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📋 Namba imenakiliwa!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnackbar('Weka code yako ya unlock', AppColors.expense);
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 1)); // UI feedback

    final result = PremiumService.verifyCode(code);

    if (result.isValid) {
      await PremiumService.unlockPremium();
      setState(() => _isVerifying = false);
      if (mounted) {
        Navigator.pop(context, true);
        _showSnackbar(result.message, AppColors.income);
      }
    } else {
      setState(() => _isVerifying = false);
      _showSnackbar(result.message, AppColors.expense);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('👑', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesabu Zangu Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fungua features zote bila kikwazo',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Features list
            _buildFeatureRow('📊', 'Ripoti za kina bila kikwazo'),
            _buildFeatureRow('📄', 'PDF na Excel download — unlimited'),
            _buildFeatureRow('📵', 'Hakuna matangazo kabisa'),
            _buildFeatureRow('📅', 'Historia yote — miaka yote'),
            _buildFeatureRow('🔔', 'Smart reminders zilizobinafsishwa'),
            _buildFeatureRow('💾', 'Google Drive backup (hivi karibuni)'),

            const SizedBox(height: 20),

            // Plan selector
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chagua Mpango',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    id: 'monthly',
                    title: 'Mwezi Mmoja',
                    price: 'Sh. ${AppConstants.premiumMonthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    sublabel: '/mwezi',
                    badge: '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPlanCard(
                    id: 'lifetime',
                    title: 'Milele',
                    price: 'Sh. ${AppConstants.premiumLifetimePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    sublabel: 'mara moja tu',
                    badge: '🔥 Bora',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Payment instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('📱', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Jinsi ya Kulipa kwa M-Pesa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStep('1', 'Tuma pesa kwa M-Pesa hadi namba:'),
                  const SizedBox(height: 6),

                  // M-Pesa number
                  GestureDetector(
                    onTap: _copyNumber,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _mpesaNumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(Icons.copy,
                              color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  _buildStep('2',
                      'Jina: Hesabu Zangu | Kiasi: Sh. ${_selectedPlan == 'monthly' ? AppConstants.premiumMonthlyPrice : AppConstants.premiumLifetimePrice}'),
                  const SizedBox(height: 4),
                  _buildStep('3',
                      'Tuma screenshot ya malipo kwa WhatsApp: $_whatsappNumber'),
                  const SizedBox(height: 4),
                  _buildStep('4',
                      'Utapata code ya unlock ndani ya dakika 30'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Code input toggle
            GestureDetector(
              onTap: () =>
                  setState(() => _showCodeInput = !_showCodeInput),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showCodeInput
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showCodeInput
                        ? 'Ficha sehemu ya code'
                        : 'Nina code ya unlock — ingiza hapa',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Code input
            if (_showCodeInput) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Mfano: HZ-MONTH-2026-XXXX',
                  labelText: 'Code ya Unlock',
                  prefixIcon: const Icon(Icons.vpn_key_outlined,
                      color: AppColors.primary),
                  filled: true,
                  fillColor: const Color(0xFFE8F5E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white),
                        )
                      : const Text(
                          '🔓 Thibitisha Code',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Close
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Sio sasa, endelea na toleo la bure',
                style: TextStyle(
                    color: AppColors.textLight, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String sublabel,
    required String badge,
  }) {
    final isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.incomeLight
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            if (badge.isNotEmpty) const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textDark,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
