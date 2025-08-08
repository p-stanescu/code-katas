import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config({ path: './.env.local' });

const envSchema = z.object({
  // Coerce string values like 'true'/'false' from env into real booleans
  SKIP_HOOKS: z.coerce.boolean().default(false),
});

export const env = envSchema.parse(process.env);
