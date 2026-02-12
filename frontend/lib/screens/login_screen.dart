import 'package:flutter/material.dart';
import '../widgets/user_agreement_dialog.dart';
import '../widgets/image_adjuster_dialog.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/top_snack_bar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final pickedImageFile = File(pickedFile.path);
      
      // Open custom image adjuster dialog
      if (mounted) {
        final adjustedFile = await showDialog<File?>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ImageAdjusterDialog(imageFile: pickedImageFile),
        );

        if (adjustedFile != null) {
          setState(() {
            _selectedImage = adjustedFile;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Side - Branding (Static)
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFF5D5FEF),
              padding: const EdgeInsets.all(60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'HYPER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Hey, Hello!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This tool is only accessible by members of Krypton',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "This tool is not meant to be distributed publicly. Every content gained from HYPER (any kind of documents, files, images, video, audio) is property of Krypton. If found leaked or misused, strict action will be taken. By creating an account, you accept these terms and agreements.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const UserAgreementDialog(),
                      );
                    },
                    icon: const Icon(Icons.description, color: Colors.white),
                    label: const Text(
                      'Read User Usage Agreement',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          
          // Right Side - Form (Animated)
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Form(
                        key: _isLogin ? _loginFormKey : _signupFormKey,
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              _isLogin ? 'Welcome Back' : 'Create Account',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              "This is an internal tool only accessible for Krypton members",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          if (!_isLogin) ...[
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                                    child: _selectedImage == null
                                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF5D5FEF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.upload, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.black),
                            maxLength: 50,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              // Strict validation: Alphanumeric and underscores only, no spaces
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return 'Username can only contain letters, numbers, and underscores';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: 'Username',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (!_isLogin) ...[
                             // Email Field
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Email',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            maxLength: 100,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),

                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            // Code Field (Only for Sign Up)
                            TextFormField(
                              controller: _codeController,
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the code';
                                }
                                if (value.length < 4) {
                                  return 'Code must be 4 characters';
                                }
                                return null;
                              },
                              maxLength: 4,
                              decoration: InputDecoration(
                                hintText: 'Code',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          
                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_isLogin) {
                                  if (_loginFormKey.currentState!.validate()) {
                                    // Handle Login
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    try {
                                      final response = await ApiService().login(
                                        username: _usernameController.text,
                                        password: _passwordController.text,
                                      );

                                      final accessToken = response['access_token'];
                                      debugPrint('Access Token: $accessToken');
                                      
                                      // Get User Profile
                                      final userProfile = await ApiService().getUserProfile(accessToken);
                                      debugPrint('User Profile: $userProfile');

                                      if (context.mounted) {
                                        Provider.of<UserProvider>(context, listen: false).setToken(accessToken);
                                        Provider.of<UserProvider>(context, listen: false).setUser(userProfile);
                                        showTopRightSnackBar(
                                          context, 
                                          'Login successful!', 
                                          isError: false
                                        );
                                        
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        showTopRightSnackBar(
                                          context, 
                                          e.toString().replaceAll('Exception: ', ''),
                                          isError: true
                                        );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  }
                                } else {
                                  if (_signupFormKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    
                                    try {
                                      await ApiService().signup(
                                        username: _usernameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        code: _codeController.text,
                                        image: _selectedImage,
                                      );

                                      if (context.mounted) {
                                        // Replaced standard SnackBar with Top Right Overlay
                                        showTopRightSnackBar(
                                          context, 
                                          'Account created successfully! Please login.', 
                                          isError: false
                                        );
                                  
                                        setState(() {
                                          _isLogin = true;
                                          _isLoading = false;
                                        });
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        showTopRightSnackBar(
                                          context, 
                                          e.toString().replaceAll('Exception: ', ''),
                                          isError: true
                                        );

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D5FEF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : Text(
                                _isLogin ? 'Login' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isLogin ? "Don't have an account?" : "Already have an account?",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(
                                    _isLogin ? 'Sign Up' : 'Login',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D5FEF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ),
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
