// Web platform: dùng iframe để nhúng VNEGREEN Super App
export default function IndexWebScreen() {
  return (
    <div
      style={{
        width: '100%',
        height: '100dvh',
        overflow: 'hidden',
        background: '#080C15',
      }}
    >
      <iframe
        src="https://demo.nlpgroup.vn/"
        style={{
          width: '100%',
          height: '100%',
          border: 'none',
          display: 'block',
        }}
        title="VNEGREEN Super App"
        allow="geolocation; camera; microphone; fullscreen"
      />
    </div>
  );
}
