# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Fonepay Khata Book** is a comprehensive digital bookkeeping solution consisting of two Flutter applications:

1. **Fonepay Business App** (Merchant-facing) - Located in `apps/merchant_app/`
2. **Fonepay App** (Customer-facing) - Located in `apps/customer_app/`

Both apps share common packages for UI components, business logic, and services, managed as a monorepo using Melos.

## Architecture

### Monorepo Structure

```
fone-hisab/
├── apps/
│   ├── merchant_app/          # Merchant-facing Flutter app
│   └── customer_app/           # Customer-facing Flutter app
├── packages/
│   ├── core/                   # Design system, theme, constants, localization
│   ├── shared_ui/              # Reusable UI components
│   ├── shared_models/          # Data models (DTOs, entities)
│   └── shared_services/        # API clients, repositories, utilities
├── melos.yaml                  # Monorepo configuration
└── pubspec.yaml                # Workspace dependencies
```

### Design System

**Color Palette** (defined in `packages/core/lib/constants/app_colors.dart`):
- Primary: `#BE3431` (Fonepay Red)
- Background Light: `#F7F8FA`
- Background Dark: `#121212`
- Surface Light: `#FFFFFF`
- Surface Dark: `#1E1E1E`
- Transaction Colors:
  - Credit (Udharo): Red shades
  - Debit (Payment): Green shades
  - Advance: Yellow shades

**Typography** (defined in `packages/core/lib/constants/app_typography.dart`):
- Font Family: Poppins (loaded via Google Fonts)
- Weights: 400 (regular), 500 (medium), 600 (semi-bold), 700 (bold)

**Theme**:
- Full Material 3 theme with light and dark mode support
- Consistent spacing: 4, 8, 12, 16, 20, 24, 32
- Border radius: 8 (small), 12 (medium), 16 (large), 20 (xlarge)

### Backend Integration

**API Architecture**:
- Custom backend (Node.js/NestJS or Spring Boot)
- RESTful API with JWT authentication
- Dio HTTP client with interceptors for auth and logging
- API configuration in `packages/shared_services/lib/config/api_config.dart`

**Environments**:
- Development: `http://localhost:3000/api/v1`
- Staging: `https://staging-api.fonepay.com/khatabook/v1`
- Production: `https://api.fonepay.com/khatabook/v1`

### State Management

- Use **Riverpod** or **Bloc** for complex state management
- Provider pattern for simpler cases
- Offline-first architecture with local caching (Hive or Drift)

### Localization

- Supported languages: English and Nepali (नेपाली)
- ARB files located in `packages/core/lib/l10n/`
- Use `AppLocalizations.of(context)` for translations
- Generate localizations: `flutter gen-l10n`

## Development Commands

### Monorepo Management (Melos)

```bash
# Install melos globally (first time only)
dart pub global activate melos

# Bootstrap all packages (link dependencies)
melos bootstrap

# Get dependencies for all packages
melos get

# Run Flutter analyze on all packages
melos analyze

# Format all Dart code
melos format

# Run all tests
melos test

# Clean all packages
melos clean
```

### Building Apps

```bash
# Build Merchant App (Android APK)
cd apps/merchant_app
flutter build apk

# Build Customer App (Android APK)
cd apps/customer_app
flutter build apk

# Or use melos scripts
melos build:merchant
melos build:customer
```

### Running Apps

```bash
# Run Merchant App
cd apps/merchant_app
flutter run

# Run Customer App
cd apps/customer_app
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with flavor (when implemented)
flutter run --flavor dev
```

### Code Generation

```bash
# Generate localization files (from core package)
cd packages/core
flutter gen-l10n

# Generate JSON serialization and Retrofit API clients
cd packages/shared_services
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

```bash
# Run tests for specific app
cd apps/merchant_app
flutter test

# Run tests with coverage
flutter test --coverage

# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test integration_test/
```

## Key Features by Phase

### Phase 1: Core Sales & Ledger (Priority)

**Merchant App:**
- Sales entry with cash/credit/advance logic
- Customer management with contact integration
- Customer list with filters (All/Udharo/Advance)
- Customer detail page with transaction history
- Basic ledger tracking

**Customer App:**
- View merchant ledgers (read-only)
- View outstanding balances
- Transaction history viewing

### Phase 2: Reports & Notifications

**Merchant App:**
- Generate customer reports (PDF/Excel)
- Transaction reports with date ranges
- Payment reminder notifications
- Due date management

**Customer App:**
- Generate merchant reports
- Payment due notifications
- Notification settings

### Phase 3: Disputes & Advanced Features

**Merchant App:**
- Handle dispute notifications
- Resolve disputes
- Advanced filters and sorting
- Search functionality
- Settings and language switching

**Customer App:**
- Raise disputes on transactions
- View bill images
- Dispute tracking
- Advanced search

## Business Logic Rules

### Sales Entry (Proceed Button Logic)

```dart
if (saleAmount > paymentAmount) {
  // Credit scenario
  buttonColor = AppColors.advanceYellow;
  buttonLabel = "Rs. ${remaining} Udharo (Credit)";
} else if (saleAmount == paymentAmount) {
  // Cash sale scenario
  buttonColor = AppColors.primary;
  buttonLabel = "Cash Sale";
} else {
  // Advance payment scenario
  buttonColor = AppColors.debitGreen;
  buttonLabel = "Rs. ${remaining} Payment";
}
```

### Customer Deletion Rules

- Customer can only be deleted when due amount = 0
- System prompts merchant to settle dues first
- "Settle Now" option guides to add clearing entry

### Date Constraints

- Bill date can be today or past dates
- Future dates are NOT allowed
- Date range filters available: Today, Yesterday, Last 7 Days, This Month, Last Month, Custom Range

## Navigation Structure

### Merchant App Bottom Navigation

1. Dashboard (Home)
2. Customers (All Customers & Khata Entries tabs)
3. Add Entry (Floating Action Button)
4. Reports
5. Settings

### Customer App Bottom Navigation

1. Dashboard (Home)
2. Merchants (All Merchants & Khata Entries tabs)
3. Notifications
4. Settings

## Data Synchronization

- Implement offline-first architecture
- Queue transactions when offline
- Sync when connection restored
- Handle conflict resolution for concurrent edits
- Real-time updates for disputes and notifications

## Security Considerations

- JWT token-based authentication
- Store tokens securely (flutter_secure_storage)
- Implement token refresh mechanism
- Encrypt sensitive data at rest
- Validate all user inputs
- Sanitize data before display to prevent XSS

## Common Development Tasks

### Adding a New Screen

1. Create screen in appropriate app's `lib/screens/` directory
2. Add route in `lib/routes/app_router.dart`
3. Update navigation logic
4. Add localization strings to ARB files

### Adding a New API Endpoint

1. Update `packages/shared_services/lib/config/api_config.dart` with endpoint
2. Create/update API client in `packages/shared_services/lib/api/`
3. Add corresponding model in `packages/shared_models/`
4. Run code generation if using Retrofit/JSON serialization

### Adding a New Shared Component

1. Create component in `packages/shared_ui/lib/components/`
2. Export from `packages/shared_ui/lib/shared_ui.dart`
3. Use in both apps by importing `package:shared_ui/shared_ui.dart`

### Updating Design System

1. Modify `packages/core/lib/constants/app_colors.dart` or `app_typography.dart`
2. Update theme in `packages/core/lib/theme/app_theme.dart`
3. Changes automatically propagate to both apps

## Testing Strategy

- **Unit Tests**: Business logic, models, utilities
- **Widget Tests**: Individual UI components
- **Integration Tests**: End-to-end user flows
- **Golden Tests**: UI screenshot regression testing
- Aim for >80% code coverage for critical paths

## Performance Considerations

- Lazy load customer/merchant lists (pagination)
- Use `ListView.builder` for long lists
- Implement image caching for bill photos
- Debounce search inputs
- Optimize database queries (indexes)
- Use `const` constructors where possible

## Troubleshooting

### Melos Bootstrap Fails
```bash
# Clear pub cache and retry
dart pub cache repair
melos clean
melos bootstrap
```

### Code Generation Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Localization Not Working
```bash
# Regenerate localization files
cd packages/core
flutter gen-l10n
flutter pub get
```

### Dio Network Errors
- Check `ApiConfig.currentEnvironment` is set correctly
- Verify backend URL is accessible
- Check auth token is valid and not expired
- Review interceptor logs in debug console

## Git Workflow

- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/***: Individual feature branches
- **hotfix/***: Urgent production fixes

Commit message format:
```
type(scope): subject

body (optional)

footer (optional)
```

Types: feat, fix, docs, style, refactor, test, chore

## Additional Resources

- BRD Document: `/Users/diwassapkota/Downloads/BRD_KhataBook.docx`
- Design Reference: `/Users/diwassapkota/Downloads/khatabook_dash.html`
- Flutter Documentation: https://docs.flutter.dev/
- Material Design 3: https://m3.material.io/

## Notes for Future Development

- Consider implementing fingerprint/face authentication
- Add export to third-party accounting software integration
- Implement analytics for business insights
- Add multi-currency support if expanding beyond Nepal
- Consider adding inventory management integration
- Implement backup and restore functionality
- Add voice-based transaction entry for accessibility
