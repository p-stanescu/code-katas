import { env } from '../env.ts';

export function log(): void {
  console.log(env.SKIP_HOOKS);
}

log();
