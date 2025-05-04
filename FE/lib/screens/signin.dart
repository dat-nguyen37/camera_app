import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/routes/app_routes.dart';
import 'package:camera_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;

  void signin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    var result = await _authService.signin(email, password);

    if (!mounted) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final user = result['success']['data']['others'];
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success']['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamed(context, AppRoute.main);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      shape: CircleBorder(),
                      foregroundColor: Colors.blue,
                      backgroundColor: const Color.fromARGB(
                        255,
                        228,
                        220,
                        220,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back you have been missed !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 18),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible =
                              !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('Forgot password?'),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: signin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Divider with text
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/icons/google.png',
                        width: 27,
                        height: 27,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.facebook,
                        color: Colors.blue,
                        size: 35,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/icons/instagram.png',
                        width: 27,
                        height: 27,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Sign in link
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account ? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoute.signup,
                        );
                      },
                      child: Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
