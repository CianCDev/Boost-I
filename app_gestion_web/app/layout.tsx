import { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'BoostI POS | El sistema de punto de venta moderno',
  description:
    'Gestiona ventas, inventario, múltiples locales y reportes en tiempo real. Prueba la demo interactiva sin instalar nada.',
  keywords: ['POS', 'punto de venta', 'inventario', 'retail', 'Venezuela'],
  openGraph: {
    title: 'BoostI POS | El sistema de punto de venta moderno',
    description: 'Gestiona tu negocio desde cualquier dispositivo.',
    type: 'website',
  },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="es">
      <body className="antialiased">{children}</body>
    </html>
  );
}