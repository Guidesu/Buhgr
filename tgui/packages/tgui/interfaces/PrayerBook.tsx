// The prayer book: write a prayer to say now, or learn prayers by heart.
// Backend: modular_dreamvalley/prayer/book.dm

import { type CSSProperties, useEffect, useRef, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  BUTTON_BG,
  cardStyle,
  FONT_SMALL,
  FONT_TINY,
  INK,
  INK_FAINT,
  INK_SOFT,
  inkButtonStyle,
  inkInputStyle,
  pageStyle,
  PARCHMENT_DEEP,
  rulerStyle,
  SEAL_GREEN,
  SEAL_RED,
  SERIF,
  sectionHeaderStyle,
  subtitleStyle,
  titleStyle,
} from './common/parchment';

type Preset = {
  name: string;
  text: string;
  shape: string;
  icon: string;
  standalone: BooleanLike;
};

type Shape = {
  id: string;
  name: string;
  desc: string;
  power: number;
  cost: number;
  time: number;
  clicks: BooleanLike;
};

type Request = {
  asked: string;
  intent: string;
  strength: number;
  refused: BooleanLike;
  harmful?: BooleanLike;
};

type Data = {
  mode: 'compose' | 'edit';
  kind: 'prayer' | 'incantation';
  who: string | null;
  god: string;
  domain: string | null;
  colour: string;
  text: string;
  shape: string;
  selected: number;
  presets: Preset[];
  counsel: string;
  summary: {
    requests: Request[];
    cost?: number;
    have?: number | null;
    eased?: string[];
    cost_label?: string;
  };
  in_game: BooleanLike;
  icons: { key: string; img: string }[];
  shapes: Shape[];
  max_presets: number;
  max_name: number;
  max_text: number;
  min_text: number;
};

const SHAPE_GLYPHS: Record<string, string> = {
  targeted: '✋',
  self: '☉',
  projectile: '➶',
  burst: '✺',
  area: '◎',
  field: '❂',
  cone: '◭',
  beam: '━',
};

const strengthWord = (s: number) => {
  if (s < 0.3) return 'faint';
  if (s < 0.8) return 'grudging';
  if (s < 1.3) return 'as asked';
  if (s < 1.9) return 'strong';
  return 'mighty';
};

const counselCss = `
.pb-counsel p { margin: 0 0 7px 0; }
.pb-counsel .good { color: ${SEAL_GREEN}; }
.pb-counsel .warn { color: ${SEAL_RED}; }
.pb-counsel .dim { color: ${INK_SOFT}; font-size: 0.92em; }
.pb-counsel .ask { font-weight: bold; }
`;

export const PrayerBook = () => {
  const { data } = useBackend<Data>();
  const compose = data.mode === 'compose';
  const arcane = data.kind === 'incantation';
  const word = arcane ? 'incantation' : 'prayer';
  const title = compose
    ? `${arcane ? 'An incantation' : 'A prayer'}, for ${data.who || 'whomever I choose'}`
    : `${arcane ? 'Incantations' : 'Prayers'} Known by Heart`;
  return (
    <Window title={arcane ? 'Incantation' : 'Prayer'} width={1040} height={760} theme="parchment">
      <Window.Content scrollable>
        <style>{counselCss}</style>
        <div style={pageStyle}>
          <div style={titleStyle}>{title}</div>
          <div style={subtitleStyle}>
            {arcane ? <>spoken to {data.god}</> : <>to {data.god}</>}
            {!arcane && data.domain ? <> &middot; of the {data.domain}</> : null}
          </div>
          <hr style={rulerStyle} />
          <div style={{ display: 'flex', gap: '18px', alignItems: 'flex-start' }}>
            <PresetList />
            <div style={{ flex: 1, minWidth: 0 }}>
              {compose || data.selected ? (
                <Editor key={`${data.mode}-${data.selected}`} />
              ) : (
                <EmptyPage />
              )}
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

const EmptyPage = () => {
  const { data, act } = useBackend<Data>();
  return (
    <div style={{ ...cardStyle, textAlign: 'center', padding: '40px 20px' }}>
      <div style={{ fontStyle: 'italic', color: INK_SOFT, marginBottom: 12 }}>
        {data.kind === 'incantation'
          ? 'An incantation worked often enough is known by heart. Learn up to '
          : 'A prayer said often enough is known by heart. Learn up to '}
        {data.max_presets}: say them from{' '}
        {data.kind === 'incantation' ? "Incant's" : "Pray's"} alt mode, or
        keep them as spells of their own.
      </div>
      <button
        type="button"
        style={inkButtonStyle({})}
        onClick={() => act('new')}
      >
        Learn a new {data.kind === 'incantation' ? 'incantation' : 'prayer'}
      </button>
    </div>
  );
};

const PresetList = () => {
  const { data, act } = useBackend<Data>();
  const compose = data.mode === 'compose';
  const iconFor = (key: string) =>
    data.icons.find((i) => i.key === key)?.img;
  const shapeFor = (id: string) => data.shapes.find((s) => s.id === id);
  return (
    <div style={{ width: 250, flexShrink: 0 }}>
      <div style={sectionHeaderStyle}>
        {compose
          ? 'Known by heart'
          : data.kind === 'incantation'
            ? 'My incantations'
            : 'My prayers'}
      </div>
      {!data.presets.length && (
        <div style={{ fontStyle: 'italic', color: INK_SOFT, fontSize: FONT_SMALL }}>
          {compose
            ? 'I know no prayers by heart yet.'
            : 'None yet.'}
        </div>
      )}
      {data.presets.map((p, i) => {
        const index = i + 1;
        const active = !compose && data.selected === index;
        const img = iconFor(p.icon);
        const shape = shapeFor(p.shape);
        return (
          <div
            key={index}
            title={compose ? 'Start from these words' : p.text}
            onClick={() => act(compose ? 'load' : 'select', { index })}
            style={{
              display: 'flex',
              gap: 8,
              alignItems: 'center',
              padding: '5px 6px',
              marginBottom: 4,
              cursor: 'pointer',
              border: `1px solid ${active ? data.colour : INK_FAINT}`,
              background: active ? PARCHMENT_DEEP : BUTTON_BG,
              borderRadius: 2,
              boxShadow: active ? `inset 3px 0 0 ${data.colour}` : undefined,
            }}
          >
            <div style={{ width: 32, height: 32, flexShrink: 0 }}>
              {img && (
                <img
                  src={`data:image/png;base64,${img}`}
                  style={{ width: 32, height: 32, imageRendering: 'pixelated' }}
                />
              )}
            </div>
            <div style={{ minWidth: 0, flex: 1 }}>
              <div
                style={{
                  fontWeight: 'bold',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                }}
              >
                {index}. {p.name}
              </div>
              <div style={{ fontSize: FONT_TINY, color: INK_SOFT }}>
                {SHAPE_GLYPHS[p.shape] || ''} {shape?.name || p.shape}
                {p.standalone
                  ? ' · own spell'
                  : data.kind === 'incantation'
                    ? ' · under Incant'
                    : ' · under Pray'}
              </div>
            </div>
          </div>
        );
      })}
      {!compose && (
        <button
          type="button"
          disabled={data.presets.length >= data.max_presets}
          style={{
            ...inkButtonStyle({ disabled: data.presets.length >= data.max_presets }),
            width: '100%',
            marginTop: 6,
          }}
          onClick={() => act('new')}
        >
          + Learn a new {data.kind === 'incantation' ? 'incantation' : 'prayer'} (
          {data.presets.length}/{data.max_presets})
        </button>
      )}
      {!compose && (
        <div style={{ fontSize: FONT_TINY, color: INK_SOFT, marginTop: 10, fontStyle: 'italic' }}>
          {data.kind === 'incantation'
            ? 'Incantations kept under Incant are cycled with the Toggle Spell Alt Mode key while Incant is readied, in this order.'
            : 'Prayers kept under Pray are cycled with the Toggle Spell Alt Mode key while Pray is readied, in this order.'}
        </div>
      )}
    </div>
  );
};

const useDebouncedSend = (value: string, send: (v: string) => void, wait = 400) => {
  const first = useRef(true);
  useEffect(() => {
    if (first.current) {
      first.current = false;
      return;
    }
    const t = setTimeout(() => send(value), wait);
    return () => clearTimeout(t);
  }, [value]);
};

const Editor = () => {
  const { data, act } = useBackend<Data>();
  const compose = data.mode === 'compose';
  const preset = !compose ? data.presets[data.selected - 1] : null;
  const [text, setText] = useState(data.text);
  const [name, setName] = useState(preset?.name || '');

  // Loading a saved prayer in compose mode changes the text server-side.
  const lastServerText = useRef(data.text);
  useEffect(() => {
    if (data.text !== lastServerText.current) {
      lastServerText.current = data.text;
      if (data.text !== text) setText(data.text);
    }
  }, [data.text]);

  useDebouncedSend(text, (v) => {
    lastServerText.current = v;
    act('set_text', { text: v });
  });
  useDebouncedSend(name, (v) => act('rename', { name: v }), 500);

  const tooShort = text.trim().length < data.min_text;

  return (
    <div>
      {preset && (
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 10 }}>
          <input
            value={name}
            maxLength={data.max_name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Name this prayer"
            style={{ ...inkInputStyle, flex: 1, fontWeight: 'bold', fontSize: '15px' }}
          />
          <button
            type="button"
            title="Move earlier"
            style={inkButtonStyle({ disabled: data.selected <= 1 })}
            onClick={() => act('move', { dir: 'up' })}
          >
            ▲
          </button>
          <button
            type="button"
            title="Move later"
            style={inkButtonStyle({ disabled: data.selected >= data.presets.length })}
            onClick={() => act('move', { dir: 'down' })}
          >
            ▼
          </button>
          <button
            type="button"
            style={inkButtonStyle({ color: SEAL_RED })}
            onClick={() => act('delete')}
          >
            Forget
          </button>
        </div>
      )}

      <textarea
        value={text}
        maxLength={data.max_text}
        autoFocus
        onChange={(e) => setText(e.target.value)}
        placeholder={
          data.kind === 'incantation'
            ? 'Say plainly what the working should do, and to whom. Fire, stone, frost - name what you draw on.'
            : `Write as you would speak to ${data.god}. Name them, ask plainly, and mind your tone.`
        }
        style={{
          ...inkInputStyle,
          width: '100%',
          boxSizing: 'border-box',
          height: 110,
          resize: 'none',
          fontSize: '15px',
          lineHeight: 1.5,
          padding: 8,
          borderLeft: `3px solid ${data.colour}`,
        }}
      />
      <div style={{ fontSize: FONT_TINY, color: INK_SOFT, textAlign: 'right' }}>
        {text.length}/{data.max_text}
      </div>

      {preset && <ShapePicker />}
      {preset && <IconPicker />}

      <Counsel />

      {preset && (
        <label
          style={{
            display: 'flex',
            gap: 8,
            alignItems: 'center',
            marginTop: 10,
            cursor: 'pointer',
          }}
        >
          <input
            type="checkbox"
            checked={!!preset.standalone}
            onChange={() => act('toggle_standalone')}
          />
          <span>
            <b>Keep it as its own spell</b>
            <span style={{ color: INK_SOFT, fontSize: FONT_SMALL }}>
              {' '}
              - a button of its own with this name and sign, instead of a
              mode of Pray.
            </span>
          </span>
        </label>
      )}

      {compose && (
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
          <button
            type="button"
            style={inkButtonStyle({ disabled: tooShort, color: data.colour })}
            disabled={tooShort}
            onClick={() => act('pray', { text })}
          >
            {data.kind === 'incantation' ? 'Incant' : 'Pray'}
            {data.summary.cost
              ? ` (${data.summary.cost} ${data.summary.cost_label || 'devotion'})`
              : ''}
          </button>
        </div>
      )}
    </div>
  );
};

const ShapePicker = () => {
  const { data, act } = useBackend<Data>();
  return (
    <div>
      <div style={sectionHeaderStyle}>Shape</div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(4, 1fr)',
          gap: 6,
        }}
      >
        {data.shapes.map((s) => {
          const active = data.shape === s.id;
          return (
            <div
              key={s.id}
              title={s.desc}
              onClick={() => act('set_shape', { shape: s.id })}
              style={{
                border: `1px solid ${active ? data.colour : INK_FAINT}`,
                background: active ? PARCHMENT_DEEP : BUTTON_BG,
                boxShadow: active ? `0 0 0 1px ${data.colour}` : undefined,
                padding: '6px 6px 5px 6px',
                cursor: 'pointer',
                borderRadius: 2,
                textAlign: 'center',
              }}
            >
              <div style={{ fontSize: '20px', color: active ? data.colour : INK_SOFT }}>
                {SHAPE_GLYPHS[s.id] || '•'}
              </div>
              <div style={{ fontWeight: 'bold', fontSize: FONT_SMALL }}>{s.name}</div>
              <div style={{ fontSize: FONT_TINY, color: INK_SOFT }}>
                strength ×{s.power} · cost ×{s.cost}
                <br />
                time ×{s.time} · {s.clicks ? 'aimed' : 'instant'}
              </div>
            </div>
          );
        })}
      </div>
      <div style={{ fontSize: FONT_SMALL, color: INK_SOFT, fontStyle: 'italic', marginTop: 4 }}>
        {data.shapes.find((s) => s.id === data.shape)?.desc}
      </div>
    </div>
  );
};

const IconPicker = () => {
  const { data, act } = useBackend<Data>();
  const preset = data.presets[data.selected - 1];
  const [open, setOpen] = useState(false);
  const current = data.icons.find((i) => i.key === preset?.icon);
  return (
    <div>
      <div style={{ ...sectionHeaderStyle, display: 'flex', alignItems: 'center', gap: 8 }}>
        <span>Sign</span>
        {current && (
          <img
            src={`data:image/png;base64,${current.img}`}
            style={{ width: 32, height: 32, imageRendering: 'pixelated' }}
          />
        )}
        <span style={{ fontSize: FONT_SMALL, fontWeight: 'normal', color: INK_SOFT }}>
          {preset?.icon}
        </span>
        <span style={{ flex: 1 }} />
        <button
          type="button"
          style={{ ...inkButtonStyle({}), fontSize: FONT_SMALL }}
          onClick={() => setOpen(!open)}
        >
          {open ? 'Close' : 'Choose'}
        </button>
      </div>
      {open && (
        <div
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            gap: 4,
            maxHeight: 150,
            overflowY: 'auto',
            padding: 4,
            border: `1px dashed ${INK_FAINT}`,
          }}
        >
          {data.icons.map((i) => {
            const active = i.key === preset?.icon;
            return (
              <div
                key={i.key}
                title={i.key}
                onClick={() => act('set_icon', { icon: i.key })}
                style={{
                  width: 36,
                  height: 36,
                  padding: 1,
                  cursor: 'pointer',
                  border: `1px solid ${active ? data.colour : 'transparent'}`,
                  background: active ? PARCHMENT_DEEP : undefined,
                }}
              >
                <img
                  src={`data:image/png;base64,${i.img}`}
                  style={{ width: 32, height: 32, imageRendering: 'pixelated' }}
                />
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

const Counsel = () => {
  const { data } = useBackend<Data>();
  const s = data.summary;
  const hasCost = typeof s.cost === 'number';
  const have = typeof s.have === 'number' ? s.have : null;
  const barStyle = (pct: number, col: string): CSSProperties => ({
    width: `${Math.max(0, Math.min(100, pct))}%`,
    height: '100%',
    background: col,
    transition: 'width 200ms',
  });
  return (
    <div>
      <div style={sectionHeaderStyle}>The counsel</div>
      {!!s.requests.length && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 8 }}>
          {s.requests.map((r, i) => (
            <div
              key={i}
              style={{
                border: `1px solid ${r.refused ? SEAL_RED : INK_FAINT}`,
                background: BUTTON_BG,
                padding: '3px 8px',
                borderRadius: 2,
                minWidth: 130,
              }}
            >
              <div style={{ fontWeight: 'bold', fontSize: FONT_SMALL, color: r.refused ? SEAL_RED : INK }}>
                {r.asked}
                {r.harmful ? ' ⚔' : ''}
              </div>
              <div style={{ height: 5, background: PARCHMENT_DEEP, marginTop: 2 }}>
                <div
                  style={barStyle(
                    (r.strength / 2) * 100,
                    r.refused ? SEAL_RED : r.strength < 0.3 ? SEAL_RED : data.colour,
                  )}
                />
              </div>
              <div style={{ fontSize: FONT_TINY, color: INK_SOFT }}>
                {r.refused ? 'refused' : strengthWord(r.strength)}
              </div>
            </div>
          ))}
        </div>
      )}
      {hasCost && (
        <div style={{ marginBottom: 8 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: FONT_SMALL }}>
            <span>
              <b>{s.cost}</b> {s.cost_label || 'devotion'}
            </span>
            {have !== null && <span style={{ color: INK_SOFT }}>I hold {have}</span>}
          </div>
          {have !== null && (
            <div
              style={{
                height: 7,
                background: PARCHMENT_DEEP,
                border: `1px solid ${INK_FAINT}`,
                position: 'relative',
              }}
            >
              <div
                style={barStyle(
                  have ? ((s.cost || 0) / have) * 100 : 100,
                  (s.cost || 0) > have ? SEAL_RED : data.colour,
                )}
              />
            </div>
          )}
        </div>
      )}
      <div
        className="pb-counsel"
        style={{
          borderLeft: `2px solid ${data.colour}`,
          padding: '4px 10px',
          fontFamily: SERIF,
          fontSize: FONT_SMALL,
          lineHeight: 1.5,
          color: INK,
          minHeight: 80,
        }}
        dangerouslySetInnerHTML={{ __html: data.counsel }}
      />
    </div>
  );
};
