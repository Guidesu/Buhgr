import { useEffect, useMemo, useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import {
  bake,
  ELSEWHERE,
  GH,
  GW,
  HINGE,
  LANDS,
  type Mark,
  paint,
  VIEW_H,
  VIEW_W,
} from './common/palimpsesteMap';

type RegionData = {
  path: string;
  key: string;
  name: string;
  desc: string;
  origin_desc: string;
  selected: boolean;
};

type Data = {
  current_origin: string | null;
  regions: RegionData[];
};

/** One little pen stroke: a peak, a tree, a dune, a hill, a tuft or a marsh reed. */
const TerrainMark = (props: { mark: Mark }) => {
  const { x, y, kind, s } = props.mark;
  const t = `translate(${x.toFixed(1)},${y.toFixed(1)}) scale(${s.toFixed(2)})`;
  switch (kind) {
    case 'peaks':
      return (
        <g transform={t}>
          <path d="M-4.5,2 L0,-4 L4.5,2" fill="#e9e2cf" />
          <path d="M0,-4 L1.2,-1.5 L-0.3,-0.6" />
        </g>
      );
    case 'woods':
      return (
        <g transform={t}>
          <circle cx={0} cy={-1.6} r={2.2} fill="#8fa872" />
          <path d="M0,0.6 L0,2.6" />
        </g>
      );
    case 'dunes':
      return <path transform={t} d="M-4,1 Q-2,-1.6 0,1 Q2,-1.6 4,1" />;
    case 'hills':
      return <path transform={t} d="M-4,1.5 Q0,-3 4,1.5" />;
    case 'marsh':
      return (
        <path transform={t} d="M-2,1.5 L-2.6,-1.5 M0,1.5 L0,-2.4 M2,1.5 L2.6,-1.5 M-3.5,1.6 L3.5,1.6" />
      );
    default:
      return <path transform={t} d="M-2.5,1 L-1.5,-0.5 M0,1 L0,-1 M2.5,1 L1.5,-0.5" />;
  }
};

// --- Component -----------------------------------------------------------

export const CharacterOriginMap = () => {
  const { act, data } = useBackend<Data>();
  const [hovered, setHovered] = useState<string | null>(null);
  const [picked, setPicked] = useState<string | null>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const baked = useMemo(() => bake(), []);

  const byKey = Object.fromEntries(data.regions.map((r) => [r.key, r]));
  const activeKey =
    hovered ||
    picked ||
    data.regions.find((r) => r.selected)?.key ||
    data.regions[0]?.key ||
    null;
  const activeRegion = data.regions.find((r) => r.key === activeKey);
  const activeIdx = LANDS.findIndex((l) => l.key === activeKey);
  const homeIdx = LANDS.findIndex((l) => byKey[l.key]?.selected);
  const present = LANDS.map((l) => !!byKey[l.key]);
  const onMap = (key: string) =>
    LANDS.some((l) => l.key === key) || key === 'the Hinge' || key === 'Elsewhere';

  useEffect(() => {
    const ctx = canvasRef.current?.getContext('2d');
    if (ctx) paint(ctx, baked, activeIdx, homeIdx, present);
  }, [baked, activeIdx, homeIdx, present.join()]);

  const landAt = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const px = Math.floor(((e.clientX - rect.left) / rect.width) * GW);
    const py = Math.floor(((e.clientY - rect.top) / rect.height) * GH);
    if (px < 0 || py < 0 || px >= GW || py >= GH) return null;
    const r = baked.region[py * GW + px];
    return r >= 0 && present[r] ? LANDS[r].key : null;
  };

  const overlayHandlers = (key: string) => ({
    onMouseEnter: () => setHovered(key),
    onMouseLeave: () => setHovered(null),
    onClick: () => setPicked(key),
    style: { cursor: 'pointer', pointerEvents: 'auto' as const },
  });
  const inkStroke = (key: string) =>
    activeKey === key
      ? { stroke: '#8a1c1c', strokeWidth: 2 }
      : { stroke: '#4a3622', strokeWidth: 1 };

  return (
    <Window title="Where Do You Hail From?" width={1060} height={680}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={3} basis={0}>
            <Section fill title="Palimpseste">
              <div
                style={{
                  position: 'relative',
                  width: '100%',
                  aspectRatio: `${VIEW_W} / ${VIEW_H}`,
                  maxHeight: 'calc(100% - 3em)',
                  boxShadow: 'inset 0 0 40px rgba(59,42,20,0.45)',
                  border: '2px solid #4a3622',
                }}
              >
                <canvas
                  ref={canvasRef}
                  width={GW}
                  height={GH}
                  style={{
                    position: 'absolute',
                    inset: 0,
                    width: '100%',
                    height: '100%',
                    cursor: hovered ? 'pointer' : 'default',
                  }}
                  onMouseMove={(e) => {
                    const key = landAt(e);
                    if (key !== hovered) setHovered(key);
                  }}
                  onMouseLeave={() => setHovered(null)}
                  onClick={(e) => {
                    const key = landAt(e);
                    if (key) setPicked(key);
                  }}
                />
                <svg
                  viewBox={`0 0 ${VIEW_W} ${VIEW_H}`}
                  preserveAspectRatio="none"
                  style={{
                    position: 'absolute',
                    inset: 0,
                    width: '100%',
                    height: '100%',
                    pointerEvents: 'none',
                  }}
                >
                  {/* Terrain marks */}
                  <g
                    fill="none"
                    stroke="#4a3622"
                    strokeWidth={0.55}
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    opacity={0.7}
                  >
                    {baked.marks.map((m, n) => (
                      <TerrainMark key={n} mark={m} />
                    ))}
                  </g>

                  {/* Sea names */}
                  {[
                    ['The Stitching Sea', 404, 232],
                    ['The Unwritten Deep', 262, 350],
                    ['Frostmargin', 400, 16],
                    ['Mere of Seams', 44, 346],
                  ].map(([name, x, y]) => (
                    <text
                      key={name as string}
                      x={x as number}
                      y={y as number}
                      textAnchor="middle"
                      fontSize="8"
                      fontStyle="italic"
                      fill="#4f6b66"
                      style={{ letterSpacing: '1.5px' }}
                    >
                      {name}
                    </text>
                  ))}

                  {/* The Hinge: a ring of doors hanging over the sea */}
                  {!!byKey['the Hinge'] && (
                    <g {...overlayHandlers('the Hinge')}>
                      <circle
                        cx={HINGE.cx}
                        cy={HINGE.cy}
                        r={HINGE.r}
                        fill="#d8cfe0"
                        {...inkStroke('the Hinge')}
                      />
                      <circle
                        cx={HINGE.cx}
                        cy={HINGE.cy}
                        r={HINGE.r - 8}
                        fill="#b2c9c4"
                        stroke="#4a3622"
                        strokeWidth={0.7}
                      />
                      {Array.from({ length: 8 }, (_, n) => n * 45).map((a) => (
                        <rect
                          key={a}
                          x={HINGE.cx - 2}
                          y={HINGE.cy - HINGE.r - 1.5}
                          width={4}
                          height={7}
                          rx={1.5}
                          fill="#4a3622"
                          transform={`rotate(${a} ${HINGE.cx} ${HINGE.cy})`}
                        />
                      ))}
                      <text
                        x={HINGE.cx}
                        y={HINGE.cy + HINGE.r + 10}
                        textAnchor="middle"
                        fontSize="8.5"
                        fill="#4a3622"
                        stroke="#f4ead0"
                        strokeWidth={2.4}
                        paintOrder="stroke"
                        style={{ fontVariant: 'small-caps' }}
                      >
                        Hinge
                      </text>
                    </g>
                  )}

                  {/* Elsewhere: a torn scrap off the map's edge */}
                  {!!byKey.Elsewhere && (
                    <g {...overlayHandlers('Elsewhere')}>
                      <path
                        d={`M${ELSEWHERE.x},${ELSEWHERE.y + 3} l14,-3 l12,4 l18,-4 l16,3 l${ELSEWHERE.w - 60},-2 l2,${ELSEWHERE.h} l-${ELSEWHERE.w - 2},2 z`}
                        fill="#efe4c6"
                        strokeDasharray="2 2"
                        {...inkStroke('Elsewhere')}
                      />
                      <text
                        x={ELSEWHERE.x + ELSEWHERE.w / 2}
                        y={ELSEWHERE.y + ELSEWHERE.h / 2 + 4}
                        textAnchor="middle"
                        fontSize="10"
                        fontStyle="italic"
                        fill="#4a3622"
                      >
                        Elsewhere
                      </text>
                    </g>
                  )}

                  {/* Land names */}
                  {LANDS.map((land, i) => {
                    if (!byKey[land.key]) return null;
                    const { x, y } = baked.labels[i];
                    const isActive = activeKey === land.key;
                    return (
                      <g key={land.key}>
                        <text
                          x={x}
                          y={y}
                          textAnchor="middle"
                          dominantBaseline="middle"
                          fontSize={land.small ? 8.5 : 10.5}
                          fontWeight={isActive ? 'bold' : 'normal'}
                          fill="#3d2b18"
                          stroke="#f4ead0"
                          strokeWidth={2.6}
                          paintOrder="stroke"
                          style={{ fontVariant: 'small-caps', letterSpacing: '0.6px' }}
                        >
                          {land.label}
                        </text>
                        {!!byKey[land.key].selected && (
                          <text
                            x={x}
                            y={y + 11}
                            textAnchor="middle"
                            fontSize="8"
                            fill="#7a1c1c"
                            stroke="#f4ead0"
                            strokeWidth={2}
                            paintOrder="stroke"
                          >
                            ✦ home
                          </text>
                        )}
                      </g>
                    );
                  })}

                  {/* Compass rose */}
                  <g transform="translate(30,26)">
                    <circle r="15" fill="#efe4c6" stroke="#4a3622" strokeWidth="0.8" />
                    <circle r="11" fill="none" stroke="#4a3622" strokeWidth="0.4" />
                    {[0, 90, 180, 270].map((a) => (
                      <path
                        key={a}
                        d="M0,-13 L2.6,0 L-2.6,0 Z"
                        fill={a === 0 ? '#8a1c1c' : '#4a3622'}
                        transform={`rotate(${a})`}
                      />
                    ))}
                    {[45, 135, 225, 315].map((a) => (
                      <path
                        key={a}
                        d="M0,-8 L1.6,0 L-1.6,0 Z"
                        fill="#4a3622"
                        fillOpacity="0.6"
                        transform={`rotate(${a})`}
                      />
                    ))}
                  </g>
                </svg>
              </div>
              {data.regions.some((r) => !onMap(r.key)) && (
                <Box mt={0.5}>
                  <Box inline color="label" mr={1}>
                    Not on the map:
                  </Box>
                  {data.regions
                    .filter((r) => !onMap(r.key))
                    .map((r) => (
                      <Button
                        key={r.path}
                        selected={activeKey === r.key}
                        icon={r.selected ? 'check' : undefined}
                        onClick={() => setPicked(r.key)}
                      >
                        {r.name}
                      </Button>
                    ))}
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item grow={2} basis={0}>
            <Section
              fill
              scrollable
              title={activeRegion?.name || 'Select a Region'}
            >
              {activeRegion ? (
                <>
                  <Box
                    color="label"
                    italic
                    mb={1}
                    dangerouslySetInnerHTML={{ __html: activeRegion.desc }}
                  />
                  <Box
                    mb={1.5}
                    dangerouslySetInnerHTML={{
                      __html: activeRegion.origin_desc,
                    }}
                  />
                  <Button
                    fluid
                    bold
                    icon="check"
                    disabled={activeRegion.selected}
                    onClick={() =>
                      act('choose_origin', { path: activeRegion.path })
                    }
                  >
                    {activeRegion.selected
                      ? 'This Is Your Origin'
                      : `Choose ${activeRegion.name}`}
                  </Button>
                </>
              ) : (
                <Box color="label">
                  Click a land on the map to read its history.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export default CharacterOriginMap;
