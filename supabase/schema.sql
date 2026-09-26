-- ============================================================
-- Skema database untuk "Cerita Kebun"
-- Jalankan seluruh file ini di Supabase Dashboard > SQL Editor
-- (Project Anda > SQL Editor > New query > paste > Run)
--
-- File ini aman dijalankan berulang kali (idempotent).
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- Kategori cerita
-- ------------------------------------------------------------
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  icon text not null default '',
  description text,
  sort_order int not null default 0
);

insert into public.categories (slug, name, icon, description, sort_order) values
  ('pengalaman-lapangan', 'Pengalaman Lapangan', '🌱', 'Cerita suka-duka awal menanam, kegagalan panen, hingga keberhasilan membasmi hama secara alami.', 1),
  ('tips-tutorial', 'Tips & Tutorial', '💡', 'Panduan praktis, seperti cara membuat kompos rumah tangga atau pengalaman pertama memulai hidroponik.', 2),
  ('profil-sosok', 'Profil & Sosok', '👨‍🌾', 'Wawancara atau kisah petani lokal inspiratif di sekitar lingkunganmu.', 3),
  ('hasil-bumi-olahan', 'Hasil Bumi & Olahan', '🍏', 'Resep atau pemanfaatan hasil panen menjadi produk bernilai tambah.', 4)
on conflict (slug) do update set
  name = excluded.name,
  icon = excluded.icon,
  description = excluded.description,
  sort_order = excluded.sort_order;

-- ------------------------------------------------------------
-- Profil publik (mengikuti auth.users)
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  created_at timestamptz not null default now()
);

-- Otomatis buat baris profil setiap ada user baru daftar
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ------------------------------------------------------------
-- Cerita (postingan)
-- user_id mengacu ke public.profiles (bukan langsung ke
-- auth.users) supaya Supabase bisa join otomatis untuk
-- menampilkan nama penulis.
-- image_path menyimpan key storage (untuk keperluan hapus foto
-- saat cerita dihapus), image_url menyimpan URL publiknya.
-- ------------------------------------------------------------
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  category_id uuid references public.categories (id) on delete set null,
  title text not null,
  description text not null,
  image_url text not null,
  image_path text not null,
  created_at timestamptz not null default now()
);

create index if not exists posts_category_idx on public.posts (category_id);
create index if not exists posts_created_at_idx on public.posts (created_at desc);

-- Migrasi untuk project yang sudah pernah menjalankan skema lama
alter table public.posts drop constraint if exists posts_user_id_fkey;
alter table public.posts
  add constraint posts_user_id_fkey
  foreign key (user_id) references public.profiles (id) on delete cascade;

-- ------------------------------------------------------------
-- Tanggapan (komentar) pada cerita
-- ------------------------------------------------------------
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists comments_post_idx on public.comments (post_id);

alter table public.comments drop constraint if exists comments_user_id_fkey;
alter table public.comments
  add constraint comments_user_id_fkey
  foreign key (user_id) references public.profiles (id) on delete cascade;

-- ------------------------------------------------------------
-- Row Level Security
-- ------------------------------------------------------------
alter table public.categories enable row level security;
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;

-- Kategori: bisa dibaca semua orang
drop policy if exists "Categories are viewable by everyone" on public.categories;
create policy "Categories are viewable by everyone"
  on public.categories for select
  using (true);

-- Profil: bisa dibaca semua orang, hanya pemilik yang bisa update
drop policy if exists "Profiles are viewable by everyone" on public.profiles;
create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Cerita: bisa dibaca semua orang, hanya user login yang bisa insert,
-- hanya pemilik yang bisa update/delete miliknya sendiri
drop policy if exists "Posts are viewable by everyone" on public.posts;
create policy "Posts are viewable by everyone"
  on public.posts for select
  using (true);

drop policy if exists "Authenticated users can insert posts" on public.posts;
create policy "Authenticated users can insert posts"
  on public.posts for insert
  with check (auth.uid() = user_id);

drop policy if exists "Owners can update their posts" on public.posts;
create policy "Owners can update their posts"
  on public.posts for update
  using (auth.uid() = user_id);

drop policy if exists "Owners can delete their posts" on public.posts;
create policy "Owners can delete their posts"
  on public.posts for delete
  using (auth.uid() = user_id);

-- Tanggapan: bisa dibaca semua orang, hanya user login yang bisa insert,
-- hanya pemilik yang bisa update/delete miliknya sendiri
drop policy if exists "Comments are viewable by everyone" on public.comments;
create policy "Comments are viewable by everyone"
  on public.comments for select
  using (true);

drop policy if exists "Authenticated users can insert comments" on public.comments;
create policy "Authenticated users can insert comments"
  on public.comments for insert
  with check (auth.uid() = user_id);

drop policy if exists "Owners can update their comments" on public.comments;
create policy "Owners can update their comments"
  on public.comments for update
  using (auth.uid() = user_id);

drop policy if exists "Owners can delete their comments" on public.comments;
create policy "Owners can delete their comments"
  on public.comments for delete
  using (auth.uid() = user_id);

-- ------------------------------------------------------------
-- Storage: bucket untuk foto cerita
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('post-images', 'post-images', true)
on conflict (id) do nothing;

drop policy if exists "Post images are publicly accessible" on storage.objects;
create policy "Post images are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'post-images');

drop policy if exists "Authenticated users can upload post images" on storage.objects;
create policy "Authenticated users can upload post images"
  on storage.objects for insert
  with check (bucket_id = 'post-images' and auth.role() = 'authenticated');

drop policy if exists "Owners can delete their post images" on storage.objects;
create policy "Owners can delete their post images"
  on storage.objects for delete
  using (bucket_id = 'post-images' and auth.uid()::text = (storage.foldername(name))[1]);
