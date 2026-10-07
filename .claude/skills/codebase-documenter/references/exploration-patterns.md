# Exploration Patterns by Framework

Use these grep patterns and glob expressions during Phase 2–4 exploration.

## Ruby on Rails

### Entry Points
```bash
# Routes overview
Glob: config/routes.rb
Grep: "resources|namespace|scope|get|post|put|patch|delete" in config/routes.rb

# Controllers
Glob: app/controllers/**/*.rb, engines/**/app/controllers/**/*.rb

# GraphQL schema roots
Glob: engines/**/app/graphql/**/*.rb
Grep: "mutation_type|query_type|subscription_type" in **/graphql/**

# Background jobs
Glob: app/jobs/**/*.rb, engines/**/app/jobs/**/*.rb

# Event handlers / listeners
Grep: "ActiveSupport::Notifications|subscribe|on " in app/

# Webhooks
Grep: "webhook" in app/controllers/ (case-insensitive)
```

### Data Models
```bash
# Schema
Read: db/schema.rb

# Models
Glob: app/models/**/*.rb, engines/**/app/models/**/*.rb

# Key associations
Grep: "belongs_to|has_many|has_one|has_and_belongs_to" in app/models/

# STI
Grep: "self.inheritance_column|type:" in app/models/

# Soft delete
Grep: "discarded_at|deleted_at|paranoia|discard" in app/models/
```

### Services / Business Logic
```bash
Glob: app/services/**/*.rb, engines/**/app/services/**/*.rb
Glob: app/mediators/**/*.rb, engines/**/app/mediators/**/*.rb
Glob: app/interactors/**/*.rb
Glob: app/commands/**/*.rb

# Dry::Monads usage
Grep: "include Dry::Monads|Success|Failure" in app/
```

### External Integrations
```bash
# HTTP clients
Grep: "Faraday|HTTParty|Net::HTTP|RestClient" in app/

# Specific SDKs
Grep: "Stripe::|Twilio::|SendGrid|MailgunClient" in app/

# ENV-based integrations
Grep: "ENV\[" in app/ (reveals external service config keys)
```

### Sidekiq / Background Jobs
```bash
Glob: app/jobs/**/*.rb
Grep: "perform_later|perform_async|delay" in app/
Grep: "sidekiq_options|queue_as" in app/jobs/
Read: config/sidekiq.yml
```

---

## Node.js / Fastify / Express

### Entry Points
```bash
Glob: src/**/routes/**/*.ts, src/**/routes/**/*.js
Glob: src/app.ts, src/server.ts, src/index.ts
Grep: "fastify.register|app.use|router\." in src/
Grep: "\.get\(|\.post\(|\.put\(|\.patch\(|\.delete\(" in src/routes/
```

### Data Models
```bash
# TypeORM / Prisma / Mongoose
Glob: src/models/**/*.ts, src/entities/**/*.ts, prisma/schema.prisma
Grep: "@Entity|@Column|@OneToMany|@ManyToOne|Schema\(" in src/

# Migrations
Glob: src/migrations/**/*.ts, db/migrations/**
```

### Services / Business Logic
```bash
Glob: src/services/**/*.ts, src/handlers/**/*.ts
Grep: "export class|export function" in src/services/
```

### External Integrations
```bash
Grep: "require\(|import.*from" in src/ | grep -i "stripe|twilio|sendgrid|axios|node-fetch"
Grep: "process.env" in src/ (reveals integration config)
```

### Background Jobs (BullMQ / Bull)
```bash
Glob: src/jobs/**/*.ts, src/workers/**/*.ts, src/queues/**/*.ts
Grep: "new Worker|new Queue|Bull\(" in src/
```

---

## React Native / Expo

### Entry Points
```bash
Glob: App.tsx, src/app/**/*.tsx, app/**/*.tsx (Expo Router)
Glob: src/navigation/**/*.tsx

# GraphQL operations
Glob: src/**/*.graphql, src/**/queries/**/*.ts, src/**/mutations/**/*.ts
Grep: "gql`|useQuery|useMutation|useSubscription" in src/
```

### Data / State
```bash
# Apollo cache / types
Glob: src/__generated__/**/*.ts (codegen output)
Grep: "InMemoryCache|TypePolicy|keyFields" in src/

# Local state
Grep: "useContext|createContext|Zustand|Redux|Jotai|Recoil" in src/
```

### External Integrations
```bash
Grep: "expo-notifications|expo-location|@stripe|RevenueCat" in package.json
Grep: "import.*from 'expo-" in src/
```

---

## Cross-Framework Patterns

### Finding Data Flow Boundaries
```bash
# Where data enters the system
Grep: "params\[|request\.body|req\.body|event\[" (controllers/handlers)

# Where data leaves the system (external calls)
Grep: "HTTP|fetch\(|axios|Faraday|RestClient|curl" in app/lib/, app/services/

# Error handling patterns
Grep: "rescue|catch|begin.*rescue|try.*catch" in app/services/

# Logging (reveals important transitions)
Grep: "Rails\.logger|logger\." in app/services/
```

### Identifying Key Patterns
```bash
# Result/Either pattern
Grep: "Success\(|Failure\(|Result\." in app/

# Observer/event pattern
Grep: "publish|emit|broadcast|notify|fire" in app/

# Repository pattern
Grep: "Repository|Repo|find_by|where\(" in app/
```
