import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterSuccess;

  const RegistrationScreen({
    super.key,
    required this.onBackPressed,
    required this.onLoginPressed,
    required this.onRegisterSuccess,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please review and accept the Terms of Service.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .register(
          _nicknameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account is ready. Please sign in.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final ts = ResponsiveUtils.textScaleFactor(context);
    final textScale = ts * ts;
    final layoutScale = ts;

    // Show error if any
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 84 * layoutScale,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size:
                (ResponsiveUtils.isTabletOrLarger(context) ? 32.0 : 24.0) *
                layoutScale,
          ),
          onPressed: widget.onBackPressed,
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0 * layoutScale),
          child: Text(
            'Create account',
            style: AppTextStyles.headline2.copyWith(fontSize: 19 * textScale),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.formMaxWidth(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20 * layoutScale,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20 * layoutScale),

                    // Nickname field
                    AppTextField(
                      hint: 'Your name',
                      controller: _nicknameController,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name.';
                        }
                        if (value.length < 3) {
                          return 'Your name must be at least 3 characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16 * layoutScale),

                    // Email field
                    AppTextField(
                      hint: 'Email address',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16 * layoutScale),

                    // Password field
                    AppTextField(
                      hint: 'Password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        if (value.length < 6) {
                          return 'Your password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20 * layoutScale),

                    // Terms checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: ResponsiveUtils.isTabletOrLarger(context)
                              ? 48
                              : 24,
                          height: ResponsiveUtils.isTabletOrLarger(context)
                              ? 48
                              : 24,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    4 * layoutScale,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * textScale),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12 * textScale,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 12 * textScale,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 12 * textScale,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 12 * textScale,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32 * layoutScale),

                    // Register button
                    PrimaryButton(
                      text: 'Create account',
                      onPressed: _handleRegister,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 24 * layoutScale),

                    // Login link
                    Center(
                      child: GestureDetector(
                        onTap: widget.onLoginPressed,
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14 * textScale,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 14 * textScale,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
