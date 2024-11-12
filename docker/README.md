### Stack Auth Setup Guide

This guide provides step-by-step instructions to set up the `stack-auth` environment using Docker. Follow each step carefully to ensure proper configuration and smooth execution.

---

### 1. **Create `.env` File**
   - Copy the development environment file:
     ```sh
     cp .env.development .env
     ```
   - **Note**: After copying, open the new `.env` file and adjust environment variables as needed.

---

### 2. **Build Docker Images**
   - Build Docker images. If you change any `NEXT_JS_*` environment variables in `.env`, rebuild the images for those changes to take effect:
     ```sh
     docker compose -f docker-compose.builder.yaml build
     ```

---

### 3. **Setup Service**
   - **Download Config Files**:
     - Fetch the latest config files and organize them into the required directories:
       ```sh
       wget https://github.com/ShaunDyson-leetcode/stack/archive/refs/heads/dev.zip -O repo.zip
       unzip repo.zip "stack-dev/docker/*" -d stack-auth
       mv stack-auth/stack-dev/docker stack-auth/
       rm -rf stack-auth/stack-dev repo.zip
       ```

---

### 4. **Network and DNS Setup**
   - **DNS Entries**:
     - Add the following entries to your system’s `/etc/hosts` file (or DNS management system):
       - `stack-auth.internal`
       - `svix-api.stack-auth.internal`
       - `api.stack-auth.internal`
   - **Port Exposure**:
     - Ensure the following ports are accessible:
       - **443**: Main service
       - **8111**: Optional (database)
     - **Firewall**: If you are on a network with firewall restrictions, ensure these ports are open.
   - **Self-Signed SSL Certificates**:
     - Place SSL files in the `volumes/nginx/certs` directory.
     - If you need to create self-signed certificates, use:
       ```sh
       openssl genrsa -out stack-auth.key 2048
       openssl req -new -key stack-auth.key -out stack-auth.csr
       openssl x509 -req -days 365 -in stack-auth.csr -signkey stack-auth.key -out stack-auth.crt
       ```
     - **Note**: This is optional for development but recommended for production. Uncomment `DEPTH_ZERO_SELF_SIGNED_CERT` in `.env` if using self-signed certificates.

---

### 5. **Start Services**
   - Start Docker services in detached mode:
     ```sh
     docker compose up -d
     ```
   - **Verification**: Run `docker ps` to confirm that all services started successfully.
   - **Troubleshooting**: Common errors at this step may include port conflicts or permission issues. Check Docker logs if services fail to start.

   - **Access Services**:
     - Open the following URLs in your browser:
       - `https://svix-api.stack-auth.internal`
       - `https://api.stack-auth.internal`
       - `https://stack-auth.internal`
     - **Browser Compatibility**: Certain browsers may show a warning for self-signed certificates; proceed past these warnings to access the sites.

---

### 6. **User Signup**
   - Access `https://stack-auth.internal` to complete the signup process.
   - **Note**: Ignore any whitelist warnings on your first login; these warnings will not affect your signup process.

---

### 7. **Set Domains and Handlers**
   - Access the Admin project (refer to the project documentation if unsure how to access this).
   - Update settings as follows:
     - **Disable**: `localhost` domain for security.
     - **Add**: `https://stack-auth.internal` to the allowed domains.
     - **Set User Verification**: Set the user to "verified" for OTP.

---

## **Development**

```sh
pnpm prisma migrate diff --from-empty --to-schema-datamodel ../../apps/backend/prisma/schema.prisma --script > ../stack-auth-services/volumes/db/stack-auth-init.sql
```