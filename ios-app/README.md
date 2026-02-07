# FindItKIET iOS App

Native iOS application for the FindItKIET campus lost-and-found system.

## Features

- 🔐 Secure authentication with Keychain storage
- 📱 SwiftUI with MVVM architecture
- 🎨 Minimal, professional design system
- 🔄 Automatic token refresh
- 📝 Lost & found item browsing
- ✅ Claim submission
- 👤 User profile management
- 🛡️ Admin moderation panel (role-based)

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Setup

1. **Open in Xcode:**
   ```bash
   open FindItApp.xcodeproj
   ```

2. **Configure Backend URL:**
   Edit `APIClient.swift` and update the `baseURL`:
   ```swift
   #if DEBUG
   baseURL = "http://localhost:3000/api/v1"  // Your backend URL
   #else
   baseURL = "https://your-production-url.com/api/v1"
   #endif
   ```

3. **Build and Run:**
   - Select a simulator or connected device
   - Press `Cmd + R` to build and run

## Architecture

```
FindItApp/
├── FindItApp.swift          # App entry point
├── Core/
│   ├── Networking/          # API client
│   ├── Security/            # Keychain service
│   ├── State/               # Global app state
│   └── Utils/               # Colors, extensions
├── Features/
│   ├── Auth/                # Login, register
│   ├── Items/               # Item list, detail, report
│   ├── Claims/              # Claim submission, history
│   ├── Admin/               # Admin panel
│   └── Profile/             # User profile
├── Components/              # Reusable UI components
├── Models/                  # Data models
└── Navigation/              # App routing
```

## Design System

### Colors
- Primary Blue: `#2563EB`
- Dark Blue: `#1E40AF`
- Success: `#16A34A`
- Warning: `#F59E0B`
- Error: `#DC2626`

### Components
- `PrimaryButton` - Main action button
- `SecondaryButton` - Secondary actions
- `ItemCard` - Item display card
- `StatusBadge` - Status indicators
- `LoadingView` - Loading state
- `EmptyStateView` - Empty state with optional action
- `ErrorBanner` - Error display with retry

## API Integration

The app uses `APIClient` for all network requests:

```swift
// Example: Fetch items
let endpoint = Endpoint(
    path: "/items",
    method: .get,
    requiresAuth: false
)

let items = try await APIClient.shared.request(
    endpoint,
    responseType: [Item].self
)
```

## Security

- **Tokens**: Stored securely in iOS Keychain
- **Auto-refresh**: Expired tokens automatically refreshed
- **HTTPS**: All network requests over HTTPS in production
- **No hardcoded secrets**: All sensitive data from backend

## Testing

### Test Credentials
Create test users via backend:
- Regular user: `user@example.com` / `<your-password>`
- Admin user: `admin@example.com` / `<your-password>`

### Test Flow
1. Login with test account
2. Browse items in home tab
3. Search and filter items
4. Report new item
5. Submit claim with proof
6. View claim status in "My Claims"
7. (Admin) Review and approve/reject claims

## Known Limitations

This is a production-ready foundation. Additional features to implement:

- Image upload for items
- Camera integration for proofs
- Push notifications
- Item detail view
- Full claim submission form
- Admin claim review interface
- Pagination for item lists
- Offline support

## Production Checklist

- [ ] Update `baseURL` to production endpoint
- [ ] Configure App Store provisioning profiles
- [ ] Add app icon and launch screen
- [ ] Enable push notifications (APNs)
- [ ] Add Analytics/Crashlytics
- [ ] Implement deep linking
- [ ] Add accessibility labels
- [ ] Performance testing
- [ ] Security audit

## License

MIT
