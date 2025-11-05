import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

enum AuthMode { Login, Signup }

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthMode _authMode = AuthMode.Login;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _email = '';
  String _password = '';
  String _displayName = '';
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
      _controller.reset();
      _controller.forward();
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Invalid
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Signup) {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _passwordController.text);
        await userCredential.user?.updateDisplayName(_displayName);
        // Create a new document for the user with uid
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'displayName': _displayName,
          'email': _email,
          'level': 1,
          'points': 0,
          'rank': 'Newbie',
          'createdAt': Timestamp.now(),
        });

      } else {
        await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      }
      // Navigation is now handled by the authStateChanges listener
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unknown error occurred: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    }

    if (mounted) {
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF13112A),
      body: Stack(
        children: [
          _buildAuroraBackground(size),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        Form(
                          key: _formKey,
                          child: _authMode == AuthMode.Login
                              ? _buildLoginForm()
                              : _buildSignupForm(),
                        ),
                        const SizedBox(height: 30),
                        _buildPrimaryButton(),
                        const SizedBox(height: 20),
                        _buildSwitchAuthModeButton(),
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

  Widget _buildAuroraBackground(Size size) {
    return Stack(
      children: [
        Positioned(top: -100, left: -100, child: _buildBlob(const Color(0xFF9040F8), 250)),
        Positioned(bottom: -150, right: -150, child: _buildBlob(const Color(0xFF00D2FF), 300)),
        Positioned(top: size.height * 0.4, right: -50, child: _buildBlob(const Color(0xFFF92B7B), 200)),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(77),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _authMode == AuthMode.Login ? 'Welcome Back!' : 'Create Account',
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _authMode == AuthMode.Login ? 'Log in to your account' : 'Start your development journey',
          style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField('Email', Icons.alternate_email, validator: (val) => val!.isEmpty || !val.contains('@') ? 'Enter a valid email' : null, onSaved: (val) => _email = val!),
        const SizedBox(height: 20),
        _buildTextField('Password', Icons.lock_outline, isPassword: true, validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null, onSaved: (val) => _password = val!),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF9F92E3))),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        _buildTextField('Name', Icons.person_outline, validator: (val) => val!.isEmpty ? 'Please enter your name' : null, onSaved: (val) => _displayName = val!),
        const SizedBox(height: 20),
        _buildTextField('Email', Icons.alternate_email, validator: (val) => val!.isEmpty || !val.contains('@') ? 'Enter a valid email' : null, onSaved: (val) => _email = val!),
        const SizedBox(height: 20),
        _buildTextField('Password', Icons.lock_outline, controller: _passwordController, isPassword: true, validator: (val) => val!.length < 8 ? 'Password must be at least 8 characters' : null),
        const SizedBox(height: 20),
        _buildTextField('Confirm Password', Icons.lock_outline, isPassword: true, validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false, FormFieldValidator<String>? validator, FormFieldSetter<String>? onSaved, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      onSaved: onSaved,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
        prefixIcon: Icon(icon, color: Colors.white.withAlpha(204), size: 20),
        filled: true,
        fillColor: const Color(0xFF2A2849).withAlpha(128),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF9F92E3), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9040F8), Color(0xFFF92B7B)]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(
                  _authMode == AuthMode.Login ? 'LOGIN' : 'CREATE ACCOUNT',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ),
      ),
    );
  }

  Widget _buildSwitchAuthModeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.Login ? 'Don\'t have an account?' : 'Already have an account?',
          style: TextStyle(color: Colors.white.withAlpha(178)),
        ),
        TextButton(
          onPressed: _switchAuthMode,
          child: Text(
            _authMode == AuthMode.Login ? 'Sign up' : 'Log in',
            style: const TextStyle(color: Color(0xFF9F92E3), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
