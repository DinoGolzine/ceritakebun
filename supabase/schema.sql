-- ============================================================
-- Skema database untuk "Cerita Kebun" (tema Taman Peri)
-- Jalankan seluruh file ini di Supabase Dashboard > SQL Editor
-- (Project Anda > SQL Editor > New query > paste > Run)
--
-- File ini aman dijalankan berulang kali (idempotent), termasuk
-- di project yang sebelumnya sudah pernah menjalankan versi lama
-- skema ini — perubahan akan otomatis disesuaikan tanpa
-- menghapus data yang sudah ada.
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- Kategori cerita — sekarang tiap kategori punya artikel info
-- singkat (info_intro + info_tips) yang tampil di halaman
-- /kategori/[slug] bersama forum tanya jawabnya.
-- ------------------------------------------------------------
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  icon text not null default '',
  description text,
  info_intro text,
  info_tips text[] not null default '{}',
  sort_order int not null default 0
);

-- Migrasi untuk project yang sudah pernah menjalankan skema lama
alter table public.categories add column if not exists info_intro text;
alter table public.categories add column if not exists info_tips text[] not null default '{}';

insert into public.categories (slug, name, icon, description, info_intro, info_tips, sort_order) values
(
  'pengalaman-lapangan',
  'Pengalaman Lapangan',
  '🌱',
  'Cerita suka-duka awal menanam, kegagalan panen, hingga keberhasilan membasmi hama secara alami.',
  'Kebun tidak melulu soal keberhasilan — di balik setiap panen yang subur biasanya ada cerita gagal coba lagi berkali-kali. Di topik ini, sesama pekebun saling berbagi pengalaman nyata: mulai dari tanaman pertama yang mati, panen yang gagal karena cuaca ekstrem, sampai cara mengatasi hama secara alami yang akhirnya berhasil setelah dicoba berulang kali.',
  array[
    'Setiap kebun punya kondisi berbeda — pengalaman orang lain adalah referensi, bukan aturan pasti.',
    'Catat apa yang sudah dicoba dan hasilnya, supaya bisa belajar dari percobaan sendiri.',
    'Kegagalan panen sering disebabkan kombinasi faktor (cuaca, hama, tanah) — jangan buru-buru menyalahkan satu penyebab.',
    'Cerita kegagalan sama berharganya dengan cerita sukses — jangan ragu membagikannya.',
    'Metode pembasmian hama alami butuh waktu untuk terlihat hasilnya, jadi konsisten adalah kunci.'
  ],
  1
),
(
  'tips-tutorial',
  'Tips & Tutorial (How-To)',
  '💡',
  'Panduan praktis, seperti cara membuat kompos rumah tangga atau memulai hidroponik.',
  'Topik ini adalah tempat berbagi panduan praktis langkah demi langkah — dari membuat kompos rumah tangga, memulai hidroponik pertama kali, sampai trik-trik kecil yang bikin urusan berkebun jadi lebih mudah. Cocok buat yang ingin belajar sambil praktik langsung.',
  array[
    'Kompos rumah tangga bisa dibuat dari sisa sayur dan buah, daun kering, dan sedikit tanah sebagai starter.',
    'Untuk pemula hidroponik, sistem wick (sumbu) paling mudah karena tidak butuh pompa listrik.',
    'Selalu mulai dari skala kecil dulu sebelum mencoba teknik baru di kebun yang lebih besar.',
    'Dokumentasikan setiap langkah tutorial dengan foto — memudahkan orang lain mengikuti dan memberi masukan.',
    'Tutorial yang baik menyertakan alasan di balik setiap langkah, bukan cuma instruksinya saja.'
  ],
  2
),
(
  'profil-sosok',
  'Profil & Sosok',
  '👨‍🌾',
  'Wawancara atau kisah petani lokal inspiratif di sekitar lingkunganmu.',
  'Di balik setiap kebun subur ada orang dengan cerita dan cara pandangnya sendiri. Topik ini untuk mengenal sosok-sosok pekebun atau petani lokal yang inspiratif — bagaimana mereka memulai, tantangan yang dihadapi, dan pelajaran yang bisa dipetik dari perjalanan mereka.',
  array[
    'Wawancara sederhana pun berharga — tanyakan bagaimana sosok tersebut memulai dan apa yang membuatnya bertahan.',
    'Ceritakan konteks lokasi dan kondisi kebun/lahan yang dikelola sosok tersebut.',
    'Fokus pada pelajaran atau kebiasaan yang bisa ditiru pembaca, bukan cuma profil singkatnya saja.',
    'Sertakan foto sosok atau kebunnya (dengan izin) agar cerita terasa lebih hidup.',
    'Sosok tidak harus terkenal — petani atau tetangga yang tekun pun layak diceritakan.'
  ],
  3
),
(
  'hasil-bumi-olahan',
  'Hasil Bumi & Olahan',
  '🍏',
  'Resep atau pemanfaatan hasil panen menjadi produk bernilai tambah.',
  'Panen yang melimpah kadang butuh sentuhan tambahan supaya tidak terbuang sia-sia. Topik ini untuk berbagi resep atau cara mengolah hasil panen menjadi produk bernilai tambah — dari selai, keripik, sampai produk fermentasi sederhana dari hasil kebun sendiri.',
  array[
    'Olahan sederhana seperti keripik atau manisan bisa memperpanjang umur simpan hasil panen yang melimpah.',
    'Sertakan takaran dan langkah yang jelas supaya resep mudah diikuti pembaca lain.',
    'Perhatikan kebersihan dan cara penyimpanan hasil olahan agar tetap aman dikonsumsi.',
    'Hasil olahan bisa jadi peluang tambahan penghasilan, bukan cuma untuk konsumsi sendiri.',
    'Bagikan juga kegagalan dalam mencoba resep — bisa jadi pelajaran berharga bagi yang lain.'
  ],
  4
)
on conflict (slug) do update set
  name = excluded.name,
  icon = excluded.icon,
  description = excluded.description,
  info_intro = excluded.info_intro,
  info_tips = excluded.info_tips,
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
-- Foto sekarang OPSIONAL — image_url dan image_path boleh kosong.
-- ------------------------------------------------------------
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  category_id uuid references public.categories (id) on delete set null,
  title text not null,
  description text not null,
  image_url text,
  image_path text,
  created_at timestamptz not null default now()
);

create index if not exists posts_category_idx on public.posts (category_id);
create index if not exists posts_created_at_idx on public.posts (created_at desc);

alter table public.posts drop constraint if exists posts_user_id_fkey;
alter table public.posts
  add constraint posts_user_id_fkey
  foreign key (user_id) references public.profiles (id) on delete cascade;

-- Migrasi: kalau sebelumnya foto wajib (NOT NULL), longgarkan jadi opsional
alter table public.posts alter column image_url drop not null;
alter table public.posts alter column image_path drop not null;

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

drop policy if exists "Categories are viewable by everyone" on public.categories;
create policy "Categories are viewable by everyone"
  on public.categories for select
  using (true);

drop policy if exists "Profiles are viewable by everyone" on public.profiles;
create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

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
