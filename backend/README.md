# FindItKIET Backend

Production-ready RESTful API for campus lost-and-found system built with Node.js, TypeScript, Express, Prisma, and PostgreSQL.

## Features

- 🔐 **Secure Authentication** - JWT with rotating refresh tokens
- 👥 **Role-Based Access Control** - USER and ADMIN roles
- 📦 **Item Management** - Report, search, and browse lost/found items
- ✅ **Proof-Based Claims** - Submit ownership proofs for verification
- 🛡️ **Admin Moderation** - Claim review, approval/rejection, and handover tracking
- 📊 **Audit Logging** - Immutable log of all admin actions
- 🚦 **Rate Limiting** - Protection against abuse
- ✨ **Type Safety** - Full TypeScript implementation
- 🔍 **Validation** - Zod schemas for all inputs
- 🏥 **Health Checks** - Monitoring endpoint

## Tech Stack

- **Runtime:** Node.js
- **Language:** TypeScript
- **Framework:** Express.js
- **Database:** PostgreSQL
- **ORM:** Prisma
- **Validation:** Zod
- **Authentication:** JWT (jsonwebtoken)
- **Password Hashing:** bcrypt
- **Logging:** Winston
- **Security:** Helmet, CORS, Rate Limiting

## Prerequisites

- Node.js >= 18.x
- PostgreSQL >= 14.x
- npm or yarn

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and configure:
   - `DATABASE_URL` - Your PostgreSQL connection string
   - `JWT_ACCESS_SECRET` - Secret for access tokens (min 32 chars)
   - `JWT_REFRESH_SECRET` - Secret for refresh tokens (min 32 chars)
   - Other configuration as needed

3. **Generate Prisma client:**
   ```bash
   npm run prisma:generate
   ```

4. **Run database migrations:**
   ```bash
   npm run prisma:migrate
   ```

5. **Start development server:**
   ```bash
   npm run dev
   ```

   Server will start on `http://localhost:3000`

## Database Setup

### Using Local PostgreSQL

1. Install PostgreSQL
2. Create database:
   ```sql
   CREATE DATABASE finditkiet;
   ```
3. Update `DATABASE_URL` in `.env`:
   ```
   DATABASE_URL="postgresql://username:password@localhost:5432/finditkiet?schema=public"
   ```

### Using Docker

```bash
docker run --name finditkiet-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=finditkiet \
  -p 5432:5432 \
  -d postgres:15
```

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Run production build
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run database migrations
- `npm run prisma:studio` - Open Prisma Studio (GUI)

## API Documentation

Base URL: `http://localhost:3000/api/v1`

### Authentication

```bash
# Register
POST /auth/register
{
  "email": "student@example.com",
  "password": "<your-password>",
  "name": "John Doe"
}

# Login
POST /auth/login
{
  "email": "student@example.com",
  "password": "<your-password>"
}

# Refresh token
POST /auth/refresh
{
  "refreshToken": "your-refresh-token"
}

# Logout
POST /auth/logout
{
  "refreshToken": "your-refresh-token"
}
```

### Items

```bash
# Create item (requires auth)
POST /items
Authorization: Bearer <access-token>
{
  "title": "Black Wallet",
  "description": "Leather wallet found in library",
  "category": "ACCESSORIES",
  "status": "FOUND",
  "location": "Library 2nd Floor",
  "reportedAt": "2026-02-03T10:00:00Z",
  "imageUrls": ["https://example.com/image.jpg"]
}

# List items (public)
GET /items?status=FOUND&category=ELECTRONICS&search=phone&page=1&limit=20

# Get item details (public)
GET /items/:id

# Update item (requires auth, owner or admin)
PATCH /items/:id
Authorization: Bearer <access-token>
{
  "title": "Updated Title",
  "description": "Updated description"
}

# Delete item (requires auth, owner or admin)
DELETE /items/:id
Authorization: Bearer <access-token>

# Get my items (requires auth)
GET /items/me/items
Authorization: Bearer <access-token>
```

### Claims

```bash
# Create claim (requires auth)
POST /items/:itemId/claims
Authorization: Bearer <access-token>
{
  "proofs": [
    {
      "type": "DESCRIPTION",
      "value": "Small scratch near the zipper"
    },
    {
      "type": "SERIAL_NUMBER",
      "value": "ABC123456",
      "imageUrl": "https://example.com/proof.jpg"
    }
  ]
}

# Get my claims (requires auth)
GET /claims/me
Authorization: Bearer <access-token>

# Get claim details (requires auth)
GET /claims/:claimId
Authorization: Bearer <access-token>
```

### Admin (ADMIN role only)

```bash
# Get all claims
GET /admin/claims?status=PENDING&page=1&limit=20
Authorization: Bearer <admin-access-token>

# Approve claim
POST /admin/claims/:claimId/approve
Authorization: Bearer <admin-access-token>
{
  "comment": "Verified with ID proof"
}

# Reject claim
POST /admin/claims/:claimId/reject
Authorization: Bearer <admin-access-token>
{
  "reason": "Insufficient proof provided"
}

# Mark item as recovered (handover complete)
POST /admin/items/:itemId/handover
Authorization: Bearer <admin-access-token>
{
  "notes": "Item returned to owner"
}

# Delete item
DELETE /admin/items/:itemId
Authorization: Bearer <admin-access-token>

# Get all items
GET /admin/items?page=1&limit=20
Authorization: Bearer <admin-access-token>

# Get audit logs
GET /admin/audit-logs?page=1&limit=50
Authorization: Bearer <admin-access-token>
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { ... }
  }
}
```

## Security Features

- **JWT Authentication** with short-lived access tokens (15 min)
- **Rotating Refresh Tokens** for enhanced security
- **Role-Based Authorization** (USER, ADMIN)
- **Rate Limiting** on sensitive endpoints
- **Input Validation** with Zod schemas
- **SQL Injection Protection** via Prisma ORM
- **Password Hashing** with bcrypt (12 rounds)
- **Helmet.js** for security headers
- **CORS** configuration

## Production Deployment

1. **Set environment to production:**
   ```
   NODE_ENV=production
   ```

2. **Use strong secrets:**
   - Generate secure JWT secrets (min 32 characters)
   - Use proper PostgreSQL credentials

3. **Deploy database migrations:**
   ```bash
   npm run prisma:deploy
   ```

4. **Build and start:**
   ```bash
   npm run build
   npm start
   ```

5. **Set up reverse proxy** (nginx/Apache) for SSL

6. **Enable monitoring** and health checks

## Project Structure

```
backend/
├── src/
│   ├── config/          # Environment and database config
│   ├── middlewares/     # Express middlewares
│   ├── modules/         # Feature modules
│   │   ├── auth/
│   │   ├── items/
│   │   ├── claims/
│   │   └── admin/
│   ├── utils/           # Utilities
│   ├── app.ts           # Express app setup
│   └── server.ts        # Server entry point
├── prisma/
│   └── schema.prisma    # Database schema
├── package.json
├── tsconfig.json
└── .env.example
```

## License

MIT
