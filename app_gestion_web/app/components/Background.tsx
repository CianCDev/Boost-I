export default function Background() {
  return (
    <div className="fixed inset-0 -z-10 overflow-hidden pointer-events-none bg-bg-base">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(0,178,255,0.25),rgba(14,17,22,1))]" />
      <div className="absolute inset-0 bg-linear-to-b from-transparent via-deep-slate/20 to-bg-base" />

      <div className="absolute -top-40 -left-40 w-[600px] h-[600px] rounded-full bg-electric/20 blur-[120px] animate-blob-slow" />
      <div className="absolute top-[28%] -right-40 w-[550px] h-[550px] rounded-full bg-indigo/15 blur-[120px] animate-blob-medium" />
      <div className="absolute top-[60%] left-[5%] w-[600px] h-[600px] rounded-full bg-mint/15 blur-[130px] animate-blob-slow" />
      <div className="absolute top-[85%] -right-20 w-[500px] h-[500px] rounded-full bg-lilac/10 blur-[120px] animate-blob-medium" />

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
