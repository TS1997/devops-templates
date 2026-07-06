import type { route as ziggyRoute } from 'ziggy-js';
import type { SharedPageProps } from '@/generated/types/App/Data';

declare module '@inertiajs/core' {
  export interface InertiaConfig {
    sharedPageProps: SharedPageProps & {
      [key: string]: unknown;
    };
  }
}

declare global {
  var route: typeof ziggyRoute;
}
