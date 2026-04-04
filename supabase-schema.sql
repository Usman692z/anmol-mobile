-- ================================================================
--   ANMOL MOBILE — SUPABASE SCHEMA
--   Run this in: Supabase Dashboard → SQL Editor → New Query
-- ================================================================

-- PRODUCTS
create table if not exists products (
  id          bigint generated always as identity primary key,
  icon        text        default '📱',
  brand       text        not null,
  name        text        not null,
  category    text        not null,
  condition   text        default 'New',
  price       integer     not null,
  old_price   integer,
  badge       text        default 'new',
  storage     text,
  ram         text,
  camera      text,
  battery     text,
  description text,
  active      boolean     default true,
  created_at  timestamptz default now()
);

-- ORDERS
create table if not exists orders (
  id             bigint generated always as identity primary key,
  order_number   text        default ('ORD-' || floor(extract(epoch from now()))::text),
  customer_name  text,
  customer_phone text,
  items          jsonb,
  total_price    integer,
  status         text        default 'pending',
  notes          text,
  created_at     timestamptz default now()
);

-- CUSTOMERS
create table if not exists customers (
  id           bigint generated always as identity primary key,
  name         text,
  phone        text unique,
  city         text    default 'Abbottabad',
  total_orders integer default 0,
  total_spent  integer default 0,
  created_at   timestamptz default now()
);

-- BANNERS
create table if not exists banners (
  id          bigint generated always as identity primary key,
  title       text    not null,
  subtitle    text,
  badge_text  text,
  slide_index integer default 0,
  active      boolean default true,
  created_at  timestamptz default now()
);

-- ================================================================
--   SEED DATA
-- ================================================================
insert into products (icon,brand,name,category,condition,price,old_price,badge,storage,ram,camera,battery,description) values
('📱','Apple','iPhone 15 Pro Max','iphone','New',419999,489999,'sale','256GB','8GB','48MP ProRAW','4422mAh','The most powerful iPhone ever. Titanium design, A17 Pro chip, and a pro camera system with 48MP main camera.'),
('📱','Apple','iPhone 14 Pro','iphone','New',329999,null,'new','128GB','6GB','48MP ProRes','3200mAh','iPhone 14 Pro with Dynamic Island, Always-On display, and 48MP main camera.'),
('📲','Samsung','Galaxy S24 Ultra','samsung','New',389999,449999,'sale','256GB','12GB','200MP AI','5000mAh','Ultimate Galaxy experience with Galaxy AI, 200MP camera, titanium frame and built-in S Pen.'),
('📱','Apple','iPhone 13','used','Used',189999,219999,'used','128GB','4GB','12MP Dual','3227mAh','Pre-owned iPhone 13 in excellent condition. Fully tested. 3-month warranty included.'),
('🎧','Apple','AirPods Pro 2nd Gen','accessories','New',49999,null,'new',null,null,null,'30hrs total','AirPods Pro 2nd Gen with Active Noise Cancellation and Personalized Spatial Audio.'),
('📲','Samsung','Galaxy A54','samsung','New',89999,109999,'sale','128GB','8GB','50MP OIS','5000mAh','Samsung Galaxy A54 5G with 6.4" Super AMOLED+, 50MP OIS camera and 5000mAh battery.');

insert into banners (title,subtitle,badge_text,slide_index) values
('iPhone 15 Pro Max','Up to 15% Off · Titanium design · A17 Pro chip','Limited Offer',0),
('Samsung Galaxy S24 Ultra','Galaxy AI · 200MP camera · Titanium frame','New Arrival',1),
('AirPods & Accessories','Original accessories · Best prices in Abbottabad','Best Value',2);

-- ================================================================
--   ROW LEVEL SECURITY
-- ================================================================
alter table products  enable row level security;
alter table orders    enable row level security;
alter table customers enable row level security;
alter table banners   enable row level security;

-- Public can read active products & banners
create policy "public read products" on products for select using (active = true);
create policy "public read banners"  on banners  for select using (active = true);
-- Public can create orders (WhatsApp checkout logging)
create policy "public insert orders" on orders   for insert with check (true);
-- Authenticated admin can do everything
create policy "admin products" on products  for all using (auth.role() = 'authenticated');
create policy "admin orders"   on orders    for all using (auth.role() = 'authenticated');
create policy "admin customers"on customers for all using (auth.role() = 'authenticated');
create policy "admin banners"  on banners   for all using (auth.role() = 'authenticated');
