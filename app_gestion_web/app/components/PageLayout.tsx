import type { ReactNode } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import Background from './Background';

export default function PageLayout({ children }: { children: ReactNode }) {
  return (
    <div className="relative isolate min-h-screen overflow-x-clip bg-bg-base text-white">
      <Background />
      <header className="fixed inset-x-0 top-0 z-50 border-b border-white/10 bg-bg-base/70 px-6 py-4 backdrop-blur-xl">
        <nav className="mx-auto flex max-w-7xl items-center justify-between">
          <Link
            href="/"
            aria-label="BoostI POS — Inicio"
            className="flex shrink-0 items-center gap-2.5"
          >
            <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-linear-to-br from-electric via-indigo to-lilac p-1.5 shadow-md shadow-electric/30">
              <Image
                src="/images/logo.png"
                alt=""
                width={1025}
                height={1025}
                className="h-full w-full object-contain"
              />
            </span>
            <span className="whitespace-nowrap text-lg font-bold tracking-tight text-white">
              BoostI POS
            </span>
          </Link>
          <Link
            href="/"
            className="text-sm text-mint transition-colors duration-300 ease-in-out hover:text-white"
          >
            ← Volver al inicio
          </Link>
        </nav>
      </header>
      <div className="relative z-10">{children}</div>
    </div>
  );
}
