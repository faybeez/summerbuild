import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../app_colors.dart';
import '../../../supabase_config.dart';
import '../../widgets/inputs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!hasSupabaseConfig) {
      setState(() {
        _errorMessage =
            'Add your Supabase URL and publishable key before logging in.';
      });
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      if (mounted && res.session == null && res.user != null) {
        context.go('/verify-email', extra: email);
      } else if (mounted && res.session != null) {
        context.go('/home');
      }
    } on AuthException catch (error) {
      if (mounted) {
        if (error.message.contains('Email not confirmed')) {
          context.go('/verify-email', extra: email);
        } else {
          setState(() => _errorMessage = error.message);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to sign in right now.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  58,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),
                const SizedBox(height: 34),
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'name@example.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                ),
                const SizedBox(height: 14),
                AppPasswordField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  onSubmitted: (_) => _signIn(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.appTerracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/style-quiz'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.appCard,
                          ),
                        )
                      : const Text('Log In'),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () => context.go('/style-quiz'),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Continue with style profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.appEspresso,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Color(0xFFF0DEC6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here?',
                      style: TextStyle(
                        color: AppColors.appEspresso.withAlpha(150),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Create account'),
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

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.appWarmCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF1DFC8)),
          ),
          child: const Icon(
            Icons.checkroom,
            color: AppColors.appTerracotta,
            size: 38,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Welcome back',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to plan outfits, review your wardrobe, and get dressed for the day.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.appEspresso.withAlpha(165),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
