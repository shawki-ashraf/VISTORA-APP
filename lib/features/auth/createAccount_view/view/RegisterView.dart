import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mira_fashon/features/auth/createAccount_view/wigets/textfiled.dart';
import 'package:mira_fashon/features/auth/login_view/view/login_view.dart';
import 'package:mira_fashon/features/shared_widgets/custombottom.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';
import 'package:mira_fashon/features/auth/login_view/cubit/account_cubit.dart';
import 'package:mira_fashon/roote.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreeToPolicy = false;
  bool _obscurePassword = true;

  static const _kBrown = Color(0xFF4A2C2A);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// 🔥 LOGO
                    Image.asset("assets/v.png", height: 45.h),

                    SizedBox(height: 16.h),

                    /// 🔥 TITLE
                    const Customtext(
                      text: "Register",
                      size: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),

                    SizedBox(height: 8.h),

                    /// ✨ SUBTITLE (NEW)
                    Text(
                      "Join our community and discover your style",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),

                    SizedBox(height: 32.h),

                    /// 🔹 NAME
                    CustomTextField(
                      controller: _nameController,
                      hint: 'Full Name',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your name' : null,
                    ),

                    SizedBox(height: 14.h),

                    /// 🔹 EMAIL
                    CustomTextField(
                      controller: _emailController,
                      hint: 'Email Address',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter your email';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 14.h),

                    /// 🔹 PASSWORD
                    CustomTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter your password';
                        }
                        if (v.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 12.h),

                    /// 🔹 CHECKBOX
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToPolicy,
                          onChanged: (v) =>
                              setState(() => _agreeToPolicy = v ?? false),
                          activeColor: _kBrown,
                        ),
                        const Text("Agree to policy"),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    /// 🔥 BUTTON + LOADING
                    BlocConsumer<AccountCubit, AccountState>(
                      listener: (context, state) {
                        if (state is AccountSuccess) {
                          _showSnackBar(
                            context,
                            "Account Created Successfully",
                            isError: false,
                          );

                          Future.delayed(const Duration(milliseconds: 300), () {
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
                        final isLoading = state is AccountLoading;

                        return Column(
                          children: [
                            /// 🔥 LOADING (فوق الزرار فقط)
                            if (isLoading)
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: SizedBox(
                                  height: 45.h,
                                  child: Lottie.asset(
                                    'assets/Loading Dots.json',
                                  ),
                                ),
                              ),

                            /// 🔘 BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: Custombottom(
                                text: 'Register',
                                ontap: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate() &&
                                            _agreeToPolicy) {
                                          context.read<AccountCubit>().register(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            username: _nameController.text,
                                          );
                                        } else if (!_agreeToPolicy) {
                                          _showSnackBar(
                                            context,
                                            "You must agree to the policy",
                                            isError: true,
                                          );
                                        }
                                      },
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 30.h),

                    /// 🔁 LOGIN NAV
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      ),
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
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

  /// 🔥 SNACKBAR
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
