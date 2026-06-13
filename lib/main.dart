import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'core/app_colors.dart';
import 'core/network_config.dart';

// Repositories Interfaces
import 'domain/repositories/i_menu_repository.dart';
import 'domain/repositories/i_event_repository.dart';
import 'domain/repositories/i_user_repository.dart';
import 'domain/repositories/i_branch_repository.dart';
import 'domain/repositories/i_cart_repository.dart';

// Repositories Implementations
import 'data/repositories/menu_repository_impl.dart';
import 'data/repositories/network_event_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/branch_repository_impl.dart';
import 'data/repositories/cart_repository_impl.dart';

// Cubits
import 'presentation/cubit/dashboard/dashboard_cubit.dart';
import 'presentation/cubit/menu/menu_cubit.dart';
import 'presentation/cubit/menu/recommendation_cubit.dart';
import 'presentation/cubit/event/event_cubit.dart';
import 'presentation/cubit/user/user_cubit.dart';
import 'presentation/cubit/branch/branch_cubit.dart';
import 'presentation/cubit/cart/cart_cubit.dart';
import 'presentation/cubit/sanctuary/sanctuary_cubit.dart';

// Screens
import 'presentation/login_screen.dart';
import 'presentation/dashboard_screen.dart';

void main() {
  runApp(const AstrolabeApp());
}

class AstrolabeApp extends StatelessWidget {
  const AstrolabeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IMenuRepository>(
          create: (context) => MenuRepositoryImpl(
            baseUrl: NetworkConfig.apiBaseUrl,
          ),
        ),
        RepositoryProvider<IEventRepository>(
          create: (context) => NetworkEventRepositoryImpl(
            client: http.Client(),
            apiBaseUrl: NetworkConfig.apiBaseUrl,
          ),
        ),
        RepositoryProvider<IUserRepository>(create: (context) => UserRepositoryImpl()),
        RepositoryProvider<IBranchRepository>(create: (context) => BranchRepositoryImpl()),
        RepositoryProvider<ICartRepository>(create: (context) => CartRepositoryImpl()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>(create: (context) => DashboardCubit()),
          BlocProvider<MenuCubit>(create: (context) => MenuCubit(context.read<IMenuRepository>())..fetchMenu()),
          BlocProvider<RecommendationCubit>(create: (context) => RecommendationCubit(context.read<IMenuRepository>())..fetchRecommendations()),
          BlocProvider<EventCubit>(create: (context) => EventCubit(context.read<IEventRepository>())..fetchEvents()),
          BlocProvider<UserCubit>(create: (context) => UserCubit(context.read<IUserRepository>())..fetchUserProfile()),
          BlocProvider<BranchCubit>(create: (context) => BranchCubit(context.read<IBranchRepository>())..fetchBranches()),
          BlocProvider<CartCubit>(create: (context) => CartCubit(context.read<ICartRepository>())..loadCart()),
          BlocProvider<SanctuaryCubit>(create: (context) => SanctuaryCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
            scaffoldBackgroundColor: AppColors.backgroundBeige,
          ),
          home: const AuthGuard(),
        ),
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: 'astro_jwt_token'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primaryTeal,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.astrolabeGold),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}