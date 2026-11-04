import type { InertiaLinkProps } from '@inertiajs/react';
import type { LucideIcon } from 'lucide-react';

export type BreadcrumbItem = {
  title: string;
  href: NonNullable<InertiaLinkProps['href']>;
};

export type NavItem = {
  title: string;
  href: NonNullable<InertiaLinkProps['href']>;
  routeName?: Parameters<typeof route>[0];
  icon?: LucideIcon | null;
  isActive?: boolean;
};
