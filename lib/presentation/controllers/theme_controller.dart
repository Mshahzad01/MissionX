import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeController extends GetxController {
  static const String _themeKey = 'isDarkMode';
  final _isDarkMode = false.obs;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = _prefs.getBool(_themeKey) ?? false;
  }

  void toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
  await _prefs.setBool(_themeKey, _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
} 