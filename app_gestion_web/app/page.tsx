'use client';

import { useEffect, useState } from 'react';
import CookieConsent from './components/CookieConsent';
import ContactDialog from './components/ContactDialog';
import OnboardingDialog from './components/OnboardingDialog';
import FAQ from './components/FAQ';
import Integrations from './components/Integrations';
import FloatingHelpButton from './components/FloatingHelpButton';

/* ============================================================
   ICONOS
   ============================================================ */
const Icon = {
  Logo: (props: any) => (
    <img
      src="https://ik.imagekit.io/xnf3fil5g/logoboosti300px.svg"
      alt="BoostI POS"
      width={28}
      height={28}
      style={{
        objectFit: 'contain',
        // ✅ Convierte cualquier color del SVG a blanco puro
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
   BACKGROUND CON DEGRADADOS CONTINUOS
   ============================================================ */
function Background() {
  return (
    <div className="fixed inset-0 -z-10 overflow-hidden pointer-events-none bg-[#0B1120]">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(30,58,138,0.35),rgba(11,17,32,1))]" />
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-[#1E293B]/20 to-[#0B1120]" />

      <div className="absolute -top-40 -left-40 w-[600px] h-[600px] rounded-full bg-[#8B5CF6]/20 blur-[120px] animate-blob-slow" />
      <div className="absolute top-[28%] -right-40 w-[550px] h-[550px] rounded-full bg-[#10B981]/15 blur-[120px] animate-blob-medium" />
      <div className="absolute top-[60%] left-[5%] w-[600px] h-[600px] rounded-full bg-[#59B1E4]/15 blur-[130px] animate-blob-slow" />
      <div className="absolute top-[85%] -right-20 w-[500px] h-[500px] rounded-full bg-[#FF984F]/10 blur-[120px] animate-blob-medium" />

      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage: 'radial-gradient(circle, #ffffff 1px, transparent 1px)',
          backgroundSize: '24px 24px',
        }}
      />
    </div>
  );
}

/* ============================================================
   NAVBAR
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

  const links = [
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
          ? 'py-3 bg-[#0B1120]/75 backdrop-blur-xl border-b border-white/10 shadow-2xl shadow-black/50'
          : 'py-5 bg-transparent border-b border-transparent'}
      `}
    >
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between">
        {/* Logo */}
        <a href="/" className="flex items-center gap-2.5 group">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#8B5CF6] via-[#59B1E4] to-[#10B981] flex items-center justify-center shadow-md shadow-[#8B5CF6]/30 group-hover:scale-105 transition-transform p-1.5">
            <Icon.Logo className="w-full h-full" />
          </div>
          <span className="font-bold text-lg text-white tracking-tight">BoostI POS</span>
        </a>

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
              <a
                key={l.href}
                href={l.href}
                className="px-4 py-1.5 text-sm font-medium text-white/70 hover:text-white rounded-full transition-colors duration-200 hover:bg-white/10"
              >
                {l.label}
              </a>
            )
          )}
        </div>

        {/* Acciones */}
        <div className="hidden md:flex items-center gap-3">
          <a
            href="/app"
            className="text-sm font-medium text-white/80 hover:text-white transition-colors px-3 py-2"
          >
            Iniciar sesión
          </a>
          <a
            href="/sandbox"
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-to-r from-[#8B5CF6] to-[#10B981] text-white text-sm font-semibold hover:opacity-90 transition-all shadow-lg shadow-[#8B5CF6]/25 hover:-translate-y-0.5"
          >
            Try Demo
            <Icon.Arrow className="w-4 h-4" />
          </a>
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
        <div className="px-4 py-4 mt-2 space-y-1 bg-[#0B1120]/95 backdrop-blur-2xl border-t border-white/10">
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
              <a
                key={l.href}
                href={l.href}
                className="block px-4 py-3 text-sm font-medium text-white/80 hover:text-white hover:bg-white/5 rounded-lg transition-colors"
                onClick={() => setOpen(false)}
              >
                {l.label}
              </a>
            )
          )}
          <div className="pt-3 mt-3 border-t border-white/10 space-y-2">
            <a
              href="/app"
              className="block px-4 py-3 text-sm font-medium text-white/80 hover:text-white rounded-lg transition-colors"
              onClick={() => setOpen(false)}
            >
              Iniciar sesión
            </a>
            <a
              href="/sandbox"
              className="block text-center px-4 py-3 rounded-xl bg-gradient-to-r from-[#8B5CF6] to-[#10B981] text-white text-sm font-semibold"
              onClick={() => setOpen(false)}
            >
              Try Demo
            </a>
          </div>
        </div>
      </div>
    </header>
  );
}

/* ============================================================
   HERO
   ============================================================ */
function Hero() {
  return (
    <section className="relative pt-32 pb-24 lg:pt-44 lg:pb-32">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Columna Izquierda: Texto */}
          <div className="text-center lg:text-left animate-fade-up">
            <span className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#8B5CF6]/15 text-[#C4B5FD] text-xs font-semibold border border-[#8B5CF6]/30">
              <span className="relative flex h-2 w-2">
                <span className="absolute inline-flex h-full w-full rounded-full bg-[#10B981] opacity-75 animate-ping-slow" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[#10B981]" />
              </span>
              Sincronización en tiempo real
            </span>

            <h1 className="mt-6 text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white leading-[1.05] tracking-tight">
              El POS que{' '}
              <span className="bg-gradient-to-r from-[#8B5CF6] via-[#59B1E4] to-[#10B981] bg-clip-text text-transparent">
                impulsa tu negocio
              </span>
            </h1>

            <p className="mt-6 text-lg text-white/70 max-w-xl mx-auto lg:mx-0 leading-relaxed">
              Gestiona ventas, inventario, múltiples locales y reportes desde
              cualquier dispositivo. Sin instalaciones complicadas, sin perder
              ni un solo dato.
            </p>

            <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
              <a
                href="/sandbox"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white text-slate-900 font-semibold hover:bg-slate-100 transition-all shadow-2xl shadow-[#8B5CF6]/20 hover:-translate-y-0.5"
              >
                Probar demo gratis
                <Icon.Arrow className="w-4 h-4" />
              </a>
              <a
                href="#pricing"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white/[0.05] text-white font-semibold border border-white/10 hover:bg-white/[0.1] hover:border-white/20 transition-all"
              >
                Ver planes
              </a>
            </div>

            <div className="mt-10 flex items-center gap-6 justify-center lg:justify-start">
              <div className="flex -space-x-3">
                {['#8B5CF6', '#10B981', '#FF984F', '#59B1E4'].map((c, i) => (
                  <div
                    key={i}
                    className="w-10 h-10 rounded-full border-2 border-[#0B1120] shadow-lg"
                    style={{ background: c }}
                  />
                ))}
              </div>
              <div className="text-sm">
                <div className="flex items-center gap-0.5">
                  {[...Array(5)].map((_, i) => (
                    <Icon.Star key={i} className="w-4 h-4 text-[#FF984F]" />
                  ))}
                </div>
                <p className="text-white/60 mt-1">
                  <strong className="text-white">+500 comercios</strong> confían en nosotros
                </p>
              </div>
            </div>
          </div>

          {/* Columna Derecha */}
          <div className="relative animate-fade-up-delay">
            <div className="relative aspect-square max-w-lg mx-auto">
              <div className="absolute inset-0 bg-gradient-to-tr from-[#8B5CF6]/30 via-[#59B1E4]/20 to-[#10B981]/30 rounded-[3rem] blur-2xl animate-blob-slow" />

              <div className="relative w-full h-full rounded-[3rem] bg-[#1E293B]/60 backdrop-blur-xl border border-white/10 shadow-2xl overflow-hidden flex items-center justify-center">
                <div className="text-center p-8">
                  <div className="w-28 h-28 mx-auto rounded-3xl bg-gradient-to-br from-[#8B5CF6] via-[#59B1E4] to-[#10B981] flex items-center justify-center shadow-2xl shadow-[#8B5CF6]/40 animate-bounce-soft p-4">
                    <Icon.Logo className="w-full h-full" />
                  </div>
                  <p className="mt-6 text-xs font-semibold text-white/50 uppercase tracking-widest">
                    [ Lottie animation ]
                  </p>
                </div>
              </div>

              <div className="absolute -top-4 -left-4 bg-[#FAF7F2] rounded-2xl shadow-2xl shadow-black/40 p-4 flex items-center gap-3 animate-float-slow z-10 border border-white/20">
                <div className="w-11 h-11 rounded-xl bg-[#D1FAE5] flex items-center justify-center">
                  <Icon.Chart className="w-5 h-5 text-[#10B981]" />
                </div>
                <div>
                  <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Ventas hoy</p>
                  <p className="text-sm font-extrabold text-slate-900">+ $2,450</p>
                </div>
              </div>

              <div className="absolute -bottom-4 -right-4 bg-[#FAF7F2] rounded-2xl shadow-2xl shadow-black/40 p-4 flex items-center gap-3 animate-float-medium z-10 border border-white/20">
                <div className="w-11 h-11 rounded-xl bg-[#8B5CF6]/15 flex items-center justify-center">
                  <Icon.Box className="w-5 h-5 text-[#8B5CF6]" />
                </div>
                <div>
                  <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Stock</p>
                  <p className="text-sm font-extrabold text-slate-900">100% actualizado</p>
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
   TRUST STRIP
   ============================================================ */
function TrustStrip() {
  const logos = ['Tienda León', 'Bodega Central', 'SuperMarket', 'Market Plus', 'La Económica'];
  return (
    <section className="py-16 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <p className="text-center text-xs uppercase tracking-[0.3em] text-white/40 font-semibold">
          Empresas que ya confían en nosotros
        </p>
        <div className="mt-10 flex flex-wrap items-center justify-center gap-x-16 gap-y-6">
          {logos.map((l) => (
            <span
              key={l}
              className="text-xl font-bold text-white/30 hover:text-white/70 transition-colors duration-300 cursor-default"
            >
              {l}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   FEATURES
   ============================================================ */
function Features() {
  const features = [
    { icon: Icon.Cart, color: 'violet', title: 'Ventas ultrarrápidas', desc: 'Cobra en segundos con lector de código de barras, balanza integrada y múltiples métodos de pago.' },
    { icon: Icon.Box, color: 'emerald', title: 'Inventario inteligente', desc: 'Controla stock, lotes y vencimientos automáticamente. Recibe alertas antes de quedarte sin producto.' },
    { icon: Icon.Store, color: 'sky', title: 'Multi-local', desc: 'Gestiona varios locales desde un solo panel. Sincronización en tiempo real entre sucursales.' },
    { icon: Icon.Chart, color: 'sandy', title: 'Reportes en vivo', desc: 'Dashboard con métricas clave: ventas por día, top productos, rendimiento por empleado.' },
    { icon: Icon.Printer, color: 'emerald', title: 'Impresión flexible', desc: 'Compatible con impresoras térmicas, Bluetooth y red. Tickets, etiquetas y códigos de barras.' },
    { icon: Icon.Cloud, color: 'violet', title: 'Siempre sincronizado', desc: 'Trabaja offline y sincroniza automáticamente cuando vuelvas a estar conectado.' },
  ];

  const colorMap: Record<string, { bg: string; text: string }> = {
    violet: { bg: 'bg-[#8B5CF6]/20', text: 'text-[#C4B5FD]' },
    emerald: { bg: 'bg-[#10B981]/20', text: 'text-[#34D399]' },
    sky: { bg: 'bg-[#59B1E4]/20', text: 'text-[#7DD3FC]' },
    sandy: { bg: 'bg-[#FF984F]/20', text: 'text-[#FDBA74]' },
  };

  return (
    <section id="features" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-[#A78BFA] uppercase tracking-[0.2em]">
            Todo lo que necesitas
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Un sistema completo para tu punto de venta
          </h2>
          <p className="mt-5 text-lg text-white/60">
            Diseñado para comercios que quieren crecer sin complicaciones.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((f, i) => {
            const c = colorMap[f.color];
            const IconComp = f.icon;
            return (
              <div
                key={i}
                className="group p-7 rounded-3xl bg-[#1E293B]/50 backdrop-blur-md border border-white/10 hover:border-[#8B5CF6]/40 hover:bg-[#1E293B]/80 transition-all duration-500 hover:-translate-y-1.5 shadow-xl"
              >
                <div className={`w-12 h-12 rounded-2xl ${c.bg} flex items-center justify-center mb-5 group-hover:scale-110 transition-transform duration-500`}>
                  <IconComp className={`w-6 h-6 ${c.text}`} />
                </div>
                <h3 className="text-xl font-bold text-white tracking-tight">{f.title}</h3>
                <p className="mt-2.5 text-sm text-white/70 leading-relaxed">{f.desc}</p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   HOW IT WORKS
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
          <span className="text-sm font-semibold text-[#34D399] uppercase tracking-[0.2em]">
            Cómo funciona
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Listo en menos de 5 minutos
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {steps.map((s, i) => (
            <div key={i} className="relative text-center">
              <div className="w-16 h-16 mx-auto rounded-2xl bg-gradient-to-br from-[#8B5CF6] to-[#59B1E4] flex items-center justify-center shadow-2xl shadow-[#8B5CF6]/30">
                <span className="text-xl font-extrabold text-white">{s.n}</span>
              </div>
              <h3 className="mt-6 text-xl font-bold text-white tracking-tight">{s.title}</h3>
              <p className="mt-2 text-white/60">{s.desc}</p>
              {i < steps.length - 1 && (
                <div className="hidden md:block absolute top-8 left-[60%] w-[80%] h-px bg-gradient-to-r from-[#8B5CF6]/40 to-transparent" />
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   STATS
   ============================================================ */
function Stats() {
  const stats = [
    { value: '+500', label: 'Comercios activos' },
    { value: '99.9%', label: 'Uptime garantizado' },
    { value: '1M+', label: 'Transacciones/mes' },
    { value: '24/7', label: 'Soporte técnico' },
  ];

  return (
    <section className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {stats.map((s, i) => (
            <div key={i} className="text-center">
              <p className="text-5xl sm:text-6xl font-extrabold bg-gradient-to-r from-[#FF984F] via-[#10B981] to-[#59B1E4] bg-clip-text text-transparent">
                {s.value}
              </p>
              <p className="mt-3 text-sm text-white/60 font-medium">{s.label}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   TESTIMONIOS
   ============================================================ */
function Testimonials() {
  const items = [
    { name: 'María González', role: 'Dueña · Bodega Central', text: 'Desde que usamos BoostI POS, los cierres de caja que antes tomaban 1 hora ahora son de 5 minutos. Los reportes son clarísimos.', avatar: '#8B5CF6' },
    { name: 'Carlos Rivas', role: 'Gerente · SuperMarket Plus', text: 'La sincronización entre nuestros 3 locales es perfecta. Ya no tenemos problemas de stock desactualizado.', avatar: '#10B981' },
    { name: 'Andrea Paredes', role: 'Propietaria · La Económica', text: 'Lo mejor es lo fácil que es de usar. Mi personal aprendió en un día y el soporte siempre está disponible.', avatar: '#FF984F' },
  ];

  return (
    <section className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-[#A78BFA] uppercase tracking-[0.2em]">
            Testimonios
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Amado por comercios de todos los tamaños
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {items.map((t, i) => (
            <div
              key={i}
              className="p-7 rounded-3xl bg-[#1E293B]/50 backdrop-blur-md border border-white/10 shadow-xl hover:border-white/20 transition-all duration-500 hover:-translate-y-1.5"
            >
              <div className="flex items-center gap-0.5 mb-5">
                {[...Array(5)].map((_, j) => (
                  <Icon.Star key={j} className="w-4 h-4 text-[#FF984F]" />
                ))}
              </div>
              <p className="text-white/80 leading-relaxed">"{t.text}"</p>
              <div className="mt-6 flex items-center gap-3">
                <div
                  className="w-11 h-11 rounded-full flex items-center justify-center text-white font-bold text-sm shadow-lg"
                  style={{ background: t.avatar }}
                >
                  {t.name.charAt(0)}
                </div>
                <div>
                  <p className="text-sm font-bold text-white">{t.name}</p>
                  <p className="text-xs text-white/50">{t.role}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   PRICING
   ============================================================ */
function Pricing() {
  const plans = [
    { name: 'Starter', price: '19', desc: 'Para comercios pequeños que están empezando.', features: ['1 local', '2 usuarios', 'Ventas ilimitadas', 'Reportes básicos', 'Soporte por email'], cta: 'Comenzar', highlighted: false },
    { name: 'Pro', price: '49', desc: 'Para negocios en crecimiento con múltiples locales.', features: ['3 locales', '10 usuarios', 'Ventas ilimitadas', 'Reportes avanzados', 'Sincronización en tiempo real', 'Soporte prioritario'], cta: 'Probar 14 días gratis', highlighted: true },
    { name: 'Enterprise', price: 'A medida', desc: 'Para cadenas y franquicias con necesidades específicas.', features: ['Locales ilimitados', 'Usuarios ilimitados', 'API personalizada', 'Onboarding dedicado', 'SLA garantizado'], cta: 'Contactar ventas', highlighted: false },
  ];

  return (
    <section id="pricing" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-[#34D399] uppercase tracking-[0.2em]">
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
                relative p-8 rounded-3xl transition-all duration-500
                ${
                  p.highlighted
                    ? 'bg-gradient-to-b from-[#8B5CF6] via-[#1E3A8A] to-[#0B1120] shadow-2xl shadow-[#8B5CF6]/30 scale-105 border border-[#8B5CF6]/50'
                    : 'bg-[#1E293B]/50 backdrop-blur-md border border-white/10 hover:-translate-y-1.5 hover:shadow-2xl'
                }
              `}
            >
              {p.highlighted && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 px-3.5 py-1 rounded-full bg-[#10B981] text-white text-xs font-extrabold tracking-wide shadow-lg">
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
                    <Icon.Check className="w-4 h-4 mt-0.5 flex-shrink-0 text-[#10B981]" />
                    {f}
                  </li>
                ))}
              </ul>
              {p.name === 'Enterprise' ? (
                <button
                  onClick={openContactDialog}
                  className="mt-8 block w-full text-center px-4 py-3.5 rounded-xl font-bold transition-all duration-300 bg-white/10 text-white hover:bg-white/20 border border-white/10"
                >
                  {p.cta}
                </button>
              ) : (
                <a
                  href="/sandbox"
                  className={`
                    mt-8 block text-center px-4 py-3.5 rounded-xl font-bold transition-all duration-300
                    ${
                      p.highlighted
                        ? 'bg-white text-slate-900 hover:bg-slate-100 shadow-lg'
                        : 'bg-white/10 text-white hover:bg-white/20 border border-white/10'
                    }
                  `}
                >
                  {p.cta}
                </a>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ============================================================
   FINAL CTA
   ============================================================ */
function FinalCTA() {
  return (
    <section id="contact" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative overflow-hidden rounded-[3rem] bg-[#1E293B]/60 backdrop-blur-xl border border-white/10 p-12 lg:p-20">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_50%,rgba(139,92,246,0.35),transparent_50%),radial-gradient(circle_at_80%_50%,rgba(16,185,129,0.3),transparent_50%)] pointer-events-none" />
          <div className="relative text-center max-w-2xl mx-auto">
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-tight">
              ¿Listo para transformar tu punto de venta?
            </h2>
            <p className="mt-5 text-lg text-white/70">
              Prueba la demo interactiva sin compromiso. Sin tarjetas, sin instalar nada.
            </p>
            <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
              <a
                href="/sandbox"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white text-slate-900 font-semibold hover:bg-slate-100 transition-all shadow-2xl shadow-white/20 hover:-translate-y-0.5"
              >
                Probar demo ahora
                <Icon.Arrow className="w-4 h-4" />
              </a>
              <button
                onClick={openContactDialog}
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-white/10 text-white font-semibold border border-white/20 hover:bg-white/20 transition-all"
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
   FOOTER
   ============================================================ */
function Footer() {
  const groups = [
    { title: 'Producto', links: ['Características', 'Planes', 'Demo', 'Integraciones'] },
    { title: 'Empresa', links: ['Sobre nosotros', 'Blog', 'Contacto', 'Trabaja con nosotros'] },
    { title: 'Recursos', links: ['Documentación', 'Centro de ayuda', 'Estado', 'API'] },
    { title: 'Legal', links: ['Términos', 'Privacidad', 'Cookies'] },
  ];

  return (
    <footer className="relative border-t border-white/10 bg-[#0B1120]/80">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-6 gap-10">
          <div className="lg:col-span-2">
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#8B5CF6] via-[#59B1E4] to-[#10B981] flex items-center justify-center shadow-lg shadow-[#8B5CF6]/30 p-1.5">
                <Icon.Logo className="w-full h-full" />
              </div>
              <span className="font-bold text-lg text-white tracking-tight">BoostI POS</span>
            </div>
            <p className="mt-5 text-sm text-white/50 max-w-xs leading-relaxed">
              El sistema de punto de venta moderno para comercios que quieren crecer.
            </p>
            <a
              href="/app"
              className="mt-5 inline-flex items-center gap-1.5 text-sm font-semibold text-[#34D399] hover:text-[#D1FAE5] transition-colors"
            >
              Abrir aplicación
              <Icon.ArrowUpRight className="w-4 h-4" />
            </a>
          </div>

          {groups.map((g) => (
            <div key={g.title}>
              <h4 className="text-sm font-bold text-white">{g.title}</h4>
              <ul className="mt-4 space-y-2.5">
                {g.links.map((l) => (
                  <li key={l}>
                    <a href="#" className="text-sm text-white/50 hover:text-white transition-colors">
                      {l}
                    </a>
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
                className="text-sm text-white/40 hover:text-white transition-colors"
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
   PÁGINA PRINCIPAL
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
        <TrustStrip />
        <Features />
        <HowItWorks />
        <Integrations />
        <Stats />
        <Testimonials />
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