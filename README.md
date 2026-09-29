# Cerita Kebun — Taman Peri

Website jurnal & forum berbagi cerita berkebun, bertema taman peri (fairytale) yang tetap
terasa dekat dengan dunia kebun/pertanian. Pengguna bisa mendaftar/masuk dengan email &
password, menulis cerita (judul, deskripsi, foto opsional), dan menanggapi cerita orang lain.
Pemilik cerita/tanggapan bisa menghapus miliknya sendiri kapan saja.

**Fitur khas:** setiap topik ("taman") punya halamannya sendiri (`/kategori/...`) yang berisi
**artikel panduan singkat** tentang topik tersebut, sekaligus forum tanya jawab khusus topik
itu — jadi bukan cuma tempat bertanya, tapi juga sumber informasi.

4 taman topik yang sudah disiapkan lengkap dengan artikel panduannya:

- 🌱 Pengalaman Lapangan
- 💡 Tips & Tutorial (How-To)
- 👨‍🌾 Profil & Sosok
- 🍏 Hasil Bumi & Olahan

**Desain:** tema taman peri — gradient senja ungu-lavender di hero, peri kecil bersayap kelopak
bunga yang terbang melintas dengan animasi CSS, kelap-kelip cahaya peri (fairy lights), dashboard
statistik ala "orb" bercahaya, kartu kategori bersinar, dan sidebar bergambar. Font judul pakai
serif dongeng "Cormorant Garamond", font isi pakai "Nunito" yang ramah dibaca.

**Teknologi:** SvelteKit (frontend) + Supabase (auth, database, storage) + Vercel (hosting).

---

## 1. Siapkan project Supabase

1. Buka [supabase.com](https://supabase.com) → **New project**. Catat *Database password* yang dibuat.
2. Setelah project siap, buka menu **SQL Editor** → **New query**.
3. Buka file `supabase/schema.sql` di project ini, salin seluruh isinya, tempel ke SQL Editor, lalu klik **Run**.
   - Script ini membuat tabel `categories` (lengkap dengan artikel panduan tiap taman topik),
     `profiles`, `posts`, `comments`, mengaktifkan Row Level Security beserta policy-nya, dan
     membuat storage bucket publik bernama `post-images` untuk foto cerita.
   - Script ini **aman dijalankan berulang** — kalau Supabase-mu sebelumnya sudah pernah
     memakai skema versi lama Cerita Kebun (dengan foto wajib), menjalankan ulang script ini
     akan otomatis menambahkan kolom artikel panduan dan melonggarkan foto jadi opsional,
     tanpa menghapus data cerita yang sudah ada.
4. Buka menu **Authentication → Providers**, pastikan **Email** aktif (biasanya sudah aktif secara default).
   - Supabase membatasi jumlah email verifikasi yang dikirim lewat layanan email bawaannya
     (sangat ketat, hanya beberapa email/jam) — kalau muncul error **"email rate limit exceeded"**
     saat mendaftar berkali-kali untuk testing, itu sebabnya. Untuk development, matikan saja
     opsi **Confirm email** di **Authentication → Settings**. Untuk production, aktifkan lagi
     dan sambungkan **SMTP sendiri** (Resend, SendGrid, Mailgun, dll) di
     **Project Settings → Authentication → SMTP Settings**.
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

1. Push isi folder ini ke repository GitHub (baru atau yang sudah ada):

   ```bash
   git add .
   git commit -m "Rombak total: tema taman peri"
   git push
   ```

2. Kalau ini repo baru, buka [vercel.com/new](https://vercel.com/new), pilih repository tersebut, klik **Import**, lalu isi **Environment Variables** (`PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_ANON_KEY`) sebelum **Deploy**.
3. Kalau ini repo yang sudah pernah di-deploy sebelumnya, push saja — Vercel otomatis redeploy, environment variable yang sudah diisi tetap dipakai.

---

## Struktur project

```
src/
  app.html              Shell HTML + font (Cormorant Garamond & Nunito)
  app.css               Design tokens (palet senja-lavender-emas, gradient, shadow bercahaya)
  lib/
    supabaseClient.js   Klien Supabase (pakai env PUBLIC_*)
    stores/auth.js      Svelte store untuk sesi user
    categoryColors.js   Pemetaan warna aksen per kategori
    components/
      FairyLights.svelte    Partikel cahaya peri berkelip (CSS murni)
      FlyingFairy.svelte    Peri bersayap kelopak bunga yang terbang melintas (animasi CSS)
      CategoryCard.svelte   Kartu taman topik bersinar
      SidebarPostMini.svelte  Kartu mini bergambar untuk sidebar
      StatOrb.svelte         Orb statistik bercahaya untuk dashboard di hero
      PostCard.svelte        Kartu cerita (menangani foto opsional dengan placeholder)
      CommentItem.svelte     Item tanggapan (dengan tombol hapus untuk pemilik)
  routes/
    +layout.svelte              Header sticky, navigasi, wiring sesi login
    +page.svelte                 Beranda: hero animasi peri + dashboard, grid taman topik, cerita terbaru + sidebar
    login/+page.svelte
    register/+page.svelte
    kategori/[slug]/+page.svelte  Halaman taman topik: artikel panduan + forum cerita topik itu
    posts/new/+page.svelte        Form tulis cerita (foto opsional, kategori bisa terisi otomatis dari link taman)
    posts/[id]/+page.svelte       Detail cerita + hapus (pemilik) + tanggapan
supabase/
  schema.sql             Semua SQL: tabel, artikel panduan tiap taman topik, RLS, storage bucket
```

## Catatan

- Animasi peri & kelap-kelip cahaya dibuat murni dengan CSS (tanpa library animasi eksternal),
  jadi ringan dan tidak menambah beban loading.
- Foto cerita **opsional** — kalau tidak diisi, kartu dan halaman detail menampilkan placeholder
  bertema taman peri, bukan kotak kosong.
- Artikel panduan tiap taman topik (ringkasan + daftar tips) disimpan sebagai data di tabel
  `categories` (`info_intro` dan `info_tips`), jadi bisa diedit langsung lewat Supabase Table
  Editor tanpa perlu mengubah kode atau deploy ulang.
- Hanya pemilik cerita yang bisa menghapus ceritanya (sekaligus foto & seluruh tanggapan di
  dalamnya ikut terhapus otomatis). Pemilik tanggapan juga bisa menghapus tanggapannya sendiri.
- Lihat `progress.md` untuk daftar fitur yang sudah selesai dan yang belum.
