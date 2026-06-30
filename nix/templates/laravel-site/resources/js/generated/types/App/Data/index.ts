export type SharedPageProps = {
  name: string;
  user?: User;
  sidebarOpen: boolean;
  locale: string;
  defaultLocale: string;
  supportedLocales: Record<string, SupportedLocale>;
};
export type SupportedLocale = {
  name: string;
  script: string;
  native: string;
  regional: string;
};
export type User = {
  name: string;
  email: string;
  emailVerifiedAt: string;
};
