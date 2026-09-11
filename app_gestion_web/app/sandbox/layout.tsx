import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Demo interactiva | Tu POS',
  description: 'Prueba el sistema POS en vivo, sin necesidad de instalar nada.',
};

export default function SandboxLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return children;
}
