import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginSuccess;

  const SignInScreen({
    super.key,
    required this.onBackPressed,
    required this.onRegisterPressed,
    required this.onLoginSuccess,
  });

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (success && mounted) {
      // Do nothing - let router redirect handle it automatically
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
            size: (ResponsiveUtils.isTabletOrLarger(context) ? 32.0 : 24.0) * layoutScale,
          ),
          onPressed: widget.onBackPressed,
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0 * layoutScale),
          child: Text('Login', style: AppTextStyles.headline2.copyWith(fontSize: 19 * textScale)),
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

                // Email field
                AppTextField(
                  hint: 'Your Email',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // if (!RegExp(
                    //   r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    // ).hasMatch(value)) {
                    //   return 'Invalid email';
                    // }
                    return null;
                  },
                ),
                SizedBox(height: 16 * layoutScale),

                // Password field
                AppTextField(
                  hint: 'Your Password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12 * layoutScale),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This feature is under development'),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14 * textScale,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 * layoutScale),

                // Login button
                PrimaryButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: isLoading,
                ),
                SizedBox(height: 24 * layoutScale),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: widget.onRegisterPressed,
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14 * textScale),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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
                SizedBox(height: 32 * layoutScale),

                // Divider with text
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * layoutScale),
                      child: Text(
                        'OR',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11 * textScale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                SizedBox(height: 24 * layoutScale),

                // Google login button
                SocialButton(
                  text: 'Sign in with Google',
                  icon: Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 24 * textScale,
                    height: 24 * textScale,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.g_mobiledata, size: 24 * textScale);
                    },
                  ),
                  onPressed: () {
                    // TODO: Implement Google login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This feature is under development'),
                      ),
                    );
                  },
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
