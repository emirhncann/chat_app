import 'package:chat_app_flutter/CustomUI/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> registerUser() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String email = _emailController.text;
      String password = _passwordController.text;

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user?.uid ?? '';

      await firestore.collection('kullanicilar').doc(userId).set({
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': email,
        'phone': _phoneController.text,
      });

      print('Kullanıcı başarıyla kaydedildi: $userId');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } catch (e) {
      print('Kullanıcı kaydetme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFD9D9D9),
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: height * 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(_nameController, 'Ad', Icons.person),
              SizedBox(height: 16.0),
              _buildTextField(_surnameController, 'Soyad', Icons.person),
              SizedBox(height: 16.0),
              _buildTextField(_emailController, 'E-posta', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 16.0),
              _buildTextField(_phoneController, 'Telefon Numarası', Icons.phone,
                  keyboardType: TextInputType.phone),
              SizedBox(height: 16.0),
              _buildTextField(_passwordController, 'Şifre', Icons.lock,
                  obscureText: true),
              SizedBox(height: 16.0),
              _buildTextField(
                  _confirmPasswordController, 'Şifre Tekrar', Icons.lock,
                  obscureText: true),
              SizedBox(height: 32.0),
              Container(
                width: width * 0.9,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0D9E2A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    await registerUser();
                  },
                  child: Text(
                    'Kayıt Ol',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
