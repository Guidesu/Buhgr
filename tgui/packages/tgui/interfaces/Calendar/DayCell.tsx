import type { CSSProperties } from 'react';

import { FONT_BODY, INK, INK_FAINT, INK_SOFT } from '../common/parchment';
import { EventBar } from './EventBar';
import { AMBER_TINT, AMBER_TINT_STRONG } from './parchment_calendar';
import type { CalendarEvent } from './shared';

type SlottedEvent = { event: CalendarEvent; slot: number };

type DayCellProps = {
  day: number;
  isToday: boolean;
  isSelected: boolean;
  events: CalendarEvent[];
  visible: SlottedEvent[];
  overflow: number;
  onClick: () => void;
};

const cellStyle = (selected: boolean, isToday: boolean): CSSProperties => ({
  position: 'relative',
  minHeight: '62px',
  padding: '3px 4px',
  cursor: 'pointer',
  border: '1px solid transparent',
  background: selected
    ? AMBER_TINT_STRONG
    : isToday
      ? AMBER_TINT
      : 'transparent',
  display: 'flex',
  flexDirection: 'column',
  fontSize: FONT_BODY,
  color: INK,
});

const dayNumberStyle = (isToday: boolean): CSSProperties => ({
  fontWeight: isToday ? 'bold' : 'normal',
  fontSize: isToday ? '13px' : '12px',
  color: isToday ? INK : INK_SOFT,
  marginBottom: '2px',
});

const barsContainerStyle: CSSProperties = {
  marginTop: 'auto',
  display: 'flex',
  flexDirection: 'column',
  gap: '1px',
};

const overflowStyle: CSSProperties = {
  fontSize: FONT_BODY,
  color: INK_FAINT,
  textAlign: 'right',
  paddingRight: '2px',
};

/** Moon for a day of the 28-day month; full moon on days 13-15. */
export const moonForDay = (day: number): { glyph: string; name: string } => {
  const d = ((day - 1) % 28) + 1;
  if (d === 1 || d === 28) return { glyph: '\u{1F311}', name: 'New Moon' };
  if (d <= 6) return { glyph: '\u{1F312}', name: 'Waxing Crescent' };
  if (d === 7) return { glyph: '\u{1F313}', name: 'First Quarter' };
  if (d <= 12) return { glyph: '\u{1F314}', name: 'Waxing Gibbous' };
  if (d <= 15) return { glyph: '\u{1F315}', name: 'Full Moon' };
  if (d <= 20) return { glyph: '\u{1F316}', name: 'Waning Gibbous' };
  if (d === 21) return { glyph: '\u{1F317}', name: 'Last Quarter' };
  return { glyph: '\u{1F318}', name: 'Waning Crescent' };
};

export const DayCell = (props: DayCellProps) => {
  const { day, isToday, isSelected, events, visible, overflow, onClick } =
    props;
  return (
    <div
      style={cellStyle(isSelected, isToday)}
      onClick={onClick}
      title={events.map((e) => e.title).join(', ')}
    >
      <div
        style={{
          ...dayNumberStyle(isToday),
          display: 'flex',
          justifyContent: 'space-between',
        }}
      >
        <span>{day}</span>
        <span title={moonForDay(day).name} style={{ opacity: 0.85 }}>
          {moonForDay(day).glyph}
        </span>
      </div>
      <div style={barsContainerStyle}>
        {visible.map(({ event: e }) => (
          <EventBar
            key={e.id}
            color={e.color_tag}
            isStart={day === e.day}
            isEnd={day === e.day + e.duration_days - 1}
            label={e.title}
          />
        ))}
        {overflow > 0 && <div style={overflowStyle}>+{overflow} more</div>}
      </div>
    </div>
  );
};
