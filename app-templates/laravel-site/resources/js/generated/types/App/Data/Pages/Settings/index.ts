export type ProfilePage = {
  mustVerifyEmail: boolean;
  status?: string;
};
export type SecurityPage = {
  canManageTwoFactor: boolean;
  twoFactorEnabled?: boolean;
  requiresConfirmation?: boolean;
};
