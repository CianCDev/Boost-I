This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Despliegue en Netlify

El sitio utiliza la exportación estática de Next.js (`output: 'export'`). La
configuración de Netlify en la raíz del repositorio establece `app_gestion_web`
como directorio base, `npm run build` como comando y `out` como directorio de
publicación. En un despliegue manual también se debe publicar `out`, nunca `.next`:
`.next` contiene archivos internos de Next.js y no es un sitio estático listo para
servir.

Las rutas `/sandbox` y `/sandbox/` sirven la página Next.js exportada como
`/sandbox.html`. El iframe continúa cargando la aplicación Flutter desde
`/sandbox/index.html`; las reglas específicas evitan confundir ambas páginas.

La exportación actual no requiere un servidor de Next.js. Si se añaden funciones
que necesiten servidor, habrá que cambiar a un despliegue con el adaptador de
Next.js de Netlify.
