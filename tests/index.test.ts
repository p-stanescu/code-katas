import { describe, expect, it } from 'vitest';
import { log, type logType } from '../src/index.ts';

describe('log', () => {
  it('returns "unset" when input is undefined', () => {
    const result: logType = log();
    expect(result).toBe('other');
  });

  it('returns "empty" for empty or whitespace-only strings', () => {
    expect(log('')).toBe('empty');
    expect(log('   ')).toBe('empty');
  });

  it('returns "set" for any non-empty string', () => {
    expect(log('0')).toBe('set');
    expect(log('false')).toBe('set');
    expect(log('hello')).toBe('set');
  });
});
