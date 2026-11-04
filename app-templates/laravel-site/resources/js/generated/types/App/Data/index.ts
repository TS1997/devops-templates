export type SharedPageProps = {
  name: string;
  user?: User;
  sidebarOpen: boolean;
  locale: string;
  defaultLocale: string;
  supportedLocales: string[];
};
export type User = {
  name: string;
  email: string;
  emailVerifiedAt: string;
};
