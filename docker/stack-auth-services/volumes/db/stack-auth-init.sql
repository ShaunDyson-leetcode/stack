-- CreateEnum
CREATE TYPE "BooleanTrue" AS ENUM ('TRUE');

-- CreateEnum
CREATE TYPE "PermissionScope" AS ENUM ('GLOBAL', 'TEAM');

-- CreateEnum
CREATE TYPE "TeamSystemPermission" AS ENUM ('UPDATE_TEAM', 'DELETE_TEAM', 'READ_MEMBERS', 'REMOVE_MEMBERS', 'INVITE_MEMBERS');

-- CreateEnum
CREATE TYPE "ContactChannelType" AS ENUM ('EMAIL');

-- CreateEnum
CREATE TYPE "ProxiedOAuthProviderType" AS ENUM ('GITHUB', 'GOOGLE', 'MICROSOFT', 'SPOTIFY');

-- CreateEnum
CREATE TYPE "StandardOAuthProviderType" AS ENUM ('GITHUB', 'FACEBOOK', 'GOOGLE', 'MICROSOFT', 'SPOTIFY', 'DISCORD', 'GITLAB', 'BITBUCKET', 'LINKEDIN', 'APPLE', 'X');

-- CreateEnum
CREATE TYPE "VerificationCodeType" AS ENUM ('ONE_TIME_PASSWORD', 'PASSWORD_RESET', 'CONTACT_CHANNEL_VERIFICATION', 'TEAM_INVITATION', 'MFA_ATTEMPT', 'PASSKEY_REGISTRATION_CHALLENGE', 'PASSKEY_AUTHENTICATION_CHALLENGE');

-- CreateEnum
CREATE TYPE "EmailTemplateType" AS ENUM ('EMAIL_VERIFICATION', 'PASSWORD_RESET', 'MAGIC_LINK', 'TEAM_INVITATION');

-- CreateTable
CREATE TABLE "Project" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "displayName" TEXT NOT NULL,
    "description" TEXT DEFAULT '',
    "configId" UUID NOT NULL,
    "isProductionMode" BOOLEAN NOT NULL,

    CONSTRAINT "Project_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectConfig" (
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "allowLocalhost" BOOLEAN NOT NULL,
    "signUpEnabled" BOOLEAN NOT NULL DEFAULT true,
    "createTeamOnSignUp" BOOLEAN NOT NULL,
    "clientTeamCreationEnabled" BOOLEAN NOT NULL,
    "clientUserDeletionEnabled" BOOLEAN NOT NULL DEFAULT false,
    "legacyGlobalJwtSigning" BOOLEAN NOT NULL DEFAULT false,
    "teamCreateDefaultSystemPermissions" "TeamSystemPermission"[],
    "teamMemberDefaultSystemPermissions" "TeamSystemPermission"[],

    CONSTRAINT "ProjectConfig_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectDomain" (
    "projectConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "domain" TEXT NOT NULL,
    "handlerPath" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "ProjectConfigOverride" (
    "projectId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProjectConfigOverride_pkey" PRIMARY KEY ("projectId")
);

-- CreateTable
CREATE TABLE "Team" (
    "projectId" TEXT NOT NULL,
    "teamId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "displayName" TEXT NOT NULL,
    "profileImageUrl" TEXT,
    "clientMetadata" JSONB,
    "clientReadOnlyMetadata" JSONB,
    "serverMetadata" JSONB,

    CONSTRAINT "Team_pkey" PRIMARY KEY ("projectId","teamId")
);

-- CreateTable
CREATE TABLE "TeamMember" (
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "teamId" UUID NOT NULL,
    "displayName" TEXT,
    "profileImageUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "isSelected" "BooleanTrue",

    CONSTRAINT "TeamMember_pkey" PRIMARY KEY ("projectId","projectUserId","teamId")
);

-- CreateTable
CREATE TABLE "TeamMemberDirectPermission" (
    "id" UUID NOT NULL,
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "teamId" UUID NOT NULL,
    "permissionDbId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "systemPermission" "TeamSystemPermission",

    CONSTRAINT "TeamMemberDirectPermission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Permission" (
    "queryableId" TEXT NOT NULL,
    "dbId" UUID NOT NULL,
    "projectConfigId" UUID,
    "projectId" TEXT,
    "teamId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "description" TEXT,
    "scope" "PermissionScope" NOT NULL,
    "isDefaultTeamCreatorPermission" BOOLEAN NOT NULL DEFAULT false,
    "isDefaultTeamMemberPermission" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Permission_pkey" PRIMARY KEY ("dbId")
);

-- CreateTable
CREATE TABLE "PermissionEdge" (
    "edgeId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "parentPermissionDbId" UUID,
    "parentTeamSystemPermission" "TeamSystemPermission",
    "childPermissionDbId" UUID NOT NULL,

    CONSTRAINT "PermissionEdge_pkey" PRIMARY KEY ("edgeId")
);

-- CreateTable
CREATE TABLE "ProjectUser" (
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "profileImageUrl" TEXT,
    "displayName" TEXT,
    "serverMetadata" JSONB,
    "clientReadOnlyMetadata" JSONB,
    "clientMetadata" JSONB,
    "requiresTotpMfa" BOOLEAN NOT NULL DEFAULT false,
    "totpSecret" BYTEA,

    CONSTRAINT "ProjectUser_pkey" PRIMARY KEY ("projectId","projectUserId")
);

-- CreateTable
CREATE TABLE "ProjectUserOAuthAccount" (
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "projectConfigId" UUID NOT NULL,
    "oauthProviderConfigId" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "email" TEXT,

    CONSTRAINT "ProjectUserOAuthAccount_pkey" PRIMARY KEY ("projectId","oauthProviderConfigId","providerAccountId")
);

-- CreateTable
CREATE TABLE "ContactChannel" (
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "type" "ContactChannelType" NOT NULL,
    "isPrimary" "BooleanTrue",
    "usedForAuth" "BooleanTrue",
    "isVerified" BOOLEAN NOT NULL,
    "value" TEXT NOT NULL,

    CONSTRAINT "ContactChannel_pkey" PRIMARY KEY ("projectId","projectUserId","id")
);

-- CreateTable
CREATE TABLE "ConnectedAccountConfig" (
    "projectConfigId" UUID NOT NULL,
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "ConnectedAccountConfig_pkey" PRIMARY KEY ("projectConfigId","id")
);

-- CreateTable
CREATE TABLE "ConnectedAccount" (
    "projectId" TEXT NOT NULL,
    "id" UUID NOT NULL,
    "projectConfigId" UUID NOT NULL,
    "connectedAccountConfigId" UUID NOT NULL,
    "projectUserId" UUID NOT NULL,
    "oauthProviderConfigId" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ConnectedAccount_pkey" PRIMARY KEY ("projectId","id")
);

-- CreateTable
CREATE TABLE "AuthMethodConfig" (
    "projectConfigId" UUID NOT NULL,
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "AuthMethodConfig_pkey" PRIMARY KEY ("projectConfigId","id")
);

-- CreateTable
CREATE TABLE "OtpAuthMethodConfig" (
    "projectConfigId" UUID NOT NULL,
    "authMethodConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "contactChannelType" "ContactChannelType" NOT NULL,

    CONSTRAINT "OtpAuthMethodConfig_pkey" PRIMARY KEY ("projectConfigId","authMethodConfigId")
);

-- CreateTable
CREATE TABLE "PasswordAuthMethodConfig" (
    "projectConfigId" UUID NOT NULL,
    "authMethodConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PasswordAuthMethodConfig_pkey" PRIMARY KEY ("projectConfigId","authMethodConfigId")
);

-- CreateTable
CREATE TABLE "PasskeyAuthMethodConfig" (
    "projectConfigId" UUID NOT NULL,
    "authMethodConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PasskeyAuthMethodConfig_pkey" PRIMARY KEY ("projectConfigId","authMethodConfigId")
);

-- CreateTable
CREATE TABLE "OAuthProviderConfig" (
    "projectConfigId" UUID NOT NULL,
    "id" TEXT NOT NULL,
    "authMethodConfigId" UUID,
    "connectedAccountConfigId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OAuthProviderConfig_pkey" PRIMARY KEY ("projectConfigId","id")
);

-- CreateTable
CREATE TABLE "ProxiedOAuthProviderConfig" (
    "projectConfigId" UUID NOT NULL,
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "type" "ProxiedOAuthProviderType" NOT NULL,

    CONSTRAINT "ProxiedOAuthProviderConfig_pkey" PRIMARY KEY ("projectConfigId","id")
);

-- CreateTable
CREATE TABLE "StandardOAuthProviderConfig" (
    "projectConfigId" UUID NOT NULL,
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "type" "StandardOAuthProviderType" NOT NULL,
    "clientId" TEXT NOT NULL,
    "clientSecret" TEXT NOT NULL,
    "facebookConfigId" TEXT,
    "microsoftTenantId" TEXT,

    CONSTRAINT "StandardOAuthProviderConfig_pkey" PRIMARY KEY ("projectConfigId","id")
);

-- CreateTable
CREATE TABLE "AuthMethod" (
    "projectId" TEXT NOT NULL,
    "id" UUID NOT NULL,
    "projectUserId" UUID NOT NULL,
    "authMethodConfigId" UUID NOT NULL,
    "projectConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AuthMethod_pkey" PRIMARY KEY ("projectId","id")
);

-- CreateTable
CREATE TABLE "OtpAuthMethod" (
    "projectId" TEXT NOT NULL,
    "authMethodId" UUID NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OtpAuthMethod_pkey" PRIMARY KEY ("projectId","authMethodId")
);

-- CreateTable
CREATE TABLE "PasswordAuthMethod" (
    "projectId" TEXT NOT NULL,
    "authMethodId" UUID NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "passwordHash" TEXT NOT NULL,

    CONSTRAINT "PasswordAuthMethod_pkey" PRIMARY KEY ("projectId","authMethodId")
);

-- CreateTable
CREATE TABLE "PasskeyAuthMethod" (
    "projectId" TEXT NOT NULL,
    "authMethodId" UUID NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "credentialId" TEXT NOT NULL,
    "publicKey" TEXT NOT NULL,
    "userHandle" TEXT NOT NULL,
    "transports" TEXT[],
    "credentialDeviceType" TEXT NOT NULL,
    "counter" INTEGER NOT NULL,

    CONSTRAINT "PasskeyAuthMethod_pkey" PRIMARY KEY ("projectId","authMethodId")
);

-- CreateTable
CREATE TABLE "OAuthAuthMethod" (
    "projectId" TEXT NOT NULL,
    "projectConfigId" UUID NOT NULL,
    "authMethodId" UUID NOT NULL,
    "oauthProviderConfigId" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OAuthAuthMethod_pkey" PRIMARY KEY ("projectId","authMethodId")
);

-- CreateTable
CREATE TABLE "OAuthToken" (
    "id" UUID NOT NULL,
    "projectId" TEXT NOT NULL,
    "oAuthProviderConfigId" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "refreshToken" TEXT NOT NULL,
    "scopes" TEXT[],

    CONSTRAINT "OAuthToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OAuthAccessToken" (
    "id" UUID NOT NULL,
    "projectId" TEXT NOT NULL,
    "oAuthProviderConfigId" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "accessToken" TEXT NOT NULL,
    "scopes" TEXT[],
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OAuthAccessToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OAuthOuterInfo" (
    "id" UUID NOT NULL,
    "info" JSONB NOT NULL,
    "innerState" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OAuthOuterInfo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectUserRefreshToken" (
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "refreshToken" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3),

    CONSTRAINT "ProjectUserRefreshToken_pkey" PRIMARY KEY ("projectId","refreshToken")
);

-- CreateTable
CREATE TABLE "ProjectUserAuthorizationCode" (
    "projectId" TEXT NOT NULL,
    "projectUserId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "authorizationCode" TEXT NOT NULL,
    "redirectUri" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "codeChallenge" TEXT NOT NULL,
    "codeChallengeMethod" TEXT NOT NULL,
    "newUser" BOOLEAN NOT NULL,
    "afterCallbackRedirectUrl" TEXT,

    CONSTRAINT "ProjectUserAuthorizationCode_pkey" PRIMARY KEY ("projectId","authorizationCode")
);

-- CreateTable
CREATE TABLE "VerificationCode" (
    "projectId" TEXT NOT NULL,
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "type" "VerificationCodeType" NOT NULL,
    "code" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "redirectUrl" TEXT,
    "method" JSONB NOT NULL DEFAULT 'null',
    "data" JSONB NOT NULL,
    "attemptCount" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "VerificationCode_pkey" PRIMARY KEY ("projectId","id")
);

-- CreateTable
CREATE TABLE "ApiKeySet" (
    "projectId" TEXT NOT NULL,
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "description" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "manuallyRevokedAt" TIMESTAMP(3),
    "publishableClientKey" TEXT,
    "secretServerKey" TEXT,
    "superSecretAdminKey" TEXT,

    CONSTRAINT "ApiKeySet_pkey" PRIMARY KEY ("projectId","id")
);

-- CreateTable
CREATE TABLE "EmailServiceConfig" (
    "projectConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmailServiceConfig_pkey" PRIMARY KEY ("projectConfigId")
);

-- CreateTable
CREATE TABLE "EmailTemplate" (
    "projectConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "content" JSONB NOT NULL,
    "type" "EmailTemplateType" NOT NULL,
    "subject" TEXT NOT NULL,

    CONSTRAINT "EmailTemplate_pkey" PRIMARY KEY ("projectConfigId","type")
);

-- CreateTable
CREATE TABLE "ProxiedEmailServiceConfig" (
    "projectConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProxiedEmailServiceConfig_pkey" PRIMARY KEY ("projectConfigId")
);

-- CreateTable
CREATE TABLE "StandardEmailServiceConfig" (
    "projectConfigId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "senderName" TEXT NOT NULL,
    "senderEmail" TEXT NOT NULL,
    "host" TEXT NOT NULL,
    "port" INTEGER NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,

    CONSTRAINT "StandardEmailServiceConfig_pkey" PRIMARY KEY ("projectConfigId")
);

-- CreateTable
CREATE TABLE "Event" (
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "isWide" BOOLEAN NOT NULL,
    "eventStartedAt" TIMESTAMP(3) NOT NULL,
    "eventEndedAt" TIMESTAMP(3) NOT NULL,
    "systemEventTypeIds" TEXT[],
    "data" JSONB NOT NULL,

    CONSTRAINT "Event_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ProjectDomain_projectConfigId_domain_key" ON "ProjectDomain"("projectConfigId", "domain");

-- CreateIndex
CREATE UNIQUE INDEX "TeamMember_projectId_projectUserId_isSelected_key" ON "TeamMember"("projectId", "projectUserId", "isSelected");

-- CreateIndex
CREATE UNIQUE INDEX "TeamMemberDirectPermission_projectId_projectUserId_teamId_p_key" ON "TeamMemberDirectPermission"("projectId", "projectUserId", "teamId", "permissionDbId");

-- CreateIndex
CREATE UNIQUE INDEX "TeamMemberDirectPermission_projectId_projectUserId_teamId_s_key" ON "TeamMemberDirectPermission"("projectId", "projectUserId", "teamId", "systemPermission");

-- CreateIndex
CREATE UNIQUE INDEX "Permission_projectConfigId_queryableId_key" ON "Permission"("projectConfigId", "queryableId");

-- CreateIndex
CREATE UNIQUE INDEX "Permission_projectId_teamId_queryableId_key" ON "Permission"("projectId", "teamId", "queryableId");

-- CreateIndex
CREATE INDEX "ProjectUser_displayName_asc" ON "ProjectUser"("projectId", "displayName" ASC);

-- CreateIndex
CREATE INDEX "ProjectUser_displayName_desc" ON "ProjectUser"("projectId", "displayName" DESC);

-- CreateIndex
CREATE INDEX "ProjectUser_createdAt_asc" ON "ProjectUser"("projectId", "createdAt" ASC);

-- CreateIndex
CREATE INDEX "ProjectUser_createdAt_desc" ON "ProjectUser"("projectId", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "ContactChannel_projectId_projectUserId_type_isPrimary_key" ON "ContactChannel"("projectId", "projectUserId", "type", "isPrimary");

-- CreateIndex
CREATE UNIQUE INDEX "ContactChannel_projectId_projectUserId_type_value_key" ON "ContactChannel"("projectId", "projectUserId", "type", "value");

-- CreateIndex
CREATE UNIQUE INDEX "ContactChannel_projectId_type_value_usedForAuth_key" ON "ContactChannel"("projectId", "type", "value", "usedForAuth");

-- CreateIndex
CREATE UNIQUE INDEX "ConnectedAccount_projectId_oauthProviderConfigId_providerAc_key" ON "ConnectedAccount"("projectId", "oauthProviderConfigId", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "OAuthProviderConfig_projectConfigId_authMethodConfigId_key" ON "OAuthProviderConfig"("projectConfigId", "authMethodConfigId");

-- CreateIndex
CREATE UNIQUE INDEX "OAuthProviderConfig_projectConfigId_connectedAccountConfigI_key" ON "OAuthProviderConfig"("projectConfigId", "connectedAccountConfigId");

-- CreateIndex
CREATE UNIQUE INDEX "ProxiedOAuthProviderConfig_projectConfigId_type_key" ON "ProxiedOAuthProviderConfig"("projectConfigId", "type");

-- CreateIndex
CREATE UNIQUE INDEX "OtpAuthMethod_projectId_projectUserId_key" ON "OtpAuthMethod"("projectId", "projectUserId");

-- CreateIndex
CREATE UNIQUE INDEX "PasswordAuthMethod_projectId_projectUserId_key" ON "PasswordAuthMethod"("projectId", "projectUserId");

-- CreateIndex
CREATE UNIQUE INDEX "PasskeyAuthMethod_projectId_projectUserId_key" ON "PasskeyAuthMethod"("projectId", "projectUserId");

-- CreateIndex
CREATE UNIQUE INDEX "OAuthAuthMethod_projectId_oauthProviderConfigId_providerAcc_key" ON "OAuthAuthMethod"("projectId", "oauthProviderConfigId", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "OAuthOuterInfo_innerState_key" ON "OAuthOuterInfo"("innerState");

-- CreateIndex
CREATE UNIQUE INDEX "ProjectUserRefreshToken_refreshToken_key" ON "ProjectUserRefreshToken"("refreshToken");

-- CreateIndex
CREATE UNIQUE INDEX "ProjectUserAuthorizationCode_authorizationCode_key" ON "ProjectUserAuthorizationCode"("authorizationCode");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationCode_projectId_code_key" ON "VerificationCode"("projectId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "ApiKeySet_publishableClientKey_key" ON "ApiKeySet"("publishableClientKey");

-- CreateIndex
CREATE UNIQUE INDEX "ApiKeySet_secretServerKey_key" ON "ApiKeySet"("secretServerKey");

-- CreateIndex
CREATE UNIQUE INDEX "ApiKeySet_superSecretAdminKey_key" ON "ApiKeySet"("superSecretAdminKey");

-- CreateIndex
CREATE INDEX "Event_data_idx" ON "Event" USING GIN ("data" jsonb_path_ops);

-- AddForeignKey
ALTER TABLE "Project" ADD CONSTRAINT "Project_configId_fkey" FOREIGN KEY ("configId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectDomain" ADD CONSTRAINT "ProjectDomain_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectConfigOverride" ADD CONSTRAINT "ProjectConfigOverride_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Team" ADD CONSTRAINT "Team_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamMember" ADD CONSTRAINT "TeamMember_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamMember" ADD CONSTRAINT "TeamMember_projectId_teamId_fkey" FOREIGN KEY ("projectId", "teamId") REFERENCES "Team"("projectId", "teamId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamMemberDirectPermission" ADD CONSTRAINT "TeamMemberDirectPermission_projectId_projectUserId_teamId_fkey" FOREIGN KEY ("projectId", "projectUserId", "teamId") REFERENCES "TeamMember"("projectId", "projectUserId", "teamId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamMemberDirectPermission" ADD CONSTRAINT "TeamMemberDirectPermission_permissionDbId_fkey" FOREIGN KEY ("permissionDbId") REFERENCES "Permission"("dbId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Permission" ADD CONSTRAINT "Permission_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Permission" ADD CONSTRAINT "Permission_projectId_teamId_fkey" FOREIGN KEY ("projectId", "teamId") REFERENCES "Team"("projectId", "teamId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PermissionEdge" ADD CONSTRAINT "PermissionEdge_parentPermissionDbId_fkey" FOREIGN KEY ("parentPermissionDbId") REFERENCES "Permission"("dbId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PermissionEdge" ADD CONSTRAINT "PermissionEdge_childPermissionDbId_fkey" FOREIGN KEY ("childPermissionDbId") REFERENCES "Permission"("dbId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUser" ADD CONSTRAINT "ProjectUser_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUserOAuthAccount" ADD CONSTRAINT "ProjectUserOAuthAccount_projectConfigId_oauthProviderConfi_fkey" FOREIGN KEY ("projectConfigId", "oauthProviderConfigId") REFERENCES "OAuthProviderConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUserOAuthAccount" ADD CONSTRAINT "ProjectUserOAuthAccount_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContactChannel" ADD CONSTRAINT "ContactChannel_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContactChannel" ADD CONSTRAINT "ContactChannel_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectedAccountConfig" ADD CONSTRAINT "ConnectedAccountConfig_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectedAccount" ADD CONSTRAINT "ConnectedAccount_projectId_oauthProviderConfigId_providerA_fkey" FOREIGN KEY ("projectId", "oauthProviderConfigId", "providerAccountId") REFERENCES "ProjectUserOAuthAccount"("projectId", "oauthProviderConfigId", "providerAccountId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectedAccount" ADD CONSTRAINT "ConnectedAccount_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectedAccount" ADD CONSTRAINT "ConnectedAccount_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectedAccount" ADD CONSTRAINT "ConnectedAccount_projectConfigId_connectedAccountConfigId_fkey" FOREIGN KEY ("projectConfigId", "connectedAccountConfigId") REFERENCES "ConnectedAccountConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectedAccount" ADD CONSTRAINT "ConnectedAccount_projectConfigId_oauthProviderConfigId_fkey" FOREIGN KEY ("projectConfigId", "oauthProviderConfigId") REFERENCES "OAuthProviderConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuthMethodConfig" ADD CONSTRAINT "AuthMethodConfig_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OtpAuthMethodConfig" ADD CONSTRAINT "OtpAuthMethodConfig_projectConfigId_authMethodConfigId_fkey" FOREIGN KEY ("projectConfigId", "authMethodConfigId") REFERENCES "AuthMethodConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasswordAuthMethodConfig" ADD CONSTRAINT "PasswordAuthMethodConfig_projectConfigId_authMethodConfigI_fkey" FOREIGN KEY ("projectConfigId", "authMethodConfigId") REFERENCES "AuthMethodConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasskeyAuthMethodConfig" ADD CONSTRAINT "PasskeyAuthMethodConfig_projectConfigId_authMethodConfigId_fkey" FOREIGN KEY ("projectConfigId", "authMethodConfigId") REFERENCES "AuthMethodConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthProviderConfig" ADD CONSTRAINT "OAuthProviderConfig_projectConfigId_authMethodConfigId_fkey" FOREIGN KEY ("projectConfigId", "authMethodConfigId") REFERENCES "AuthMethodConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthProviderConfig" ADD CONSTRAINT "OAuthProviderConfig_projectConfigId_connectedAccountConfig_fkey" FOREIGN KEY ("projectConfigId", "connectedAccountConfigId") REFERENCES "ConnectedAccountConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthProviderConfig" ADD CONSTRAINT "OAuthProviderConfig_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProxiedOAuthProviderConfig" ADD CONSTRAINT "ProxiedOAuthProviderConfig_projectConfigId_id_fkey" FOREIGN KEY ("projectConfigId", "id") REFERENCES "OAuthProviderConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StandardOAuthProviderConfig" ADD CONSTRAINT "StandardOAuthProviderConfig_projectConfigId_id_fkey" FOREIGN KEY ("projectConfigId", "id") REFERENCES "OAuthProviderConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuthMethod" ADD CONSTRAINT "AuthMethod_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuthMethod" ADD CONSTRAINT "AuthMethod_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuthMethod" ADD CONSTRAINT "AuthMethod_projectConfigId_authMethodConfigId_fkey" FOREIGN KEY ("projectConfigId", "authMethodConfigId") REFERENCES "AuthMethodConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OtpAuthMethod" ADD CONSTRAINT "OtpAuthMethod_projectId_authMethodId_fkey" FOREIGN KEY ("projectId", "authMethodId") REFERENCES "AuthMethod"("projectId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OtpAuthMethod" ADD CONSTRAINT "OtpAuthMethod_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasswordAuthMethod" ADD CONSTRAINT "PasswordAuthMethod_projectId_authMethodId_fkey" FOREIGN KEY ("projectId", "authMethodId") REFERENCES "AuthMethod"("projectId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasswordAuthMethod" ADD CONSTRAINT "PasswordAuthMethod_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasskeyAuthMethod" ADD CONSTRAINT "PasskeyAuthMethod_projectId_authMethodId_fkey" FOREIGN KEY ("projectId", "authMethodId") REFERENCES "AuthMethod"("projectId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasskeyAuthMethod" ADD CONSTRAINT "PasskeyAuthMethod_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthAuthMethod" ADD CONSTRAINT "OAuthAuthMethod_projectId_authMethodId_fkey" FOREIGN KEY ("projectId", "authMethodId") REFERENCES "AuthMethod"("projectId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthAuthMethod" ADD CONSTRAINT "OAuthAuthMethod_projectId_oauthProviderConfigId_providerAc_fkey" FOREIGN KEY ("projectId", "oauthProviderConfigId", "providerAccountId") REFERENCES "ProjectUserOAuthAccount"("projectId", "oauthProviderConfigId", "providerAccountId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthAuthMethod" ADD CONSTRAINT "OAuthAuthMethod_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthAuthMethod" ADD CONSTRAINT "OAuthAuthMethod_projectConfigId_oauthProviderConfigId_fkey" FOREIGN KEY ("projectConfigId", "oauthProviderConfigId") REFERENCES "OAuthProviderConfig"("projectConfigId", "id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthToken" ADD CONSTRAINT "OAuthToken_projectId_oAuthProviderConfigId_providerAccount_fkey" FOREIGN KEY ("projectId", "oAuthProviderConfigId", "providerAccountId") REFERENCES "ProjectUserOAuthAccount"("projectId", "oauthProviderConfigId", "providerAccountId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OAuthAccessToken" ADD CONSTRAINT "OAuthAccessToken_projectId_oAuthProviderConfigId_providerA_fkey" FOREIGN KEY ("projectId", "oAuthProviderConfigId", "providerAccountId") REFERENCES "ProjectUserOAuthAccount"("projectId", "oauthProviderConfigId", "providerAccountId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUserRefreshToken" ADD CONSTRAINT "ProjectUserRefreshToken_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectUserAuthorizationCode" ADD CONSTRAINT "ProjectUserAuthorizationCode_projectId_projectUserId_fkey" FOREIGN KEY ("projectId", "projectUserId") REFERENCES "ProjectUser"("projectId", "projectUserId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiKeySet" ADD CONSTRAINT "ApiKeySet_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmailServiceConfig" ADD CONSTRAINT "EmailServiceConfig_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "ProjectConfig"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmailTemplate" ADD CONSTRAINT "EmailTemplate_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "EmailServiceConfig"("projectConfigId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProxiedEmailServiceConfig" ADD CONSTRAINT "ProxiedEmailServiceConfig_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "EmailServiceConfig"("projectConfigId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StandardEmailServiceConfig" ADD CONSTRAINT "StandardEmailServiceConfig_projectConfigId_fkey" FOREIGN KEY ("projectConfigId") REFERENCES "EmailServiceConfig"("projectConfigId") ON DELETE CASCADE ON UPDATE CASCADE;

