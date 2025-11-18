# Fonepay Khata Book - Complete Project Guide

## 🎯 Project Overview

**Fonepay Khata Book** is a comprehensive digital bookkeeping solution consisting of:

1. **Two Flutter Apps** (This Repository)
   - Merchant App (Fonepay Business)
   - Customer App (Fonepay)

2. **One Spring Boot Backend** (Separate Repository - To Be Created)
   - Single API serving both apps
   - MySQL database
   - JWT authentication

---

## 📁 Repository Structure

```
Current Repository (fone-hisab):
└── Flutter monorepo with design system, shared packages, and both apps

Backend Repository (to be created):
└── Spring Boot + MySQL backend
```

---

## 📚 Documentation Index

### **Frontend (Flutter) - This Repository**

| Document | Purpose |
|----------|---------|
| `README.md` | Project overview and quick start |
| `CLAUDE.md` | **Complete development guide for Flutter apps** |
| `ROADMAP.md` | 5-phase development roadmap |
| `PROJECT_SETUP_SUMMARY.md` | What's been set up and next steps |
| `PROJECT_STATUS.txt` | Quick status overview |

### **Backend (Spring Boot) - For Separate Project**

| Document | Purpose |
|----------|---------|
| `BACKEND_README.md` | **Start here for backend overview** |
| `BACKEND_SETUP.md` | Project scaffolding and structure |
| `BACKEND_API_SPEC.md` | Complete API endpoint specifications |
| `BACKEND_DATABASE_SCHEMA.md` | MySQL schema and relationships |
| `BACKEND_SECURITY.md` | JWT auth and security config |
| `BACKEND_BUSINESS_LOGIC.md` | Business rules and calculations |

---

## 🚀 Getting Started

### For Frontend Development (Flutter Apps)

```bash
# 1. Bootstrap the project
melos bootstrap

# 2. Generate localizations
cd packages/core && flutter gen-l10n && cd ../..

# 3. Run merchant app
cd apps/merchant_app && flutter run

# 4. Run customer app
cd apps/customer_app && flutter run
```

**Read**: `CLAUDE.md` for complete development guidelines.

### For Backend Development (Spring Boot)

1. **Create separate project**:
   ```bash
   mkdir ../fonepay-khatabook-backend
   cd ../fonepay-khatabook-backend
   ```

2. **Follow**: `BACKEND_SETUP.md` for project structure

3. **Implement in order**:
   - Authentication (Week 1-2)
   - Customer Management (Week 3-4)
   - Transactions & Ledger (Week 5-6)
   - Reports & Disputes (Week 7-8)

**Read**: `BACKEND_README.md` for complete backend guidelines.

---

## 🎨 Design System

Already implemented in `packages/core/`:

- **Primary Color**: #BE3431 (Fonepay Red)
- **Font**: Poppins (Google Fonts)
- **Theme**: Material 3 with light/dark modes
- **Localization**: English & Nepali (नेपाली)

Reference: `/Users/diwassapkota/Downloads/khatabook_dash.html`

---

## 🔄 How Frontend & Backend Connect

### API Configuration

Flutter apps connect to backend via endpoints defined in:
```
packages/shared_services/lib/config/api_config.dart
```

Current configuration:
```dart
static const String devBaseUrl = 'http://localhost:3000/api/v1';
static const String stagingBaseUrl = 'https://staging-api.fonepay.com/khatabook/v1';
static const String prodBaseUrl = 'https://api.fonepay.com/khatabook/v1';
```

**Update these** to match your Spring Boot backend URL (default: `http://localhost:8080/api/v1`).

### Alignment

- ✅ API endpoints in Flutter match backend spec
- ✅ Request/response DTOs aligned
- ✅ Authentication flow (JWT) ready on both sides
- ✅ Error handling format consistent

---

## 📊 Development Phases

### Phase 1: Core Sales & Ledger (Weeks 1-8) - **PRIORITY**

**Frontend (Flutter)**:
- [ ] Authentication (Login/Register/OTP)
- [ ] Dashboard with summary cards
- [ ] Sales entry screen
- [ ] Customer list with filters
- [ ] Customer detail page
- [ ] Transaction history
- [ ] Offline storage setup

**Backend (Spring Boot)**:
- [ ] Project setup
- [ ] Authentication APIs
- [ ] Customer management endpoints
- [ ] Transaction endpoints
- [ ] Ledger calculation logic

### Phase 2: Reports & Notifications (Weeks 9-14)

**Frontend**:
- [ ] Report generation (PDF/Excel)
- [ ] Payment reminders
- [ ] Notification center
- [ ] Due date management

**Backend**:
- [ ] Report generation service
- [ ] Firebase Cloud Messaging setup
- [ ] Notification APIs

### Phase 3: Disputes & Advanced (Weeks 15-22)

**Frontend**:
- [ ] Raise/resolve disputes
- [ ] Advanced search and filters
- [ ] Settings and preferences
- [ ] Language switcher

**Backend**:
- [ ] Dispute management APIs
- [ ] Advanced filtering logic
- [ ] File upload handling

---

## 🔐 Security Checklist

**Frontend**:
- [ ] Secure storage for tokens (flutter_secure_storage)
- [ ] Input validation
- [ ] Biometric auth (Phase 2+)

**Backend**:
- [ ] JWT token implementation
- [ ] BCrypt password hashing
- [ ] SQL injection prevention (JPA)
- [ ] XSS prevention
- [ ] HTTPS enforcement
- [ ] Rate limiting
- [ ] Environment variables for secrets

---

## 🧪 Testing Strategy

### Frontend (Flutter)
```bash
# Run all tests
melos test

# Run specific app tests
cd apps/merchant_app && flutter test

# Run with coverage
flutter test --coverage
```

### Backend (Spring Boot)
```bash
# Run all tests
mvn test

# Run with coverage
mvn test jacoco:report
```

---

## 📦 Deployment

### Frontend (Flutter)

**Android**:
```bash
cd apps/merchant_app
flutter build apk --release

cd ../customer_app
flutter build apk --release
```

**iOS**:
```bash
flutter build ipa --release
```

### Backend (Spring Boot)

**JAR**:
```bash
mvn clean package
java -jar target/khatabook-backend-1.0.0.jar
```

**Docker**:
```bash
docker build -t fonepay-khatabook-backend .
docker-compose up -d
```

---

## 🎯 Critical Business Rules

From `BACKEND_BUSINESS_LOGIC.md`:

1. **Balance**: Use BigDecimal (2 decimal places)
2. **Positive Balance**: Customer owes merchant (Udharo)
3. **Negative Balance**: Merchant owes customer (Advance)
4. **Bill Date**: Cannot be in future
5. **Customer Deletion**: Only when balance = 0
6. **Transaction Deletion**: Only when customer balance = 0
7. **Transaction Update**: Cannot change amounts
8. **Balance Sync**: Atomic with transaction creation

---

## 🤝 Team Collaboration

### Recommended Team Structure

**Frontend Team (2 developers)**:
- 1 on Merchant App
- 1 on Customer App
- Shared packages (collaborate)

**Backend Team (1 developer)**:
- Spring Boot API development
- Database management
- DevOps

**Design/QA (2 people)**:
- UI/UX designer
- QA engineer

---

## 📖 Key Resources

**External Documentation**:
- BRD: `/Users/diwassapkota/Downloads/BRD_KhataBook.docx`
- Design: `/Users/diwassapkota/Downloads/khatabook_dash.html`
- Flutter: https://docs.flutter.dev/
- Spring Boot: https://spring.io/projects/spring-boot
- Material Design 3: https://m3.material.io/

---

## 🆘 Troubleshooting

### Flutter Issues

**Melos bootstrap fails**:
```bash
dart pub cache repair
melos clean
melos bootstrap
```

**Localization not working**:
```bash
cd packages/core
flutter gen-l10n
flutter pub get
```

### Backend Issues

**Database connection fails**:
- Check MySQL is running
- Verify credentials in `application.yml`
- Ensure database exists

**JWT token errors**:
- Verify JWT_SECRET is set
- Check token expiration time
- Validate token format

---

## 📈 Success Metrics

### Phase 1 Targets
- 100+ merchant sign-ups
- 500+ customer accounts
- 1,000+ transactions recorded
- 99%+ crash-free rate

### Launch Targets
- 1,000+ active merchants
- 5,000+ registered customers
- 10,000+ daily transactions
- 4.5+ star rating

---

## 📞 Next Steps

### Today
1. ✅ Review this guide
2. ⬜ Review CLAUDE.md (Frontend)
3. ⬜ Review BACKEND_README.md (Backend)

### This Week
1. ⬜ Create Spring Boot backend project
2. ⬜ Set up MySQL database
3. ⬜ Implement authentication (both frontend & backend)
4. ⬜ Test auth flow end-to-end

### Next 2 Weeks
1. ⬜ Implement customer management
2. ⬜ Build sales entry screen
3. ⬜ Create transaction APIs
4. ⬜ Test core transaction flow

---

## ✅ What's Already Done

**Frontend (Flutter)**:
- ✅ Monorepo structure
- ✅ Design system (colors, typography, theme)
- ✅ Localization (English & Nepali)
- ✅ API client configuration
- ✅ Project documentation

**Backend (Spring Boot)**:
- ✅ Complete API specification
- ✅ Database schema design
- ✅ Security architecture
- ✅ Business logic requirements
- ✅ Implementation guidelines

**You're 100% ready to start development!** 🎉

---

**Project Start Date**: November 15, 2024
**Status**: Foundation Complete - Ready for Development
**Next Milestone**: Phase 1 MVP (8 weeks)

Good luck with the implementation! 🚀
