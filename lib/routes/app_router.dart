import 'package:flutter/material.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../shell/main_shell.dart';
import '../screens/patients/patient_detail_screen.dart';
import '../screens/patients/add_patient_screen.dart';
import '../screens/patients/edit_patient_screen.dart';
import '../screens/analysis/analysis_result_screen.dart';
import '../screens/analysis/new_analysis_screen.dart';
import '../screens/analysis/followup_chat_screen.dart';
import '../models/patient.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const LandingScreen(), settings);

      case '/login':
        return _buildRoute(const LoginScreen(), settings);

      case '/register':
        return _buildRoute(const RegisterScreen(), settings);

      case '/dashboard':
        return _buildRoute(const MainShell(initialTab: 0), settings);

      case '/analytics':
        return _buildRoute(const MainShell(initialTab: 2), settings);

      case '/patients':
        return _buildRoute(const MainShell(initialTab: 1), settings);

      case '/patients/add':
        return _buildRoute(const AddPatientScreen(), settings);

      case '/analysis/new':
        // Check if a patient was passed as argument
        final patient = settings.arguments as Patient?;
        return _buildRoute(NewAnalysisScreen(preselectedPatient: patient), settings);

      default:
        // Handle dynamic routes
        if (settings.name != null) {
          // Analysis detail route: /analysis/:id
          if (settings.name!.startsWith('/analysis/') &&
              !settings.name!.contains('/chat')) {
            final analysisId = settings.name!.split('/').last;
            return _buildRoute(
              AnalysisResultScreen(analysisId: analysisId),
              settings,
            );
          }

          // Analysis chat route: /analysis/:id/chat
          if (settings.name!.contains('/analysis/') &&
              settings.name!.endsWith('/chat')) {
            final parts = settings.name!.split('/');
            final analysisId = parts[parts.length - 2];
            return _buildRoute(
              FollowupChatScreen(analysisId: analysisId),
              settings,
            );
          }

          // Patient detail route: /patients/:id
          if (settings.name!.startsWith('/patients/') &&
              !settings.name!.endsWith('/edit')) {
            final patientId = settings.name!.split('/').last;
            return _buildRoute(
              PatientDetailScreen(patientId: patientId),
              settings,
            );
          }

          // Patient edit route: /patients/:id/edit
          if (settings.name!.endsWith('/edit')) {
            final patient = settings.arguments as Patient?;
            if (patient != null) {
              return _buildRoute(
                EditPatientScreen(patient: patient),
                settings,
              );
            }
          }
        }

        // 404 route
        return _buildRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
          settings,
        );
    }
  }

  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
