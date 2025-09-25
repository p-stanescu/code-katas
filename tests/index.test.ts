import { describe, expect, it } from 'vitest';
import { log } from '../katas/index';

describe('log', () => {
  it('runs without throwing', () => {
    expect(() => log()).not.toThrow();
  });
});
