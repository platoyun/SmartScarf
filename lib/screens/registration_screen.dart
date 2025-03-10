import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _acceptedPolicy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose your sign up method',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSignUpOption(Icons.email, 'Email'),
                  _buildSignUpOption(Icons.phone, 'Phone'),
                  _buildSignUpOption(Icons.wechat, 'WeChat'),
                  _buildSignUpOption(Icons.account_balance_wallet, 'Alipay'),
                ],
              ),
              const SizedBox(height: 48.0),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedPolicy,
                    onChanged: (value) {
                      setState(() {
                        _acceptedPolicy = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I accept the Terms of Service and Privacy Policy',
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpOption(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 40),
          onPressed: () {
            // TODO: Implement specific registration flow
          },
        ),
        Text(label),
      ],
    );
  }
} 