import { env } from '../env.ts';

export function log(): string {
  console.log(env.SKIP_HOOKS);
}

log();
