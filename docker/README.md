### Docker - Build at Building Server

1. **Update Environment Variables**
   - Navigate to `docker/setup` and update the `.env` file:
     ```sh
     cd docker/setup
     cp .env.development .env
     cd ../..
     ```

2. **Create Tokens**
   - Install dependencies and run the key generation script:
     ```sh
     cd docker/setup
     pnpm i --ignore-workspace
     pnpm tsx scripts/generateKeys.ts
     cd ../..
     ```

3. **Configure Hosts**
   - Set the following environment variables:
     ```env
     NEXT_PUBLIC_STACK_URL=https://api.stack-auth.internal
     NEXT_PUBLIC_STACK_SVIX_SERVER_URL=https://svix-api.stack-auth.internal
     NEXT_PUBLIC_STACK_HEAD_TAGS=[{ "tagName": "script", "attributes": {}, "innerHTML": "// insert head tags here" }]
     ```

4. **Sentry Integration**
   - Set up Sentry variables according to [Sentry's documentation](https://docs.sentry.io/platforms/javascript/guides/nextjs/manual-setup):
     ```env
     NEXT_PUBLIC_SENTRY_DSN=
     NEXT_PUBLIC_SENTRY_ORG=
     NEXT_PUBLIC_SENTRY_PROJECT=
     SENTRY_AUTH_TOKEN=
     ```

5. **Generate Builder Environment**
   - Run the builder environment generation script:
     ```sh
     cd docker/setup
     pnpm dotenv -c -- tsx scripts/generateBuilderEnv.ts
     cd ../..
     ```

6. **Build Docker Images**
   - Navigate to `docker/builder` and build:
     ```sh
     cd docker/builder
     docker compose build
     cd ..
     ```

---

### Services at Deployment Server

1. **Prepare Environment Files**
   - Copy the `.env.dashboard` configuration:
     ```sh
     cd docker/setup
     pnpm dotenv -c -- tsx scripts/generateDashboardEnv.ts
     cd ../..
     ```

2. **Configure `.env` File**
   - Populate `.env` in `docker/services` with required values from `setup/.env`:
     - `POSTGRES_STACKFRAME_PASSWORD`
     - `POSTGRES_SVIX_PASSWORD`
     - `SVIX_JWT_SECRET`

3. **Configure `.env.backend` File**
   - Include necessary secrets like `STACK_SERVER_SECRET` and `STACK_SVIX_API_KEY`.
   - Generate the `STACK_SVIX_API_KEY`:
     ```sh
     docker compose up svix-server -d
     docker exec -it <container_id> sh
     svix-server jwt generate
     ```

4. **Configure Sentry Variables**
   - Copy Sentry-related variables into `.env.sentry` from `setup/.env`.

5. **SSL Certificates**
   - Place SSL files in the `certs` directory.

6. **Start Docker Services**
   - Start services in detached mode:
     ```sh
     cd docker/services
     docker compose up -d
     ```

7. **Initialize Data**
   - If deploying and building on the same server, run initialization:
     ```sh
     cd docker/setup
     cp -r ../../apps/backend/prisma/ .
     pnpm prisma generate
     pnpm prisma migrate deploy
     pnpm dotenv -c -- tsx scripts/seed.ts
     ```
   - Use `pnpm prisma studio` to update ProjectUser, adding `"internal"` to `managedProjectIds`.

8. **User Signup**
   - Access `https://stack-auth.internal` and complete the signup process.
   - Ignore whitelist warnings on first-time signup and proceed to sign in.

9. **Set Domains and Handlers**
   - In the Admin project:
     - Disable localhost.
     - Add `https://stack-auth.internal` to domains.
     - Set user to "verified" for otp.
