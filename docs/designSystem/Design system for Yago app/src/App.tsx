import { useState } from 'react'

// ─── Token reference ──────────────────────────────────────────────────────────
const TOKENS = {
  colors: {
    primary: { label: 'Primary', value: '#FF6B35', use: 'Acciones principales, CTA, énfasis' },
    foreground: { label: 'Foreground', value: '#1D1D1F', use: 'Texto principal' },
    muted: { label: 'Muted Foreground', value: '#6E6E73', use: 'Texto secundario, etiquetas' },
    subtle: { label: 'Tertiary', value: '#AEAEB2', use: 'Placeholders, deshabilitados' },
    background: { label: 'Background', value: '#FFFFFF', use: 'Fondo de pantalla' },
    surface: { label: 'Surface', value: '#F5F5F7', use: 'Superficies elevadas, inputs' },
    border: { label: 'Border', value: '#E5E5EA', use: 'Separadores, bordes hairline' },
  },
  semantic: {
    lost: { label: 'Perdida', value: '#FF3B30', bg: '#FFF2F1' },
    found: { label: 'Encontrada', value: '#34C759', bg: '#F1FFF5' },
    reunited: { label: 'Reunida', value: '#5AC8FA', bg: '#F0FAFE' },
    community: { label: 'Comunidad', value: '#AF52DE', bg: '#F8F0FE' },
  },
  type: [
    { name: 'Display', size: '34px', weight: '200', tracking: '-0.02em', sample: 'Encontrá a Luna' },
    { name: 'Title 1', size: '28px', weight: '300', tracking: '-0.015em', sample: 'Mascotas perdidas' },
    { name: 'Title 2', size: '22px', weight: '400', tracking: '-0.01em', sample: 'Cerca de vos' },
    { name: 'Headline', size: '17px', weight: '500', tracking: '-0.005em', sample: 'Publicar mascota' },
    { name: 'Body', size: '17px', weight: '400', tracking: '0', sample: 'Lhasa Apso, hembra, 3 años. Collar rojo.' },
    { name: 'Callout', size: '16px', weight: '400', tracking: '0', sample: 'Última vez vista en Palermo, CABA' },
    { name: 'Subheadline', size: '15px', weight: '400', tracking: '0.005em', sample: 'Hace 2 horas · 800m de distancia' },
    { name: 'Footnote', size: '13px', weight: '400', tracking: '0.005em', sample: 'Publicado por Martín García' },
    { name: 'Caption', size: '12px', weight: '400', tracking: '0.01em', sample: 'Actualizado hoy a las 14:32' },
  ],
  radius: [
    { name: 'sm', value: '8px', use: 'Tags, chips' },
    { name: 'md', value: '12px', use: 'Cards, botones' },
    { name: 'lg', value: '16px', use: 'Modales, sheets' },
    { name: 'xl', value: '20px', use: 'Hero cards' },
    { name: 'full', value: '9999px', use: 'Avatares, pills' },
  ],
  spacing: [4, 8, 12, 16, 20, 24, 32, 40, 48, 64],
}

// ─── Reusable components ──────────────────────────────────────────────────────

function SectionTitle({ label, title }: { label: string; title: string }) {
  return (
    <div className="mb-8">
      <p style={{ fontSize: '11px', fontWeight: 500, letterSpacing: '0.08em', color: '#FF6B35', textTransform: 'uppercase' }}>{label}</p>
      <h2 style={{ fontSize: '22px', fontWeight: 300, letterSpacing: '-0.01em', color: '#1D1D1F', marginTop: '2px' }}>{title}</h2>
    </div>
  )
}

function Divider() {
  return <div style={{ height: '1px', backgroundColor: '#E5E5EA', margin: '56px 0' }} />
}

// ─── Sections ─────────────────────────────────────────────────────────────────

function HeroSection() {
  return (
    <div style={{ paddingBottom: '56px', borderBottom: '1px solid #E5E5EA' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '32px' }}>
        <div style={{
          width: 40, height: 40, borderRadius: '10px',
          background: '#FF6B35',
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
          </svg>
        </div>
        <span style={{ fontSize: '20px', fontWeight: 500, color: '#1D1D1F', letterSpacing: '-0.01em' }}>Yago</span>
      </div>

      <h1 style={{ fontSize: '48px', fontWeight: 200, letterSpacing: '-0.03em', lineHeight: 1.1, color: '#1D1D1F', marginBottom: '16px' }}>
        Design System
      </h1>
      <p style={{ fontSize: '17px', fontWeight: 300, color: '#6E6E73', lineHeight: 1.6, maxWidth: '480px' }}>
        Tokens, componentes y patrones para Yago — la plataforma para encontrar mascotas perdidas y construir una comunidad.
      </p>
      <div style={{ display: 'flex', gap: '8px', marginTop: '24px', flexWrap: 'wrap' }}>
        {['v1.0', 'iOS-first', 'Light theme', 'Minimalista'].map(tag => (
          <span key={tag} style={{
            fontSize: '12px', fontWeight: 500, letterSpacing: '0.01em',
            padding: '4px 10px', borderRadius: '9999px',
            border: '1px solid #E5E5EA', color: '#6E6E73', backgroundColor: '#F5F5F7'
          }}>{tag}</span>
        ))}
      </div>
    </div>
  )
}

function ColorsSection() {
  return (
    <div>
      <SectionTitle label="01 — Foundation" title="Colores" />

      <div style={{ marginBottom: '32px' }}>
        <p style={{ fontSize: '12px', fontWeight: 500, letterSpacing: '0.05em', color: '#AEAEB2', textTransform: 'uppercase', marginBottom: '12px' }}>Paleta base</p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: '12px' }}>
          {Object.values(TOKENS.colors).map(c => (
            <div key={c.label} style={{ borderRadius: '12px', overflow: 'hidden', border: '1px solid #E5E5EA' }}>
              <div style={{ height: '72px', backgroundColor: c.value }} />
              <div style={{ padding: '10px 12px', backgroundColor: '#FFFFFF' }}>
                <p style={{ fontSize: '13px', fontWeight: 500, color: '#1D1D1F' }}>{c.label}</p>
                <p style={{ fontSize: '11px', color: '#AEAEB2', marginTop: '1px', fontFamily: 'monospace' }}>{c.value}</p>
                <p style={{ fontSize: '11px', color: '#6E6E73', marginTop: '4px', lineHeight: 1.4 }}>{c.use}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div>
        <p style={{ fontSize: '12px', fontWeight: 500, letterSpacing: '0.05em', color: '#AEAEB2', textTransform: 'uppercase', marginBottom: '12px' }}>Estados semánticos</p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: '12px' }}>
          {Object.values(TOKENS.semantic).map(s => (
            <div key={s.label} style={{
              display: 'flex', alignItems: 'center', gap: '12px',
              padding: '14px 16px', borderRadius: '12px',
              backgroundColor: s.bg, border: `1px solid ${s.value}22`
            }}>
              <div style={{ width: 10, height: 10, borderRadius: '9999px', backgroundColor: s.value, flexShrink: 0 }} />
              <div>
                <p style={{ fontSize: '14px', fontWeight: 500, color: '#1D1D1F' }}>{s.label}</p>
                <p style={{ fontSize: '11px', fontFamily: 'monospace', color: '#6E6E73' }}>{s.value}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

function TypographySection() {
  return (
    <div>
      <SectionTitle label="02 — Foundation" title="Tipografía" />
      <div style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
        <span style={{ fontSize: '13px', fontWeight: 500, color: '#6E6E73' }}>Fuente:</span>
        <span style={{ fontSize: '13px', fontWeight: 600, color: '#1D1D1F', letterSpacing: '-0.005em' }}>Inter</span>
        <span style={{ fontSize: '12px', color: '#AEAEB2' }}>— weights 200, 300, 400, 500, 600</span>
      </div>
      <div style={{ border: '1px solid #E5E5EA', borderRadius: '16px', overflow: 'hidden' }}>
        {TOKENS.type.map((t, i) => (
          <div key={t.name} style={{
            display: 'grid', gridTemplateColumns: '96px 1fr 80px 80px',
            padding: '16px 20px', gap: '16px', alignItems: 'center',
            borderBottom: i < TOKENS.type.length - 1 ? '1px solid #E5E5EA' : 'none',
          }}>
            <div>
              <p style={{ fontSize: '12px', fontWeight: 600, color: '#FF6B35', letterSpacing: '0.02em' }}>{t.name}</p>
            </div>
            <p style={{ fontSize: t.size, fontWeight: t.weight as any, letterSpacing: t.tracking, color: '#1D1D1F', lineHeight: 1.2 }}>
              {t.sample}
            </p>
            <p style={{ fontSize: '11px', fontFamily: 'monospace', color: '#AEAEB2', textAlign: 'right' }}>{t.size}</p>
            <p style={{ fontSize: '11px', fontFamily: 'monospace', color: '#AEAEB2', textAlign: 'right' }}>{t.weight}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

function SpacingSection() {
  return (
    <div>
      <SectionTitle label="03 — Foundation" title="Espaciado" />
      <p style={{ fontSize: '14px', color: '#6E6E73', marginBottom: '24px' }}>Base 4px — escala lineal 4, 8, 12, 16, 20, 24, 32, 40, 48, 64</p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {TOKENS.spacing.map(s => (
          <div key={s} style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ width: s, height: 20, backgroundColor: '#FF6B35', borderRadius: '3px', opacity: 0.15 + (s / 64) * 0.7, flexShrink: 0 }} />
            <div style={{ display: 'flex', gap: '16px' }}>
              <span style={{ fontSize: '12px', fontFamily: 'monospace', color: '#6E6E73', minWidth: '28px' }}>{s}px</span>
              <span style={{ fontSize: '12px', color: '#AEAEB2' }}>= {s / 4} unidades</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

function RadiusSection() {
  return (
    <div>
      <SectionTitle label="04 — Foundation" title="Radio de borde" />
      <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
        {TOKENS.radius.map(r => (
          <div key={r.name} style={{ textAlign: 'center' }}>
            <div style={{
              width: 72, height: 72, borderRadius: r.value,
              border: '1.5px solid #E5E5EA', backgroundColor: '#F5F5F7',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              marginBottom: '8px'
            }}>
              <span style={{ fontSize: '11px', fontFamily: 'monospace', color: '#6E6E73' }}>{r.value}</span>
            </div>
            <p style={{ fontSize: '12px', fontWeight: 600, color: '#1D1D1F' }}>{r.name}</p>
            <p style={{ fontSize: '11px', color: '#AEAEB2', marginTop: '2px' }}>{r.use}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

function ButtonsSection() {
  return (
    <div>
      <SectionTitle label="05 — Componentes" title="Botones" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>

        {/* Primary */}
        <div>
          <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Primary</p>
          <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
            {[
              { label: 'Large', size: '17px', padding: '14px 24px' },
              { label: 'Default', size: '15px', padding: '11px 20px' },
              { label: 'Small', size: '13px', padding: '8px 14px' },
            ].map(b => (
              <button key={b.label} style={{
                backgroundColor: '#FF6B35', color: '#FFFFFF',
                fontSize: b.size, fontWeight: 500, letterSpacing: '-0.01em',
                padding: b.padding, borderRadius: '12px', border: 'none',
                cursor: 'pointer', transition: 'opacity 0.15s',
              }}>{b.label === 'Large' ? 'Publicar mascota' : b.label === 'Default' ? 'Ver publicación' : 'Filtrar'}</button>
            ))}
          </div>
        </div>

        {/* Secondary */}
        <div>
          <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Secondary</p>
          <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
            <button style={{
              backgroundColor: '#F5F5F7', color: '#1D1D1F',
              fontSize: '17px', fontWeight: 500, letterSpacing: '-0.01em',
              padding: '14px 24px', borderRadius: '12px', border: 'none', cursor: 'pointer',
            }}>Registrar mascota</button>
            <button style={{
              backgroundColor: '#F5F5F7', color: '#1D1D1F',
              fontSize: '15px', fontWeight: 500, letterSpacing: '-0.01em',
              padding: '11px 20px', borderRadius: '12px', border: 'none', cursor: 'pointer',
            }}>Mis mascotas</button>
          </div>
        </div>

        {/* Ghost */}
        <div>
          <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Ghost / Outline</p>
          <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
            <button style={{
              backgroundColor: 'transparent', color: '#FF6B35',
              fontSize: '17px', fontWeight: 500, letterSpacing: '-0.01em',
              padding: '13px 24px', borderRadius: '12px', border: '1.5px solid #FF6B35', cursor: 'pointer',
            }}>Contactar dueño</button>
            <button style={{
              backgroundColor: 'transparent', color: '#1D1D1F',
              fontSize: '15px', fontWeight: 400, letterSpacing: '-0.005em',
              padding: '10px 20px', borderRadius: '12px', border: '1px solid #E5E5EA', cursor: 'pointer',
            }}>Cancelar</button>
          </div>
        </div>

        {/* Destructive */}
        <div>
          <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Destructive</p>
          <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
            <button style={{
              backgroundColor: '#FF3B30', color: '#FFFFFF',
              fontSize: '15px', fontWeight: 500, letterSpacing: '-0.01em',
              padding: '11px 20px', borderRadius: '12px', border: 'none', cursor: 'pointer',
            }}>Eliminar publicación</button>
          </div>
        </div>

        {/* Icon buttons */}
        <div>
          <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Icono</p>
          <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
            {[
              { bg: '#FF6B35', stroke: 'white', icon: 'heart' },
              { bg: '#F5F5F7', stroke: '#1D1D1F', icon: 'share' },
              { bg: '#F5F5F7', stroke: '#6E6E73', icon: 'bookmark' },
            ].map((btn, i) => (
              <button key={i} style={{
                width: 44, height: 44, borderRadius: '12px',
                backgroundColor: btn.bg, border: 'none', cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {btn.icon === 'heart' && (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={btn.stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                  </svg>
                )}
                {btn.icon === 'share' && (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={btn.stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                    <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/>
                    <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
                  </svg>
                )}
                {btn.icon === 'bookmark' && (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={btn.stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
                  </svg>
                )}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

function BadgesSection() {
  const statuses = [
    { label: 'Perdida', color: '#FF3B30', bg: '#FFF2F1' },
    { label: 'Encontrada', color: '#34C759', bg: '#F1FFF5' },
    { label: 'Reunida', color: '#5AC8FA', bg: '#F0FAFE' },
    { label: 'Comunidad', color: '#AF52DE', bg: '#F8F0FE' },
    { label: 'Nueva', color: '#FF9500', bg: '#FFF8F0' },
    { label: 'Urgente', color: '#FF3B30', bg: '#FFF2F1' },
  ]

  return (
    <div>
      <SectionTitle label="06 — Componentes" title="Badges y etiquetas" />

      <div style={{ marginBottom: '24px' }}>
        <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Estado de publicación</p>
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
          {statuses.map(s => (
            <span key={s.label} style={{
              fontSize: '12px', fontWeight: 600, letterSpacing: '0.02em',
              padding: '4px 10px', borderRadius: '9999px',
              color: s.color, backgroundColor: s.bg,
            }}>{s.label}</span>
          ))}
        </div>
      </div>

      <div>
        <p style={{ fontSize: '12px', fontWeight: 500, color: '#AEAEB2', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>Tags de características</p>
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
          {['Hembra', 'Pequeño', 'Collar rojo', 'Esterilizada', 'Con chip', 'Pelaje largo', 'Marrón', '3 años'].map(tag => (
            <span key={tag} style={{
              fontSize: '13px', fontWeight: 400, letterSpacing: '0',
              padding: '5px 12px', borderRadius: '9999px',
              color: '#1D1D1F', backgroundColor: '#F5F5F7',
              border: '1px solid #E5E5EA',
            }}>{tag}</span>
          ))}
        </div>
      </div>
    </div>
  )
}

function InputsSection() {
  return (
    <div>
      <SectionTitle label="07 — Componentes" title="Formularios" />
      <div style={{ maxWidth: '420px', display: 'flex', flexDirection: 'column', gap: '20px' }}>

        {/* Default */}
        <div>
          <label style={{ display: 'block', fontSize: '13px', fontWeight: 500, color: '#1D1D1F', marginBottom: '6px' }}>Nombre de la mascota</label>
          <input
            defaultValue="Luna"
            style={{
              width: '100%', padding: '13px 16px', borderRadius: '12px',
              border: '1px solid #E5E5EA', fontSize: '17px', color: '#1D1D1F',
              backgroundColor: '#FFFFFF', outline: 'none', boxSizing: 'border-box',
              fontFamily: 'Inter, sans-serif',
            }}
          />
        </div>

        {/* Focused (simulated) */}
        <div>
          <label style={{ display: 'block', fontSize: '13px', fontWeight: 500, color: '#1D1D1F', marginBottom: '6px' }}>Última ubicación conocida</label>
          <input
            placeholder="Ej: Palermo, Buenos Aires"
            style={{
              width: '100%', padding: '13px 16px', borderRadius: '12px',
              border: '1.5px solid #FF6B35', fontSize: '17px', color: '#1D1D1F',
              backgroundColor: '#FFFFFF', outline: 'none', boxSizing: 'border-box',
              fontFamily: 'Inter, sans-serif', boxShadow: '0 0 0 3px rgba(255,107,53,0.12)',
            }}
          />
          <p style={{ fontSize: '12px', color: '#6E6E73', marginTop: '6px' }}>Ingresá la dirección o arrastrá el mapa</p>
        </div>

        {/* Error */}
        <div>
          <label style={{ display: 'block', fontSize: '13px', fontWeight: 500, color: '#1D1D1F', marginBottom: '6px' }}>Fecha de desaparición</label>
          <input
            defaultValue="32/13/2024"
            style={{
              width: '100%', padding: '13px 16px', borderRadius: '12px',
              border: '1.5px solid #FF3B30', fontSize: '17px', color: '#1D1D1F',
              backgroundColor: '#FFF2F1', outline: 'none', boxSizing: 'border-box',
              fontFamily: 'Inter, sans-serif',
            }}
          />
          <p style={{ fontSize: '12px', color: '#FF3B30', marginTop: '6px' }}>La fecha ingresada no es válida</p>
        </div>

        {/* Textarea */}
        <div>
          <label style={{ display: 'block', fontSize: '13px', fontWeight: 500, color: '#1D1D1F', marginBottom: '6px' }}>Descripción</label>
          <textarea
            rows={4}
            defaultValue="Luna es una Lhasa Apso de 3 años, muy sociable. Lleva collar rojo con medalla plateada y su nombre."
            style={{
              width: '100%', padding: '13px 16px', borderRadius: '12px',
              border: '1px solid #E5E5EA', fontSize: '15px', color: '#1D1D1F',
              backgroundColor: '#FFFFFF', outline: 'none', boxSizing: 'border-box',
              fontFamily: 'Inter, sans-serif', lineHeight: 1.6, resize: 'none',
            }}
          />
        </div>
      </div>
    </div>
  )
}

function CardsSection() {
  return (
    <div>
      <SectionTitle label="08 — Patrones" title="Cards de publicación" />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '16px' }}>

        {/* Lost pet card */}
        <div style={{ borderRadius: '16px', border: '1px solid #E5E5EA', overflow: 'hidden', backgroundColor: '#FFFFFF' }}>
          <div style={{ position: 'relative' }}>
            <img
              src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=220&fit=crop&auto=format"
              alt="Luna, Lhasa Apso perdida"
              style={{ width: '100%', height: 180, objectFit: 'cover', display: 'block' }}
            />
            <div style={{ position: 'absolute', top: 12, left: 12 }}>
              <span style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '0.04em', padding: '4px 10px', borderRadius: '9999px', color: '#FF3B30', backgroundColor: '#FFF2F1' }}>PERDIDA</span>
            </div>
            <div style={{ position: 'absolute', top: 12, right: 12 }}>
              <button style={{ width: 32, height: 32, borderRadius: '9999px', backgroundColor: 'rgba(255,255,255,0.9)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1D1D1F" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
                </svg>
              </button>
            </div>
          </div>
          <div style={{ padding: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
              <div>
                <h3 style={{ fontSize: '17px', fontWeight: 600, color: '#1D1D1F', letterSpacing: '-0.01em' }}>Luna</h3>
                <p style={{ fontSize: '13px', color: '#6E6E73', marginTop: '1px' }}>Lhasa Apso · Hembra · 3 años</p>
              </div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginBottom: '12px' }}>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#AEAEB2" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
              </svg>
              <span style={{ fontSize: '12px', color: '#AEAEB2' }}>Palermo, CABA · hace 6 horas · 800m</span>
            </div>
            <div style={{ display: 'flex', gap: '8px', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ display: 'flex', gap: '6px' }}>
                {['Collar rojo', 'Con chip'].map(t => (
                  <span key={t} style={{ fontSize: '11px', padding: '3px 8px', borderRadius: '9999px', backgroundColor: '#F5F5F7', color: '#6E6E73', border: '1px solid #E5E5EA' }}>{t}</span>
                ))}
              </div>
              <button style={{ fontSize: '13px', fontWeight: 500, color: '#FF6B35', border: 'none', backgroundColor: 'transparent', cursor: 'pointer', padding: 0 }}>Ver más →</button>
            </div>
          </div>
        </div>

        {/* Found pet card */}
        <div style={{ borderRadius: '16px', border: '1px solid #E5E5EA', overflow: 'hidden', backgroundColor: '#FFFFFF' }}>
          <div style={{ position: 'relative' }}>
            <img
              src="https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=220&fit=crop&auto=format"
              alt="Gato encontrado"
              style={{ width: '100%', height: 180, objectFit: 'cover', display: 'block' }}
            />
            <div style={{ position: 'absolute', top: 12, left: 12 }}>
              <span style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '0.04em', padding: '4px 10px', borderRadius: '9999px', color: '#34C759', backgroundColor: '#F1FFF5' }}>ENCONTRADA</span>
            </div>
          </div>
          <div style={{ padding: '16px' }}>
            <div style={{ marginBottom: '8px' }}>
              <h3 style={{ fontSize: '17px', fontWeight: 600, color: '#1D1D1F', letterSpacing: '-0.01em' }}>Gato sin identificar</h3>
              <p style={{ fontSize: '13px', color: '#6E6E73', marginTop: '1px' }}>Gato · Macho · Adulto</p>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginBottom: '12px' }}>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#AEAEB2" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
              </svg>
              <span style={{ fontSize: '12px', color: '#AEAEB2' }}>Recoleta, CABA · hace 2 días</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ display: 'flex', gap: '6px' }}>
                {['Naranja', 'Asustado'].map(t => (
                  <span key={t} style={{ fontSize: '11px', padding: '3px 8px', borderRadius: '9999px', backgroundColor: '#F5F5F7', color: '#6E6E73', border: '1px solid #E5E5EA' }}>{t}</span>
                ))}
              </div>
              <button style={{ fontSize: '13px', fontWeight: 500, color: '#FF6B35', border: 'none', backgroundColor: 'transparent', cursor: 'pointer', padding: 0 }}>Ver más →</button>
            </div>
          </div>
        </div>

        {/* Reunited card */}
        <div style={{ borderRadius: '16px', border: '1px solid #E5E5EA', overflow: 'hidden', backgroundColor: '#FFFFFF' }}>
          <div style={{ position: 'relative' }}>
            <img
              src="https://images.unsplash.com/photo-1477884213360-7e9d7dcc1e48?w=400&h=220&fit=crop&auto=format"
              alt="Max reunido con su familia"
              style={{ width: '100%', height: 180, objectFit: 'cover', display: 'block' }}
            />
            <div style={{ position: 'absolute', top: 12, left: 12 }}>
              <span style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '0.04em', padding: '4px 10px', borderRadius: '9999px', color: '#5AC8FA', backgroundColor: '#F0FAFE' }}>REUNIDA</span>
            </div>
          </div>
          <div style={{ padding: '16px' }}>
            <div style={{ marginBottom: '8px' }}>
              <h3 style={{ fontSize: '17px', fontWeight: 600, color: '#1D1D1F', letterSpacing: '-0.01em' }}>Max</h3>
              <p style={{ fontSize: '13px', color: '#6E6E73', marginTop: '1px' }}>Border Collie · Macho · 5 años</p>
            </div>
            <p style={{ fontSize: '13px', color: '#6E6E73', lineHeight: 1.5 }}>¡Max volvió a casa después de 4 días! Gracias a toda la comunidad Yago. 🐾</p>
          </div>
        </div>
      </div>
    </div>
  )
}

function FeedSection() {
  return (
    <div>
      <SectionTitle label="09 — Patrones" title="Feed de comunidad" />
      <div style={{ maxWidth: '480px', display: 'flex', flexDirection: 'column', gap: '1px', border: '1px solid #E5E5EA', borderRadius: '16px', overflow: 'hidden' }}>

        {/* Feed item 1 */}
        <div style={{ padding: '16px', backgroundColor: '#FFFFFF' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
            <div style={{ width: 36, height: 36, borderRadius: '9999px', backgroundColor: '#F5F5F7', overflow: 'hidden', flexShrink: 0 }}>
              <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=72&h=72&fit=crop&auto=format" alt="Martín García" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>
            <div style={{ flex: 1 }}>
              <p style={{ fontSize: '14px', fontWeight: 600, color: '#1D1D1F' }}>Martín García</p>
              <p style={{ fontSize: '12px', color: '#AEAEB2' }}>hace 2 horas</p>
            </div>
            <span style={{ fontSize: '11px', fontWeight: 600, padding: '3px 8px', borderRadius: '9999px', color: '#FF3B30', backgroundColor: '#FFF2F1' }}>PERDIDA</span>
          </div>
          <p style={{ fontSize: '15px', color: '#1D1D1F', lineHeight: 1.5, marginBottom: '12px' }}>
            Se perdió mi perra Luna en Palermo. Lhasa Apso, collar rojo. Por favor si la ven avísenme 🙏
          </p>
          <div style={{ borderTop: '1px solid #E5E5EA', paddingTop: '12px', display: 'flex', gap: '20px' }}>
            {[
              { icon: '♡', label: '24', active: false },
              { icon: '💬', label: '8 respuestas', active: false },
              { icon: '📍', label: 'Ver en mapa', active: false },
            ].map((action, i) => (
              <button key={i} style={{ display: 'flex', alignItems: 'center', gap: '5px', fontSize: '13px', color: '#6E6E73', border: 'none', backgroundColor: 'transparent', cursor: 'pointer', padding: 0 }}>
                <span>{action.icon}</span>
                <span>{action.label}</span>
              </button>
            ))}
          </div>
        </div>

        <div style={{ height: '1px', backgroundColor: '#E5E5EA' }} />

        {/* Feed item 2 */}
        <div style={{ padding: '16px', backgroundColor: '#FFFFFF' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
            <div style={{ width: 36, height: 36, borderRadius: '9999px', backgroundColor: '#F5F5F7', overflow: 'hidden', flexShrink: 0 }}>
              <img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=72&h=72&fit=crop&auto=format" alt="Sara López" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>
            <div style={{ flex: 1 }}>
              <p style={{ fontSize: '14px', fontWeight: 600, color: '#1D1D1F' }}>Sara López</p>
              <p style={{ fontSize: '12px', color: '#AEAEB2' }}>ayer · 18:45</p>
            </div>
            <span style={{ fontSize: '11px', fontWeight: 600, padding: '3px 8px', borderRadius: '9999px', color: '#5AC8FA', backgroundColor: '#F0FAFE' }}>REUNIDA</span>
          </div>
          <p style={{ fontSize: '15px', color: '#1D1D1F', lineHeight: 1.5 }}>
            ¡Rocky volvió a casa! 5 días desaparecido y gracias a Yago lo encontramos.
            <span style={{ color: '#FF6B35', fontWeight: 500 }}> Infinitas gracias a toda la comunidad</span> ❤️
          </p>
        </div>
      </div>
    </div>
  )
}

function NavSection() {
  const [active, setActive] = useState('feed')
  const tabs = [
    { id: 'feed', label: 'Inicio', icon: 'home' },
    { id: 'search', label: 'Buscar', icon: 'search' },
    { id: 'publish', label: 'Publicar', icon: 'plus' },
    { id: 'map', label: 'Mapa', icon: 'map' },
    { id: 'profile', label: 'Perfil', icon: 'user' },
  ]

  const Icon = ({ name, active }: { name: string; active: boolean }) => {
    const stroke = active ? '#FF6B35' : '#AEAEB2'
    const w = 22
    if (name === 'home') return <svg width={w} height={w} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
    if (name === 'search') return <svg width={w} height={w} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
    if (name === 'plus') return <svg width={w} height={w} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
    if (name === 'map') return <svg width={w} height={w} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>
    if (name === 'user') return <svg width={w} height={w} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
    return null
  }

  return (
    <div>
      <SectionTitle label="10 — Patrones" title="Navegación" />
      <div style={{ maxWidth: '390px' }}>
        <div style={{
          backgroundColor: 'rgba(255,255,255,0.9)',
          backdropFilter: 'blur(20px)',
          borderTop: '1px solid #E5E5EA',
          borderRadius: '16px',
          padding: '8px 0 4px',
          display: 'flex',
          justifyContent: 'space-around',
          border: '1px solid #E5E5EA',
        }}>
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActive(tab.id)}
              style={{
                display: 'flex', flexDirection: 'column', alignItems: 'center',
                gap: '3px', padding: '4px 12px', border: 'none',
                backgroundColor: 'transparent', cursor: 'pointer',
              }}
            >
              {tab.id === 'publish'
                ? <div style={{ width: 44, height: 44, borderRadius: '14px', backgroundColor: '#FF6B35', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '2px' }}>
                    <Icon name={tab.icon} active={true} />
                  </div>
                : <Icon name={tab.icon} active={active === tab.id} />
              }
              <span style={{ fontSize: '10px', fontWeight: active === tab.id ? 600 : 400, color: active === tab.id ? '#FF6B35' : '#AEAEB2', letterSpacing: '0.01em' }}>
                {tab.label}
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}

// ─── Main ─────────────────────────────────────────────────────────────────────

export default function App() {
  return (
    <div style={{ backgroundColor: '#FFFFFF', minHeight: '100%' }}>
      <div style={{ maxWidth: '900px', margin: '0 auto', padding: '64px 32px 120px' }}>
        <HeroSection />
        <div style={{ height: '56px' }} />
        <ColorsSection />
        <Divider />
        <TypographySection />
        <Divider />
        <SpacingSection />
        <Divider />
        <RadiusSection />
        <Divider />
        <ButtonsSection />
        <Divider />
        <BadgesSection />
        <Divider />
        <InputsSection />
        <Divider />
        <CardsSection />
        <Divider />
        <FeedSection />
        <Divider />
        <NavSection />
      </div>
    </div>
  )
}
