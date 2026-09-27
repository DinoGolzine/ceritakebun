# Cerita Kebun

Website jurnal & forum berbagi cerita berkebun. Pengguna bisa mendaftar/masuk dengan email
& password, menulis cerita (judul, deskripsi, foto), dan menanggapi cerita orang lain.
Pemilik cerita/tanggapan bisa menghapus miliknya sendiri kapan saja.

Tampilan memakai layout original (hero, filter kategori, grid cerita 2 kolom — tanpa dashboard
statistik/ilustrasi/sidebar), dengan tema warna coklat dan font mesin ketik ("Special Elite",
pengganti terdekat untuk "True Typewriter" karena nama tersebut tidak tersedia di Google Fonts)
pada paragraf cerita.

Kategori cerita yang sudah disiapkan:

- 🌱 **Pengalaman Lapangan** — suka-duka menanam, kegagalan panen, keberhasilan membasmi hama
- 💡 **Tips & Tutorial** — panduan praktis, misalnya cara membuat kompos atau memulai hidroponik
- 👨‍🌾 **Profil & Sosok** — wawancara/kisah petani lokal inspiratif
- 🍏 **Hasil Bumi & Olahan** — resep atau produk olahan dari hasil panen

**Teknologi:** SvelteKit (frontend) + Supabase (auth, database, storage) + Vercel (hosting).

---

## 1. Siapkan project Supabase

1. Buka [supabase.com](https://supabase.com) → **New project**. Catat *Database password* yang dibuat.
2. Setelah project siap, buka menu **SQL Editor** → **New query**.
3. Buka file `supabase/schema.sql` di project ini, salin seluruh isinya, tempel ke SQL Editor, lalu klik **Run**.
   - Script ini membuat tabel `categories`, `profiles`, `posts`, `comments`, mengisi 4 kategori
     awal, mengaktifkan Row Level Security beserta policy-nya, dan membuat storage bucket
     publik bernama `post-images` untuk foto cerita.
4. Buka menu **Authentication → Providers**, pastikan **Email** aktif (biasanya sudah aktif secara default).
   - Supabase membatasi jumlah email verifikasi yang dikirim lewat layanan email bawaannya
     (sangat ketat, hanya beberapa email/jam) — kalau muncul error **"email rate limit exceeded"**
     saat mendaftar berkali-kali untuk testing, itu sebabnya. Untuk development, matikan saja
     opsi **Confirm email** di **Authentication → Settings** supaya bisa langsung login tanpa
     verifikasi. Untuk production, aktifkan lagi dan sambungkan **SMTP sendiri** (Resend,
     SendGrid, Mailgun, dll) di **Project Settings → Authentication → SMTP Settings** agar
     tidak kena limit.
5. Buka menu **Project Settings → API**, catat dua nilai berikut (dipakai di langkah 2):
   - **Project URL**
   - **anon public key**

## 2. Jalankan secara lokal (opsional, untuk uji coba)

1. Ekstrak file zip project ini, lalu buka folder-nya di terminal.
2. Salin `.env.example` menjadi `.env`, lalu isi dengan nilai dari Supabase:

   ```
   PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
   PUBLIC_SUPABASE_ANON_KEY=isi-dengan-anon-public-key-anda
   ```

3. Install dependencies dan jalankan:

   ```bash
   npm install
   npm run dev
   ```

4. Buka `http://localhost:5173` di browser.

## 3. Deploy ke Vercel

Ada dua cara. Pilih salah satu.

### Cara A — lewat Vercel CLI langsung dari folder zip (paling cepat)

1. Ekstrak zip ini, buka foldernya di terminal.
2. Install Vercel CLI jika belum punya:

   ```bash
   npm install -g vercel
   ```

3. Login lalu deploy:

   ```bash
   vercel login
   vercel
   ```

4. Sebelum atau saat deploy pertama, tambahkan environment variable berikut di
   **Settings → Environment Variables** (Production dan Preview):

   | Name | Value |
   |---|---|
   | `PUBLIC_SUPABASE_URL` | Project URL dari Supabase |
   | `PUBLIC_SUPABASE_ANON_KEY` | anon public key dari Supabase |

5. Deploy ke production:

   ```bash
   vercel --prod
   ```

6. Setelah selesai, tambahkan URL yang diberikan Vercel ke
   **Authentication → URL Configuration → Site URL / Redirect URLs** di Supabase.

### Cara B — lewat GitHub + Vercel Dashboard

1. Push isi folder ini ke repository GitHub baru:

   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin <url-repo-github-anda>
   git push -u origin main
   ```

2. Buka [vercel.com/new](https://vercel.com/new), pilih repository tersebut, klik **Import**.
3. Sebelum klik **Deploy**, isi **Environment Variables**:
   - `PUBLIC_SUPABASE_URL`
   - `PUBLIC_SUPABASE_ANON_KEY`
4. Klik **Deploy** — Vercel otomatis mendeteksi SvelteKit (adapter-vercel sudah dikonfigurasi di `svelte.config.js`).
5. Tambahkan URL production Vercel ke pengaturan URL Supabase seperti pada Cara A langkah 6.

---

## Struktur project

```
src/
  app.html              Shell HTML + font (Space Grotesk, JetBrains Mono, Special Elite)
  app.css               Design tokens (palet coklat, radius, warna kategori, kelas .typewriter)
  lib/
    supabaseClient.js   Klien Supabase (pakai env PUBLIC_*)
    stores/auth.js      Svelte store untuk sesi user
    categoryColors.js   Pemetaan warna aksen per kategori
    components/
      PostCard.svelte
      CommentItem.svelte  (dengan tombol hapus untuk pemilik)
  routes/
    +layout.svelte      Header, navigasi, wiring sesi login
    +page.svelte        Beranda: hero, filter kategori, grid cerita 2 kolom
    login/+page.svelte
    register/+page.svelte
    posts/new/+page.svelte    Form tulis cerita (judul, kategori, isi, foto wajib)
    posts/[id]/+page.svelte   Detail cerita + hapus (pemilik) + tanggapan
supabase/
  schema.sql             Semua SQL: tabel, seed kategori, RLS, storage bucket
```

## Catatan

- Paragraf cerita (ringkasan di kartu, isi lengkap di halaman detail, tanggapan) memakai
  kelas CSS `.typewriter` (font Special Elite) — ubah nilai `--font-type` di `src/app.css`
  bila ingin mengganti font ini nanti.
- Autentikasi, database, dan storage semuanya lewat Supabase — tidak ada backend server terpisah.
- Foto cerita **wajib** diisi saat menulis cerita baru, disimpan di storage bucket publik
  `post-images`, dikelompokkan per folder `user_id`.
- Hanya pemilik cerita yang bisa menghapus ceritanya (sekaligus foto & seluruh tanggapan di
  dalamnya ikut terhapus otomatis). Pemilik tanggapan juga bisa menghapus tanggapannya sendiri.
- Lihat `progress.md` untuk daftar fitur yang sudah selesai dan yang belum.
