import 'package:flutter/material.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  // CREAS UNA INSTANCIA DE LA CLASE
  UserModel? _user;

  // OBTIENES EL USUARIO
  UserModel? get user => _user;
  UserProvider() {
    // Intentar cargar el usuario desde SharedPreferences cuando se crea el proveedor
  }
  Future<void> initUser() async {
    //print("1.2 -------------- init");
    await _loadUserFromPrefs();
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    //print("2.1----------------------------------save user");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  Future<void> updateUser(UserModel newUser) async {
    _user = newUser;
    //print("1.1 -------------------------------update User");
    await _saveUserToPrefs(newUser);
    notifyListeners();
  }

  Future<void> _loadUserFromPrefs() async {
    //print("2.2-------------------------------load User");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    //print("user json------------------------");
    //print(userJson);
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }
  // ACTUALIZAS EL VALOR DEL OBJETO Y NOTIFICAMOS A LOS RECEPTORES
  /*void updateUser(UserModel newUser) async {
    _user = newUser;
    notifyListeners();
  }*/
}
