# Azure AD Setup Guide

This guide explains how to configure Azure Active Directory (Microsoft Entra ID) for OpenFlow authentication.

## Prerequisites

- Azure account with Azure Active Directory access
- Azure Student account (recommended for students)
- Access to Azure Portal

## Step 1: Register Application in Azure Portal

1. Log in to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** (or **Microsoft Entra ID**)
3. Click on **App registrations** in the left menu
4. Click **New registration**

### Application Registration Details

- **Name**: `OpenFlow` (or your preferred name)
- **Supported account types**: 
  - For single organization: **Accounts in this organizational directory only**
  - For multiple organizations: **Accounts in any organizational directory**
- **Redirect URI**: 
  - Type: **Web**
  - URI: 
    - Development: `http://localhost:8080/login/oauth2/code/azure`
    - Production: `https://<your-backend-url>/login/oauth2/code/azure`
  - **Important**: 
    - Replace `<your-backend-url>` with your actual backend URL
    - Must use HTTPS (except localhost)
    - **Don't have a domain?** See [Simple HTTPS Setup Guide](https-setup-simple.md) for options including cheap domains ($1-2/year)
    - See [HTTPS Setup Guide](https-setup.md) for full setup instructions

5. Click **Register**

## Step 2: Configure API Permissions

1. In your app registration, go to **API permissions**
2. Click **Add a permission**
3. Select **Microsoft Graph**
4. Select **Delegated permissions**
5. Add the following permissions:
   - `openid` (usually added automatically)
   - `profile`
   - `email`
6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]** (if you have admin rights)
   - This step is required for the permissions to work

## Step 3: Create Client Secret

1. In your app registration, go to **Certificates & secrets**
2. Click **New client secret**
3. Enter a description: `OpenFlow Production Secret` (or your preferred name)
4. Select expiration: **24 months** (or per your organization's policy)
5. Click **Add**
6. **IMPORTANT**: Copy the secret value immediately - it's shown only once!
   - Store this securely - you'll need it for GitHub Secrets

## Step 4: Collect Required Information

You'll need the following values for GitHub Secrets:

### Application (client) ID
- Location: App registration → **Overview** → **Application (client) ID**
- Format: GUID (e.g., `12345678-1234-1234-1234-123456789012`)

### Directory (tenant) ID
- Location: App registration → **Overview** → **Directory (tenant) ID**
- Format: GUID (e.g., `87654321-4321-4321-4321-210987654321`)

### Client Secret Value
- Location: The value you copied in Step 3
- Format: Secret string

### Issuer URI
- Format: `https://login.microsoftonline.com/{tenant-id}/v2.0`
- Example: `https://login.microsoftonline.com/87654321-4321-4321-4321-210987654321/v2.0`
- Replace `{tenant-id}` with your Directory (tenant) ID

### JWK Set URI
- Format: `https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys`
- Example: `https://login.microsoftonline.com/87654321-4321-4321-4321-210987654321/discovery/v2.0/keys`
- Replace `{tenant-id}` with your Directory (tenant) ID

## Step 5: Configure Redirect URIs

1. In your app registration, go to **Authentication**
2. Under **Redirect URIs**, add:
   - Development: `http://localhost:8080/login/oauth2/code/azure`
   - Production: `https://api.openflow.world/login/oauth2/code/azure`
   - **Note**: Replace with your actual backend domain if different
3. Under **Implicit grant and hybrid flows**, ensure:
   - **ID tokens** is checked (if needed)
4. Click **Save**

## Step 6: Configure Role-Based Access Control (RBAC)

OpenFlow supports two mechanisms for role assignment from Azure AD:

### Option A: Azure AD Groups (Recommended)

1. In Azure Portal, go to **Azure Active Directory** → **Groups**
2. Create the following groups:
   - **Openflow-Admins**: Users with full admin access (create/manage boards, columns, users)
   - **Openflow-Users**: Normal users (create/move/modify tasks, comment)
3. Add users to the appropriate groups
4. In your App Registration, go to **Token configuration**
5. Click **Add groups claim**
6. Select **Security groups** and configure:
   - For ID token: Check **Group ID**
   - For Access token: Check **Group ID**
7. Click **Add**
8. Copy the **Object ID** of each group (found in Groups → select group → Overview)

### Option B: App Roles

1. In your App Registration, go to **App roles**
2. Click **Create app role**
3. Create the following roles:
   - **Admin**:
     - Display name: `Administrator`
     - Allowed member types: `Users/Groups`
     - Value: `Admin`
     - Description: `Full access to create and manage boards, columns, and users`
   - **User**:
     - Display name: `Normal User`
     - Allowed member types: `Users/Groups`
     - Value: `User`
     - Description: `Can create, move, and modify tasks`
4. Go to **Enterprise applications** → Select your app → **Users and groups**
5. Click **Add user/group** and assign roles to users/groups

### Role Mapping in OpenFlow

| Role in OpenFlow | Azure AD Group | App Role | Access |
|------------------|----------------|----------|--------|
| ADMIN | Openflow-Admins | Admin | Create/manage boards, columns, and user access |
| USER | Openflow-Users | User | Create/move/modify tasks and comment |
| Anonymous | (not authenticated) | - | View public boards only |

## Step 7: Add Secrets to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets (see [GitHub Secrets Setup Guide](github-secrets-setup.md) for details):
   - `AZURE_TENANT_ID` - Your Directory (tenant) ID
   - `AZURE_CLIENT_ID` - Your Application (client) ID
   - `AZURE_CLIENT_SECRET` - Your client secret value
   - `AZURE_ISSUER_URI` - Issuer URI (from Step 4)
   - `AZURE_JWK_SET_URI` - JWK Set URI (from Step 4)
   - `AUTH_MODE` - `both`, `azure`, or `jwt` (optional, defaults to `both`)
   - `AZURE_ADMIN_GROUP_ID` - Object ID of Openflow-Admins group (if using groups)
   - `AZURE_USER_GROUP_ID` - Object ID of Openflow-Users group (optional)

## Step 8: Environment-Specific Configuration

### Development Environment
- Use `http://localhost:8080/login/oauth2/code/azure` as redirect URI
- Can use same Azure AD app or create separate app for development

### Staging Environment
- Use staging backend URL: `https://staging-api.example.com/login/oauth2/code/azure`
- Consider creating separate Azure AD app for staging

### Production Environment
- Use production backend URL: `https://api.example.com/login/oauth2/code/azure`
- Use production Azure AD app
- Ensure client secret is not expired

## Troubleshooting

### Common Issues

#### "Redirect URI mismatch" Error
- **Cause**: Redirect URI in Azure Portal doesn't match the one used by the application
- **Solution**: 
  1. Check the exact redirect URI in Azure Portal (App registration → Authentication)
  2. Ensure it matches exactly: `https://<your-backend-url>/login/oauth2/code/azure`
  3. Check for trailing slashes, http vs https, etc.

#### "Invalid client secret" Error
- **Cause**: Client secret expired or incorrect
- **Solution**:
  1. Create a new client secret in Azure Portal
  2. Update `AZURE_CLIENT_SECRET` in GitHub Secrets
  3. Redeploy the application

#### "Insufficient privileges" Error
- **Cause**: API permissions not granted or admin consent not provided
- **Solution**:
  1. Go to App registration → API permissions
  2. Ensure `openid`, `profile`, `email` are added
  3. Click "Grant admin consent" if you have admin rights
  4. If you don't have admin rights, contact your Azure AD administrator

#### Authentication Works But User Not Created
- **Cause**: Azure AD filter not processing correctly
- **Solution**:
  1. Check backend logs for errors
  2. Verify `AUTH_MODE` is set to `both` or `azure`
  3. Check database connection
  4. Verify Azure AD claims are being extracted correctly

### Verification Steps

1. **Test Azure AD Login**:
   - Click "Sign in with Microsoft" on login page
   - Should redirect to Microsoft login
   - After login, should redirect back to application
   - User should be created in database

2. **Check User in Database**:
   - Verify user has `authProvider = "azure"`
   - Verify `azureAdId` is set
   - Verify `password` is null (Azure AD users don't have passwords)
   - Verify `role` is set correctly (ADMIN or USER)

3. **Test Role Assignment**:
   - Log in with a user in Openflow-Admins group
   - Verify the user can create boards and manage columns
   - Log in with a user in Openflow-Users group
   - Verify the user can only create/modify tasks
   - Access `/public/boards` without authentication to verify anonymous access

5. **Check Backend Logs**:
   - Look for Azure AD authentication messages
   - Look for role extraction logs (e.g., "User is member of admin group")
   - Check for any errors in user sync process

## Security Best Practices

1. **Client Secret Rotation**:
   - Rotate client secrets regularly (before expiration)
   - Update GitHub Secrets when rotating
   - Use separate secrets for different environments

2. **Redirect URI Security**:
   - Use HTTPS in production
   - Don't use wildcard redirect URIs
   - Validate redirect URIs match exactly

3. **Permission Management**:
   - Use least privilege principle
   - Only request necessary permissions
   - Regularly review and remove unused permissions

4. **Secret Storage**:
   - Never commit secrets to version control
   - Use GitHub Secrets for CI/CD
   - Use Kubernetes Secrets for runtime
   - Rotate secrets on security incidents

## Next Steps

- Review [GitHub Secrets Setup Guide](github-secrets-setup.md) for secret configuration
- Check [Installation Guide](installation.md) for deployment steps
- See [Architecture Documentation](overview.md) for system overview

## Additional Resources

- [Azure AD Documentation](https://docs.microsoft.com/en-us/azure/active-directory/)
- [Spring Security OAuth2 Documentation](https://docs.spring.io/spring-security/reference/servlet/oauth2/index.html)
- [Microsoft Identity Platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/)

