import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double defaultPadding = 16.0;
const double smallPadding = 8.0;
const double largePadding = 20.0;

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color hint;
  final Color background;
  final Color pink;
  final Color skyBlue;
  final Color green;
  final Color purple;
  final Color red;
  final Color cryptoSelected;
  final Color white;
  final Color black;
  final Color primaryLight;

  const AppColors({
    required this.primary,
    required this.hint,
    required this.background,
    required this.pink,
    required this.skyBlue,
    required this.green,
    required this.purple,
    required this.red,
    required this.cryptoSelected,
    required this.white,
    required this.black,
    required this.primaryLight,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? hint,
    Color? background,
    Color? pink,
    Color? skyBlue,
    Color? green,
    Color? purple,
    Color? red,
    Color? cryptoSelected,
    Color? white,
    Color? black,
    Color? primaryLight,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      hint: hint ?? this.hint,
      background: background ?? this.background,
      pink: pink ?? this.pink,
      skyBlue: skyBlue ?? this.skyBlue,
      green: green ?? this.green,
      purple: purple ?? this.purple,
      red: red ?? this.red,
      cryptoSelected: cryptoSelected ?? this.cryptoSelected,
      white: white ?? this.white,
      black: black ?? this.black,
      primaryLight: primaryLight ?? this.primaryLight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      background: Color.lerp(background, other.background, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      skyBlue: Color.lerp(skyBlue, other.skyBlue, t)!,
      green: Color.lerp(green, other.green, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      red: Color.lerp(red, other.red, t)!,
      cryptoSelected: Color.lerp(cryptoSelected, other.cryptoSelected, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
    );
  }

  static const light = AppColors(
    primary: Color(0xFF6F35A5),
    hint: Color(0xA66F35A5),
    background: Color(0xFFFFFFFF),
    pink: Color(0xFFEB62D0),
    skyBlue: Color(0xFF01A3FF),
    green: Color(0xFF1EBA62),
    purple: Color(0xFF9568ff),
    red: Color(0xFFFF0000),
    cryptoSelected: Color(0xFF9fce63),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    primaryLight: Color(0xFFF1E6FF),
  );

  static const dark = AppColors(
    primary: Color(0xFF6F35A5),
    hint: Colors.grey,
    background: Color(0xFF121212),
    pink: Color(0xFFEB62D0),
    skyBlue: Color(0xFF01A3FF),
    green: Color(0xFF1EBA62),
    purple: Color(0xFFBB86FC),
    red: Color(0xFFFF5C5C),
    cryptoSelected: Color(0xFFA3D977),
    white: Color(0xFFEAEAEA),
    black: Color(0xFF000000),
    primaryLight: Color(0xFF2C2C2C),
  );
}

// LIGHT THEME
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.light.background,
  extensions: const <ThemeExtension<dynamic>>[
    AppColors.light,
  ],
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: AppColors.light.black,
    displayColor: AppColors.light.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: AppColors.light.primary,
      maximumSize: const Size(double.infinity, 56),
      minimumSize: const Size(double.infinity, 56),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.light.primaryLight,
    iconColor: AppColors.light.primary,
    prefixIconColor: AppColors.light.primary,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: defaultPadding,
      vertical: defaultPadding,
    ),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      borderSide: BorderSide.none,
    ),
  ),
);

// DARK THEME
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.dark.background,
  extensions: const <ThemeExtension<dynamic>>[
    AppColors.dark,
  ],
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: AppColors.dark.white,
    displayColor: AppColors.dark.primary,
  ),
);
