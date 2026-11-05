'use client';

import { useEffect, useState, useRef } from 'react';
import {
  AnimatePresence,
  motion,
  useMotionValueEvent,
  useScroll,
} from 'framer-motion';
import Link from 'next/link';
import CookieConsent from './components/CookieConsent';
import ContactDialog from './components/ContactDialog';
import OnboardingDialog from './components/OnboardingDialog';
import FAQ from './components/FAQ';
import Integrations from './components/Integrations';
import FloatingHelpButton from './components/FloatingHelpButton';
import Background from './components/Background';
import {
  Store,
  ShoppingBag,
  Truck,
  Calculator,
  Users,
  BarChart3,
  Smartphone,
  Calendar,
  Utensils,
  Tags,
  CloudOff,
  MapPin,
  ShieldCheck,
  CreditCard,
} from './components/icons';

/* ============================================================
   ICONOS
   ============================================================ */
const Icon = {
  Logo: (props: any) => (
    <img
      src="https://ik.imagekit.io/xnf3fil5g/logo.png?updatedAt=1793739883090"
      alt="BoostI POS"
      width={28}
      height={28}
      style={{
        objectFit: 'contain',
        filter: 'brightness(0) invert(1)',
      }}
      {...props}
    />
  ),
  Cart: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <circle cx="9" cy="21" r="1" />
      <circle cx="20" cy="21" r="1" />
      <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
    </svg>
  ),
  Box: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
      <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
      <line x1="12" y1="22.08" x2="12" y2="12" />
    </svg>
  ),
  Store: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M3 9l1-5h16l1 5M4 9v11a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V9M4 9h16" />
      <path d="M9 22V12h6v10" />
    </svg>
  ),
  Chart: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M3 3v18h18" />
      <path d="M7 14l4-4 4 4 5-5" />
    </svg>
  ),
  Printer: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <polyline points="6 9 6 2 18 2 18 9" />
      <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" />
      <rect x="6" y="14" width="12" height="8" />
    </svg>
  ),
  Cloud: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z" />
    </svg>
  ),
  Check: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <polyline points="20 6 9 17 4 12" />
    </svg>
  ),
  Arrow: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <line x1="5" y1="12" x2="19" y2="12" />
      <polyline points="12 5 19 12 12 19" />
    </svg>
  ),
  ArrowUpRight: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <line x1="7" y1="17" x2="17" y2="7" />
      <polyline points="7 7 17 7 17 17" />
    </svg>
  ),
  Star: (props: any) => (
    <svg viewBox="0 0 24 24" fill="currentColor" {...props}>
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
  ),
  Menu: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" {...props}>
      <line x1="3" y1="6" x2="21" y2="6" />
      <line x1="3" y1="12" x2="21" y2="12" />
      <line x1="3" y1="18" x2="21" y2="18" />
    </svg>
  ),
  X: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" {...props}>
      <line x1="18" y1="6" x2="6" y2="18" />
      <line x1="6" y1="6" x2="18" y2="18" />
    </svg>
  ),
  Zap: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" />
    </svg>
  ),
  Monitor: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <rect x="2" y="3" width="20" height="14" rx="2" />
      <line x1="12" y1="17" x2="12" y2="21" />
    </svg>
  ),
  Phone: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
    </svg>
  ),
  Tag: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l7.17 7.17a2 2 0 0 1 0 2.83z" />
      <line x1="7" y1="7" x2="7.01" y2="7" />
    </svg>
  ),
  Users: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.47" />
    </svg>
  ),
  BarChart: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <line x1="12" y1="20" x2="12" y2="10" />
      <line x1="18" y1="20" x2="18" y2="4" />
      <line x1="6" y1="20" x2="6" y2="16" />
    </svg>
  ),
  CreditCard: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <rect x="1" y="4" width="22" height="16" rx="2" ry="2" />
      <line x1="1" y1="10" x2="7" y2="10" />
      <line x1="1" y1="14" x2="7" y2="14" />
    </svg>
  ),
  ClipboardList: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <rect x="8" y="2" width="8" height="4" rx="1" ry="1" />
      <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2" />
      <path d="M12 15h4" />
      <path d="M12 10h4" />
    </svg>
  ),
  RefreshCw: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M1 4v4h8" />
      <path d="M12 20v-4h-8" />
    </svg>
  ),
  DollarSign: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <line x1="12" y1="1" x2="12" y2="23" />
      <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
    </svg>
  ),
  ShieldCheck: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
    </svg>
  ),
  Globe: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <circle cx="12" cy="12" r="10" />
      <line x1="2" y1="12" x2="22" y2="12" />
      <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
    </svg>
  ),
  Lock: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
      <path d="M7 11V7a5 5 0 0 1 10 0v4" />
    </svg>
  ),
  UserCheck: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <polyline points="16 14 20 14 22 10 18 6 12 2" />
    </svg>
  ),
  Target: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <circle cx="12" cy="12" r="10" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  ),
  Wifi: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M5 12.55a11 11 0 0 1 14.08 0" />
      <path d="M1.42 9a16 16 0 0 1 21.16 0" />
      <path d="M8.53 16.11a6 6 0 0 1 6.95 0" />
      <line x1="12" y1="15" x2="12" y2="10.5" />
    </svg>
  ),
  Settings: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82-.33l-.06-.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82.33l.06.06a2 2 0 0 1 2.83 0l.06-.06a2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
    </svg>
  ),
  Mail: (props: any) => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
      <polyline points="22,6 12,13 2,6" />
    </svg>
  ),
};

/* ============================================================
   HELPER: Abre el diálogo de contacto desde cualquier parte
   ============================================================ */
function openContactDialog() {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent('open-contact-dialog'));
  }
}

/* ============================================================
   HOOK: Pausa animaciones al cambiar de pestaña
   ============================================================ */
function usePageVisibility() {
  useEffect(() => {
    const handler = () => {
      document.documentElement.classList.toggle('tab-hidden', document.hidden);
    };
    document.addEventListener('visibilitychange', handler);
    return () => document.removeEventListener('visibilitychange', handler);
  }, []);
}

/* ============================================================
   NAVBAR (colores actualizados)
   ============================================================ */
function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    let rafId: number | null = null;
    const onScroll = () => {
      if (rafId !== null) return;
      rafId = window.requestAnimationFrame(() => {
        setScrolled(window.scrollY > 20);
        rafId = null;
      });
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => {
      window.removeEventListener('scroll', onScroll);
      if (rafId !== null) window.cancelAnimationFrame(rafId);
    };
  }, []);

  const links: { label: string; href?: string; action?: string }[] = [
    { label: 'Producto', href: '#features' },
    { label: 'Cómo funciona', href: '#how' },
    { label: 'Planes', href: '#pricing' },
    { label: 'Contáctanos', action: 'contact' },
  ];

  return (
    <header
      className={`
        fixed top-0 left-0 right-0 z-50 transition-all duration-300 ease-out
        ${scrolled
          ? 'py-3 bg-bg-base/75 backdrop-blur-xl border-b border-white/10 shadow-2xl shadow-black/50'
          : 'py-5 bg-transparent border-b border-transparent'}
      `}
    >
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between">
        {/* Logo */}
        <Link href="/" className="flex shrink-0 items-center gap-2.5 group">
          <div className="w-10 h-10 shrink-0 rounded-xl bg-linear-to-br from-electric via-indigo to-lilac flex items-center justify-center shadow-md shadow-electric/30 group-hover:scale-105 transition-transform p-1.5">
            <Icon.Logo className="w-full h-full" />
          </div>
          <span className="whitespace-nowrap font-bold text-lg text-white tracking-tight">BoostI POS</span>
        </Link>

        {/* Links centrados */}
        <div className="hidden md:flex items-center gap-1 px-3 py-1.5 rounded-full border border-white/10 bg-white/[0.04] backdrop-blur-md">
          {links.map((l) =>
            l.action === 'contact' ? (
              <button
                key={l.label}
                onClick={openContactDialog}
                className="px-4 py-1.5 text-sm font-medium text-white/70 hover:text-white rounded-full transition-colors duration-200 hover:bg-white/10"
              >
                {l.label}
              </button>
            ) : (
              <Link
                key={l.href || l.label}
                href={l.href || '#'}
                className="px-4 py-1.5 text-sm font-medium text-white/70 hover:text-white rounded-full transition-colors duration-200 hover:bg-white/10"
              >
                {l.label}
              </Link>
            )
          )}
        </div>

        {/* Acciones */}
        <div className="hidden md:flex items-center gap-3">
          <Link
            href="/app"
            className="text-sm font-medium text-white/80 hover:text-white transition-colors px-3 py-2"
          >
            Iniciar sesión
          </Link>
          <Link
            href="/sandbox"
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-linear-to-r from-electric to-indigo text-white text-sm font-semibold hover:opacity-90 transition-all shadow-lg shadow-electric/25 hover:-translate-y-0.5"
          >
            Try Demo
            <Icon.Arrow className="w-4 h-4" />
          </Link>
        </div>

        {/* Móvil */}
        <button
          className="md:hidden p-2 rounded-lg hover:bg-white/10 text-white transition-colors"
          onClick={() => setOpen(!open)}
          aria-label="Abrir menú"
        >
          {open ? <Icon.X className="w-6 h-6" /> : <Icon.Menu className="w-6 h-6" />}
        </button>
      </nav>

      {/* Menú Móvil */}
      <div
        className={`
          md:hidden overflow-hidden transition-all duration-300 ease-in-out
          ${open ? 'max-h-[400px] opacity-100' : 'max-h-0 opacity-0'}
        `}
      >
        <div className="px-4 py-4 mt-2 space-y-1 bg-bg-base/95 backdrop-blur-2xl border-t border-white/10">
          {links.map((l) =>
            l.action === 'contact' ? (
              <button
                key={l.label}
                onClick={() => {
                  setOpen(false);
                  openContactDialog();
                }}
                className="block w-full text-left px-4 py-3 text-sm font-medium text-white/80 hover:text-white hover:bg-white/5 rounded-lg transition-colors"
              >
                {l.label}
              </button>
            ) : (
              <Link
                key={l.href || l.label}
                href={l.href || '#'}
                className="block px-4 py-3 text-sm font-medium text-white/80 hover:text-white hover:bg-white/5 rounded-lg transition-colors"
                onClick={() => setOpen(false)}
              >
                {l.label}
              </Link>
            )
          )}
          <div className="pt-3 mt-3 border-t border-white/10 space-y-2">
            <Link
              href="/app"
              className="block px-4 py-3 text-sm font-medium text-white/80 hover:text-white rounded-lg transition-colors"
              onClick={() => setOpen(false)}
            >
              Iniciar sesión
            </Link>
            <Link
              href="/sandbox"
              className="block text-center px-4 py-3 rounded-xl bg-linear-to-r from-electric to-indigo text-white text-sm font-semibold"
              onClick={() => setOpen(false)}
            >
              Try Demo
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}

/* ============================================================
   HERO (estructura mantenida, ventana Mac a la derecha, gradiente electric→indigo)
   ============================================================ */
function Hero() {
  // Media del Hero: autodetecta /images/hero-demo.mp4 (.gif como fallback), o acepta drag & drop
  const [mediaUrl, setMediaUrl] = useState<string | null | false>(false); // false = sin cargar nada aún
  const [mediaKind, setMediaKind] = useState<'video' | 'gif'>('video');

  // Al montar, intenta reproducir el video por defecto del proyecto (si existe)
  useEffect(() => {
    const v = document.createElement('video');
    v.onerror = () => setMediaUrl(null);
    v.onloadeddata = () => setMediaUrl('/images/hero-demo.mp4');
    v.src = '/images/hero-demo.mp4';
    v.load();
  }, []);

  return (
    <section className="relative pt-32 pb-24 lg:pt-44 lg:pb-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Columna Izquierda: Texto */}
          <div className="text-center lg:text-left animate-fade-up">
            <span className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-electric/15 text-lilac text-xs font-semibold border border-electric/30">
              <span className="relative flex h-2 w-2">
                <span className="absolute inline-flex h-full w-full rounded-full bg-mint opacity-75 animate-ping-slow" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-mint" />
              </span>
              Sincronización en tiempo real
            </span>

            <h1 className="mt-6 text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white leading-[1.05] tracking-tight">
              El POS que{' '}
              <span className="bg-linear-to-r from-electric via-indigo to-lilac bg-clip-text text-transparent">
                impulsa tu negocio
              </span>
            </h1>

            <p className="mt-6 text-lg text-white/70 max-w-xl mx-auto lg:mx-0 leading-relaxed">
              Gestiona ventas, inventario, múltiples locales y reportes desde
              cualquier dispositivo. Sin instalaciones complicadas, sin perder
              ni un solo dato.
            </p>

            <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
              <Link
                href="/sandbox"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-linear-to-r from-electric to-indigo text-white font-semibold hover:opacity-90 transition-all shadow-2xl shadow-electric/25 hover:-translate-y-0.5"
              >
                Probar demo gratis
                <Icon.Arrow className="w-4 h-4" />
              </Link>
              <Link
                href="#pricing"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white/[0.05] text-white font-semibold border border-white/10 hover:bg-white/[0.1] hover:border-white/20 transition-all"
              >
                Ver planes
              </Link>
            </div>

            {/* Prueba social honesta: badge de origen */}
            <div className="mt-10 flex flex-col sm:flex-row items-center gap-3 justify-center lg:justify-start">
              <span className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-mint/10 text-mint text-xs font-semibold border border-mint/25">
                <Icon.Store className="w-3.5 h-3.5" />
                Hecho en Venezuela
              </span>
              <p className="text-sm text-white/50">
                Diseñado para la nueva era del comercio
              </p>
            </div>
          </div>

          {/* Columna Derecha: Ventana Mac + Placeholder GIF/Video */}
          <div className="relative animate-fade-up-delay">
            <div className="relative aspect-square max-w-lg mx-auto">
              {/* Glow detrás */}
              <div className="absolute inset-0 bg-linear-to-tr from-electric/30 via-indigo/20 to-lilac/30 rounded-[3rem] blur-2xl animate-blob-slow" />

              {/* Ventana Mac */}
              <div className="relative w-full h-full rounded-[3rem] bg-deep-slate/60 backdrop-blur-xl border border-white/10 shadow-2xl overflow-hidden flex flex-col">
                {/* Barra de títulos de la ventana */}
                <div className="flex items-center gap-2 px-5 py-3 bg-deep-slate/40 border-b border-white/5">
                  <div className="w-3 h-3 rounded-full bg-[#FF5F57]" />
                  <div className="w-3 h-3 rounded-full bg-[#FEBC2E]" />
                  <div className="w-3 h-3 rounded-full bg-[#28C840]" />
                </div>

                {/* Contenido: placeholder / GIF / Video (con drag & drop) */}
                <div
                  className="flex-1 flex items-center justify-center p-8 bg-bg-base/40 relative overflow-hidden"
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={(e) => {
                    e.preventDefault();
                    const file = e.dataTransfer?.files?.[0];
                    if (!file) return;
                    const url = URL.createObjectURL(file);
                    if (file.type.startsWith('video/') || file.name.toLowerCase().endsWith('.mp4')) {
                      setMediaKind('video');
                      setMediaUrl(url);
                    } else if (file.type === 'image/gif' || file.name.toLowerCase().endsWith('.gif')) {
                      setMediaKind('gif');
                      setMediaUrl(url);
                    }
                  }}
                >
                  {mediaUrl ? (
                    mediaKind === 'video' ? (
                      <video
                        src={mediaUrl}
                        className="absolute inset-0 w-full h-full object-cover"
                        autoPlay
                        loop
                        muted
                        playsInline
                        onError={() => {
                          setMediaKind('gif');
                          setMediaUrl('/images/hero-demo.gif');
                        }}
                      />
                    ) : (
                      /* eslint-disable-next-line @next/next/no-img-element */
                      <img
                        src={mediaUrl}
                        alt="Demo BoostI POS"
                        className="absolute inset-0 w-full h-full object-cover"
                        onError={() => setMediaUrl(null)}
                      />
                    )
                  ) : (
                    <div className="text-center">
                      <div className="w-32 h-32 mx-auto rounded-2xl border-2 border-dashed border-electric/30 bg-bg-base/60 flex items-center justify-center mb-4 backdrop-blur-sm">
                        <Icon.Monitor className="w-12 h-12 text-electric" />
                      </div>
                      <p className="text-xs font-semibold text-white/50 uppercase tracking-widest mb-1">
                        Demo BoostI POS
                      </p>
                      <p className="text-[10px] text-muted">
                        Arrastra aquí un .mp4 o .gif para verlo en loop (sin sonido)
                      </p>
                    </div>
                  )}
                </div>

                {/* Tarjetas flotantes (estilo widgets de la app) */}
                <div className="absolute -top-4 -left-4 bg-deep-slate/80 rounded-2xl shadow-2xl shadow-black/40 p-4 flex items-center gap-3 animate-float-slow z-10 border border-white/10 backdrop-blur-md">
                  <div className="w-11 h-11 rounded-xl bg-mint/20 flex items-center justify-center">
                    <Icon.Zap className="w-5 h-5 text-mint" />
                  </div>
                  <div>
                    <p className="text-[10px] text-muted font-bold uppercase tracking-wider">Ventas hoy</p>
                    <p className="text-sm font-extrabold text-white">+ $2,450</p>
                  </div>
                </div>

                <div className="absolute -bottom-4 -right-4 bg-deep-slate/80 rounded-2xl shadow-2xl shadow-black/40 p-4 flex items-center gap-3 animate-float-medium z-10 border border-white/10 backdrop-blur-md">
                  <div className="w-11 h-11 rounded-xl bg-electric/20 flex items-center justify-center">
                    <Icon.Box className="w-5 h-5 text-electric" />
                  </div>
                  <div>
                    <p className="text-[10px] text-muted font-bold uppercase tracking-wider">Stock</p>
                    <p className="text-sm font-extrabold text-white">100% actualizado</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   VISIÓN (sección centrada + mascota saludando)
   ============================================================ */
function Vision() {
  return (
    <section className="py-24 relative">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-5 gap-10 items-center">
          {/* Mascota saludando (aparece cuando publicas public/images/mascot-wave.png) */}
          <motion.div
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-80px' }}
            transition={{ duration: 0.6, ease: 'easeInOut' }}
            className="hidden lg:flex lg:col-span-2 relative items-center justify-center"
          >
            <div className="relative w-72 h-72 rounded-[3rem] bg-[radial-gradient(circle_at_50%_40%,rgba(0,178,255,0.25),rgba(14,17,22,0)_70%)] flex items-center justify-center">
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(99,102,241,0.15),transparent_60%)] blur-2xl" />
              <motion.img
                src="/images/mascot-wave.png"
                alt="Mascota de BoostI saludando"
                className="relative max-w-full max-h-full object-contain mix-blend-screen drop-shadow-[0_8px_32px_rgba(0,178,255,0.35)]"
                onError={(e) => { (e.currentTarget as HTMLImageElement).style.display = 'none'; }}
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 4, ease: 'easeInOut', repeat: Infinity }}
              />
            </div>
          </motion.div>

          {/* Texto */}
          <motion.div
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-80px' }}
            transition={{ duration: 0.6, ease: 'easeInOut', delay: 0.1 }}
            className="text-center lg:col-span-3"
          >
            <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center mb-6 border border-white/10">
              <Icon.Store className="w-6 h-6 text-electric" />
            </div>
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight mb-6">
              Menos dolores de cabeza.<br className="hidden md:block" />
              Más tiempo para crecer.
            </h2>
            <p className="text-lg text-white/70 leading-relaxed max-w-2xl mx-auto">
              Nuestra visión es digitalizar y potenciar los negocios del país.
              Queremos que tengas tranquilidad y comodidad, tanto tú como tu
              equipo. Desde la contabilidad y el control de inventario hasta la
              gestión de empleados y clientes, BoostI POS es el ecosistema que
              elimina el caos operativo para que puedas enfocarte en lo que
              realmente importa: impulsar tu negocio.
            </p>
          </motion.div>
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   APP MODES — Sticky Scroll con framer-motion
   (h-[300vh] + contenedor sticky h-screen; el progreso del scroll
   se divide en 3 tercios: Retail → Restaurante → Servicios)
   ============================================================ */
function AppModes() {
  const containerRef = useRef<HTMLElement | null>(null);
  const [activeIndex, setActiveIndex] = useState(0);
  const [direction, setDirection] = useState(1); // 1: hacia adelante, -1: hacia atrás
  const [imgFailed, setImgFailed] = useState(false); // placeholder si la mascota no existe

  const modes: {
    title: string;
    desc: string;
    color: string;
    mascot: string;
  }[] = [
    {
      title: 'Modo Retail',
      desc: 'Cobra en segundos con lector de barras, control de lotes y balanzas integradas. El punto de venta más rápido para tu tienda.',
      color: '#87FF9B', // mint
      mascot: '/images/mascot-retail.png',
    },
    {
      title: 'Modo Restaurante',
      desc: 'Gestiona mesas, comandas en cocina (KDS) y divisiones de cuenta sin complicaciones. La sala y la cocina, siempre sincronizadas.',
      color: '#00B2FF', // electric
      mascot: '/images/mascot-rest.png',
    },
    {
      title: 'Modo Servicios',
      desc: 'Administra citas, tiempos de atención y comisiones de tus empleados. Agenda, cobra y fideliza desde un solo lugar.',
      color: '#A78BFA', // lilac
      mascot: '/images/mascot-serv.png',
    },
  ];

  const current = modes[activeIndex];

  // Reinicia el placeholder al cambiar de modo (la mascota de otro modo puede sí existir)
  useEffect(() => setImgFailed(false), [activeIndex]);

  // Progreso del scroll de la sección → cambia el modo activo por tercios
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ['start start', 'end end'],
  });

  useMotionValueEvent(scrollYProgress, 'change', (v) => {
    const next = Math.min(2, Math.floor(v / (1 / 3)));
    if (next !== activeIndex) {
      setDirection(next > activeIndex ? 1 : -1);
      setActiveIndex(next);
    }
  });

  const go = (dir: 1 | -1) => {
    const next = (activeIndex + dir + modes.length) % modes.length;
    setDirection(dir);
    setActiveIndex(next);
  };

  return (
    <section
      ref={containerRef}
      className="relative h-[300vh]"
      aria-label="Modos de uso de BoostI"
    >
      {/* Contenedor sticky: ocupa toda la pantalla mientras se hace scroll */}
      <div className="sticky top-0 h-screen w-full flex items-center justify-center overflow-hidden">
        {/* Glow de fondo dinámico (cambia de color según el modo) */}
        <motion.div
          animate={{ backgroundColor: current.color }}
          transition={{ duration: 0.8, ease: 'easeInOut' }}
          className="absolute inset-0 opacity-[0.07] blur-[150px]"
        />

        {/* Contenido 50/50: mascota (izquierda) + texto (derecha) */}
        <div className="relative z-10 grid lg:grid-cols-2 gap-12 items-center max-w-6xl mx-auto px-4 sm:px-6 w-full">
          {/* --- Polígono con la mascota --- */}
          <div className="hidden sm:flex justify-center">
            <div
              className="relative w-[380px] h-[420px]"
              style={{
                clipPath:
                  'polygon(20% 0%, 80% 0%, 100% 50%, 80% 100%, 20% 100%, 0% 50%)',
              }}
            >
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeIndex}
                  initial={{ opacity: 0, scale: 0.94 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.94 }}
                  transition={{ duration: 0.4, ease: 'easeInOut' }}
                  className="absolute inset-0"
                >
                  {/* Fondo del polígono (color animado por modo) */}
                  <motion.div
                    animate={{ backgroundColor: current.color }}
                    transition={{ duration: 0.6, ease: 'easeInOut' }}
                    className="absolute inset-0 opacity-90"
                  />
                  {/* Mascota con filtro integrado, o placeholder elegante si aún no existe */}
                  <AnimatePresence mode="wait">
                    {imgFailed ? (
                      <motion.div
                        key={`ph-${activeIndex}`}
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.3, ease: 'easeInOut' }}
                        className="absolute inset-0 flex flex-col items-center justify-center gap-3"
                      >
                        <span className="text-xs font-bold uppercase tracking-[0.25em] text-bg-base/50">
                          {current.title}
                        </span>
                      </motion.div>
                    ) : (
                      <motion.img
                        key={`img-${activeIndex}`}
                        src={current.mascot}
                        alt={`Mascota de BoostI — ${current.title}`}
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.94 }}
                        transition={{ duration: 0.35, ease: 'easeInOut' }}
                        className="absolute inset-0 w-full h-full object-contain p-8 mix-blend-multiply filter brightness-90 contrast-125 drop-shadow-xl"
                        onError={() => setImgFailed(true)}
                      />
                    )}
                  </AnimatePresence>
                </motion.div>
              </AnimatePresence>
            </div>
          </div>

          {/* --- Título, descripción y navegación --- */}
          <div className="text-center lg:text-left">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeIndex}
                initial={{ opacity: 0, y: direction * 24 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: direction * -24 }}
                transition={{ duration: 0.35, ease: 'easeInOut' }}
              >
                <span
                  className="text-sm font-semibold uppercase tracking-[0.2em] transition-colors duration-500 ease-in-out"
                  style={{ color: current.color }}
                >
                  Modos de uso
                </span>
                <h2
                  className="mt-3 text-4xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight uppercase"
                  style={{ textShadow: '0 0 60px rgba(255,255,255,0.08)' }}
                >
                  {current.title}
                </h2>
                <p className="mt-5 text-lg text-white/70 leading-relaxed max-w-lg mx-auto lg:mx-0">
                  {current.desc}
                </p>
              </motion.div>
            </AnimatePresence>

            {/* Flechas de navegación (cambian de modo al hacer clic) */}
            <div className="mt-8 flex items-center gap-3 justify-center lg:justify-start">
              <button
                onClick={() => go(-1)}
                aria-label="Modo anterior"
                className="w-11 h-11 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300 ease-in-out hover:-translate-x-0.5"
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5">
                  <path d="M19 12H5" />
                  <path d="m12 19-7-7 7-7" />
                </svg>
              </button>
              <button
                onClick={() => go(1)}
                aria-label="Modo siguiente"
                className="w-11 h-11 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300 ease-in-out hover:translate-x-0.5"
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5">
                  <path d="M5 12h14" />
                  <path d="m12 5 7 7-7 7" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        {/* Indicadores de progreso (estilo carrusel) */}
        <div className="absolute bottom-10 left-1/2 -translate-x-1/2 z-10 flex items-center gap-2.5">
          {modes.map((m, i) => (
            <button
              key={i}
              onClick={() => {
                setDirection(i > activeIndex ? 1 : -1);
                setActiveIndex(i);
              }}
              aria-label={`Ir a ${m.title}`}
              className="group py-2"
            >
              <div
                className="h-1.5 rounded-full transition-all duration-300 ease-in-out group-hover:opacity-100"
                style={{
                  width: i === activeIndex ? 36 : 14,
                  backgroundColor:
                    i === activeIndex ? m.color : 'rgba(255,255,255,0.25)',
                }}
              />
            </button>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   VENTAJAS (3 tarjetas con iconos, electric y lilac)
   ============================================================ */
function Advantages() {
  const advantages: { title: string; desc: string; icon: any; color: string; mascot?: string }[] = [
    {
      title: 'Offline-First',
      desc: 'Nunca dejes de vender. Nuestra arquitectura offline-first te permite operar al 100% sin internet. Al conectarte, todo se sincroniza automáticamente.',
      icon: CloudOff,
      color: '#00B2FF', // electric
    },
    {
      title: 'Scanner Remoto',
      desc: '¿No tienes lector? Usa tu celular. Envía los códigos de barras a la PC en tiempo real vía WiFi.',
      icon: Smartphone,
      color: '#A78BFA', // lilac
      mascot: '/images/mascot-phone.png',
    },
    {
      title: 'Ventas al Mayor',
      desc: 'Configura precios por volumen, listas especiales para distribuidores y maneja grandes cantidades fácilmente.',
      icon: Tags,
      color: '#A78BFA', // lilac
    },
  ];

  return (
    <section className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-electric uppercase tracking-[0.2em]">
            Ventajas competitivas
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight">
            Construido para vender sin límites
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {advantages.map((a, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-60px' }}
              transition={{ duration: 0.5, ease: 'easeInOut', delay: i * 0.1 }}
              className="group relative p-8 rounded-3xl bg-deep-slate/50 backdrop-blur-md border border-white/10 hover:border-white/20 transition-all duration-500 ease-in-out hover:-translate-y-1.5 overflow-hidden"
            >
              <div className="w-14 h-14 rounded-2xl flex items-center justify-center mb-6 bg-white/5 border border-white/10 shadow-xl transition-all duration-500 ease-in-out group-hover:scale-110" style={{ color: a.color }}>
                <a.icon className="w-7 h-7" />
              </div>
              <h3 className="text-xl font-bold text-white tracking-tight mb-3">{a.title}</h3>
              <p className="text-white/70 leading-relaxed">{a.desc}</p>

              {/* Mascota con celular (aparece cuando publicas public/images/mascot-phone.png) */}
              {a.mascot && (
                <motion.img
                  src={a.mascot}
                  alt="Mascota de BoostI con celular"
                  className="absolute -bottom-2 -right-2 w-28 h-28 object-contain pointer-events-none drop-shadow-[0_8px_24px_rgba(167,139,250,0.3)]"
                  onError={(e) => { (e.currentTarget as HTMLImageElement).style.display = 'none'; }}
                  animate={{ y: [0, -6, 0] }}
                  transition={{ duration: 3.5, ease: 'easeInOut', repeat: Infinity, delay: 0.5 + i * 0.2 }}
                />
              )}
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   FEATURES → MÓDULOS INTERACTIVOS (grid, clic para expandir con framer-motion)
   ============================================================ */
function Features() {
  const [expandedId, setExpandedId] = useState<number | null>(null);

  const modules = [
    {
      title: 'Punto de Venta (POS)',
      desc: 'Cobra rápido, divide cuentas, aplica descuentos y acepta múltiples métodos de pago.',
      icon: Store,
      color: '#00B2FF', // electric
    },
    {
      title: 'Inventario y Lotes',
      desc: 'Controla stock exacto por lotes, fechas de vencimiento y recibe alertas de stock bajo.',
      icon: ShoppingBag,
      color: '#87FF9B', // mint
    },
    {
      title: 'Compras y Proveedores',
      desc: 'Registra entradas de mercancía, gestiona cuentas por pagar y mantén un historial de costos.',
      icon: Truck,
      color: '#00B2FF', // electric
    },
    {
      title: 'Caja y Arqueos',
      desc: 'Abre y cierra turnos con control total de ingresos, egresos y gastos operativos.',
      icon: Calculator,
      color: '#87FF9B', // mint
    },
    {
      title: 'Clientes y Lealtad',
      desc: 'Guarda el historial de compras, gestiona créditos y envía promociones.',
      icon: Users,
      color: '#00B2FF', // electric
    },
    {
      title: 'Reportes y Estadísticas',
      desc: 'Visualiza ventas por día, productos más vendidos y rendimiento de tus empleados.',
      icon: BarChart3,
      color: '#87FF9B', // mint
    },
  ];

  const panelVariants = {
    hidden: { height: 0, opacity: 0 },
    visible: { height: 'auto', opacity: 1, transition: { duration: 0.3, ease: 'easeInOut' as const } },
  };

  return (
    <section id="features" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-lilac uppercase tracking-[0.2em]">
            Módulos del ecosistema
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Todo lo que tu negocio necesita
          </h2>
          <p className="mt-5 text-lg text-white/60">
            Haz clic en cualquier módulo para ver más detalles.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {modules.map((m, i) => {
            const isExpanded = expandedId === i;
            return (
              <motion.div
                key={i}
                whileHover={{ y: -4 }}
                whileTap={{ scale: 0.98 }}
                transition={{ duration: 0.2, ease: 'easeInOut' }}
                onClick={() => setExpandedId(isExpanded ? null : i)}
                className={`group cursor-pointer p-7 rounded-3xl border transition-all duration-500 ease-in-out
                  ${isExpanded
                    ? 'bg-deep-slate/90 border-electric/50 shadow-2xl shadow-electric/20 ring-1 ring-electric/30'
                    : 'bg-deep-slate/50 border-white/10 hover:border-electric/40 hover:bg-deep-slate/80'}
                `}
              >
                <div
                  className="w-12 h-12 rounded-2xl flex items-center justify-center mb-5 bg-white/5 border border-white/10 transition-all duration-500 ease-in-out group-hover:scale-110"
                  style={{ color: m.color }}
                >
                  <m.icon className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-bold text-white tracking-tight mb-2">{m.title}</h3>

                <AnimatePresence mode="wait">
                  {isExpanded && (
                    <motion.div
                      initial={false}
                      animate="visible"
                      exit="hidden"
                      variants={panelVariants}
                      className="mt-5 pt-5 border-t border-white/10 overflow-hidden"
                    >
                      <div className="animate-fade-up">
                        <p className="text-white/70 leading-relaxed text-sm">{m.desc}</p>
                        <div className="mt-4 flex items-center gap-2 text-xs text-muted font-medium">
                          <span className="w-2 h-2 rounded-full bg-electric" />
                          Módulo activo
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   ALL MODULES → LISTA COMPLETA DE FUNCIONES (tabla con checkmarks)
   ============================================================ */
function AllModules() {
  const allModules = [
    { title: 'POS y Cobro rápido', desc: 'Cobra en segundos con lector de código de barras, balanza integrada y múltiples métodos de pago.', icon: Store, color: '#00B2FF' },
    { title: 'Gestión de Mesas y KDS (Restaurante)', desc: 'Administra mesas, envía comandas a cocina y gestiona divisiones de cuenta sin complicaciones.', icon: Utensils, color: '#87FF9B' },
    { title: 'Gestión de Citas y Comisiones (Servicios)', desc: 'Administra citas, tiempos de atención y comisiones de tus empleados de forma sencilla.', icon: Calendar, color: '#00B2FF' },
    { title: 'Inventario por Lotes y Vencimientos', desc: 'Controla stock exacto por lotes, fechas de vencimiento y recibe alertas de stock bajo.', icon: ShoppingBag, color: '#87FF9B' },
    { title: 'Compras y Proveedores', desc: 'Registra entradas de mercancía, gestiona cuentas por pagar y mantén un historial de costos.', icon: Truck, color: '#00B2FF' },
    { title: 'Arqueo de Caja y Gastos', desc: 'Abre y cierra turnos con control total de ingresos, egresos y gastos operativos.', icon: Calculator, color: '#87FF9B' },
    { title: 'Clientes, Créditos y Lealtad', desc: 'Guarda el historial de compras, gestiona créditos y envía promociones a tus clientes.', icon: Users, color: '#00B2FF' },
    { title: 'Ventas al Mayor y Listas de Precios', desc: 'Configura precios por volumen, listas especiales para distribuidores y maneja grandes cantidades fácilmente.', icon: Tags, color: '#87FF9B' },
    { title: 'Scanner Remoto (Celular a PC)', desc: 'Usa tu celular como lector de códigos de barras y envía la información a la PC en tiempo real vía WiFi.', icon: Smartphone, color: '#00B2FF' },
    { title: 'Reportes y Estadísticas', desc: 'Visualiza ventas por día, productos más vendidos y rendimiento de tus empleados.', icon: BarChart3, color: '#87FF9B' },
    { title: 'Multi-local y Sincronización', desc: 'Gestiona varios locales desde un solo panel con sincronización en tiempo real entre sucursales.', icon: MapPin, color: '#00B2FF' },
    { title: 'Roles y Permisos de Empleados', desc: 'Asigna roles y permisos granulares a cada empleado para controlar el acceso al sistema.', icon: ShieldCheck, color: '#87FF9B' },
  ];

  return (
    <section id="all-modules" className="py-24 relative bg-deep-slate/20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-mint uppercase tracking-[0.2em]">
            Lista completa de funciones
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight">
            Todo incluido en BoostI POS
          </h2>
          <p className="mt-5 text-lg text-white/60">
            Todas las funciones que tu negocio necesita, sin costos ocultos.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
          {allModules.map((mod, i) => (
            <div
              key={i}
              className="group flex items-center gap-4 p-6 rounded-2xl bg-white/[0.03] border border-white/10 hover:border-electric/40 hover:bg-white/[0.06] transition-all duration-300 ease-in-out"
            >
              <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 bg-white/5 border border-white/10 shadow-lg">
                <mod.icon className="w-5 h-5" style={{ color: mod.color }} />
              </div>
              <div>
                <h3 className="text-base font-bold text-white tracking-tight group-hover:text-electric transition-colors duration-300">{mod.title}</h3>
                <p className="text-xs text-muted mt-0.5 leading-relaxed">{mod.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   HOW IT WORKS (colores actualizados)
   ============================================================ */
function HowItWorks() {
  const steps = [
    { n: '01', title: 'Crea tu cuenta', desc: 'Regístrate en menos de un minuto. Sin tarjetas de crédito.' },
    { n: '02', title: 'Configura tu negocio', desc: 'Agrega productos, precios e impresoras. Todo desde el celular o PC.' },
    { n: '03', title: 'Empieza a vender', desc: 'Cobra, imprime tickets y consulta reportes en tiempo real.' },
  ];

  return (
    <section id="how" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-mint uppercase tracking-[0.2em]">
            Cómo funciona
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Listo en menos de 5 minutos
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {steps.map((s, i) => (
            <div key={i} className="relative text-center">
              <div className="w-16 h-16 mx-auto rounded-2xl bg-linear-to-br from-electric to-indigo flex items-center justify-center shadow-2xl shadow-electric/30">
                <span className="text-xl font-extrabold text-white">{s.n}</span>
              </div>
              <h3 className="mt-6 text-xl font-bold text-white tracking-tight">{s.title}</h3>
              <p className="mt-2 text-white/60">{s.desc}</p>
              {i < steps.length - 1 && (
                <div className="hidden md:block absolute top-8 left-[60%] w-[80%] h-px bg-linear-to-r from-electric/40 to-transparent" />
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   PRICING (colores actualizados)
   ============================================================ */
function Pricing() {
  const plans = [
    { name: 'Starter', price: '15', desc: 'Para comercios pequeños que están empezando.', features: ['1 local', '3 usuarios', 'Ventas ilimitadas', 'Reportes básicos', 'Soporte por email'], cta: 'Comenzar', highlighted: false },
    { name: 'Pro', price: '30', desc: 'Para negocios en crecimiento con múltiples locales.', features: ['3 locales', 'Usuarios ilimitados', 'Ventas ilimitadas', 'Reportes avanzados', 'Sincronización en tiempo real', 'Soporte prioritario'], cta: 'Probar 14 días gratis', highlighted: true },
    { name: 'Enterprise', price: 'A medida', desc: 'Para cadenas y franquicias con necesidades específicas.', features: ['Locales ilimitados', 'Usuarios ilimitados', 'API personalizada', 'Onboarding dedicado', 'SLA garantizado'], cta: 'Contactar ventas', highlighted: false },
  ];

  return (
    <section id="pricing" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-mint uppercase tracking-[0.2em]">
            Planes
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Precios simples y transparentes
          </h2>
          <p className="mt-5 text-lg text-white/60">Sin costos ocultos. Cancela cuando quieras.</p>
        </div>

        <div className="grid md:grid-cols-3 gap-6 items-stretch">
          {plans.map((p, i) => (
            <div
              key={i}
              className={`
                relative p-8 rounded-3xl transition-all duration-500 ease-in-out
                ${
                  p.highlighted
                    ? 'bg-linear-to-b from-electric via-indigo to-bg-base shadow-2xl shadow-electric/30 scale-105 border border-electric/50'
                    : 'bg-deep-slate/50 backdrop-blur-md border border-white/10 hover:-translate-y-1.5 hover:shadow-2xl'
                }
              `}
            >
              {p.highlighted && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 px-3.5 py-1 rounded-full bg-mint text-bg-base text-xs font-extrabold tracking-wide shadow-lg">
                  MÁS POPULAR
                </span>
              )}
              <h3 className="text-2xl font-bold text-white">{p.name}</h3>
              <p className="mt-2 text-sm text-white/70">{p.desc}</p>
              <div className="mt-6 flex items-baseline gap-1">
                {p.price !== 'A medida' && <span className="text-2xl text-white/60">$</span>}
                <span className="text-5xl font-extrabold text-white">{p.price}</span>
                {p.price !== 'A medida' && <span className="text-white/60">/mes</span>}
              </div>
              <ul className="mt-6 space-y-3">
                {p.features.map((f, j) => (
                  <li key={j} className="flex items-start gap-2 text-sm text-white/80">
                    <Icon.Check className="w-4 h-4 mt-0.5 flex-shrink-0 text-mint" />
                    {f}
                  </li>
                ))}
              </ul>
              {p.name === 'Enterprise' ? (
                <button
                  onClick={openContactDialog}
                  className="mt-8 block w-full text-center px-4 py-3.5 rounded-xl font-bold transition-all duration-300 ease-in-out bg-white/10 text-white hover:bg-white/20 border border-white/10"
                >
                  {p.cta}
                </button>
              ) : (
                <Link
                  href="/sandbox"
                  className={`
                    mt-8 block text-center px-4 py-3.5 rounded-xl font-bold transition-all duration-300 ease-in-out
                    ${
                      p.highlighted
                        ? 'bg-linear-to-r from-electric to-indigo text-white hover:opacity-90 shadow-lg'
                        : 'bg-white/10 text-white hover:bg-white/20 border border-white/10'
                    }
                  `}
                >
                  {p.cta}
                </Link>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   FINAL CTA (colores actualizados)
   ============================================================ */
function FinalCTA() {
  return (
    <section id="contact" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative overflow-hidden rounded-[3rem] bg-deep-slate/60 backdrop-blur-xl border border-white/10 p-12 lg:p-20">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_50%,rgba(0,178,255,0.35),transparent_50%),radial-gradient(circle_at_80%_50%,rgba(99,102,241,0.3),transparent_50%)] pointer-events-none" />
          <div className="relative text-center max-w-2xl mx-auto">
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
              ¿Listo para transformar tu punto de venta?
            </h2>
            <p className="mt-5 text-lg text-white/70">
              Prueba la demo interactiva sin compromiso. Sin tarjetas, sin instalar nada.
            </p>
            <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
              <Link
                href="/sandbox"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white text-slate-900 font-semibold hover:bg-slate-100 transition-all duration-300 ease-in-out shadow-2xl shadow-white/20 hover:-translate-y-0.5"
              >
                Probar demo ahora
                <Icon.Arrow className="w-4 h-4" />
              </Link>
              <button
                onClick={openContactDialog}
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white/10 text-white font-semibold border border-white/20 hover:bg-white/20 transition-all duration-300 ease-in-out"
              >
                Contactar ventas
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   FOOTER (colores actualizados con next/link)
   ============================================================ */
function Footer() {
  const groups = [
    { title: 'Producto', links: [{ label: 'Características', href: '/caracteristicas' }, { label: 'Planes', href: '/planes' }, { label: 'Demo', href: '/sandbox' }, { label: 'Integraciones', href: '/integraciones' }] },
    { title: 'Empresa', links: [{ label: 'Sobre nosotros', href: '/sobre-nosotros' }, { label: 'Blog', href: '/blog' }, { label: 'Contacto', href: '/contacto' } /* , { label: 'Trabaja con nosotros', href: '/trabaja-con-nosotros' } — aún no listo */] },
    { title: 'Recursos', links: [{ label: 'Documentación', href: '/documentacion' }, { label: 'Centro de ayuda', href: '/centro-de-ayuda' }, { label: 'Estado', href: '/estado' } /* , { label: 'API', href: '/api' } — aún no listo */] },
    { title: 'Legal', links: [{ label: 'Términos', href: '/terminos' }, { label: 'Privacidad', href: '/privacidad' }, { label: 'Cookies', href: '/cookies' }] },
  ];

  return (
    <footer className="relative border-t border-white/10 bg-bg-base/80">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-6 gap-10">
          <div className="lg:col-span-2">
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 shrink-0 rounded-xl bg-linear-to-br from-electric via-indigo to-lilac flex items-center justify-center shadow-lg shadow-electric/30 p-1.5">
                <Icon.Logo className="w-full h-full" />
              </div>
              <span className="whitespace-nowrap font-bold text-lg text-white tracking-tight">BoostI POS</span>
            </div>
            <p className="mt-5 text-sm text-white/50 max-w-xs leading-relaxed">
              El sistema de punto de venta moderno para comercios que quieren crecer.
            </p>
            <Link
              href="/app"
              className="mt-5 inline-flex items-center gap-1.5 text-sm font-semibold text-mint hover:text-leaf transition-colors duration-300 ease-in-out"
            >
              Abrir aplicación
              <Icon.ArrowUpRight className="w-4 h-4" />
            </Link>
          </div>

          {groups.map((g) => (
            <div key={g.title}>
              <h4 className="text-sm font-bold text-white">{g.title}</h4>
              <ul className="mt-4 space-y-2.5">
                {g.links.map((l) => (
                  <li key={l.label}>
                    <Link
                      href={l.href}
                      className="text-sm text-white/50 hover:text-white transition-colors duration-300 ease-in-out"
                    >
                      {l.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-14 pt-8 border-t border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-sm text-white/40">
            © {new Date().getFullYear()} BoostI POS · JAH Lab. Todos los derechos reservados.
          </p>
          <div className="flex items-center gap-6">
            {['Twitter', 'LinkedIn', 'GitHub'].map((s) => (
              <a
                key={s}
                href="#"
                className="text-sm text-white/40 hover:text-white transition-colors duration-300 ease-in-out"
              >
                {s}
              </a>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}

/* ============================================================
   PÁGINA PRINCIPAL (orden final actualizado)
   ============================================================ */
export default function HomePage() {
  usePageVisibility();

  const [contactOpen, setContactOpen] = useState(false);
  const [onboardingOpen, setOnboardingOpen] = useState(false);

  // Auto-abrir onboarding en la primera visita (a los 2.5s)
  useEffect(() => {
    const done = localStorage.getItem('boostipos_onboarding_done');
    if (!done) {
      const timer = setTimeout(() => setOnboardingOpen(true), 2500);
      return () => clearTimeout(timer);
    }
  }, []);

  // Escuchar evento global para abrir el diálogo de contacto
  useEffect(() => {
    const handler = () => setContactOpen(true);
    window.addEventListener('open-contact-dialog', handler);
    return () => window.removeEventListener('open-contact-dialog', handler);
  }, []);

  return (
    <>
      <Background />
      <Navbar />
      <main className="relative">
        <Hero />
        <Vision />
        <AppModes />
        <Advantages />
        <Features />
        <AllModules />
        <HowItWorks />
        <Integrations />
        <Pricing />
        <FAQ />
        <FinalCTA />
        <Footer />
      </main>

      {/* Capa de overlays */}
      <CookieConsent />
      <FloatingHelpButton onClick={() => setOnboardingOpen(true)} />
      <ContactDialog open={contactOpen} onClose={() => setContactOpen(false)} />
      <OnboardingDialog open={onboardingOpen} onClose={() => setOnboardingOpen(false)} />
    </>
  );
}
