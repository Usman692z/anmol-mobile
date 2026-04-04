# ANMOL MOBILE – Complete Technical Documentation
> Version 1.0 | Full Stack Mobile Shop Application

---

## 📁 FOLDER STRUCTURE

```
anmol-mobile/
├── customer-website/          # Next.js Customer Frontend
│   ├── index.html             # Standalone demo (included)
│   ├── pages/
│   │   ├── index.tsx          # Homepage
│   │   ├── products/
│   │   │   ├── index.tsx      # Products listing
│   │   │   └── [id].tsx       # Product detail
│   │   ├── cart.tsx
│   │   ├── wishlist.tsx
│   │   └── auth/
│   │       ├── login.tsx
│   │       └── signup.tsx
│   ├── components/
│   │   ├── Navbar.tsx
│   │   ├── ProductCard.tsx
│   │   ├── ProductModal.tsx
│   │   ├── CartDrawer.tsx
│   │   ├── BannerSlider.tsx
│   │   └── Footer.tsx
│   ├── lib/
│   │   ├── supabase.ts
│   │   └── api.ts
│   └── styles/
│       └── globals.css
│
├── admin-panel/               # React Admin Dashboard
│   ├── admin.html             # Standalone demo (included)
│   ├── src/
│   │   ├── pages/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Products.tsx
│   │   │   ├── Orders.tsx
│   │   │   ├── Categories.tsx
│   │   │   └── Banners.tsx
│   │   └── components/
│   │       ├── Sidebar.tsx
│   │       ├── ProductForm.tsx
│   │       └── DataTable.tsx
│
├── backend/                   # Node.js + Express API
│   ├── src/
│   │   ├── routes/
│   │   │   ├── products.ts
│   │   │   ├── orders.ts
│   │   │   ├── categories.ts
│   │   │   ├── auth.ts
│   │   │   └── upload.ts
│   │   ├── middleware/
│   │   │   ├── auth.ts
│   │   │   └── upload.ts
│   │   └── index.ts
│   ├── .env.example
│   └── package.json
│
├── mobile-app/                # React Native (Expo)
│   ├── app/
│   │   ├── (tabs)/
│   │   │   ├── index.tsx      # Home
│   │   │   ├── shop.tsx       # Products
│   │   │   ├── cart.tsx
│   │   │   └── profile.tsx
│   │   └── product/[id].tsx
│   ├── components/
│   └── app.json
│
└── README.md
```

---

## 🗄️ DATABASE SCHEMA (Supabase / PostgreSQL)

```sql
-- =====================
-- USERS TABLE
-- =====================
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  phone       TEXT UNIQUE,
  role        TEXT DEFAULT 'customer',   -- 'customer' | 'admin'
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- CATEGORIES TABLE
-- =====================
CREATE TABLE categories (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  slug        TEXT NOT NULL UNIQUE,
  icon        TEXT,
  description TEXT,
  sort_order  INT DEFAULT 0,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, slug, icon) VALUES
  ('iPhone', 'iphone', '📱'),
  ('Samsung', 'samsung', '📲'),
  ('Used Phones', 'used-phones', '♻️'),
  ('Accessories', 'accessories', '🎧'),
  ('Smartwatches', 'smartwatches', '⌚'),
  ('Chargers', 'chargers', '🔌');

-- =====================
-- PRODUCTS TABLE
-- =====================
CREATE TABLE products (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL UNIQUE,
  brand       TEXT NOT NULL,
  category_id INT REFERENCES categories(id) ON DELETE SET NULL,
  description TEXT,
  price       NUMERIC(12,2) NOT NULL,
  old_price   NUMERIC(12,2),
  condition   TEXT DEFAULT 'New',        -- 'New' | 'Used - Excellent' | 'Used - Good'
  badge       TEXT,                       -- 'new' | 'offer' | 'hot' | null
  specs       JSONB DEFAULT '{}',
  images      TEXT[] DEFAULT '{}',
  stock       INT DEFAULT 0,
  featured    BOOLEAN DEFAULT FALSE,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Example specs JSONB:
-- { "Storage": "256GB", "RAM": "8GB", "Camera": "48MP", "Battery": "4422mAh", "Display": "6.7 inch OLED" }

-- =====================
-- PRODUCT IMAGES TABLE
-- =====================
CREATE TABLE product_images (
  id          SERIAL PRIMARY KEY,
  product_id  INT REFERENCES products(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- BANNERS TABLE
-- =====================
CREATE TABLE banners (
  id          SERIAL PRIMARY KEY,
  title       TEXT NOT NULL,
  subtitle    TEXT,
  tag         TEXT,
  image_url   TEXT,
  link        TEXT,
  bg_color    TEXT DEFAULT '#1a1a2e',
  active      BOOLEAN DEFAULT TRUE,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- ORDERS TABLE
-- =====================
CREATE TABLE orders (
  id          SERIAL PRIMARY KEY,
  order_number TEXT UNIQUE DEFAULT 'ORD-' || LPAD(nextval('order_seq')::TEXT, 6, '0'),
  user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
  customer_name  TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  total_amount   NUMERIC(12,2) NOT NULL,
  status      TEXT DEFAULT 'pending',  -- pending | processing | completed | cancelled
  channel     TEXT DEFAULT 'website',  -- website | whatsapp | walk-in
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE SEQUENCE IF NOT EXISTS order_seq START 2400;

-- =====================
-- ORDER ITEMS TABLE
-- =====================
CREATE TABLE order_items (
  id          SERIAL PRIMARY KEY,
  order_id    INT REFERENCES orders(id) ON DELETE CASCADE,
  product_id  INT REFERENCES products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  price       NUMERIC(12,2) NOT NULL,
  qty         INT NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- WISHLIST TABLE
-- =====================
CREATE TABLE wishlists (
  id         SERIAL PRIMARY KEY,
  user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  product_id INT REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- =====================
-- ROW LEVEL SECURITY
-- =====================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;

-- Users can read own data
CREATE POLICY "Users read own" ON users FOR SELECT USING (auth.uid() = id);
-- Admins can read all
CREATE POLICY "Admins all" ON users FOR ALL USING (
  (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
);
```

---

## 🔌 API STRUCTURE (Node.js / Express)

### Base URL: `https://api.anmolmobile.pk/v1`

### Authentication
```
POST   /auth/signup          – Register with email/phone
POST   /auth/login           – Login (email/password)
POST   /auth/otp/send        – Send OTP to phone
POST   /auth/otp/verify      – Verify OTP
POST   /auth/logout          – Logout
GET    /auth/me              – Get current user
```

### Products
```
GET    /products             – List products (query: category, brand, condition, search, page, limit)
GET    /products/:id         – Get product by ID
GET    /products/slug/:slug  – Get product by slug
POST   /products             – [Admin] Create product
PUT    /products/:id         – [Admin] Update product
DELETE /products/:id         – [Admin] Delete product
POST   /products/:id/images  – [Admin] Upload images (multipart/form-data)
```

### Categories
```
GET    /categories           – List all categories
POST   /categories           – [Admin] Create category
PUT    /categories/:id       – [Admin] Update category
DELETE /categories/:id       – [Admin] Delete category
```

### Orders
```
GET    /orders               – [Admin] List all orders
GET    /orders/my            – [Auth] Get user's orders
GET    /orders/:id           – Get order by ID
POST   /orders               – Create order
PUT    /orders/:id/status    – [Admin] Update order status
```

### Banners
```
GET    /banners              – Get active banners
POST   /banners              – [Admin] Create banner
PUT    /banners/:id          – [Admin] Update banner
DELETE /banners/:id          – [Admin] Delete banner
```

### Upload
```
POST   /upload/image         – [Admin] Upload single image → returns { url }
POST   /upload/images        – [Admin] Upload multiple images → returns { urls[] }
```

---

## 📱 MOBILE APP SETUP (React Native + Expo)

```bash
# 1. Install Expo CLI
npm install -g @expo/cli

# 2. Create project
npx create-expo-app anmol-mobile --template expo-template-blank-typescript

# 3. Install dependencies
cd anmol-mobile
npx expo install expo-router react-native-safe-area-context
npx expo install @react-native-async-storage/async-storage
npm install @supabase/supabase-js
npm install react-native-url-polyfill

# 4. Configure app.json
{
  "expo": {
    "name": "ANMOL MOBILE",
    "slug": "anmol-mobile",
    "version": "1.0.0",
    "icon": "./assets/icon.png",
    "splash": { "image": "./assets/splash.png", "backgroundColor": "#0a0a0a" },
    "android": { "package": "pk.anmolmobile.app" },
    "ios": { "bundleIdentifier": "pk.anmolmobile.app" }
  }
}

# 5. Run
npx expo start
```

### Key Mobile Features to Implement:
- Push Notifications: `expo-notifications`
- Camera for images: `expo-image-picker`
- Deep linking to WhatsApp: `Linking.openURL('whatsapp://send?phone=923145000994')`
- Maps: `expo-linking` to open Google Maps

---

## 🌐 NEXT.JS CUSTOMER WEBSITE SETUP

```bash
npx create-next-app@latest anmol-customer --typescript --tailwind --app
cd anmol-customer
npm install @supabase/supabase-js @supabase/ssr
npm install framer-motion
npm install react-hot-toast
npm install react-image-gallery

# Environment variables (.env.local)
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_WHATSAPP_NUMBER=923145000994
```

---

## ⚙️ BACKEND SETUP (Node.js)

```bash
mkdir anmol-backend && cd anmol-backend
npm init -y
npm install express cors helmet dotenv
npm install @supabase/supabase-js
npm install multer @aws-sdk/client-s3  # for image uploads
npm install jsonwebtoken bcryptjs
npm install -D typescript ts-node @types/node @types/express

# .env file
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
PORT=4000
JWT_SECRET=your-jwt-secret
SUPABASE_STORAGE_BUCKET=product-images
```

---

## 🚀 DEPLOYMENT GUIDE

### Customer Website → Vercel
```bash
npm install -g vercel
cd anmol-customer
vercel --prod
# Set env vars in Vercel dashboard
```

### Admin Panel → Vercel or Netlify
```bash
cd anmol-admin
npm run build
vercel --prod
```

### Backend API → Railway or Render
```bash
# Railway (recommended - free tier)
npm install -g @railway/cli
railway login
railway init
railway up

# OR Render.com
# Connect GitHub repo → auto-deploy
```

### Database → Supabase (Free tier)
```
1. Create account at supabase.com
2. New Project → "anmol-mobile"
3. Go to SQL Editor → run the schema above
4. Storage → create bucket "product-images" (public)
5. Authentication → enable Phone OTP
6. Copy SUPABASE_URL and ANON_KEY to .env
```

### Mobile App → Google Play + App Store
```bash
# Android
npx expo build:android
# Upload .aab to Google Play Console

# iOS  
npx expo build:ios
# Upload .ipa via Transporter or Xcode
```

---

## 🔔 PUSH NOTIFICATIONS SETUP

```javascript
// Using Expo Push Notifications
import * as Notifications from 'expo-notifications';

// Register device
const { data: token } = await Notifications.getExpoPushTokenAsync();
// Save token to Supabase users table

// Send from admin/backend
const message = {
  to: token,
  title: '🔥 New Offer!',
  body: 'iPhone 15 Pro Max – PKR 30,000 OFF today only!',
  data: { screen: 'ProductDetail', id: 1 }
};
await fetch('https://exp.host/--/api/v2/push/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(message)
});
```

---

## 💬 WHATSAPP INTEGRATION

```javascript
// Direct order via WhatsApp
const orderViaWhatsApp = (product, cart) => {
  const items = cart.map(i => `• ${i.name} x${i.qty} = PKR ${i.price * i.qty}`).join('\n');
  const msg = `Hi ANMOL MOBILE! 👋\n\nI want to order:\n${items}\n\nTotal: PKR ${total}\n\nPlease confirm availability.`;
  const url = `https://wa.me/923145000994?text=${encodeURIComponent(msg)}`;
  window.open(url, '_blank');
};

// WhatsApp Catalog (direct link)
const catalogURL = 'https://wa.me/c/923145000994';
```

---

## 🔒 SECURITY CHECKLIST

- [x] Supabase Row Level Security enabled
- [x] Admin routes protected with JWT middleware
- [x] File upload validation (type + size limits)
- [x] Input sanitization on all forms
- [x] HTTPS enforced (Vercel/Railway auto-SSL)
- [x] Rate limiting on auth endpoints
- [x] Environment variables never in source code

---

## 📊 RECOMMENDED TECH STACK (Final Decision)

| Layer | Technology | Why |
|-------|-----------|-----|
| Customer Website | Next.js 14 + TypeScript | SEO, performance, SSR |
| Admin Panel | React + Vite | Fast, simple dashboard |
| Mobile App | React Native + Expo | Cross-platform iOS + Android |
| Backend | Node.js + Express | Familiar, scalable |
| Database | Supabase (PostgreSQL) | Free tier, real-time, auth built-in |
| Image Storage | Supabase Storage | Integrated with DB |
| Hosting (Web) | Vercel | Free, auto-deploy from GitHub |
| Hosting (API) | Railway | Free tier, easy Node.js |
| Push Notifications | Expo Push | Works on both platforms |
| Authentication | Supabase Auth | Email + Phone OTP |

---

*ANMOL MOBILE – Built for Pakistan's #1 mobile shop*
*WhatsApp: +92 314 5000994 | Facebook: /anmolmobile | Abbottabad, Pakistan*
