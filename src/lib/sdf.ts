export type vec2 = { x: number, y: number }

export const vec2 = {
  ZERO: { x: 0, y: 0 } as const satisfies vec2,
  ONE: { x: 1, y: 1 } as const satisfies vec2,
  create: (x: number = 0, y: number = 0): vec2 => ({ x, y }),

  add: (a: vec2, b: vec2): vec2 => vec2.create(a.x + b.x, a.y + b.y),
  multiply_number: (a: vec2, b: number): vec2 => vec2.create(a.x * b, a.y * b),
  multiply_vec2: (a: vec2, b: vec2): vec2 => vec2.create(a.x * b.x, a.y * b.y),
} as const;

export type vec4 = { x: number, y: number, z: number, w: number };

export const vec4 = {
  ZERO: { x: 0, y: 0, z: 0, w: 0 } as const satisfies vec4,
  ONE: { x: 1, y: 1, z: 1, w: 1 } as const satisfies vec4,
  create: (x: number = 0, y: number = 0, z: number = 0, w: number = 0 ): vec4 => ({ x: x, y: y, z: z, w: w }),
} as const;

export type SDFCanvasState = {
  brushes: SDFBrush[];
}

export enum SDFOperation {
    None = 0,
    Union,
    Subtraction,
    Intersection,
}

export enum SDFType {
  None = 0,
  Circle,
  Box,
}

export type SDFBrush = {
    position: vec2;
    boundsExtents: vec2;
    color: vec4;
  sdf: SDF;
}

export const SDFBrush = {
  create: (sdf: SDF): SDFBrush => ({ data: { position: vec2.ZERO, boundsExtents: vec2.ZERO, color: vec4.ZERO }, sdf }),
} as const;

export type SDFBrushData = {
  position: vec2;
  boundsExtents: vec2;
  color: vec4;
}

export const SDFBrushData = {
  STRIDE: 8 as const,
} as const;

export type SDF = {
  type: SDFType;
}

export type CircleSDF = SDF & {
  type: SDFType.Circle;
  data: CircleSDFData;
}

export const CircleSDF = {
  create: (radius: number = 0): CircleSDF => ({ type: SDFType.Circle, data: { radius }}),
} as const;

export type CircleSDFData = {
  radius: number;
}

export const CircleSDFData = {
  STRIDE: 1 as const,
} as const;

export type BoxSDF = SDF & {
  type: SDFType.Box;
  data: BoxSDFData;
}

export const BoxSDF = {
  create: (size: vec2 = vec2.ZERO): BoxSDF => ({ type: SDFType.Box, data: { size }}),
} as const;

export type BoxSDFData = {
  size: vec2;
}

export const BoxSDFData = {
  STRIDE: 2 as const
} as const;


