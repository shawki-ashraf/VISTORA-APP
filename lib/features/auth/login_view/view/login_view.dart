import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mira_fashon/features/auth/createAccount_view/view/RegisterView.dart';
import 'package:mira_fashon/features/shared_widgets/custombottom.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';
import 'package:mira_fashon/features/auth/login_view/cubit/account_cubit.dart';
import 'package:mira_fashon/features/auth/createAccount_view/wigets/textfiled.dart';
import 'package:mira_fashon/roote.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  static const _kBrown = Color(0xFF4A2C2A);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreeToPolicy = false;
  bool _obscurePassword = true;
  @override
  void initState() {
    _emailController.text = "shawki@gmail.com";
    _passwordController.text = "123456789";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            // 🔥 يخلي الصفحة في النص
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 🔥
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/v.png", height: 40.h),
                    const SizedBox(height: 16),

                    const Customtext(
                      text: "Login",
                      color: Colors.black87,
                      size: 22,
                      fontWeight: FontWeight.bold,
                    ),

                    Customtext(
                      text: "Welcome back! Please login to your account",
                      color: Colors.grey,
                      size: 14,
                    ),

                    const SizedBox(height: 40),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      hint: 'E-Mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToPolicy,
                          onChanged: (v) =>
                              setState(() => _agreeToPolicy = v ?? false),
                          activeColor: LoginView._kBrown,
                        ),
                        const Expanded(
                          child: Customtext(
                            text: 'Agree to the usage policy',
                            color: Colors.black54,
                            size: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    BlocConsumer<AccountCubit, AccountState>(
                      listener: (context, state) {
                        if (state is AccountSuccess) {
                          _showSnackBar(
                            context,
                            "Login Successful",
                            isError: false,
                          );

                          Future.delayed(const Duration(milliseconds: 200), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomBottomNav(),
                              ),
                            );
                          });
                        } else if (state is AccountFailure) {
                          _showSnackBar(context, state.error, isError: true);
                        }
                      },
                      builder: (context, state) {
                        if (state is AccountLoading) {
                          return SizedBox(
                            width: 150,
                            height: 50,
                            child: Center(
                              child: Lottie.asset(
                                'assets/Loading Dots.json',
                                width: 180,
                                height: 180,
                              ),
                            ),
                          );
                        } else {
                          return Custombottom(
                            text: 'Login',
                            ontap: () {
                              if (_formKey.currentState!.validate() &&
                                  _agreeToPolicy) {
                                context.read<AccountCubit>().login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                              } else if (!_agreeToPolicy) {
                                _showSnackBar(
                                  context,
                                  'You must agree to the policy',
                                  isError: true,
                                );
                              }
                            },
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 28),

                    Column(
                      children: [
                        const Customtext(
                          text: 'Do you have an Account',
                          color: Colors.black54,
                          size: 12,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterView(),
                            ),
                          ),
                          child: const Customtext(
                            text: 'Register A New Account',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Custom SnackBar
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade400 : Colors.green,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
