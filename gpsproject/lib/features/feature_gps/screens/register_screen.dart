import 'package:flutter/material.dart';
import 'package:gpsproject/service/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _email = '';
  String _username = '';
  String _fullname = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/register.jpg', // Burada arka plan resminizin yolunu belirtin
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: screenHeight,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        const Text(
                          'Here',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.email, color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            fillColor: Color.fromARGB(145, 16, 16, 16),
                            filled: true,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            _email = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-posta giriniz';
                            }
                            if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                              return 'Lütfen geçerli bir e-posta adresi giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            fillColor: Color.fromARGB(145, 16, 16, 16),
                            filled: true,
                          ),
                          onChanged: (value) {
                            _username = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kullanıcı adı giriniz';
                            }
                            if (value.length < 3) {
                              return 'Kullanıcı adı en az 3 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Adınız',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            fillColor: Color.fromARGB(145, 16, 16, 16),
                            filled: true,
                          ),
                          onChanged: (value) {
                            _fullname = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Adınızı giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon:
                                Icon(Icons.password, color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            fillColor: Color.fromARGB(145, 16, 16, 16),
                            filled: true,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            _password = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre giriniz';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Şifreyi tekrar giriniz',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon:
                                Icon(Icons.password, color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            fillColor: Color.fromARGB(145, 16, 16, 16),
                            filled: true,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifreyi tekrar giriniz';
                            }
                            if (value != _password) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String? result = await _authService.signUp(
                                _email,
                                _username,
                                _fullname,
                                _password,
                              );
                              if (result == "success") {
                                Navigator.pushNamed(context, '/login');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          result ?? 'Registration failed')),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Kayıt Ol',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Zaten bir hesabınız var mı? Giriş yapın',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
