# 99HomeBazaar — Frontend Documentation

## Project Structure

```
src/
├── app/                        # Next.js App Router pages
│   ├── page.tsx                # Home /
│   ├── layout.tsx              # Root layout
│   ├── buy/page.tsx            # Buy /buy
│   ├── rent/page.tsx           # Rent /rent
│   ├── sell/page.tsx           # Sell /sell
│   ├── property/[id]/page.tsx  # Property Detail /property/:id
│   ├── signin/page.tsx         # Sign In /signin
│   ├── register/page.tsx       # Register /register
│   ├── forget/page.tsx         # Forgot Password /forget
│   ├── about/page.tsx          # About /about
│   ├── contact/page.tsx        # Contact /contact
│   ├── terms/page.tsx          # Terms /terms
│   ├── privacy/page.tsx        # Privacy /privacy
│   └── dashboard/
│       ├── layout.tsx          # Dashboard layout (wraps providers)
│       ├── page.tsx            # Dashboard /dashboard
│       ├── analytics/page.tsx  # Analytics /dashboard/analytics
│       ├── comparisons/
│       │   ├── page.tsx        # Comparisons /dashboard/comparisons
│       │   └── [id]/page.tsx   # Comparison Detail /dashboard/comparisons/:id
│       ├── inquiries/
│       │   ├── page.tsx        # Inquiries /dashboard/inquiries
│       │   └── [id]/page.tsx   # Inquiry Chat /dashboard/inquiries/:id
│       ├── reviews/page.tsx    # My Reviews /dashboard/reviews
│       ├── history/page.tsx    # Search History /dashboard/history
│       ├── support/
│       │   ├── page.tsx        # Support /dashboard/support
│       │   └── [id]/page.tsx   # Ticket Detail /dashboard/support/:id
│       └── profile/page.tsx    # Profile /dashboard/profile
├── components/                 # Shared UI components
├── context/                    # React Context providers
├── hooks/                      # Custom hooks
├── lib/                        # API client, cache, firebase
├── types/                      # TypeScript types
└── utils/                      # Validation helpers
```

---

## Pages & API Reference

### `/` — Home
**File:** `src/app/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Featured properties | `GET` | `/properties/featured` |
| Newsletter subscribe | `POST` | `/newsletter/subscribe` |

**Components:** `Navbar`, `Hero`, `FeaturedProperties`, `Editorial`, `Services`, `Newsletter`, `Footer`

---

### `/buy` — Buy Properties
**File:** `src/app/buy/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| List properties | `GET` | `/properties?type=sale&search=&propType=&minPrice=&maxPrice=&minBeds=&sort=&page=&limit=` |
| Record search | `POST` | `/search-history` |

**Features:** Live filter + search, pagination (12/page), URL param sync, search history recording

---

### `/rent` — Rent Properties
**File:** `src/app/rent/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| List properties | `GET` | `/properties?type=rent&search=&propType=&minPrice=&maxPrice=&minBeds=&sort=&page=&limit=` |
| Record search | `POST` | `/search-history` |

**Features:** Same as Buy page but filtered to `type=rent`

---

### `/property/[id]` — Property Detail
**File:** `src/app/property/[id]/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Get property | `GET` | `/properties/:id` |
| Submit inquiry | `POST` | `/inquiries` |
| Toggle save | `POST` | `/saved/toggle/:propertyId` |
| Get reviews | `GET` | `/reviews/property/:propertyId` |
| Submit review | `POST` | `/reviews` |

**Features:** Image gallery, save/unsave (heart), inquiry form (auth required), reviews with ratings, add to comparison

---

### `/sell` — List a Property
**File:** `src/app/sell/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Get upload URL | `GET` | `/uploads/properties` |
| Upload image | `PUT` | Supabase presigned URL |
| Create property | `POST` | `/properties` |

**Features:** 4-step form (Details → Location → Photos & Price → Review), Google Places autocomplete for address, multi-image upload to Supabase, requires verified account

---

### `/signin` — Sign In
**File:** `src/app/signin/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Login | `POST` | `/auth/login` |
| Google OAuth | `POST` | `/oauth/google` |

---

### `/register` — Register
**File:** `src/app/register/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Register | `POST` | `/auth/register` |
| Google OAuth | `POST` | `/oauth/google` |

**Features:** Role selector (buyer / seller / agent), password strength meter

---

### `/forget` — Forgot Password
**File:** `src/app/forget/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Generate OTP | `POST` | `/auth/otp/generate` |
| Change password | `PATCH` | `/auth/password` |

**Features:** OTP via email or phone, password strength meter

---

### `/about` — About
**File:** `src/app/about/page.tsx`

No API calls. Static marketing page with animated counters, team, timeline, and values sections.

---

### `/contact` — Contact
**File:** `src/app/contact/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Create support ticket | `POST` | `/support` |

**Note:** Requires login to submit. Creates a support ticket under the hood.

---

### `/terms` & `/privacy`
Static legal pages. No API calls.

---

## Dashboard Pages (all require auth)

### `/dashboard` — Main Dashboard
**File:** `src/app/dashboard/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| My listings | `GET` | `/users/my-listings` |
| Saved properties | `GET` | `/saved` (via SavedSearchContext on mount) |

**Features:** Saved properties tab, My Listings tab with status badges, quick nav to sub-pages

---

### `/dashboard/analytics` — Analytics
**File:** `src/app/dashboard/analytics/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Analytics overview | `GET` | `/analytics/overview` |

**Features:** Total views/saves/inquiries, listing status breakdown, inquiry trend chart (30 days), top properties by views & inquiries

---

### `/dashboard/comparisons` — Comparisons
**File:** `src/app/dashboard/comparisons/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| List comparisons | `GET` | `/comparisons` |
| Delete comparison | `DELETE` | `/comparisons/:id` |

---

### `/dashboard/comparisons/[id]` — Comparison Detail
**File:** `src/app/dashboard/comparisons/[id]/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Get comparison + analysis | `GET` | `/comparisons/:id` |
| Add property | `POST` | `/comparisons/:id/add-property` |
| Remove property | `POST` | `/comparisons/:id/remove-property` |

---

### `/dashboard/inquiries` — Inquiries
**File:** `src/app/dashboard/inquiries/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| My inquiries | `GET` | `/inquiries/me?status=` |

**Features:** Filter by status (active / closed), shows sent vs received

---

### `/dashboard/inquiries/[id]` — Inquiry Chat
**File:** `src/app/dashboard/inquiries/[id]/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Get inquiry | `GET` | `/inquiries/:id` |
| Send message | `POST` | `/inquiries/:id/message` |
| Update status | `PATCH` | `/inquiries/:id/status` |

---

### `/dashboard/reviews` — My Reviews
**File:** `src/app/dashboard/reviews/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| My reviews | `GET` | `/reviews/user/my-reviews` |
| Delete review | `DELETE` | `/reviews/:id` |

---

### `/dashboard/history` — Search History
**File:** `src/app/dashboard/history/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| List history | `GET` | `/search-history?page=&limit=10` |
| Delete entry | `DELETE` | `/search-history/:id` |
| Clear all | `DELETE` | `/search-history` |

**Features:** Client-side filter by query text + date range (today / week / month / all), pagination

---

### `/dashboard/support` — Support Tickets
**File:** `src/app/dashboard/support/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| List tickets | `GET` | `/support` |
| Create ticket | `POST` | `/support` |
| Close ticket | `POST` | `/support/:id/close` |

---

### `/dashboard/support/[id]` — Ticket Detail
**File:** `src/app/dashboard/support/[id]/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Get ticket | `GET` | `/support/:id` |
| Add message | `POST` | `/support/:id/messages` |
| Close ticket | `POST` | `/support/:id/close` |

---

### `/dashboard/profile` — Profile Settings
**File:** `src/app/dashboard/profile/page.tsx`

| API | Method | Endpoint |
|-----|--------|----------|
| Update profile | `PATCH` | `/users/update-profile` |
| Get upload URL (avatar) | `GET` | `/uploads/avatar` |
| Get upload URL (PAN) | `GET` | `/uploads/pancards` |
| Get upload URL (Aadhaar) | `GET` | `/uploads/aadhar` |
| Upload image | `PUT` | Supabase presigned URL |
| Generate OTP (email/phone) | `POST` | `/auth/otp/generate` |
| Verify OTP | `POST` | `/auth/otp/verify` |

**Features:** Avatar upload, KYC (PAN + Aadhaar) with image upload, OTP-based email/phone verification, fields lock after full verification

---

## Context Providers

| Context | Wraps | Purpose |
|---------|-------|---------|
| `AuthContext` | Entire app | JWT auth, login/register/logout, OTP, Google OAuth |
| `PropertyContext` | Entire app | Fetch/create properties, current property |
| `SavedSearchContext` | Entire app | Save/unsave properties, saved list |
| `InquiryContext` | Entire app | Submit & fetch inquiries |
| `ReviewContext` | Entire app | Submit, fetch, delete reviews |
| `UserContext` | Entire app | Profile update, image upload to Supabase |
| `ThemeContext` | Entire app | Light/dark/custom theme |
| `AnalyticsContext` | Dashboard layout | Fetch analytics overview |
| `ComparisonContext` | Dashboard layout | CRUD comparisons |
| `SupportContext` | Dashboard layout + Contact | CRUD support tickets |
| `SearchHistoryContext` | Dashboard layout | Fetch/delete search history |

---

## API Client (`src/lib/api.ts`)

All requests go through `apiFetch()` which:
- Sends cookies (`credentials: "include"`) for JWT session
- Throws on non-2xx with the backend error message
- Uses `withCache()` for GET requests (TTL: SHORT=1min, MEDIUM=15min, LONG=1hr)

| Module | Base Path |
|--------|-----------|
| `authApi` | `/auth` |
| `usersApi` | `/users` |
| `propertiesApi` | `/properties` |
| `inquiriesApi` | `/inquiries` |
| `newsletterApi` | `/newsletter` |
| `comparisonsApi` | `/comparisons` |
| `savedSearchesApi` | `/saved` |
| `searchHistoryApi` | `/search-history` |
| `analyticsApi` | `/analytics` |
| `reviewsApi` | `/reviews` |
| `supportApi` | `/support` |

---

## Environment Variables

```env
NEXT_PUBLIC_API_URL=http://localhost:4000/api
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=<key>        # Google Places (sell page)
NEXT_PUBLIC_FIREBASE_*=<values>              # Google OAuth
```
