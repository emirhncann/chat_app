import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefon Numarası',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre Tekrar',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text;
                String email = _emailController.text;
                String phone = _phoneController.text;
                String password = _passwordController.text;
                String confirmPassword = _confirmPasswordController.text;

                if (password == confirmPassword) {
                  try {
                    UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    // Kullanıcı oluşturuldu
                    print('Kullanıcı oluşturuldu: ${userCredential.user!.uid}');
                  } catch (e) {
                    // Hata durumu
                    print('Hata: $e');
                  }
                } else {
                  // Şifreler eşleşmiyor
                  print('Şifreler eşleşmiyor');
                }
              },
              child: Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
