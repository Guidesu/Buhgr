import type { CSSProperties } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  badgeStyle,
  cardStyle,
  dashedFrameStyle,
  FONT_SMALL,
  INK,
  INK_FAINT,
  INK_SOFT,
  pageStyle,
  rulerStyle,
  SEAL_AMBER,
  SEAL_BLUE,
  SEAL_GREEN,
  SEAL_RED,
  sectionHeaderStyle,
  subtitleStyle,
  titleStyle,
} from './common/parchment';

type Mood = { desc: string; count: number };
type Vice = { name: string; desc: string };
type Bonus = { name: string; value: number };

type Data = {
  has_sanity: boolean;
  sanity?: number;
  sanity_max?: number;
  sanity_text?: string;
  insight?: number;
  insight_threshold?: number;
  resting?: boolean;
  rest?: number;
  rest_threshold?: number;
  desires?: string[];
  breakdowns?: string[];
  stress: number;
  good_moods: Mood[];
  bad_moods: Mood[];
  vices: Vice[];
  oddity_bonuses: Bonus[];
};

const moodWord = (stress: number) => {
  if (stress <= -5) return 'Content';
  if (stress < 0) return 'At ease';
  if (stress === 0) return 'Steady';
  if (stress < 5) return 'Troubled';
  if (stress < 10) return 'Distressed';
  return 'Despairing';
};

/** An ink-drawn meter: a framed trough filled with a wash of colour. */
const Meter = (props: {
  label: string;
  value: number;
  max: number;
  color: string;
  note?: string;
}) => {
  const { label, value, max, color, note } = props;
  const pct = Math.max(0, Math.min(100, (value / Math.max(1, max)) * 100));
  const trough: CSSProperties = {
    position: 'relative',
    height: '14px',
    border: `1px solid ${INK_SOFT}`,
    borderRadius: '1px',
    background: 'var(--p-card-bg)',
    overflow: 'hidden',
  };
  const fill: CSSProperties = {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    width: `${pct}%`,
    background: color,
    opacity: 0.75,
  };
  return (
    <div style={{ marginBottom: '10px' }}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          fontSize: FONT_SMALL,
          color: INK_SOFT,
        }}
      >
        <span style={{ fontWeight: 'bold', color: INK }}>{label}</span>
        <span>
          {Math.round(value)} / {max}
        </span>
      </div>
      <div style={trough}>
        <div style={fill} />
      </div>
      {!!note && (
        <div
          style={{ fontStyle: 'italic', color: INK_SOFT, fontSize: FONT_SMALL }}
        >
          {note}
        </div>
      )}
    </div>
  );
};

const MoodLine = (props: { mood: Mood; good: boolean }) => {
  const { mood, good } = props;
  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'baseline',
        gap: '8px',
        padding: '2px 0',
        borderBottom: `1px dotted ${INK_FAINT}`,
      }}
    >
      <span
        style={{
          flex: '0 0 auto',
          width: '8px',
          height: '8px',
          borderRadius: '50%',
          background: good ? SEAL_GREEN : SEAL_RED,
          marginTop: '4px',
        }}
      />
      <span style={{ flex: '1 1 auto' }}>{mood.desc}</span>
      {mood.count > 1 && (
        <span style={{ color: INK_SOFT, fontSize: FONT_SMALL }}>
          x{mood.count}
        </span>
      )}
    </div>
  );
};

export const MindStatus = () => {
  const { data } = useBackend<Data>();
  const sanity = data.sanity ?? 0;
  const sanityMax = data.sanity_max || 100;
  const sanityColor =
    sanity >= sanityMax * 0.6
      ? SEAL_GREEN
      : sanity >= sanityMax * 0.3
        ? SEAL_AMBER
        : SEAL_RED;
  const desires = data.desires ?? [];
  const breakdowns = data.breakdowns ?? [];
  const moods = [
    ...data.bad_moods.map((m) => ({ m, good: false })),
    ...data.good_moods.map((m) => ({ m, good: true })),
  ];

  return (
    <Window width={480} height={680} theme="parchment" title="Mind">
      <Window.Content scrollable>
        <div style={pageStyle}>
          <div style={titleStyle}>The Mind</div>
          <div style={subtitleStyle}>
            {data.has_sanity ? data.sanity_text : 'My thoughts are my own.'}
          </div>
          <hr style={rulerStyle} />

          {!!breakdowns.length && (
            <div
              style={{
                ...cardStyle,
                borderColor: SEAL_RED,
                color: SEAL_RED,
                textAlign: 'center',
              }}
            >
              <b>My mind is breaking:</b> {breakdowns.join(', ')}.
            </div>
          )}

          {!!data.has_sanity && (
            <>
              <Meter
                label="Sanity"
                value={sanity}
                max={sanityMax}
                color={sanityColor}
              />
              <Meter
                label="Insight"
                value={data.insight ?? 0}
                max={data.insight_threshold || 100}
                color={SEAL_BLUE}
              />
              {!!data.resting && (
                <Meter
                  label="Rest"
                  value={data.rest ?? 0}
                  max={data.rest_threshold || 100}
                  color={SEAL_AMBER}
                  note={
                    desires.length
                      ? `I long for ${desires.join(' and ')}.`
                      : undefined
                  }
                />
              )}
            </>
          )}

          <div style={sectionHeaderStyle}>
            Mood
            <span style={badgeStyle(data.stress > 0 ? SEAL_RED : SEAL_GREEN)}>
              {moodWord(data.stress)}
            </span>
          </div>
          {moods.length ? (
            moods.map(({ m, good }, i) => (
              <MoodLine key={i} mood={m} good={good} />
            ))
          ) : (
            <div style={{ color: INK_SOFT, fontStyle: 'italic' }}>
              Nothing weighs on me, and nothing lifts me.
            </div>
          )}

          {!!data.vices.length && (
            <>
              <div style={sectionHeaderStyle}>Vices</div>
              {data.vices.map((vice, i) => (
                <div key={i} style={cardStyle}>
                  <div style={{ fontWeight: 'bold' }}>{vice.name}</div>
                  <div style={{ color: INK_SOFT, fontSize: FONT_SMALL }}>
                    {vice.desc}
                  </div>
                </div>
              ))}
            </>
          )}

          {!!data.oddity_bonuses.length && (
            <>
              <div style={sectionHeaderStyle}>Gifts of Oddities</div>
              <div>
                {data.oddity_bonuses.map((bonus) => (
                  <span
                    key={bonus.name}
                    style={badgeStyle(bonus.value > 0 ? SEAL_GREEN : SEAL_RED)}
                  >
                    {bonus.name} {bonus.value > 0 ? `+${bonus.value}` : bonus.value}
                  </span>
                ))}
              </div>
            </>
          )}

          {!!data.has_sanity && (
            <div style={{ ...dashedFrameStyle, marginTop: '16px' }}>
              Insight grows as my mind is shaken and mended. When it is full I
              gain desires, and indulging them lets me rest and turn insight
              into strength. Company, food, drink, prayer, music and a smoke ease
              the mind; wounds, horrors and a bad mood wear it down.
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};

export default MindStatus;
