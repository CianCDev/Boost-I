import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'splash_screen.dart';

class ConfiguracionEmpresaScreen extends StatefulWidget {
  const ConfiguracionEmpresaScreen({super.key});

  @override
  State<ConfiguracionEmpresaScreen> createState() =>
      _ConfiguracionEmpresaScreenState();
}

class _ConfiguracionEmpresaScreenState
    extends State<ConfiguracionEmpresaScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _anonKeyController = TextEditingController();
  final TextEditingController _empresaIdController = TextEditingController();
  bool _isLoading = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    // Cargar valores existentes para prellenar
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('supabase_url') ?? '';
    final anonKey = prefs.getString('supabase_anon_key') ?? '';
    final empresaId = prefs.getString('empresa_id') ?? '';
    setState(() {
      _urlController.text = url;
      _anonKeyController.text = anonKey;
      _empresaIdController.text = empresaId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Configuración de Empresa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(68, 109, 241, 1),
                Color.fromARGB(255, 85, 59, 235)
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: isDesktop ? 600 : double.infinity,
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.business_center,
                    size: 64,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Conecta tu empresa a BoostI POS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa las credenciales de tu proyecto Supabase para comenzar a usar el sistema.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // URL
                  TextField(
                    controller: _urlController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'URL de Supabase',
                      hintText: 'https://xxxxx.supabase.co',
                      prefixIcon: const Icon(Icons.link, color: Color(0xFF64748B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Anon Key
                  TextField(
                    controller: _anonKeyController,
                    obscureText: _obscureKey,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Anon Key de Supabase',
                      hintText: 'sb_publishable_... o eyJhbGci...',
                      prefixIcon: const Icon(Icons.key, color: Color(0xFF64748B)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Empresa ID
                  TextField(
                    controller: _empresaIdController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Identificador de la empresa (opcional)',
                      hintText: 'mi-empresa (se generará automáticamente)',
                      prefixIcon: const Icon(Icons.tag, color: Color(0xFF64748B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botón
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarConfiguracion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded),
                                SizedBox(width: 12),
                                Text(
                                  'Guardar y Conectar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: const Color(0xFF0284C7), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'La aplicación se reiniciará después de guardar la configuración.',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF0369A1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardarConfiguracion() async {
    String url = _urlController.text.trim();
    final anonKey = _anonKeyController.text.trim();

    // ✅ Limpiar URL: eliminar cualquier ruta extra
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    // Si contiene "/rest/v1", eliminarlo
    if (url.contains('/rest/v1')) {
      url = url.replaceFirst(RegExp(r'/rest/v1.*'), '');
    }
    // Asegurar que termina con .supabase.co
    if (!url.contains('supabase.co')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La URL debe ser un dominio de Supabase válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (url.isEmpty || anonKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL y Anon Key son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabase_url', url);
      await prefs.setString('supabase_anon_key', anonKey);

      String empresaId = _empresaIdController.text.trim();
      if (empresaId.isEmpty) {
        final bytes = utf8.encode(url);
        int hash = 0;
        for (var b in bytes) {
          hash = (hash + b) * 31;
        }
        empresaId = 'empresa_${hash.abs().toRadixString(16)}';
      }
      await prefs.setString('empresa_id', empresaId);

      // ✅ Inicializar Supabase con la URL limpia
      try {
        await Supabase.initialize(
          url: url,
          publishableKey: anonKey,
        );
        debugPrint('✅ Supabase inicializado desde configuración');
      } catch (e) {
        // Si ya está inicializado, ignoramos el error
        debugPrint('⚠️ Supabase ya inicializado o error al inicializar: $e');
      }

      // ✅ Mostrar SnackBar antes de navegar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Configuración guardada. Reiniciando...'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Esperar un momento para que se muestre el SnackBar y luego navegar
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          // Navegar al Splash para que recargue la configuración
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}