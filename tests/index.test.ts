import { describe, expect, it } from 'vitest';
import { log } from '../katas/index.ts';

describe('log', () => {
  it('runs without throwing', () => {
    expect(() => log()).not.toThrow();
  });
});
