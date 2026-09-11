'use client';

export default function FloatingHelpButton({ onClick }: { onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className="fixed bottom-6 left-6 z-[90] group"
      aria-label="Ver tutorial"
    >
      <div className="relative">
        {/* Anillo pulsante */}
        <div className="absolute inset-0 rounded-full bg-[#8B5CF6]/40 animate-ping" />
        {/* Botón */}
        <div className="relative w-14 h-14 rounded-full bg-gradient-to-br from-[#8B5CF6] to-[#59B1E4] flex items-center justify-center shadow-xl shadow-[#8B5CF6]/40 hover:scale-110 transition-transform">
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="white"
            strokeWidth="2.5"
            strokeLinecap="round"
            strokeLinejoin="round"
            className="w-6 h-6"
          >
            <circle cx="12" cy="12" r="10" />
            <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
            <line x1="12" y1="17" x2="12.01" y2="17" />
          </svg>
        </div>
        {/* Tooltip */}
        <div className="absolute left-full ml-3 top-1/2 -translate-y-1/2 px-3 py-1.5 rounded-lg bg-[#1E293B] border border-white/10 text-white text-xs font-semibold whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none shadow-lg">
          Ver tutorial
        </div>
      </div>
    </button>
  );
}