import type { SharedPageProps } from '@/generated/types/App/Data';

declare module '@inertiajs/core' {
  export interface InertiaConfig {
    sharedPageProps: SharedPageProps & {
      [key: string]: unknown;
    };
  }
}
