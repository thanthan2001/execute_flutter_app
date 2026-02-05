// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_clean_app/global/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: 'test@example.com');
    final passwordController = TextEditingController(text: '123456');

    return BaseScaffold(
      appBarTitle: 'Login',
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppInput(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppPasswordInput(
              controller: passwordController,
              labelText: 'Password',
            ),
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return AppButton.primary(
                  text: 'Login',
                  isLoading: isLoading,
                  width: double.infinity,
                  onPressed: isLoading ? null : () {
                    final email = emailController.text;
                    final password = passwordController.text;
                    context.read<AuthBloc>().add(
                          LoginEvent(email: email, password: password),
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
