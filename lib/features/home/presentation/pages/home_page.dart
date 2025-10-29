// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_clean_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_clean_app/global/widgets/base_scaffold.dart'; // Import BaseScaffold

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: 'Home',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.go('/login');
          },
        )
      ],
      body: Center(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Text('Welcome, ${state.user.name}!');
            }
            return const Text('Welcome!');
          },
        ),
      ),
    );
  }
}
