// lib/features/pos/presentation/providers/themes/app_colors.dart
import 'package:flutter/material.dart';

// ========== NUEVA PALETA ==========
const Color primaryGreen = Color(0xFF10B981);  // Acción principal
const Color secondaryBlue = Color(0xFF59B1E4); // Marca / acento
const Color darkBlue = Color(0xFF0F2A44);      // Fondo modo oscuro (más azul)

const Color bgDark = Color(0xFF1E293B);        // Fondo oscuro alternativo (cards)
const Color bgLight = Color(0xFFF8FAFC);       // Fondo claro general
const Color cardDark = Color(0xFF334155);      // Superficie card oscura
const Color cardLight = Color(0xFFFFFFFF);     // Superficie card clara

const Color textDark = Color(0xFF0F172A);      // Texto principal oscuro
const Color textMuted = Color(0xFF64748B);     // Texto secundario / mutado

const Color blueSoft = Color(0xFFE0F2FE);      // Fondo chips/badges
const Color greenSoft = Color(0xFFD1FAE5);     // Fondo estados

// ========== DERIVADOS Y ALIAS ==========
// Para modo oscuro, necesitamos un tono más claro de bgDark para cards
const Color deepSpaceBlueLight = Color(0xFF2D3748); // Equivalente a cardDark
const Color slateGreyLight = Color(0xFF94A3B8);     // Equivalente a textMuted más claro

// ========== ALIAS PARA COMPATIBILIDAD (se eliminarán gradualmente) ==========
const Color brightSnow = bgLight;              // #F8FAFC
const Color deepSpaceBlue = bgDark;            // #1E293B (fondo oscuro alternativo)
const Color slateGrey = textMuted;             // #64748B
const Color mintLeaf = primaryGreen;           // #10B981
const Color pumpkinSpice = Color(0xFFF97316);  // #F97316 (naranja para advertencias)
const Color seashell = Color(0xFFFFF4ED);      // #FFF4ED (detalles cálidos)
const Color redError = Color(0xFFEF4444);      // #EF4444 (errores)