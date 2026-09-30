/*
 * The map of Palimpseste is generated, not drawn.
 *
 * - Every land grows from one or more seed discs.
 * - The coastline is a smooth union of all seeds (a sum of Gaussian bumps), so
 *   neighbouring lands merge into one continent, roughened by fractal noise.
 * - Borders between lands come from a noise-warped "nearest seed" (weighted by
 *   each seed's radius), which makes them wander like real frontiers.
 * - A height field (the same bumps plus noise) is hill-shaded from the
 *   north-west for relief.
 * - Terrain marks (peaks, woods, dunes, hills) are scattered inside each land.
 *
 * Everything is baked once into a pixel grid that is both the picture and the
 * hit-test map.
 */

// Map space, in the same units the seeds use.
export const VIEW_W = 500;
export const VIEW_H = 360;
// Pixels per map unit when baking; 2 keeps coastlines crisp.
export const SCALE = 2;
export const GW = VIEW_W * SCALE;
export const GH = VIEW_H * SCALE;

type Seed = [x: number, y: number, r: number];

export type Terrain = 'peaks' | 'woods' | 'dunes' | 'hills' | 'fields' | 'marsh';

export type Land = {
  key: string;
  label: string;
  color: string;
  terrain: Terrain;
  seeds: Seed[];
  /** Label position; defaults to the land's centre of mass. */
  lx?: number;
  ly?: number;
  small?: boolean;
};

export const LANDS: Land[] = [
  { key: 'Tamarhel', label: 'Tamarhel', color: '#cdd6d6', terrain: 'peaks', seeds: [[100, 64, 48], [62, 56, 30], [140, 48, 26]] },
  { key: 'the Vyrlands', label: 'Vyrlands', color: '#aebf8e', terrain: 'woods', seeds: [[205, 58, 44], [232, 40, 22]] },
  { key: 'the Conjunct', label: 'Conjunct', color: '#bfb89c', terrain: 'hills', seeds: [[300, 62, 46], [342, 50, 26]] },
  { key: 'Tír Aenna', label: 'Tír Aenna', color: '#a3c784', terrain: 'hills', seeds: [[60, 118, 34], [40, 132, 20]], small: true },
  { key: 'Faerhen', label: 'Faerhen', color: '#d9c893', terrain: 'fields', seeds: [[160, 118, 46]] },
  { key: 'the Seamvale', label: 'Seamvale', color: '#e8d57a', terrain: 'fields', seeds: [[255, 128, 36]] },
  { key: 'Varovia', label: 'Varovia', color: '#9c9aaa', terrain: 'woods', seeds: [[330, 108, 32]], small: true },
  { key: 'Yharrow', label: 'Yharrow', color: '#ad8f8b', terrain: 'hills', seeds: [[368, 146, 28]], small: true },
  { key: 'Thessadra', label: 'Thessadra', color: '#c4b3d0', terrain: 'peaks', seeds: [[64, 176, 40]] },
  { key: 'Golaren', label: 'Golaren', color: '#d2c09a', terrain: 'fields', seeds: [[130, 184, 34]], small: true },
  { key: 'the Laurentine Dominion', label: 'Laurentine Dominion', color: '#dfb487', terrain: 'fields', seeds: [[210, 184, 44]] },
  { key: "Turtle's Back", label: "Turtle's Back", color: '#b6cd93', terrain: 'woods', seeds: [[308, 200, 40], [340, 222, 26]] },
  { key: 'the Khemet Sands', label: 'Khemet Sands', color: '#ecd894', terrain: 'dunes', seeds: [[82, 236, 40]] },
  { key: 'Athrae', label: 'Athrae', color: '#dba56e', terrain: 'dunes', seeds: [[152, 246, 36]] },
  { key: 'Ashurim', label: 'Ashurim', color: '#d8bd84', terrain: 'dunes', seeds: [[228, 248, 34]] },
  {
    key: 'the Ilé-Orun Coast',
    label: 'Ilé-Orun Coast',
    color: '#c7a566',
    terrain: 'marsh',
    seeds: [[150, 296, 40], [98, 290, 30], [198, 294, 24]],
  },
  {
    key: 'the Achaeon Isles',
    label: 'Achaeon Isles',
    color: '#e8dfc2',
    terrain: 'hills',
    seeds: [[300, 292, 12], [330, 304, 14], [358, 288, 9], [316, 322, 9], [348, 322, 7], [378, 308, 5]],
    lx: 334,
    ly: 272,
    small: true,
  },
  {
    key: 'the Dunmoor Isles',
    label: 'Dunmoor Isles',
    color: '#a9b0b3',
    terrain: 'hills',
    seeds: [[418, 128, 14], [446, 140, 12], [428, 156, 8], [460, 120, 6]],
    lx: 438,
    ly: 106,
    small: true,
  },
  {
    key: 'Psyiadonia',
    label: 'Psyiadonia',
    color: '#b9a88f',
    terrain: 'hills',
    seeds: [[436, 294, 22], [462, 308, 16], [418, 316, 12], [450, 328, 10]],
  },
  {
    key: 'Hinomura',
    label: 'Hinomura',
    color: '#dbb0ab',
    terrain: 'peaks',
    seeds: [[450, 206, 12], [463, 232, 13], [456, 262, 9], [441, 228, 6], [472, 254, 5]],
    lx: 470,
    ly: 186,
    small: true,
  },
];

// The Hinge floats apart from the world; Elsewhere is a scrap off its edge.
export const HINGE = { cx: 446, cy: 46, r: 21 };
export const ELSEWHERE = { x: 6, y: 318, w: 64, h: 34 };

const INK: RGB = [74, 54, 34];
const SEA: RGB = [172, 197, 193];
const SHALLOW: RGB = [206, 220, 206];
const PAPER: RGB = [240, 229, 200];
const RED: RGB = [138, 28, 28];

type RGB = [number, number, number];

// --- Noise ---------------------------------------------------------------

const hash = (x: number, y: number, seed: number) => {
  let h = (x * 374761393 + y * 668265263 + seed * 2147483647) | 0;
  h = Math.imul(h ^ (h >>> 13), 1274126177);
  h ^= h >>> 16;
  return (h >>> 0) / 4294967295;
};

const smooth = (t: number) => t * t * (3 - 2 * t);

const valueNoise = (x: number, y: number, seed: number) => {
  const xi = Math.floor(x);
  const yi = Math.floor(y);
  const xf = smooth(x - xi);
  const yf = smooth(y - yi);
  const a = hash(xi, yi, seed);
  const b = hash(xi + 1, yi, seed);
  const c = hash(xi, yi + 1, seed);
  const d = hash(xi + 1, yi + 1, seed);
  return a + (b - a) * xf + (c - a) * yf + (a - b - c + d) * xf * yf;
};

/** Fractal noise in roughly [-0.5, 0.5]. */
const fbm = (x: number, y: number, seed: number, octaves = 4) => {
  let sum = 0;
  let amp = 0.5;
  let freq = 1;
  let norm = 0;
  for (let i = 0; i < octaves; i++) {
    sum += valueNoise(x * freq, y * freq, seed + i * 101) * amp;
    norm += amp;
    amp *= 0.5;
    freq *= 2.03;
  }
  return sum / norm - 0.5;
};

const hexRgb = (hex: string): RGB => [
  parseInt(hex.slice(1, 3), 16),
  parseInt(hex.slice(3, 5), 16),
  parseInt(hex.slice(5, 7), 16),
];

const mix = (a: RGB, b: RGB, t: number): RGB => [
  a[0] + (b[0] - a[0]) * t,
  a[1] + (b[1] - a[1]) * t,
  a[2] + (b[2] - a[2]) * t,
];

// --- Baking --------------------------------------------------------------

export type Mark = { x: number; y: number; kind: Terrain; s: number };

export type Baked = {
  /** Land index per pixel, -1 for sea. */
  region: Int16Array;
  /** Height per pixel, for hill-shading. */
  height: Float32Array;
  /** Distance to the nearest land in pixels (sea only, capped). */
  coastDist: Uint8Array;
  /** Per-pixel paper grain in [0, 1]. */
  grain: Float32Array;
  /** Where each land's label goes, in map units. */
  labels: { x: number; y: number }[];
  /** Terrain marks, in map units. */
  marks: Mark[];
};

let bakedCache: Baked | null = null;

export const bake = (): Baked => {
  if (bakedCache) return bakedCache;
  const N = GW * GH;
  const region = new Int16Array(N).fill(-1);
  const height = new Float32Array(N);
  const grain = new Float32Array(N);
  const seeds: { x: number; y: number; r: number; land: number }[] = [];
  LANDS.forEach((land, i) => {
    for (const [x, y, r] of land.seeds) seeds.push({ x, y, r, land: i });
  });

  for (let py = 0; py < GH; py++) {
    for (let px = 0; px < GW; px++) {
      const x = px / SCALE;
      const y = py / SCALE;
      // Warp the sample point so borders and coasts wander.
      const wx = x + fbm(x / 40, y / 40, 11) * 30;
      const wy = y + fbm(x / 40, y / 40, 29) * 30;
      // Frontiers get a second, finer wander on top.
      const bx = wx + fbm(x / 13, y / 13, 41, 3) * 14;
      const by = wy + fbm(x / 13, y / 13, 43, 3) * 14;
      let field = 0;
      let best = -Infinity;
      let bestLand = -1;
      for (const s of seeds) {
        const dx = wx - s.x;
        const dy = wy - s.y;
        const q = (dx * dx + dy * dy) / (s.r * s.r);
        field += Math.exp(-q * 1.25);
        const ex = bx - s.x;
        const ey = by - s.y;
        const f = 1 - Math.sqrt(ex * ex + ey * ey) / s.r;
        if (f > best) {
          best = f;
          bestLand = s.land;
        }
      }
      const idx = py * GW + px;
      // Ragged coastline: fine noise over the smooth union of seeds.
      const coast = fbm(x / 14, y / 14, 53, 5) * 0.5;
      if (field + coast > 0.34) region[idx] = bestLand;
      // Ridged terrain for mountain lands, gentle swells elsewhere.
      const ridged = 0.5 - Math.abs(fbm(x / 14, y / 14, 71, 4)) * 2;
      const rough = bestLand >= 0 && LANDS[bestLand].terrain === 'peaks' ? 0.9 : 0.35;
      height[idx] = field * 0.5 + ridged * rough + fbm(x / 30, y / 30, 83, 3) * 0.4;
      grain[idx] = fbm(x / 2.5, y / 2.5, 97, 2) + 0.5;
    }
  }

  // Distance to land for every sea pixel (breadth-first, capped).
  const cap = 60;
  const coastDist = new Uint8Array(N).fill(cap);
  const queue = new Int32Array(N);
  let head = 0;
  let tail = 0;
  for (let i = 0; i < N; i++) {
    if (region[i] >= 0) {
      coastDist[i] = 0;
      queue[tail++] = i;
    }
  }
  while (head < tail) {
    const i = queue[head++];
    const d = coastDist[i] + 1;
    if (d >= cap) continue;
    const x = i % GW;
    if (x > 0 && coastDist[i - 1] > d) {
      coastDist[i - 1] = d;
      queue[tail++] = i - 1;
    }
    if (x < GW - 1 && coastDist[i + 1] > d) {
      coastDist[i + 1] = d;
      queue[tail++] = i + 1;
    }
    if (i >= GW && coastDist[i - GW] > d) {
      coastDist[i - GW] = d;
      queue[tail++] = i - GW;
    }
    if (i < N - GW && coastDist[i + GW] > d) {
      coastDist[i + GW] = d;
      queue[tail++] = i + GW;
    }
  }

  // Label at each land's centre of mass unless placed by hand.
  const sums = LANDS.map(() => ({ x: 0, y: 0, n: 0 }));
  for (let i = 0; i < N; i++) {
    const r = region[i];
    if (r < 0) continue;
    sums[r].x += i % GW;
    sums[r].y += Math.floor(i / GW);
    sums[r].n++;
  }
  const labels = LANDS.map((land, i) =>
    land.lx !== undefined
      ? { x: land.lx, y: land.ly! }
      : sums[i].n
        ? { x: sums[i].x / sums[i].n / SCALE, y: sums[i].y / sums[i].n / SCALE }
        : { x: land.seeds[0][0], y: land.seeds[0][1] },
  );

  // Terrain marks on a jittered grid, kept clear of borders, coasts and labels.
  const regionAt = (x: number, y: number) => {
    const px = Math.round(x * SCALE);
    const py = Math.round(y * SCALE);
    if (px < 0 || py < 0 || px >= GW || py >= GH) return -1;
    return region[py * GW + px];
  };
  const marks: Mark[] = [];
  const step = 11;
  for (let gy = step / 2; gy < VIEW_H; gy += step) {
    for (let gx = step / 2; gx < VIEW_W; gx += step) {
      const jx = gx + (hash(gx, gy, 5) - 0.5) * step * 0.8;
      const jy = gy + (hash(gx, gy, 6) - 0.5) * step * 0.8;
      const r = regionAt(jx, jy);
      if (r < 0) continue;
      const land = LANDS[r];
      if (land.seeds[0][2] < 20) continue; // islands stay clean
      const clear = 6;
      if (
        regionAt(jx - clear, jy) !== r ||
        regionAt(jx + clear, jy) !== r ||
        regionAt(jx, jy - clear) !== r ||
        regionAt(jx, jy + clear) !== r
      ) {
        continue;
      }
      const lab = labels[r];
      const halfW = (land.label.length * (land.small ? 4.6 : 5.6)) / 2 + 4;
      if (Math.abs(jx - lab.x) < halfW && Math.abs(jy - lab.y) < 10) continue;
      // Thin out by noise so marks gather in ranges and groves, not a grid.
      const density =
        land.terrain === 'fields' ? 0.25 : land.terrain === 'marsh' ? 0.35 : 0.55;
      if (fbm(jx / 22, jy / 22, 131) + 0.5 < 1 - density) continue;
      marks.push({ x: jx, y: jy, kind: land.terrain, s: 0.8 + hash(gx, gy, 7) * 0.5 });
    }
  }

  bakedCache = { region, height, coastDist, grain, labels, marks };
  return bakedCache;
};

export const paint = (
  ctx: CanvasRenderingContext2D,
  baked: Baked,
  active: number,
  home: number,
  present: boolean[],
) => {
  const img = ctx.createImageData(GW, GH);
  const out = img.data;
  const { region, height, coastDist, grain } = baked;
  const colors = LANDS.map((l) => hexRgb(l.color));

  for (let py = 0; py < GH; py++) {
    for (let px = 0; px < GW; px++) {
      const i = py * GW + px;
      const r = region[i];
      const g = grain[i];
      let c: RGB;

      if (r < 0) {
        const d = coastDist[i];
        // Shallows fade into open sea; ink depth rings follow the coast.
        c = d < 16 ? mix(SHALLOW, SEA, d / 16) : SEA;
        if (d > 16) c = mix(c, [150, 180, 178], Math.min(1, (d - 16) / 44) * 0.6);
        if (d === 7 || d === 15) c = mix(c, INK, 0.3);
        if (d === 24) c = mix(c, INK, 0.12);
        // Faint wave strokes in open water.
        const wave =
          Math.sin(px * 0.21 + Math.sin(py * 0.05) * 4) * Math.sin(py * 0.85);
        if (d > 30 && wave > 0.975) c = mix(c, INK, 0.3);
        c = mix(c, PAPER, 0.1 + g * 0.1);
      } else {
        const up = py > 0 ? region[i - GW] : r;
        const down = py < GH - 1 ? region[i + GW] : r;
        const left = px > 0 ? region[i - 1] : r;
        const right = px < GW - 1 ? region[i + 1] : r;
        const coastEdge = up < 0 || down < 0 || left < 0 || right < 0;
        const seam =
          !coastEdge && (up !== r || down !== r || left !== r || right !== r);

        c = present[r] ? colors[r] : mix(colors[r], PAPER, 0.6);
        // Hill-shade: light from the north-west.
        const hx = px > 1 && px < GW - 2 ? height[i + 2] - height[i - 2] : 0;
        const hy =
          py > 1 && py < GH - 2 ? height[i + 2 * GW] - height[i - 2 * GW] : 0;
        const shade = Math.max(-1, Math.min(1, (hx + hy) * 5));
        c = shade > 0 ? mix(c, INK, shade * 0.2) : mix(c, [255, 252, 238], -shade * 0.22);
        // Paper grain and a darker rim inside the coast.
        c = mix(c, INK, (1 - g) * 0.06);
        if (r === home) c = mix(c, [232, 196, 88], 0.25);
        if (r === active) c = mix(c, [255, 250, 235], 0.3);

        if (coastEdge) {
          c = r === active ? RED : INK;
        } else if (seam) {
          const touchesActive =
            r === active ||
            up === active ||
            down === active ||
            left === active ||
            right === active;
          // Stitched seam: short dashes along the border.
          const stitch = ((px + py) >> 2) % 3 !== 0;
          if (touchesActive) c = RED;
          else if (stitch) c = mix(c, INK, 0.85);
        }
      }

      const o = i * 4;
      out[o] = c[0];
      out[o + 1] = c[1];
      out[o + 2] = c[2];
      out[o + 3] = 255;
    }
  }
  ctx.putImageData(img, 0, 0);
};
