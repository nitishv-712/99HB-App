# 99HomeBazaar — User API Documentation

**Base URL:** `http://localhost:4000/api`  
**Auth:** Dual-token system — `accessToken` (cookie or `x-auth-accesstoken: Bearer <token>`) + `refreshToken` (cookie or `x-auth-refreshtoken: Bearer <token>`)  
**Rate Limit:** 200 req / 15 min globally. Auth OTP endpoints: 3 req / 15 min.

---

## Response Format

All endpoints return a consistent shape:

```json
{ "success": true, "message": "...", "data": {} }
```

Paginated responses:
```json
{
  "success": true,
  "data": [],
  "pagination": { "total": 100, "page": 1, "limit": 20, "pages": 5 }
}
```

Error responses:
```json
{ "success": false, "message": "Error description" }
```

---

## Authentication

Tokens are issued as **httpOnly cookies** (`accessToken`, `refreshToken`) AND as response headers (`x-auth-accesstoken`, `x-auth-refreshtoken`). Use whichever fits your client (web = cookies, mobile = headers).

When the access token expires, the middleware automatically refreshes it using the refresh token — no manual refresh call needed. The new access token is returned in the same cookie/header.

---

## 1. Auth — `/api/auth`

### POST `/auth/register`
Create a new user account.

**Body:**
```json
{
  "firstName": "john",
  "lastName": "doe",
  "email": "john@example.com",
  "password": "min8chars",
  "phone": "+919876543210",
  "role": "buyer"
}
```
- `role`: `"buyer"` | `"seller"` | `"agent"` (default: `"buyer"`)
- `phone`: optional

**Response `201`:**
```json
{
  "data": {
    "user": { "_id", "firstName", "lastName", "email", "role", "avatar", "isVerified", ... }
  }
}
```
Tokens issued in cookies + headers.

---

### POST `/auth/login`
**Body:**
```json
{ "email": "john@example.com", "password": "yourpassword" }
```

**Response `200`:** Same user shape as register. KYC fields (`panCard`, `aadharCard`) are flattened onto the user object if present.

---

### POST `/auth/logout`
🔒 Requires auth.  
Clears session and cookies. No body needed.

---

### GET `/auth/me`
🔒 Requires auth.  
Returns current user with KYC fields flattened.

---

### PATCH `/auth/password`
Reset password via OTP (no auth required).

**Body:**
```json
{
  "otp": "123456",
  "newPassword": "newpassword",
  "email": "john@example.com"
}
```
- Either `email` or `phone` required, not both.

---

### POST `/auth/otp/generate`
Send OTP to email or phone. Rate limited: **3 requests / 15 min**.

**Body:**
```json
{ "email": "john@example.com" }
// or
{ "phone": "+919876543210" }
```

---

### POST `/auth/otp/verify`
Verify OTP. If user is authenticated, also marks email/phone as verified and updates the field.

**Body:**
```json
{ "email": "john@example.com", "otp": "123456" }
```

---

## 2. OAuth — `/api/oauth`

### POST `/oauth/google`
Firebase-based Google / Phone OAuth login or registration.

**Body:**
```json
{
  "idToken": "<firebase_id_token>",
  "provider": "google",
  "platform": "web",
  "role": "buyer"
}
```
- `provider`: `"google"` | `"phone"`
- `platform`: `"web"` | `"android"` | `"ios"`
- `role`: only used on first-time registration

**Response `200`:** Full user object + tokens in cookies/headers.

---

## 3. Properties — `/api/properties`

### GET `/properties`
Public (optional auth). Logged-in users won't see their own listings.

**Query params:**
| Param | Type | Description |
|---|---|---|
| `type` | string | `sale` or `rent` |
| `propType` | string | `House`, `Apartment`, `Villa`, `Penthouse`, `Townhouse`, `Land`, `Office` |
| `city` | string | City prefix match |
| `search` | string | Full-text search (title, description, city, state) |
| `minPrice` | number | |
| `maxPrice` | number | |
| `minBeds` | number | |
| `minBaths` | number | |
| `minArea` | number | sqft |
| `featured` | `"true"` | Featured only |
| `sort` | string | `price_asc`, `price_desc`, `oldest`, `popular` (default: newest) |
| `page` | number | default `1` |
| `limit` | number | default `12`, max `50` |

**Response `200`:** Paginated list. Fields excluded from list: `location`, `description`, `yearBuilt`, `owner`, `views`, `saves`, `inquiries`.

---

### GET `/properties/featured`
Public. Returns up to 6 featured active listings. Cached 1 hour.

---

### GET `/properties/:id`
Public (optional auth). Returns full property with `owner` populated (`firstName`, `lastName`, `avatar`, `phone`, `email`, `role`). Increments view count.

---

### POST `/properties`
🔒 Requires auth. Roles: `seller` or `agent` only.

**Body:**
```json
{
  "title": "3BHK Apartment in Bandra",
  "description": "...",
  "listingType": "sale",
  "propertyType": "Apartment",
  "price": 9500000,
  "address": {
    "street": "14 Hill Road",
    "city": "Mumbai",
    "state": "Maharashtra",
    "zip": "400050"
  },
  "bedrooms": 3,
  "bathrooms": 2,
  "sqft": 1200,
  "yearBuilt": 2018,
  "badge": "New",
  "isFeatured": false,
  "images": [
    { "url": "https://...", "filename": "img1.jpg", "isPrimary": true }
  ]
}
```
- `badge`: `"Premium"` | `"New"` | `"Featured"` | `null`
- Status defaults to `"pending"` (requires admin approval to go `"active"`)
- At least 1 image required

**Response `201`:** Created property object.

---

### PATCH `/properties/:id`
🔒 Requires auth. Owner only.

Updatable fields: `title`, `description`, `price`, `address`, `bedrooms`, `bathrooms`, `sqft`, `yearBuilt`, `badge`, `isFeatured`, `status`.

---

### DELETE `/properties/:id`
🔒 Requires auth. Owner only.

---

## 4. Users — `/api/users`

### GET `/users/saved`
🔒 Requires auth.  
Returns user's saved properties (active only). Fields: `title`, `address`, `price`, `listingType`, `images`, `bedrooms`, `bathrooms`, `sqft`, `badge`.

---

### GET `/users/my-listings`
🔒 Requires auth.  
Returns all properties owned by the current user.

**Query params:** `status` (filter), `page`, `limit`

---

### PATCH `/users/update-profile`
🔒 Requires auth. Blocked if user is already verified (`isVerified: true`).

**Body (all optional):**
```json
{
  "firstName": "john",
  "lastName": "doe",
  "phone": "+919876543210",
  "email": "new@example.com",
  "avatar": "https://...",
  "panNumber": "ABCDE1234F",
  "panCardImage": "https://...",
  "aadharNumber": "1234 5678 9012",
  "aadharCardImage": "https://..."
}
```
- Changing `email` or `phone` resets their verified status
- KYC fields trigger a verification request to admins via socket when both PAN and Aadhar are complete
- Restricted fields (cannot be updated): `password`, `isVerified`, `kyc`, `_id`

---

## 5. Inquiries — `/api/inquiries`

### POST `/inquiries`
🔒 Requires auth. Start an inquiry thread on a property.

**Body:**
```json
{ "property": "<propertyId>", "message": "I am interested in this property..." }
```
- `message`: 5–2000 characters

**Response `201`:** Created inquiry object.

---

### GET `/inquiries`
🔒 Requires auth. Returns all inquiries where user is either the buyer or the property owner.

**Query params:** `status` (`active` | `closed`), `page`, `limit`

---

### GET `/inquiries/me`
🔒 Requires auth. Same as `GET /inquiries` — alias.

---

### GET `/inquiries/:id`
🔒 Requires auth. Returns inquiry + messages. Messages are filtered by visibility:
- Buyer sees only `visibleToUser: true` messages
- Owner sees only `visibleToOwner: true` messages

---

### POST `/inquiries/:id/message`
🔒 Requires auth. Send a message in an inquiry thread. Must be buyer or owner.

**Body:**
```json
{ "text": "Can we schedule a visit?" }
```
- `text`: 1–2000 characters

---

### PATCH `/inquiries/:id/status`
🔒 Requires auth. Property owner only.

**Body:**
```json
{ "status": "closed" }
```
- `status`: `"active"` | `"closed"`

---

## 6. Comparisons — `/api/comparisons`

### POST `/comparisons`
🔒 Requires auth. Create a property comparison list.

**Body:**
```json
{
  "name": "Mumbai vs Pune",
  "description": "Comparing options",
  "propertyIds": ["<id1>", "<id2>", "<id3>"],
  "tags": ["budget", "family"],
  "notes": "Prefer closer to metro"
}
```
- `propertyIds`: 1–10 unique active property IDs
- `name`: max 100 chars
- `description`: max 500 chars (optional)
- `notes`: max 2000 chars (optional)

---

### GET `/comparisons`
🔒 Requires auth. Paginated list of user's comparisons.

---

### GET `/comparisons/:id`
🔒 Requires auth. Owner only. Returns comparison + analysis:

```json
{
  "comparison": { ... },
  "analysis": {
    "totalProperties": 3,
    "priceRange": { "min": 5000000, "max": 12000000, "average": 8000000 },
    "bedroomRange": { "min": 2, "max": 4 },
    "bathroomRange": { "min": 1, "max": 3 },
    "sqftRange": { "min": 900, "max": 2000, "average": 1400 },
    "pricePerSqft": [{ "propertyId": "...", "title": "...", "pricePerSqft": 4166.67 }]
  }
}
```

---

### PATCH `/comparisons/:id`
🔒 Requires auth. Owner only. Update `name`, `description`, `notes`, `tags`, `isPublic`, `propertyIds`.

---

### POST `/comparisons/:id/add-property`
🔒 Requires auth. Owner only.

**Body:** `{ "propertyId": "<id>" }`

---

### POST `/comparisons/:id/remove-property`
🔒 Requires auth. Owner only. If last property is removed, the entire comparison is deleted.

**Body:** `{ "propertyId": "<id>" }`

**Response includes:** `{ "deleted": true }` if comparison was auto-deleted.

---

### DELETE `/comparisons/:id`
🔒 Requires auth. Owner only.

---

## 7. Reviews — `/api/reviews`

### POST `/reviews`
🔒 Requires auth. Cannot review your own property. One review per user per property.

**Body:**
```json
{
  "property": "<propertyId>",
  "rating": 4,
  "title": "Great location",
  "comment": "Very spacious and well maintained..."
}
```
- `rating`: 1–5
- `title`: 5–100 chars
- `comment`: 10–2000 chars

---

### GET `/reviews/property/:propertyId`
Public (optional auth). Returns paginated reviews for a property.

**Query params:**
| Param | Values | Description |
|---|---|---|
| `sort` | `rating-high`, `rating-low`, `oldest` | default: newest |
| `rating` | `1`–`5` | Filter by star rating |
| `page`, `limit` | | |

**Response includes:**
```json
{
  "data": [...reviews],
  "stats": {
    "averageRating": 4.2,
    "totalReviews": 18,
    "ratingBreakdown": { "5": 8, "4": 5, "3": 3, "2": 1, "1": 1 }
  },
  "userReview": null
}
```
`userReview` is populated if the requesting user has already reviewed this property.

---

### GET `/reviews/user/my-reviews`
🔒 Requires auth. Returns all reviews by the current user with property info.

---

### GET `/reviews/:id`
Public (optional auth). Non-published reviews are only visible to their author.

---

### PATCH `/reviews/:id`
🔒 Requires auth. Author only. Update `rating`, `title`, `comment` (all optional).

---

### DELETE `/reviews/:id`
🔒 Requires auth. Author only.

---

## 8. Saved Properties — `/api/saved`

### GET `/saved`
🔒 Requires auth. Returns paginated saved properties.

---

### POST `/saved/toggle/:propertyId`
🔒 Requires auth. Toggles save/unsave.

**Response:**
```json
{ "data": { "saved": true }, "message": "Added to saved" }
// or
{ "data": { "saved": false }, "message": "Removed from saved" }
```

---

## 9. Search History — `/api/search-history`

### GET `/search-history`
🔒 Requires auth. Paginated search history.

---

### POST `/search-history`
🔒 Requires auth.

**Body:**
```json
{ "query": "3bhk in mumbai", "filters": { "city": "mumbai", "minBeds": 3 } }
```
- `query`: max 500 chars

---

### DELETE `/search-history`
🔒 Requires auth. Clears all history.

---

### DELETE `/search-history/:id`
🔒 Requires auth. Deletes a single entry.

---

## 10. Support Tickets — `/api/support`

All routes require auth.

### POST `/support`
Create a support ticket.

**Body:**
```json
{
  "subject": "Cannot upload property images",
  "category": "listing",
  "priority": "high",
  "message": "When I try to upload..."
}
```
- `category`: `"technical"` | `"billing"` | `"account"` | `"listing"` | `"other"`
- `priority`: `"low"` | `"medium"` | `"high"` (default: `"medium"`)
- `message`: 1–5000 chars

---

### GET `/support`
List own tickets. **Query params:** `status`, `category`, `priority`, `page`, `limit`

Ticket statuses: `"open"` | `"in-progress"` | `"resolved"` | `"closed"`

---

### GET `/support/:id`
Single ticket with paginated messages.

---

### POST `/support/:id/messages`
Reply to a ticket. Rate limited: **20 messages / 15 min per ticket**.  
Cannot reply to `"closed"` tickets.

**Body:** `{ "message": "Here is more info..." }`

---

### POST `/support/:id/close`
Close own ticket.

---

## 11. Analytics — `/api/analytics`

### GET `/analytics/overview`
🔒 Requires auth. Returns stats for all properties owned by the current user.

**Response:**
```json
{
  "totalListings": 5,
  "activeListings": 3,
  "pendingListings": 1,
  "soldListings": 1,
  "rentedListings": 0,
  "archivedListings": 0,
  "totalViews": 1240,
  "totalSaves": 87,
  "totalInquiries": 34,
  "averageViewsPerListing": 248,
  "averageSavesPerListing": 17.4,
  "conversionRate": 2.74,
  "listingsByType": { "sale": 3, "rent": 2 },
  "topByViews": [...],
  "topByInquiries": [...],
  "inquiryTrend": [{ "date": "2025-01-15", "count": 3 }],
  "inquiryStatus": { "active": 20, "closed": 14 }
}
```

---

### GET `/analytics/property/:id`
🔒 Requires auth. Owner only. Detailed analytics for a single property.

**Response:**
```json
{
  "property": { "_id", "title", "price", "status", "listingType", "createdAt", "daysListed" },
  "analytics": {
    "totalViews": 340,
    "totalSaves": 22,
    "totalInquiries": 11,
    "conversionRate": 3.24,
    "saveRate": 6.47,
    "inquiryStatus": { "active": 7, "closed": 4 },
    "inquiryTrend": [...],
    "inquiries": [{ "_id", "user", "status", "lastMessageAt", "createdAt" }]
  }
}
```

---

## 12. Upload — `/api/uploads`

### GET `/uploads/:name`
🔒 Requires auth. Get a pre-signed upload URL.

- `name`: `"avatar"` | `"aadhar"` | `"pancards"` | `"properties"`

**Response:**
```json
{ "uploadUrl": "https://...", "publicUrl": "https://..." }
```
Use `uploadUrl` to PUT the file directly, then store `publicUrl` in your profile/property.

---

## 13. Newsletter — `/api/newsletter`

### POST `/newsletter/subscribe`
**Body:** `{ "email": "user@example.com" }`

---

### POST `/newsletter/unsubscribe`
**Body:** `{ "email": "user@example.com" }`

---

## 14. Leads — `/api/leads`

### POST `/leads`
No auth required. Submit a property interest lead.

**Body:**
```json
{
  "intent": "buy",
  "phone": "+919876543210",
  "address": "Bandra West, Mumbai",
  "placeId": "ChIJ...",
  "city": "Mumbai",
  "state": "Maharashtra"
}
```
- `intent`, `phone`, `address` are required

---

## User Roles & Permissions

| Role | Can List Properties | Can Inquire | Can Review |
|---|---|---|---|
| `buyer` | ❌ | ✅ | ✅ |
| `seller` | ✅ | ✅ | ✅ |
| `agent` | ✅ | ✅ | ✅ |

---

## Property Status Flow

```
pending → active (admin approves)
active  → sold | rented | archived
```
Users can only update their own listings. Status changes to `sold`/`rented`/`archived` can be done by the owner.

---

## Common Error Codes

| Code | Meaning |
|---|---|
| `400` | Validation error / bad request |
| `401` | Not authenticated |
| `403` | Forbidden (wrong role or not owner) |
| `404` | Resource not found |
| `409` | Duplicate (email, phone, review) |
| `429` | Rate limit exceeded |
