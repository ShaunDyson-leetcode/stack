console.log('#.env.dashboard')
console.log(`NEXT_PUBLIC_STACK_URL=${process.env.NEXT_PUBLIC_STACK_URL}`);
console.log(`NEXT_PUBLIC_STACK_PROJECT_ID=internal`);
console.log(`NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=${process.env.NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY}`);
console.log(`STACK_SECRET_SERVER_KEY=${process.env.STACK_SECRET_SERVER_KEY}`);
console.log(`NEXT_PUBLIC_STACK_SVIX_SERVER_URL=${process.env.NEXT_PUBLIC_STACK_SVIX_SERVER_URL}`);
console.log(`NEXT_PUBLIC_STACK_HEAD_TAGS=${process.env.NEXT_PUBLIC_STACK_HEAD_TAGS}`)
console.log()
console.log('#.env.backend')
console.log(`STACK_SERVER_SECRET=${process.env.STACK_SERVER_SECRET}`)
console.log()
console.log('#sentry')
console.log(`NEXT_PUBLIC_SENTRY_DSN=${process.env.NEXT_PUBLIC_SENTRY_DSN}`)
console.log(`NEXT_PUBLIC_SENTRY_ORG=${process.env.NEXT_PUBLIC_SENTRY_ORG}`)
console.log(`NEXT_PUBLIC_SENTRY_PROJECT=${process.env.NEXT_PUBLIC_SENTRY_PROJECT}`)
console.log(`SENTRY_AUTH_TOKEN=${process.env.SENTRY_AUTH_TOKEN}`)
