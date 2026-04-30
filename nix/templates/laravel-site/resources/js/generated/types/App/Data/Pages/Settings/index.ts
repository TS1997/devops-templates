export type ProfilePageData = {
  mustVerifyEmail: boolean;
  status?: string;
};
export type SecurityPageData = {
  canManageTwoFactor: boolean;
  twoFactorEnabled?: boolean;
  requiresConfirmation?: boolean;
};
