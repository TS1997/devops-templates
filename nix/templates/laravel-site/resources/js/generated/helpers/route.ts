type RouteParameters = {
  login: never;
  'login.store': never;
  logout: never;
  'password.request': never;
  'password.email': never;
  'password.reset': {
    token: string | number;
  };
  'password.update': never;
  register: never;
  'register.store': never;
  'verification.notice': never;
  'verification.verify': {
    id: string | number;
    hash: string | number;
  };
  'verification.send': never;
  'password.confirm': never;
  'password.confirm.store': never;
  'password.confirmation': never;
  'two-factor.login': never;
  'two-factor.login.store': never;
  'two-factor.enable': never;
  'two-factor.disable': never;
  'two-factor.confirm': never;
  'two-factor.qr-code': never;
  'two-factor.secret-key': never;
  'two-factor.recovery-codes': never;
  'two-factor.regenerate-recovery-codes': never;
  'profile.edit': never;
  'profile.update': never;
  'profile.destroy': never;
  'security.edit': never;
  'user-password.update': never;
  home: never;
  dashboard: never;
  'appearance.edit': never;
};
export function route<T extends keyof RouteParameters>(
  name: T,
  parameters?: [RouteParameters[T]] extends [never]
    ? Record<string, never>
    : RouteParameters[T],
  absolute: boolean = false,
): string {
  let url: string = '/' + routes[name];

  if (parameters) {
    for (const [key, value] of Object.entries(parameters)) {
      url = url.replace(`{${key}}`, String(value));
    }
  }

  if (absolute) {
    url = window.location.origin + url;
  }

  return url;
}
const routes = {
  login: 'login',
  'login.store': 'login',
  logout: 'logout',
  'password.request': 'forgot-password',
  'password.email': 'forgot-password',
  'password.reset': 'reset-password/{token}',
  'password.update': 'reset-password',
  register: 'register',
  'register.store': 'register',
  'verification.notice': 'email/verify',
  'verification.verify': 'email/verify/{id}/{hash}',
  'verification.send': 'email/verification-notification',
  'password.confirm': 'user/confirm-password',
  'password.confirm.store': 'user/confirm-password',
  'password.confirmation': 'user/confirmed-password-status',
  'two-factor.login': 'two-factor-challenge',
  'two-factor.login.store': 'two-factor-challenge',
  'two-factor.enable': 'user/two-factor-authentication',
  'two-factor.disable': 'user/two-factor-authentication',
  'two-factor.confirm': 'user/confirmed-two-factor-authentication',
  'two-factor.qr-code': 'user/two-factor-qr-code',
  'two-factor.secret-key': 'user/two-factor-secret-key',
  'two-factor.recovery-codes': 'user/two-factor-recovery-codes',
  'two-factor.regenerate-recovery-codes': 'user/two-factor-recovery-codes',
  'profile.edit': 'settings/profile',
  'profile.update': 'settings/profile',
  'profile.destroy': 'settings/profile',
  'security.edit': 'settings/security',
  'user-password.update': 'settings/password',
  home: '/',
  dashboard: 'dashboard',
  'appearance.edit': 'settings/appearance',
};
