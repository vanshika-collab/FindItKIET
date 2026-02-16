# FindItKIET - Testing Guide

## Backend Testing

### 1. Start the Backend Server

```bash
cd backend
npm run dev
```

Server will start on `http://localhost:3000`

### 2. Test API Endpoints

**Option A: Use the Test Script**
```bash
cd backend
./test-api.sh
```

**Option B: Manual Testing with curl**

1. **Register User**
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "<your-password>",
    "name": "Test User"
  }'
```

2. **Login**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "<your-password>"
  }'
```

3. **Create Item** (save the access token from login)
```bash
curl -X POST http://localhost:3000/api/v1/items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "title": "Black Wallet",
    "description": "Found in library",
    "category": "ACCESSORIES",
    "status": "FOUND",
    "location": "Library 2nd Floor",
    "reportedAt": "2026-02-03T10:00:00Z",
    "imageUrls": []
  }'
```

4. **List Items** (no auth required)
```bash
curl http://localhost:3000/api/v1/items
```

### 3. Create Admin User

Connect to PostgreSQL:
```bash
/opt/homebrew/opt/postgresql@15/bin/psql finditkiet
```

Update user role:
```sql
UPDATE "User" SET role = 'ADMIN' WHERE email = 'user@example.com';
\q
```

## iOS App Testing

### 1. Open in Xcode

```bash
cd ios-app
open FindItApp.xcodeproj
```

### 2. Select Simulator

- iPhone 15 Pro recommended
- iOS 17.0+

### 3. Build and Run

Press `Cmd + R`

### 4. Test Flow

1. **Login Screen**
   - Email: `user@example.com`
   - Password: `<your-password>`
   - Click "Login"

2. **Home Tab**
   - View list of items
   - Use search bar
   - Try filters (Lost/Found)
   - Tap an item to view details

3. **Item Detail**
   - View images, description, location
   - Click "Submit Claim" button

4. **Claim Submission**
   - Select proof type (Description, Serial Number, etc.)
   - Enter proof value
   - Add multiple proofs
   - Submit claim

5. **My Claims Tab**
   - View submitted claims
   - Check claim status

6. **Profile Tab**
   - View user info
   - Logout

7. **Admin Tab** (if admin user)
   - Review claims
   - Approve/reject claims
   - View audit logs

## Integration Testing Checklist

- [x] Backend server starts successfully
- [x] Database migrations run
- [x] User registration works
- [x] User login works
- [x] Token refresh works
- [ ] Item creation with authentication
- [ ] Item listing (public)
- [ ] Item detail view
- [ ] Claim submission
- [ ] Admin claim review
- [ ] Audit logging

## Known Test Results

✅ **Working:**
- Server startup
- Database connection
- User registration
- Token generation
- Token refresh
- API routing

⚠️ **Requires Manual Testing:**
- Full item CRUD flow
- Claim submission workflow
- Admin operations
- iOS app integration

## Common Issues

### PostgreSQL Not Running
```bash
brew services start postgresql@15
```

### Port Already in Use
```bash
lsof -ti:3000 | xargs kill -9
```

### Database Reset
```bash
cd backend
npx prisma migrate reset
```

### Clean Install
```bash
cd backend
rm -rf node_modules
npm install
npx prisma generate
```

## Test Credentials

- **Regular User**: `user@example.com` / `<your-password>`
- **Admin User**: Same as above, after SQL update

## Next Steps

1. Complete manual testing of all endpoints
2. Test iOS app with live backend
3. Add automated tests (Jest for backend, XCTest for iOS)
4. Performance testing
5. Security audit
