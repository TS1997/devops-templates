import type { SharedPagePropsData } from '@/generated/types/App/Data';

declare module '@inertiajs/core' {
  export interface InertiaConfig {
    sharedPageProps: SharedPagePropsData & {
      [key: string]: unknown;
    };
  }
}
