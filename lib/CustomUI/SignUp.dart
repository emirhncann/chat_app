import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController =
      TextEditingController(text: '+90');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              enabled: false, // Kullanıcının silebilmesini engellemek için
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Burada kullanıcının girdiği bilgileri kullanabilirsiniz
                String firstName = _firstNameController.text;
                String lastName = _lastNameController.text;
                String phoneNumber = _phoneNumberController.text;

                // Kullanıcı bilgileriyle yapılacak işlemleri gerçekleştir
                print('First Name: $firstName');
                print('Last Name: $lastName');
                print('Phone Number: $phoneNumber');
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignUpScreen(),
  ));
}
