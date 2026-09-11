'use client';

import { useEffect, useState } from 'react';

interface ContactDialogProps {
  open: boolean;
  onClose: () => void;
}

export default function ContactDialog({ open, onClose }: ContactDialogProps) {
  const [formData, setFormData] = useState({
    nombre: '',
    email: '',
    telefono: '',
    empresa: '',
    empleados: '1-5',
    mensaje: '',
  });
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  // Bloquear scroll cuando está abierto + ESC para cerrar
  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden';
      const onEsc = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
      document.addEventListener('keydown', onEsc);
      return () => {
        document.body.style.overflow = '';
        document.removeEventListener('keydown', onEsc);
      };
    }
  }, [open, onClose]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    // TODO: conectar a tu backend/API real
    setTimeout(() => {
      setLoading(false);
      setSubmitted(true);
      setTimeout(() => {
        setSubmitted(false);
        onClose();
        setFormData({
          nombre: '', email: '', telefono: '', empresa: '', empleados: '1-5', mensaje: '',
        });
      }, 2000);
    }, 1000);
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      {/* Overlay */}
      <div
        className="absolute inset-0 bg-[#0B1120]/80 backdrop-blur-sm animate-in fade-in duration-200"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-lg rounded-3xl bg-[#1E293B] border border-white/10 shadow-2xl shadow-black/50 overflow-hidden">
        {/* Glow decorativo */}
        <div className="absolute top-0 right-0 w-64 h-64 bg-[#8B5CF6]/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute bottom-0 left-0 w-64 h-64 bg-[#10B981]/15 rounded-full blur-3xl pointer-events-none" />

        {/* Botón cerrar */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-10 p-2 rounded-lg text-white/60 hover:text-white hover:bg-white/10 transition-colors"
          aria-label="Cerrar"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" className="w-5 h-5">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        <div className="relative p-8">
          {!submitted ? (
            <>
              {/* Header */}
              <div className="mb-6">
                <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#10B981]/15 text-[#34D399] text-[10px] font-bold uppercase tracking-wider border border-[#10B981]/30">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#10B981] animate-pulse" />
                  Respuesta en menos de 24h
                </span>
                <h2 className="mt-3 text-2xl font-extrabold text-white tracking-tight">
                  Hablemos de tu negocio
                </h2>
                <p className="mt-2 text-sm text-white/60">
                  Cuéntanos qué necesitas y te mostramos cómo BoostI POS se adapta.
                </p>
              </div>

              {/* Formulario */}
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-white/70 mb-1.5">
                      Nombre *
                    </label>
                    <input
                      type="text"
                      required
                      value={formData.nombre}
                      onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
                      className="w-full px-3.5 py-2.5 rounded-lg bg-white/5 border border-white/10 text-white text-sm placeholder-white/30 focus:outline-none focus:border-[#8B5CF6]/50 focus:bg-white/[0.08] transition-all"
                      placeholder="Tu nombre"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-white/70 mb-1.5">
                      Teléfono
                    </label>
                    <input
                      type="tel"
                      value={formData.telefono}
                      onChange={(e) => setFormData({ ...formData, telefono: e.target.value })}
                      className="w-full px-3.5 py-2.5 rounded-lg bg-white/5 border border-white/10 text-white text-sm placeholder-white/30 focus:outline-none focus:border-[#8B5CF6]/50 focus:bg-white/[0.08] transition-all"
                      placeholder="+58 412-0000000"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-white/70 mb-1.5">
                    Email *
                  </label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-lg bg-white/5 border border-white/10 text-white text-sm placeholder-white/30 focus:outline-none focus:border-[#8B5CF6]/50 focus:bg-white/[0.08] transition-all"
                    placeholder="tu@empresa.com"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-white/70 mb-1.5">
                      Empresa
                    </label>
                    <input
                      type="text"
                      value={formData.empresa}
                      onChange={(e) => setFormData({ ...formData, empresa: e.target.value })}
                      className="w-full px-3.5 py-2.5 rounded-lg bg-white/5 border border-white/10 text-white text-sm placeholder-white/30 focus:outline-none focus:border-[#8B5CF6]/50 focus:bg-white/[0.08] transition-all"
                      placeholder="Nombre del negocio"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-white/70 mb-1.5">
                      Empleados
                    </label>
                    <select
                      value={formData.empleados}
                      onChange={(e) => setFormData({ ...formData, empleados: e.target.value })}
                      className="w-full px-3.5 py-2.5 rounded-lg bg-white/5 border border-white/10 text-white text-sm focus:outline-none focus:border-[#8B5CF6]/50 focus:bg-white/[0.08] transition-all"
                    >
                      <option className="bg-[#1E293B]" value="1-5">1-5</option>
                      <option className="bg-[#1E293B]" value="6-20">6-20</option>
                      <option className="bg-[#1E293B]" value="21-50">21-50</option>
                      <option className="bg-[#1E293B]" value="50+">+50</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-white/70 mb-1.5">
                    Mensaje
                  </label>
                  <textarea
                    rows={3}
                    value={formData.mensaje}
                    onChange={(e) => setFormData({ ...formData, mensaje: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-lg bg-white/5 border border-white/10 text-white text-sm placeholder-white/30 focus:outline-none focus:border-[#8B5CF6]/50 focus:bg-white/[0.08] transition-all resize-none"
                    placeholder="Cuéntanos sobre tu negocio…"
                  />
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full inline-flex items-center justify-center gap-2 px-4 py-3.5 rounded-xl bg-gradient-to-r from-[#8B5CF6] to-[#59B1E4] text-white font-bold text-sm hover:opacity-90 disabled:opacity-60 transition-all shadow-lg shadow-[#8B5CF6]/25"
                >
                  {loading ? (
                    <>
                      <div className="w-4 h-4 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                      Enviando…
                    </>
                  ) : (
                    <>
                      Enviar mensaje
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4">
                        <line x1="5" y1="12" x2="19" y2="12" />
                        <polyline points="12 5 19 12 12 19" />
                      </svg>
                    </>
                  )}
                </button>

                <p className="text-center text-[11px] text-white/40">
                  Al enviar aceptas nuestra política de privacidad.
                </p>
              </form>
            </>
          ) : (
            // Success state
            <div className="py-12 text-center">
              <div className="w-20 h-20 mx-auto rounded-full bg-[#10B981]/15 flex items-center justify-center mb-6">
                <svg viewBox="0 0 24 24" fill="none" stroke="#10B981" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="w-10 h-10">
                  <polyline points="20 6 9 17 4 12" />
                </svg>
              </div>
              <h3 className="text-2xl font-extrabold text-white tracking-tight">
                ¡Mensaje enviado!
              </h3>
              <p className="mt-3 text-sm text-white/60 max-w-xs mx-auto">
                Nos pondremos en contacto contigo en las próximas 24 horas.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}