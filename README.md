# Fonepay Khata Book

A comprehensive digital bookkeeping solution for Small and Medium Businesses (SMBs) in Nepal.

## Overview

Fonepay Khata Book consists of two Flutter applications:

- **Fonepay Business App**: Merchant-facing app for managing customer ledgers, credit records, and transactions
- **Fonepay App**: Customer-facing app for viewing ledgers and managing credit transactions with merchants

## Features

### Merchant App
- 📊 Digital sales entry (Cash/Credit/Advance)
- 👥 Customer management with ledger tracking
- 💰 Credit and advance payment tracking
- 📦 **Supplier management** (🚧 In Progress)
- 📦 **Inventory tracking with stock management** (🚧 In Progress)
- 🛒 **Purchase recording with itemized entries** (🚧 In Progress)
- 💵 **Supplier payment tracking** (🚧 In Progress)
- 📊 **Dashboard analytics** (inventory value, supplier payables)
- 🔔 **Low stock alerts and reorder suggestions** (🚧 In Progress)
- 📈 Transaction reports (PDF/Excel)
- 🔔 Payment reminders
- 🌓 Dark mode support
- 🌍 Multi-language (English & Nepali)

### Customer App
- 👁️ View merchant ledgers
- 💳 Track outstanding balances
- ⚠️ Raise disputes on transactions
- 🔔 Payment due notifications
- 📊 Transaction history
- 🌍 Multi-language (English & Nepali)

## Architecture

This project uses a monorepo structure managed by Melos:

```
fone-hisab/
├── apps/
│   ├── merchant_app/          # Merchant-facing app
│   └── customer_app/           # Customer-facing app
└── packages/
    ├── core/                   # Design system & theme
    ├── shared_ui/              # Reusable UI components
    ├── shared_models/          # Data models
    └── shared_services/        # API clients & services
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0.0 or higher
- Melos CLI: `dart pub global activate melos`

### Installation

1. Clone the repository:
```bash
git clone https://github.com/fonepay/fone-hisab.git
cd fone-hisab
```

2. Bootstrap the monorepo:
```bash
melos bootstrap
```

3. Run the merchant app:
```bash
cd apps/merchant_app
flutter run
```

4. Run the customer app:
```bash
cd apps/customer_app
flutter run
```

## Development

### Common Commands

```bash
# Get dependencies for all packages
melos get

# Run code analysis
melos analyze

# Format code
melos format

# Run tests
melos test

# Build merchant app
melos build:merchant

# Build customer app
melos build:customer
```

### Code Generation

```bash
# Generate localization files
cd packages/core
flutter gen-l10n

# Generate JSON serialization
cd packages/shared_services
flutter pub run build_runner build --delete-conflicting-outputs
```

## Project Structure

- **apps/**: Flutter applications
- **packages/**: Shared packages
  - **core/**: Design system, theme, constants, localization
  - **shared_ui/**: Reusable UI components
  - **shared_models/**: Data models and DTOs
  - **shared_services/**: API clients and business services

## Design System

- **Primary Color**: #BE3431 (Fonepay Red)
- **Font**: Poppins
- **Border Radius**: 12px (medium), 16px (large)
- **Dark Mode**: Fully supported

## Localization

Supported languages:
- English
- Nepali (नेपाली)

## Backend Integration

The app integrates with a custom REST API backend. Configure the environment in:
```dart
packages/shared_services/lib/config/api_config.dart
```

## Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Run tests and linting: `melos test && melos analyze`
4. Submit a pull request

## License

Copyright © 2024 Fonepay Payment Services Ltd. All rights reserved.

## Contact

For support or inquiries, contact: support@fonepay.com
