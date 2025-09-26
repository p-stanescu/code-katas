export type logType = 'other' | 'empty' | 'set';

export function log(input?: string): logType {
  const trimmed = input?.trim();
  if (trimmed === undefined) {
    return 'other';
  }
  if (trimmed === '') {
    return 'empty';
  }
  return 'set';
}
