// The NPC Workshop: make, keep and spawn NPC people.
// Backend: modular_dreamvalley/npc/workshop.dm

import { useEffect, useRef, useState } from 'react';
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
  PARCHMENT_DEEP,
  pageStyle,
  rulerStyle,
  SEAL_GREEN,
  SEAL_RED,
  sectionHeaderStyle,
  subtitleStyle,
  titleStyle,
} from './common/parchment';

type Option = { path: string; name: string };
type Domain = Option & { gods: Option[] };
type Trait = { id: string; low: string; high: string };

type Record = {
  id: string;
  name: string;
  gender: string;
  age: string;
  species: string;
  job: string | null;
  origin: string | null;
  domain: string | null;
  god: string | null;
  traits: { [id: string]: number };
  speech: string;
  backstory: string;
  goals: string;
  memories: string[];
  relationships: { [name: string]: [number, string] };
  autospawn: BooleanLike;
  home: string;
  personality: string;
  spawned: BooleanLike;
  saved: BooleanLike;
  doing?: string;
  why?: string;
  needs?: { [need: string]: number };
  log?: string[];
  mood?: string;
  house?: (string | number)[] | null;
};

type Data = {
  records: {
    id: string;
    name: string;
    summary: string;
    spawned: BooleanLike;
    autospawn: BooleanLike;
  }[];
  editing: Record | null;
  mind_online: BooleanLike;
  mind_answered: number;
  mind_failed: number;
  mind_latency: number;
  mind_queue: number;
  test_reply: string | null;
  test_pending: BooleanLike;
  species: Option[];
  origins: Option[];
  domains: Domain[];
  jobs: { [title: string]: string };
  traits: Trait[];
  ages: string[];
  areas: string[];
};

const labelStyle = {
  fontSize: FONT_SMALL,
  color: INK_SOFT,
  display: 'block',
  marginTop: 8,
};

const selectStyle = { ...inkInputStyle, width: '100%', boxSizing: 'border-box' as const };

export const NpcWorkshop = () => {
  const { data } = useBackend<Data>();
  return (
    <Window title="NPC Workshop" width={1100} height={780} theme="parchment">
      <Window.Content scrollable>
        <div style={pageStyle}>
          <div style={titleStyle}>The NPC Workshop</div>
          <div style={subtitleStyle}>
            people of Palimpseste, made by hand and kept on file
          </div>
          <MindStatus />
          <hr style={rulerStyle} />
          <div style={{ display: 'flex', gap: 18, alignItems: 'flex-start' }}>
            <RecordList />
            <div style={{ flex: 1, minWidth: 0 }}>
              {data.editing ? (
                <Editor key={data.editing.id} />
              ) : (
                <div style={{ ...cardStyle, textAlign: 'center', padding: 40, color: INK_SOFT, fontStyle: 'italic' }}>
                  Pick someone on the left, make a new person, or roll a
                  stranger.
                </div>
              )}
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

const MindStatus = () => {
  const { data } = useBackend<Data>();
  return (
    <div style={{ textAlign: 'center', fontSize: FONT_SMALL }}>
      <span style={{ color: data.mind_online ? SEAL_GREEN : SEAL_RED, fontWeight: 'bold' }}>
        {data.mind_online ? '● The mind is awake' : '○ The mind is asleep'}
      </span>
      <span style={{ color: INK_SOFT }}>
        {data.mind_online
          ? ` · ${data.mind_answered} answered · ${data.mind_failed} failed · last took ${data.mind_latency}s · ${data.mind_queue} waiting`
          : ' · run tools/dreamvalley/npc_ai/start_npc_ai.bat to wake it. NPCs still spawn without it.'}
      </span>
    </div>
  );
};

const RecordList = () => {
  const { data, act } = useBackend<Data>();
  return (
    <div style={{ width: 260, flexShrink: 0 }}>
      <div style={{ display: 'flex', gap: 6, marginBottom: 8 }}>
        <button type="button" style={{ ...inkButtonStyle({}), flex: 1 }} onClick={() => act('new')}>
          + New
        </button>
        <button type="button" style={{ ...inkButtonStyle({}), flex: 1 }} onClick={() => act('roll')}>
          🎲 Stranger
        </button>
      </div>
      {!data.records.length && (
        <div style={{ fontStyle: 'italic', color: INK_SOFT, fontSize: FONT_SMALL }}>
          Nobody yet.
        </div>
      )}
      {data.records.map((r) => {
        const active = data.editing?.id === r.id;
        return (
          <div
            key={r.id}
            onClick={() => act('select', { id: r.id })}
            style={{
              padding: '5px 8px',
              marginBottom: 4,
              cursor: 'pointer',
              border: `1px solid ${active ? INK : INK_FAINT}`,
              background: active ? PARCHMENT_DEEP : BUTTON_BG,
              borderRadius: 2,
            }}
          >
            <div style={{ fontWeight: 'bold' }}>
              {r.name}
              {r.spawned ? <span style={{ color: SEAL_GREEN }}> ●</span> : null}
            </div>
            <div style={{ fontSize: FONT_TINY, color: INK_SOFT }}>
              {r.summary}
              {r.autospawn ? ' · appears each round' : ''}
            </div>
          </div>
        );
      })}
    </div>
  );
};

/** A text field that tells the server about changes a moment after typing stops. */
const Field = (props: {
  value: string;
  field: string;
  multiline?: boolean;
  rows?: number;
  placeholder?: string;
}) => {
  const { act } = useBackend<Data>();
  const [value, setValue] = useState(props.value);
  const first = useRef(true);
  useEffect(() => {
    if (first.current) {
      first.current = false;
      return;
    }
    const t = setTimeout(() => act('set', { field: props.field, value }), 500);
    return () => clearTimeout(t);
  }, [value]);
  const style = { ...inkInputStyle, width: '100%', boxSizing: 'border-box' as const };
  return props.multiline ? (
    <textarea
      value={value}
      rows={props.rows || 3}
      placeholder={props.placeholder}
      onChange={(e) => setValue(e.target.value)}
      style={{ ...style, resize: 'vertical' }}
    />
  ) : (
    <input
      value={value}
      placeholder={props.placeholder}
      onChange={(e) => setValue(e.target.value)}
      style={style}
    />
  );
};

const Select = (props: {
  value: string;
  field: string;
  options: { value: string; label: string }[];
}) => {
  const { act } = useBackend<Data>();
  return (
    <select
      value={props.value}
      onChange={(e) => act('set', { field: props.field, value: e.target.value })}
      style={selectStyle}
    >
      {props.options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
        </option>
      ))}
    </select>
  );
};

const Editor = () => {
  const { data, act } = useBackend<Data>();
  const e = data.editing as Record;
  const domain = data.domains.find((d) => d.path === (e.domain || ''));
  return (
    <div>
      <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginBottom: 10 }}>
        <button type="button" style={inkButtonStyle({ color: SEAL_GREEN })} onClick={() => act('save')}>
          {e.saved ? 'Save' : 'Save (new)'}
        </button>
        <button type="button" style={inkButtonStyle({})} onClick={() => act('spawn')}>
          {e.spawned ? 'Respawn here' : 'Spawn here'}
        </button>
        {!!e.spawned && (
          <>
            <button type="button" style={inkButtonStyle({})} onClick={() => act('jump')}>
              Go to them
            </button>
            <button type="button" style={inkButtonStyle({})} onClick={() => act('despawn')}>
              Despawn
            </button>
          </>
        )}
        <button type="button" style={inkButtonStyle({})} onClick={() => act('clone')}>
          Clone
        </button>
        <span style={{ flex: 1 }} />
        <button type="button" style={inkButtonStyle({ color: SEAL_RED })} onClick={() => act('delete')}>
          Delete
        </button>
      </div>

      {!!e.spawned && e.doing && <LiveView />}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '0 12px' }}>
        <div>
          <span style={labelStyle}>Name</span>
          <Field value={e.name} field="name" />
        </div>
        <div>
          <span style={labelStyle}>Sex</span>
          <Select value={e.gender} field="gender" options={[{ value: 'male', label: 'Man' }, { value: 'female', label: 'Woman' }]} />
        </div>
        <div>
          <span style={labelStyle}>Age</span>
          <Select value={e.age} field="age" options={data.ages.map((a) => ({ value: a, label: a }))} />
        </div>
        <div>
          <span style={labelStyle}>Species</span>
          <Select value={e.species} field="species" options={data.species.map((s) => ({ value: s.path, label: s.name }))} />
        </div>
        <div>
          <span style={labelStyle}>Origin</span>
          <Select value={e.origin || ''} field="origin" options={data.origins.map((o) => ({ value: o.path, label: o.name }))} />
        </div>
        <div>
          <span style={labelStyle}>Work (outfit and skills)</span>
          <Select
            value={e.job || ''}
            field="job"
            options={[{ value: '', label: 'No trade' }, ...Object.keys(data.jobs).map((t) => ({ value: t, label: t }))]}
          />
        </div>
        <div>
          <span style={labelStyle}>Domain</span>
          <Select value={e.domain || ''} field="domain" options={data.domains.map((d) => ({ value: d.path, label: d.name }))} />
        </div>
        <div>
          <span style={labelStyle}>God</span>
          <Select
            value={e.god || ''}
            field="god"
            options={[{ value: '', label: domain?.gods.length ? 'None in particular' : '-' }, ...(domain?.gods || []).map((g) => ({ value: g.path, label: g.name }))]}
          />
        </div>
        <div>
          <span style={labelStyle}>Home (area, for round start)</span>
          <select value={e.home} onChange={(ev) => act('set', { field: 'home', value: ev.target.value })} style={selectStyle}>
            <option value="">Nowhere set</option>
            {data.areas.map((a) => (
              <option key={a} value={a}>
                {a}
              </option>
            ))}
          </select>
        </div>
      </div>
      <label style={{ display: 'flex', gap: 6, alignItems: 'center', marginTop: 8, cursor: 'pointer' }}>
        <input type="checkbox" checked={!!e.autospawn} onChange={() => act('set', { field: 'autospawn' })} />
        <span>Appears at home every round</span>
      </label>

      <div style={sectionHeaderStyle}>Temperament</div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px 18px' }}>
        {data.traits.map((t) => (
          <TraitSlider key={t.id} trait={t} value={e.traits[t.id] || 0} />
        ))}
      </div>
      <div style={{ fontSize: FONT_SMALL, color: INK_SOFT, fontStyle: 'italic', marginTop: 4 }}>
        In a word: {e.personality}.
      </div>

      <div style={sectionHeaderStyle}>Voice and story</div>
      <span style={labelStyle}>How they talk</span>
      <Field value={e.speech} field="speech" placeholder="curt, swears, calls everyone lad" />
      <span style={labelStyle}>Their past</span>
      <Field value={e.backstory} field="backstory" multiline rows={4} placeholder="Where they came from, what happened to them, what they hide." />
      <span style={labelStyle}>What they want</span>
      <Field value={e.goals} field="goals" multiline rows={2} placeholder="Pay off the debt. Find their brother. Never be cold again." />

      {(!!e.memories.length || !!Object.keys(e.relationships).length) && (
        <>
          <div style={sectionHeaderStyle}>What they remember</div>
          {e.memories.map((m, i) => (
            <div key={i} style={{ fontSize: FONT_SMALL }}>
              • {m}
            </div>
          ))}
          {Object.keys(e.relationships).map((name) => (
            <div key={name} style={{ fontSize: FONT_SMALL }}>
              <b>{name}</b>: {e.relationships[name][1]} ({e.relationships[name][0]})
            </div>
          ))}
          <button type="button" style={{ ...inkButtonStyle({ color: SEAL_RED }), marginTop: 6 }} onClick={() => act('set', { field: 'forget' })}>
            Make them forget everything
          </button>
        </>
      )}

      <TestTalk />
    </div>
  );
};

const TraitSlider = (props: { trait: Trait; value: number }) => {
  const { act } = useBackend<Data>();
  const [v, setV] = useState(props.value);
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: FONT_SMALL }}>
      <span style={{ width: 72, textAlign: 'right', color: v < -20 ? INK : INK_SOFT }}>{props.trait.low}</span>
      <input
        type="range"
        min={-100}
        max={100}
        step={10}
        value={v}
        onChange={(e) => setV(Number(e.target.value))}
        onMouseUp={() => act('set_trait', { trait: props.trait.id, value: v })}
        onKeyUp={() => act('set_trait', { trait: props.trait.id, value: v })}
        style={{ flex: 1 }}
      />
      <span style={{ width: 80, color: v > 20 ? INK : INK_SOFT }}>{props.trait.high}</span>
    </div>
  );
};

const TestTalk = () => {
  const { data, act } = useBackend<Data>();
  const [text, setText] = useState('');
  return (
    <div>
      <div style={sectionHeaderStyle}>Speak with them</div>
      <div style={{ fontSize: FONT_TINY, color: INK_SOFT, marginBottom: 4 }}>
        A quick test of their voice through the mind, as if a stranger walked
        up to them. Nothing here is remembered.
      </div>
      <div style={{ display: 'flex', gap: 6 }}>
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && text.trim()) act('test', { text });
          }}
          placeholder="Good evening. Do you know the road north?"
          style={{ ...inkInputStyle, flex: 1 }}
        />
        <button
          type="button"
          disabled={!!data.test_pending || !text.trim()}
          style={inkButtonStyle({ disabled: !!data.test_pending || !text.trim() })}
          onClick={() => act('test', { text })}
        >
          {data.test_pending ? 'Thinking…' : 'Say'}
        </button>
      </div>
      {!!data.test_reply && (
        <div style={{ ...cardStyle, marginTop: 8, fontStyle: 'italic' }}>
          <b style={{ fontStyle: 'normal' }}>{data.editing?.name}:</b> {data.test_reply}
        </div>
      )}
    </div>
  );
};

const LiveView = () => {
  const { data } = useBackend<Data>();
  const e = data.editing as Record;
  return (
    <div style={{ ...cardStyle, marginBottom: 10 }}>
      <div style={{ fontWeight: 'bold' }}>
        Now: {e.doing}
        {e.why ? <span style={{ fontWeight: 'normal', fontStyle: 'italic', color: INK_SOFT }}> - "{e.why}"</span> : null}
      </div>
      {(!!e.mood || !!e.house) && (
        <div style={{ fontSize: FONT_SMALL, color: INK_SOFT }}>
          {e.mood ? `Feels ${e.mood} lately. ` : ''}
          {e.house ? `Has built a ${e.house[6]} (${e.house[7]}) at ${e.house[0]},${e.house[1]}.` : ''}
        </div>
      )}
      <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', margin: '6px 0' }}>
        {Object.keys(e.needs || {}).map((n) => {
          const v = (e.needs || {})[n];
          return (
            <div key={n} style={{ width: 110, fontSize: FONT_TINY }}>
              {n}
              <div style={{ height: 5, background: PARCHMENT_DEEP, border: `1px solid ${INK_FAINT}` }}>
                <div style={{ width: `${v}%`, height: '100%', background: v >= 70 ? SEAL_RED : v >= 35 ? '#b8862c' : SEAL_GREEN }} />
              </div>
            </div>
          );
        })}
      </div>
      {(e.log || []).map((l, i) => (
        <div key={i} style={{ fontSize: FONT_TINY, color: INK_SOFT }}>
          {l}
        </div>
      ))}
    </div>
  );
};
