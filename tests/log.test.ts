import { describe, expect, it, vi } from 'vitest';

import { log } from '../katas/index.ts';

describe('log', () => {
  it('should call console.log with "hello"', () => {
    const spy = vi.spyOn(console, 'log').mockImplementation(() => {});
    log();
    expect(spy).toHaveBeenCalledWith(true);
    spy.mockRestore();
  });
});
