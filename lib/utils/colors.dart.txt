import 'package:flutter/material.dart';

class AppColors {
  // ━━━ PRIMARY COLORS ━━━
  static const Color primary = Color(0xFF1B5E20);        // Kijani kirefu
  static const Color primaryLight = Color(0xFF4CAF50);   // Kijani laini
  static const Color secondary = Color(0xFFF9A825);      // Njano ya Tanzania
  static const Color secondaryLight = Color(0xFFFFD54F); // Njano laini

  // ━━━ TRANSACTION COLORS ━━━
  static const Color income = Color(0xFF2E7D32);         // Mapato - Kijani
  static const Color incomeLight = Color(0xFFE8F5E9);    // Mapato bg
  static const Color expense = Color(0xFFC62828);        // Matumizi - Nyekundu
  static const Color expenseLight = Color(0xFFFFEBEE);   // Matumizi bg

  // ━━━ BACKGROUND COLORS ━━━
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  // ━━━ TEXT COLORS ━━━
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF616161);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ━━━ CATEGORY COLORS ━━━
  static const List<Color> categoryColors = [
    Color(0xFF1565C0), // Bluu - Umeme
    Color(0xFF00838F), // Cyan - Maji
    Color(0xFFE65100), // Chungwa - Mafuta
    Color(0xFF6A1B9A), // Zambarau - Usafiri
    Color(0xFF558B2F), // Kijani - Chakula
    Color(0xFF37474F), // Kijivu - Data/Airtime
    Color(0xFFC62828), // Nyekundu - Afya
    Color(0xFF4E342E), // Kahawia - Kodi
    Color(0xFF1B5E20), // Kijani kirefu - Elimu
    Color(0xFF880E4F), // Waridi - Mavazi
    Color(0xFFF57F17), // Manjano - Nyinginezo
  ];
}
