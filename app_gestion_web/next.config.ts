/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    dangerouslyAllowSVG: true,
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'ik.imagekit.io',
        port: '',
        pathname: '/xnf3fil5g/**',
      },
    ],
  },
};

export default nextConfig;
