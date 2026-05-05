/* global React */
const { useState, useEffect, useRef, useMemo } = React;

/* ──────────────────────────────────────────────────────────
   Wanted Design System primitives — for 원가계산기
   Buttons, Inputs, Badges, Sheets, Tabs, Charts, Icons
   ────────────────────────────────────────────────────────── */

// ── Lucide-style stroke icons (1.5px, 24 grid) ────────────
const Icon = ({ name, size = 20, color = "currentColor", strokeWidth = 1.5, style }) => {
  const paths = {
    plus: <><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></>,
    minus: <line x1="5" y1="12" x2="19" y2="12" />,
    chevronLeft: <polyline points="15 18 9 12 15 6" />,
    chevronRight: <polyline points="9 18 15 12 9 6" />,
    chevronDown: <polyline points="6 9 12 15 18 9" />,
    chevronUp: <polyline points="18 15 12 9 6 15" />,
    search: <><circle cx="11" cy="11" r="7" /><line x1="20" y1="20" x2="16.65" y2="16.65" /></>,
    x: <><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></>,
    check: <polyline points="20 6 9 17 4 12" />,
    home: <><path d="M3 11l9-8 9 8" /><path d="M5 10v10h14V10" /></>,
    package: <><path d="M16.5 9.4 7.55 4.24" /><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" /><polyline points="3.27 6.96 12 12.01 20.73 6.96" /><line x1="12" y1="22.08" x2="12" y2="12" /></>,
    blend: <><circle cx="9" cy="9" r="6" /><circle cx="15" cy="15" r="6" /></>,
    chef: <><path d="M6 14a4 4 0 0 1-2-7.5A4 4 0 0 1 12 4a4 4 0 0 1 8 2.5A4 4 0 0 1 18 14" /><path d="M6 14v6h12v-6" /></>,
    chart: <><line x1="3" y1="20" x2="21" y2="20" /><line x1="7" y1="20" x2="7" y2="13" /><line x1="12" y1="20" x2="12" y2="9" /><line x1="17" y1="20" x2="17" y2="16" /></>,
    receipt: <><path d="M4 2v20l3-2 3 2 3-2 3 2 3-2 3 2V2" /><line x1="8" y1="7" x2="16" y2="7" /><line x1="8" y1="11" x2="16" y2="11" /><line x1="8" y1="15" x2="13" y2="15" /></>,
    camera: <><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" /><circle cx="12" cy="13" r="4" /></>,
    edit: <><path d="M12 20h9" /><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4z" /></>,
    trash: <><polyline points="3 6 5 6 21 6" /><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6" /><path d="M10 11v6" /><path d="M14 11v6" /></>,
    alert: <><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" /><line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" /></>,
    info: <><circle cx="12" cy="12" r="10" /><line x1="12" y1="16" x2="12" y2="12" /><line x1="12" y1="8" x2="12.01" y2="8" /></>,
    filter: <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3" />,
    sliders: <><line x1="4" y1="21" x2="4" y2="14" /><line x1="4" y1="10" x2="4" y2="3" /><line x1="12" y1="21" x2="12" y2="12" /><line x1="12" y1="8" x2="12" y2="3" /><line x1="20" y1="21" x2="20" y2="16" /><line x1="20" y1="12" x2="20" y2="3" /><line x1="1" y1="14" x2="7" y2="14" /><line x1="9" y1="8" x2="15" y2="8" /><line x1="17" y1="16" x2="23" y2="16" /></>,
    bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.73 21a2 2 0 0 1-3.46 0" /></>,
    arrowUp: <><line x1="12" y1="19" x2="12" y2="5" /><polyline points="5 12 12 5 19 12" /></>,
    arrowDown: <><line x1="12" y1="5" x2="12" y2="19" /><polyline points="19 12 12 19 5 12" /></>,
    arrowRight: <><line x1="5" y1="12" x2="19" y2="12" /><polyline points="12 5 19 12 12 19" /></>,
    calendar: <><rect x="3" y="4" width="18" height="18" rx="2" ry="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" /></>,
    settings: <><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" /></>,
    moreH: <><circle cx="5" cy="12" r="1" /><circle cx="12" cy="12" r="1" /><circle cx="19" cy="12" r="1" /></>,
    menu: <><line x1="3" y1="12" x2="21" y2="12" /><line x1="3" y1="6" x2="21" y2="6" /><line x1="3" y1="18" x2="21" y2="18" /></>,
    history: <><path d="M3 12a9 9 0 1 0 3-6.7L3 8" /><polyline points="3 3 3 8 8 8" /><polyline points="12 7 12 12 16 14" /></>,
    sparkle: <><path d="M12 3l1.8 5.4L19 10l-5.2 1.6L12 17l-1.8-5.4L5 10l5.2-1.6z" /><path d="M19 17l.9 2.1L22 20l-2.1.9L19 23l-.9-2.1L16 20l2.1-.9z" /></>,
  };
  const p = paths[name];
  if (!p) return null;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color}
      strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round" style={style}>{p}</svg>
  );
};

// ── Button ────────────────────────────────────────────────
const Button = ({ children, variant = 'primary', size = 'md', icon, iconRight, full, onClick, disabled, type, style, ...rest }) => {
  const base = {
    fontFamily: 'var(--font-sans)',
    fontWeight: 700,
    letterSpacing: '-0.006em',
    border: 0,
    cursor: disabled ? 'not-allowed' : 'pointer',
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
    transition: 'background 160ms ease-out, transform 100ms ease-out',
    width: full ? '100%' : 'auto',
  };
  const sizes = {
    sm: { padding: '7px 14px', fontSize: 13, borderRadius: 8 },
    md: { padding: '11px 18px', fontSize: 14, borderRadius: 10 },
    lg: { padding: '14px 22px', fontSize: 16, borderRadius: 12 },
  };
  const variants = {
    primary: { background: 'var(--primary)', color: '#fff' },
    secondary: { background: '#fff', color: 'var(--fg-strong)', boxShadow: 'inset 0 0 0 1px var(--border-subtle)' },
    tertiary: { background: 'rgba(112,115,124,0.05)', color: 'var(--fg-strong)' },
    danger: { background: 'var(--negative)', color: '#fff' },
    ghost: { background: 'transparent', color: 'var(--fg-strong)' },
  };
  const dis = disabled ? { background: 'rgba(112,115,124,0.12)', color: 'rgba(23,23,23,0.28)', boxShadow: 'none' } : {};
  return (
    <button onClick={onClick} disabled={disabled} type={type}
      style={{ ...base, ...sizes[size], ...variants[variant], ...dis, ...style }} {...rest}>
      {icon && <Icon name={icon} size={size === 'sm' ? 14 : 16} />}
      {children}
      {iconRight && <Icon name={iconRight} size={size === 'sm' ? 14 : 16} />}
    </button>
  );
};

// ── Input ─────────────────────────────────────────────────
const Field = ({ label, children, hint, error, suffix }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
    {label && (
      <div style={{ font: '600 13px/1.4 var(--font-sans)', color: 'var(--fg-strong)' }}>
        {label} {suffix && <span style={{ color: 'var(--fg-tertiary)', fontWeight: 500 }}>{suffix}</span>}
      </div>
    )}
    {children}
    {(hint || error) && (
      <div style={{ font: '500 12px/1.333 var(--font-sans)', color: error ? '#E52222' : 'var(--fg-tertiary)' }}>
        {error || hint}
      </div>
    )}
  </div>
);

const Input = ({ value, onChange, placeholder, type = 'text', error, suffix, prefix, style, ...rest }) => {
  const [focused, setFocused] = useState(false);
  const wrap = {
    display: 'flex', alignItems: 'center', background: '#fff',
    borderRadius: 12, padding: '0 14px',
    boxShadow: error ? 'inset 0 0 0 2px var(--negative)'
      : focused ? 'inset 0 0 0 2px var(--primary)'
      : 'inset 0 0 0 1px var(--border-subtle)',
    transition: 'box-shadow 160ms ease-out',
  };
  return (
    <div style={{ ...wrap, ...style }}>
      {prefix && <span style={{ color: 'var(--fg-tertiary)', marginRight: 8, font: '500 15px/1.467 var(--font-sans)' }}>{prefix}</span>}
      <input
        type={type} value={value ?? ''} placeholder={placeholder}
        onChange={(e) => onChange?.(e.target.value)}
        onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
        style={{
          flex: 1, font: '500 15px/1.467 var(--font-sans)',
          padding: '11px 0', color: 'var(--fg-strong)',
          border: 0, outline: 0, background: 'transparent', minWidth: 0,
        }}
        {...rest}
      />
      {suffix && <span style={{ color: 'var(--fg-tertiary)', marginLeft: 8, font: '500 14px/1 var(--font-sans)' }}>{suffix}</span>}
    </div>
  );
};

// ── Badge ─────────────────────────────────────────────────
const Badge = ({ children, tone = 'neutral', size = 'md', style }) => {
  const tones = {
    neutral: { bg: 'rgba(112,115,124,0.1)', fg: 'var(--fg-secondary)' },
    primary: { bg: 'var(--primary-soft)', fg: 'var(--primary)' },
    positive: { bg: 'var(--positive-soft)', fg: 'var(--positive)' },
    negative: { bg: 'var(--negative-soft)', fg: 'var(--negative)' },
    warning: { bg: 'var(--warning-soft)', fg: 'var(--warning)' },
    info: { bg: 'var(--info-soft)', fg: 'var(--info)' },
    ai: { bg: 'var(--accent-ai-soft)', fg: 'var(--accent-ai)' },
  };
  const t = tones[tone];
  const sz = size === 'sm'
    ? { padding: '2px 8px', fontSize: 11, borderRadius: 999 }
    : { padding: '4px 10px', fontSize: 12, borderRadius: 999 };
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      background: t.bg, color: t.fg, fontWeight: 600,
      letterSpacing: '0.025em', whiteSpace: 'nowrap',
      ...sz, ...style,
    }}>{children}</span>
  );
};

// ── Card ──────────────────────────────────────────────────
const Card = ({ children, padding = 16, style, onClick }) => (
  <div onClick={onClick} style={{
    background: '#fff',
    borderRadius: 16,
    boxShadow: 'inset 0 0 0 1px var(--border-subtle)',
    padding,
    cursor: onClick ? 'pointer' : 'default',
    ...style,
  }}>{children}</div>
);

// ── Bottom Sheet ──────────────────────────────────────────
const Sheet = ({ open, onClose, title, children, height = 'auto', actions }) => (
  <>
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, background: 'rgba(20,25,30,0.45)',
      opacity: open ? 1 : 0, pointerEvents: open ? 'auto' : 'none',
      transition: 'opacity 200ms ease-out', zIndex: 30,
    }} />
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      background: '#fff', borderRadius: '20px 20px 0 0',
      transform: open ? 'translateY(0)' : 'translateY(100%)',
      transition: 'transform 240ms cubic-bezier(0.32, 0.72, 0, 1)',
      zIndex: 31, maxHeight: '92%',
      display: 'flex', flexDirection: 'column',
      boxShadow: '0 -4px 24px rgba(0,0,0,0.08)',
    }}>
      <div style={{
        padding: '12px 0 4px', display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ width: 36, height: 4, background: 'rgba(112,115,124,0.28)', borderRadius: 2 }} />
      </div>
      {title && (
        <div style={{
          padding: '8px 20px 16px',
          font: '700 18px/1.4 var(--font-sans)',
          letterSpacing: '-0.012em', color: 'var(--fg-strong)',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <span>{title}</span>
          <button onClick={onClose} style={{
            border: 0, background: 'transparent', padding: 4, cursor: 'pointer',
            color: 'var(--fg-secondary)',
          }}><Icon name="x" size={22} /></button>
        </div>
      )}
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 20px 20px', height }}>
        {children}
      </div>
      {actions && (
        <div style={{
          padding: '12px 20px calc(20px + env(safe-area-inset-bottom))',
          borderTop: '1px solid var(--border-subtle)',
          background: '#fff',
          display: 'flex', gap: 8,
        }}>{actions}</div>
      )}
    </div>
  </>
);

// ── Tabs (segmented) ──────────────────────────────────────
const Segment = ({ value, options, onChange, style }) => (
  <div style={{
    display: 'flex', background: 'rgba(112,115,124,0.08)',
    padding: 3, borderRadius: 10, gap: 2, ...style,
  }}>
    {options.map((opt) => {
      const active = value === opt.value;
      return (
        <button key={opt.value} onClick={() => onChange(opt.value)}
          style={{
            flex: 1, border: 0, background: active ? '#fff' : 'transparent',
            color: active ? 'var(--fg-strong)' : 'var(--fg-secondary)',
            font: '600 13px/1.3 var(--font-sans)',
            padding: '8px 12px', borderRadius: 8,
            boxShadow: active ? '0 1px 2px rgba(23,23,23,0.06)' : 'none',
            cursor: 'pointer', transition: 'all 160ms ease-out',
          }}>{opt.label}</button>
      );
    })}
  </div>
);

// ── Toast ─────────────────────────────────────────────────
const ToastCtx = React.createContext(null);
const ToastProvider = ({ children }) => {
  const [toasts, setToasts] = useState([]);
  const push = (msg, tone = 'neutral') => {
    const id = Math.random().toString(36).slice(2);
    setToasts((t) => [...t, { id, msg, tone }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 2200);
  };
  return (
    <ToastCtx.Provider value={push}>
      {children}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 90,
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
        pointerEvents: 'none', zIndex: 50,
      }}>
        {toasts.map((t) => {
          const tones = {
            neutral: { bg: 'rgba(20,25,30,0.92)', fg: '#fff' },
            positive: { bg: 'var(--positive)', fg: '#fff' },
            negative: { bg: 'var(--negative)', fg: '#fff' },
          };
          const c = tones[t.tone] || tones.neutral;
          return (
            <div key={t.id} style={{
              background: c.bg, color: c.fg,
              padding: '10px 18px', borderRadius: 999,
              font: '600 13px/1.3 var(--font-sans)',
              boxShadow: '0 6px 16px rgba(23,23,23,0.18)',
              animation: 'toastIn 220ms ease-out',
            }}>{t.msg}</div>
          );
        })}
      </div>
    </ToastCtx.Provider>
  );
};
const useToast = () => React.useContext(ToastCtx);

// ── Sparkline (line chart) ────────────────────────────────
const Sparkline = ({ data, w = 260, h = 60, stroke = 'var(--primary)', fill = 'rgba(0,102,255,0.12)' }) => {
  if (!data || data.length < 2) return null;
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const pts = data.map((v, i) => {
    const x = (i / (data.length - 1)) * w;
    const y = h - ((v - min) / range) * (h - 8) - 4;
    return [x, y];
  });
  const d = pts.map(([x, y], i) => (i === 0 ? `M${x},${y}` : `L${x},${y}`)).join(' ');
  const area = `${d} L${w},${h} L0,${h} Z`;
  return (
    <svg width={w} height={h} style={{ display: 'block' }}>
      <path d={area} fill={fill} />
      <path d={d} stroke={stroke} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
      {pts.map(([x, y], i) => (
        <circle key={i} cx={x} cy={y} r={i === pts.length - 1 ? 3 : 0} fill={stroke} />
      ))}
    </svg>
  );
};

// ── Bar chart (horizontal) ────────────────────────────────
const BarStack = ({ items, total, height = 12 }) => {
  const colors = ['#0066FF', '#6541F2', '#00BF40', '#FF9200', '#00BDDE', '#FA73E3', '#FF5E00'];
  return (
    <div style={{
      display: 'flex', height, borderRadius: 999, overflow: 'hidden',
      background: 'var(--bg-muted)',
    }}>
      {items.map((it, i) => (
        <div key={i} style={{
          width: `${(it.value / total) * 100}%`,
          background: it.color || colors[i % colors.length],
        }} />
      ))}
    </div>
  );
};

// ── Donut chart ───────────────────────────────────────────
const Donut = ({ items, size = 140, stroke = 18, centerLabel, centerValue }) => {
  const colors = ['#0066FF', '#6541F2', '#00BF40', '#FF9200', '#00BDDE', '#FA73E3'];
  const total = items.reduce((s, it) => s + it.value, 0);
  const r = (size - stroke) / 2;
  const cx = size / 2;
  const cy = size / 2;
  const C = 2 * Math.PI * r;
  let acc = 0;
  return (
    <svg width={size} height={size}>
      <circle cx={cx} cy={cy} r={r} fill="none"
        stroke="var(--bg-muted)" strokeWidth={stroke} />
      {items.map((it, i) => {
        const len = (it.value / total) * C;
        const dasharray = `${len} ${C}`;
        const dashoffset = -((acc / total) * C);
        acc += it.value;
        return (
          <circle key={i} cx={cx} cy={cy} r={r} fill="none"
            stroke={it.color || colors[i % colors.length]} strokeWidth={stroke}
            strokeDasharray={dasharray} strokeDashoffset={dashoffset}
            transform={`rotate(-90 ${cx} ${cy})`} strokeLinecap="butt" />
        );
      })}
      {centerLabel && (
        <text x={cx} y={cy - 4} textAnchor="middle"
          fontFamily="var(--font-sans)" fontSize="11" fontWeight="600"
          fill="var(--fg-tertiary)" letterSpacing="0.025em">{centerLabel}</text>
      )}
      {centerValue && (
        <text x={cx} y={cy + 14} textAnchor="middle"
          fontFamily="var(--font-sans)" fontSize="18" fontWeight="700"
          fill="var(--fg-strong)" letterSpacing="-0.02em">{centerValue}</text>
      )}
    </svg>
  );
};

// ── Bars (vertical, day-of-week style) ────────────────────
const VBars = ({ data, w = 280, h = 100, color = 'var(--primary)' }) => {
  const max = Math.max(...data.map(d => d.v)) || 1;
  const bw = (w - (data.length - 1) * 8) / data.length;
  return (
    <svg width={w} height={h + 20}>
      {data.map((d, i) => {
        const bh = (d.v / max) * h;
        const x = i * (bw + 8);
        const y = h - bh;
        return (
          <g key={i}>
            <rect x={x} y={y} width={bw} height={bh} rx={6}
              fill={d.highlight ? 'var(--primary)' : 'rgba(0,102,255,0.18)'} />
            <text x={x + bw / 2} y={h + 14} textAnchor="middle"
              fontFamily="var(--font-sans)" fontSize="11" fontWeight="500"
              fill="var(--fg-tertiary)">{d.label}</text>
          </g>
        );
      })}
    </svg>
  );
};

// Bottom Tab Bar
const TabBar = ({ active, onChange }) => {
  const tabs = [
    { id: 'home', label: '홈', icon: 'home' },
    { id: 'ingredients', label: '재료', icon: 'package' },
    { id: 'recipes', label: '레시피', icon: 'chef' },
    { id: 'reports', label: '리포트', icon: 'chart' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      background: 'rgba(255,255,255,0.92)',
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      borderTop: '1px solid var(--border-subtle)',
      padding: '6px 8px calc(8px + env(safe-area-inset-bottom))',
      display: 'flex', justifyContent: 'space-around',
      zIndex: 20,
    }}>
      {tabs.map((t) => {
        const on = active === t.id;
        return (
          <button key={t.id} onClick={() => onChange(t.id)}
            style={{
              flex: 1, border: 0, background: 'transparent',
              padding: '6px 0', cursor: 'pointer',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
              color: on ? 'var(--primary)' : 'var(--fg-tertiary)',
            }}>
            <Icon name={t.icon} size={22} strokeWidth={on ? 2 : 1.6} />
            <div style={{
              font: '600 10px/1 var(--font-sans)', letterSpacing: '0.025em',
            }}>{t.label}</div>
          </button>
        );
      })}
    </div>
  );
};

// Top app bar
const AppBar = ({ title, leading, trailing, subtitle, onBack, large }) => (
  <div style={{
    padding: '60px 16px 8px',
    background: '#fff',
    borderBottom: large ? 'none' : '1px solid var(--border-subtle)',
  }}>
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, height: 32 }}>
      {onBack ? (
        <button onClick={onBack} style={{
          border: 0, background: 'transparent', padding: 4, marginLeft: -4,
          cursor: 'pointer', color: 'var(--fg-strong)',
        }}><Icon name="chevronLeft" size={24} /></button>
      ) : leading}
      <div style={{ flex: 1, font: '700 17px/1.3 var(--font-sans)', letterSpacing: '-0.012em', color: 'var(--fg-strong)', textAlign: large ? 'left' : 'center', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
        {!large && title}
      </div>
      {trailing && <div style={{ display: 'flex', gap: 4 }}>{trailing}</div>}
    </div>
    {large && (
      <div style={{ padding: '12px 0 8px' }}>
        <div style={{ font: '700 28px/1.2 var(--font-sans)', letterSpacing: '-0.024em', color: 'var(--fg-strong)' }}>{title}</div>
        {subtitle && <div style={{ font: '500 14px/1.4 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 4 }}>{subtitle}</div>}
      </div>
    )}
  </div>
);

// Stat card
const Stat = ({ label, value, delta, deltaTone = 'positive', sub, icon, iconBg, onClick, style }) => {
  const tones = { positive: 'var(--positive)', negative: 'var(--negative)', neutral: 'var(--fg-tertiary)' };
  return (
    <Card padding={14} onClick={onClick} style={{ display: 'flex', flexDirection: 'column', gap: 8, ...style }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>{label}</div>
        {icon && (
          <div style={{
            width: 28, height: 28, borderRadius: 8,
            background: iconBg || 'var(--primary-soft)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'var(--primary)',
          }}><Icon name={icon} size={16} /></div>
        )}
      </div>
      <div style={{ font: '700 22px/1.2 var(--font-sans)', letterSpacing: '-0.018em', color: 'var(--fg-strong)' }}>{value}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
        {delta && (
          <span style={{
            font: '600 11px/1.2 var(--font-sans)',
            color: tones[deltaTone],
            display: 'inline-flex', alignItems: 'center', gap: 2,
          }}>
            <Icon name={deltaTone === 'positive' ? 'arrowUp' : deltaTone === 'negative' ? 'arrowDown' : 'arrowRight'} size={12} />
            {delta}
          </span>
        )}
        {sub && <span style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{sub}</span>}
      </div>
    </Card>
  );
};

Object.assign(window, {
  Icon, Button, Field, Input, Badge, Card,
  Sheet, Segment, ToastProvider, useToast,
  Sparkline, BarStack, Donut, VBars,
  TabBar, AppBar, Stat,
});
