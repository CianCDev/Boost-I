import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart';

class SeleccionarDepartamentoDialog extends ConsumerStatefulWidget {
  final int? localId;

  const SeleccionarDepartamentoDialog({super.key, this.localId});

  @override
  ConsumerState<SeleccionarDepartamentoDialog> createState() => _SeleccionarDepartamentoDialogState();
}

class _SeleccionarDepartamentoDialogState extends ConsumerState<SeleccionarDepartamentoDialog> {
  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(todosDepartamentosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_business_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Agregar Departamento',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // CONTENIDO
                Expanded(
                  child: departamentosAsync.when(
                    data: (departamentos) {
                      final disponibles = departamentos.where((d) => d.localId != widget.localId).toList();
                      if (disponibles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_center_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'No hay departamentos disponibles',
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _crearNuevoDepartamento(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Crear nuevo departamento'),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: disponibles.length,
                        itemBuilder: (context, index) {
                          final d = disponibles[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              child: Icon(
                                Icons.business_center_rounded,
                                size: 16,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                            title: Text(
                              d.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: d.descripcion != null && d.descripcion!.isNotEmpty
                                ? Text(
                                    d.descripcion!,
                                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                  )
                                : null,
                            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            onTap: () {
                              d.localId = widget.localId;
                              ref.read(guardarDepartamentoProvider(d).future).then((_) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context, d);
                              });
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
                const SizedBox(height: 8),
                // BOTÓN CREAR NUEVO (siempre visible)
                TextButton.icon(
                  onPressed: _crearNuevoDepartamento,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Crear nuevo departamento'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _crearNuevoDepartamento() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CrearDepartamentoDialog(
        localIdPreseleccionado: widget.localId,
      ),
    );
    if (result == true) {
      ref.invalidate(todosDepartamentosProvider);
      setState(() {});
    }
  }
}