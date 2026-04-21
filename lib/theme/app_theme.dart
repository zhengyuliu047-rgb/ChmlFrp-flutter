import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // 品牌主色调 - 渐变色系 (从靛蓝到紫罗兰的梦幻渐变)
  // ============================================================
  static const primaryColor = Color(0xFF6366F1);    // 靛蓝
  static const primaryLight = Color(0xFF818CF8);   // 浅靛蓝
  static const primaryDark = Color(0xFF4F46E5);   // 深靛蓝
  static const secondaryColor = Color(0xFF8B5CF6); // 紫色
  static const secondaryLight = Color(0xFFA78BFA); // 浅紫
  static const secondaryDark = Color(0xFF7C3AED); // 深紫
  static const accentColor = Color(0xFFEC4899);    // 粉色
  static const accentLight = Color(0xFFF472B6);    // 浅粉

  // ============================================================
  // 功能色 - 语义化色彩系统
  // ============================================================
  static const successColor = Color(0xFF10B981);  // 翡翠绿
  static const successLight = Color(0xFF34D399);   // 浅翡翠
  static const warningColor = Color(0xFFF59E0B);  // 琥珀橙
  static const warningLight = Color(0xFFFBBF24);  // 浅琥珀
  static const errorColor = Color(0xFFEF4444);     // 珊瑚红
  static const errorLight = Color(0xFFF87171);    // 浅珊瑚
  static const infoColor = Color(0xFF3B82F6);     // 天蓝
  static const infoLight = Color(0xFF60A5FA);      // 浅天蓝

  // ============================================================
  // 中性色 - 层次分明的内容层级
  // ============================================================
  static const backgroundColor = Color(0xFFF8FAFC);   // 雪白背景
  static const surfaceColor = Color(0xFFFFFFFF);      // 纯白卡片
  static const surfaceVariant = Color(0xFFF1F5F9);   // 灰白表面
  static const textPrimary = Color(0xFF0F172A);       // 深墨色
  static const textSecondary = Color(0xFF475569);    // 石墨色
  static const textTertiary = Color(0xFF94A3B8);     // 银灰色
  static const borderColor = Color(0xFFE2E8F0);      // 薄雾边框
  static const dividerColor = Color(0xFFE2E8F0);      // 分割线

  // ============================================================
  // 渐变色定义 - 品牌视觉核心
  // ============================================================
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, accentColor],
  );

  static final glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF).withOpacity(0.4),
      Color(0xFFFFFFFF).withOpacity(0.1),
    ],
  );

  // ============================================================
  // 字体配置
  // ============================================================
  static const fontFamily = 'HarmonyOS Sans';
  static const fontFamilyMono = 'JetBrains Mono';

  // ============================================================
  // 圆角配置 - 统一的圆角系统
  // ============================================================
  static const borderRadiusSmall = 8.0;
  static const borderRadiusMedium = 12.0;
  static const borderRadiusLarge = 16.0;
  static const borderRadiusXLarge = 24.0;
  static const borderRadiusFull = 9999.0;

  // ============================================================
  // 阴影系统 - 多层次空间感
  // ============================================================
  static const shadowXs = BoxShadow(
    color: Color(0x08000000),
    offset: Offset(0, 1),
    blurRadius: 1,
    spreadRadius: 0,
  );

  static const shadowSm = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );

  static const shadowMd = BoxShadow(
    color: Color(0x12000000),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -1,
  );

  static const shadowLg = BoxShadow(
    color: Color(0x19000000),
    offset: Offset(0, 8),
    blurRadius: 16,
    spreadRadius: -2,
  );

  static const shadowXl = BoxShadow(
    color: Color(0x24000000),
    offset: Offset(0, 20),
    blurRadius: 40,
    spreadRadius: -5,
  );

  // 彩色阴影
  static BoxShadow primaryShadow({double opacity = 0.2}) => BoxShadow(
    color: primaryColor.withOpacity(opacity),
    offset: const Offset(0, 8),
    blurRadius: 24,
    spreadRadius: -4,
  );

  static BoxShadow successShadow({double opacity = 0.2}) => BoxShadow(
    color: successColor.withOpacity(opacity),
    offset: const Offset(0, 4),
    blurRadius: 12,
    spreadRadius: -2,
  );

  // ============================================================
  // 主主题 - Material 3 现代化设计
  // ============================================================
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    primaryColorLight: primaryLight,
    primaryColorDark: primaryDark,
    fontFamily: fontFamily,
    fontFamilyFallback: const [
      'HarmonyOS Sans',
      'PingFang SC',
      'Microsoft YaHei',
      'Noto Sans CJK SC'
    ],
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight.withOpacity(0.2),
      secondary: secondaryColor,
      secondaryContainer: secondaryLight.withOpacity(0.2),
      tertiary: accentColor,
      tertiaryContainer: accentLight.withOpacity(0.2),
      surface: surfaceColor,
      surfaceContainerHighest: surfaceVariant,
      error: errorColor,
      errorContainer: errorLight.withOpacity(0.2),
      onPrimary: Colors.white,
      onPrimaryContainer: primaryDark,
      onSecondary: Colors.white,
      onSecondaryContainer: secondaryDark,
      onTertiary: Colors.white,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      onError: Colors.white,
      outline: borderColor,
      outlineVariant: borderColor.withOpacity(0.5),
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    dividerColor: dividerColor,

    // 卡片主题
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceColor,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        side: BorderSide(color: primaryColor, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: textTertiary, fontWeight: FontWeight.w400),
      labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      errorStyle: TextStyle(color: errorColor, fontWeight: FontWeight.w500),
    ),

    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return borderColor;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.4);
        }
        return borderColor.withOpacity(0.5);
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.12);
        }
        return Colors.transparent;
      }),
    ),

    // 滑块主题
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: borderColor,
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    // 进度条主题
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: borderColor,
      circularTrackColor: borderColor,
      linearMinHeight: 4,
    ),

    // 浮动按钮主题
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
    ),

    // 导航栏主题
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surfaceColor,
      indicatorColor: primaryColor.withOpacity(0.15),
      selectedIconTheme: IconThemeData(color: primaryColor, size: 24),
      unselectedIconTheme: IconThemeData(color: textSecondary, size: 24),
      selectedLabelTextStyle: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    ),

    // 对话框主题
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusXLarge),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontFamily: fontFamily,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        fontFamily: fontFamily,
      ),
    ),

    // Snackbar 主题
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    // 文本主题
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.15,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.25,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
        height: 1.4,
      ),
    ),
  );

  // 暗黑主题（预留）
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    // 其他暗黑主题配置...
  );
}

// ================================================================
// 扩展方法 - 方便在代码中使用主题
// ================================================================
extension ThemeExtension on BuildContext {
  // 颜色快捷访问
  Color get primaryColor => AppTheme.primaryColor;
  Color get secondaryColor => AppTheme.secondaryColor;
  Color get accentColor => AppTheme.accentColor;
  Color get successColor => AppTheme.successColor;
  Color get warningColor => AppTheme.warningColor;
  Color get errorColor => AppTheme.errorColor;
  Color get infoColor => AppTheme.infoColor;
  Color get backgroundColor => AppTheme.backgroundColor;
  Color get surfaceColor => AppTheme.surfaceColor;
  Color get surfaceVariant => AppTheme.surfaceVariant;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
  Color get textTertiary => AppTheme.textTertiary;
  Color get borderColor => AppTheme.borderColor;
  Color get dividerColor => AppTheme.dividerColor;

  // 圆角快捷访问
  double get borderRadiusSmall => AppTheme.borderRadiusSmall;
  double get borderRadiusMedium => AppTheme.borderRadiusMedium;
  double get borderRadiusLarge => AppTheme.borderRadiusLarge;
  double get borderRadiusXLarge => AppTheme.borderRadiusXLarge;
  double get borderRadiusFull => AppTheme.borderRadiusFull;

  // 渐变色快捷访问
  LinearGradient get primaryGradient => AppTheme.primaryGradient;
  LinearGradient get accentGradient => AppTheme.accentGradient;
  LinearGradient get glassGradient => AppTheme.glassGradient;
}

// ================================================================
// 通用装饰器 - 可复用的视觉效果
// ================================================================
class AppDecorators {
  // 玻璃态卡片
  static BoxDecoration glass({
    double opacity = 0.7,
    double borderRadius = AppTheme.borderRadiusLarge,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      );

  // 悬浮卡片
  static BoxDecoration floating({
    Color color = AppTheme.surfaceColor,
    double borderRadius = AppTheme.borderRadiusLarge,
    bool hasShadow = true,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: hasShadow
            ? [
                AppTheme.shadowMd,
                AppTheme.shadowSm,
              ]
            : null,
      );

  // 渐变边框卡片
  static BoxDecoration gradientBorder({
    double borderRadius = AppTheme.borderRadiusLarge,
    double borderWidth = 2,
    Gradient gradient = AppTheme.primaryGradient,
  }) =>
      BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderWidth > 0 ? AppTheme.borderColor : Colors.transparent,
          width: 1,
        ),
        boxShadow: [AppTheme.shadowMd],
      );
}
