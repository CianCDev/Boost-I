// lib/features/pos/presentation/screens/welcome_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/responsive_helper.dart';
import 'email_login_screen.dart';
import 'login_screen.dart';
import 'register_company_screen.dart';

/// Pantalla de bienvenida para el primer uso de la app.
///
/// Ofrece 3 caminos:
/// - "Ya tengo una cuenta" → EmailLoginScreen (admin configura dispositivo)
/// - "Crear mi empresa"    → RegisterCompanyScreen (nuevo negocio)
/// - "Ya está configurada" → LoginScreen (empleado entra con PIN)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenSize = MediaQuery.of(context).size;

    final containerWidth = isMobile
        ? screenSize.width * 0.9
        : (screenSize.width > 600 ? 600.0 : screenSize.width * 0.9);

    final paddingSize = isMobile ? 24.0 : 42.0;
    final buttonHeight = isMobile ? 64.0 : 76.0;
    final logoSize = isMobile ? 100.0 : 140.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // ============================================================
          // FONDO CON GRADIENTE
          // ============================================================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF1A1A4E),
                  Color(0xFF2D1B69),
                  Color(0xFF4C2B8C),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Blob superior izquierdo (verde)
          Positioned(
            top: -150,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Blob inferior derecho (púrpura)
          Positioned(
            bottom: -150,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // ============================================================
          // CONTENIDO
          // ============================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: containerWidth,
                  margin: isMobile
                      ? const EdgeInsets.symmetric(horizontal: 16)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: -5,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        blurRadius: 60,
                        spreadRadius: -10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: EdgeInsets.all(paddingSize),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ========================================
                            // LOGO + TÍTULO
                            // ========================================
                            _buildLogo(logoSize, isMobile),
                            const SizedBox(height: 24),

                            Center(
                              child: Text(
                                'Bienvenido a BoostI POS',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                '¿Cómo quieres empezar?',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // ========================================
                            // BOTÓN: YA TENGO UNA CUENTA (email login)
                            // ========================================
                            _buildPrimaryButton(
                              context: context,
                              height: buttonHeight,
                              isMobile: isMobile,
                              icon: Icons.login_rounded,
                              title: 'Ya tengo una cuenta',
                              subtitle: 'Iniciar sesión con email',
                              color: const Color(0xFF10B981),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EmailLoginScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // ========================================
                            // BOTÓN: CREAR MI EMPRESA (register)
                            // ========================================
                            _buildPrimaryButton(
                              context: context,
                              height: buttonHeight,
                              isMobile: isMobile,
                              icon: Icons.business_rounded,
                              title: 'Crear mi empresa',
                              subtitle: 'Registrar un nuevo negocio',
                              color: const Color(0xFF8B5CF6),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterCompanyScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // ========================================
                            // BOTÓN: YA ESTÁ CONFIGURADA (PIN login)
                            // ========================================
                            _buildSecondaryButton(
                              context: context,
                              height: buttonHeight,
                              isMobile: isMobile,
                              icon: Icons.pin_rounded,
                              title: 'Ya está configurada',
                              subtitle: 'Ingresar PIN de empleado',
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // ========================================
                            // FOOTER
                            // ========================================
                            Center(
                              child: Text(
                                'v1.0.0  ·  JAH Lab',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontWeight: FontWeight.w400,
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
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPONENTES UI
  // ============================================================

  Widget _buildLogo(double size, bool isMobile) {
    final double iconSize = size * 0.5;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/logoboosti300px.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFF6EE7B7)],
          ).createShader(bounds),
          child: Text(
            'BoostI POS',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required double height,
    required bool isMobile,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required double height,
    required bool isMobile,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}