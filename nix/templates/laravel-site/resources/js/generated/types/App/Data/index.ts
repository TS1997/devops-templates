export type SharedPagePropsData = {
  name: string;
  user?: UserData;
  sidebarOpen: boolean;
  locale: string;
  defaultLocale: string;
  supportedLocales: Record<string, SupportedLocaleData>;
};
export type SupportedLocaleData = {
  name: string;
  script: string;
  native: string;
  regional: string;
};
export type UserData = {
  name: string;
  email: string;
  emailVerifiedAt: string;
};
