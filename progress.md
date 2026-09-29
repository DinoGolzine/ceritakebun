# Progress

Status: Rombak total (iterasi ketiga) — tema taman peri (fairytale) dengan animasi CSS,
tiap taman topik kini punya halaman info + forum sendiri, foto jadi opsional. Skema database
berubah (kolom artikel panduan + foto opsional) — **jalankan ulang `supabase/schema.sql`** di
Supabase kamu, aman dan tidak menghapus data lama.

## Sudah dibuat

- [x] Setup project SvelteKit + adapter-vercel + integrasi Supabase client
- [x] Skema database (`supabase/schema.sql`): tabel `categories` (dengan `info_intro` +
      `info_tips`), `profiles`, `posts`, `comments`
- [x] 4 taman topik di-seed lengkap dengan artikel panduannya: Pengalaman Lapangan,
      Tips & Tutorial (How-To), Profil & Sosok, Hasil Bumi & Olahan
- [x] Row Level Security: cerita & tanggapan bisa dibaca semua orang, hanya bisa ditambahkan
      oleh user yang login, hanya pemilik yang bisa update/delete miliknya
- [x] Storage bucket publik `post-images` + policy upload (harus login) & baca (publik)
- [x] Registrasi & login dengan email/password (Supabase Auth)
- [x] **Halaman tiap taman topik (`/kategori/[slug]`)**: banner berwarna dengan kelap-kelip
      cahaya peri, artikel panduan (ringkasan + daftar tips), dan forum cerita khusus topik
      itu di halaman yang sama, plus tombol "Tulis Cerita" yang otomatis memilih taman terkait
- [x] **Foto saat menulis cerita sekarang opsional** — kalau tidak diisi, kartu & halaman
      detail menampilkan placeholder bertema taman peri, bukan kotak kosong
- [x] **Tombol "Hapus cerita"** untuk pemilik — menghapus baris database, foto di storage
      (kalau ada), dan seluruh tanggapan di dalamnya (cascade)
- [x] **Tombol "Hapus" pada tiap tanggapan** untuk pemilik tanggapan tersebut
- [x] Beranda bergaya dashboard: hero gradient senja dengan **animasi peri terbang** (sayap
      berkelopak bunga) dan **partikel cahaya peri berkelip**, orb statistik (total cerita,
      tanggapan, cerita minggu ini, jumlah taman), grid 4 kartu taman topik bersinar, daftar
      cerita terbaru, sidebar berisi navigasi taman cepat + "Cerita Bergambar" dengan thumbnail
- [x] Desain tema taman peri: font "Cormorant Garamond" (judul, gaya dongeng) + "Nunito" (isi,
      ramah dibaca), palet senja ungu-lavender-emas-pink, kartu dengan shadow bercahaya
- [x] Animasi dibuat murni CSS (tanpa library eksternal) — ringan dan tidak membebani loading
- [x] README dengan langkah setup Supabase & dua cara deploy ke Vercel (CLI & GitHub), termasuk
      catatan migrasi untuk project Supabase yang sudah pernah pakai skema lama

## Belum dibuat / bisa dikembangkan lagi

- [ ] Edit cerita/tanggapan dari UI (RLS sudah mengizinkan pemilik update, tinggal buat formnya)
- [ ] Pencarian cerita berdasarkan kata kunci
- [ ] Paginasi / infinite scroll untuk daftar cerita (saat ini memuat sebagian sekaligus)
- [ ] Upload lebih dari satu foto per cerita (saat ini hanya satu foto sampul)
- [ ] Foto pada tanggapan (saat ini tanggapan hanya teks)
- [ ] Like / bookmark cerita
- [ ] Halaman profil pengguna (daftar cerita & tanggapan miliknya)
- [ ] Notifikasi saat cerita ditanggapi
- [ ] Kompresi/resize gambar sebelum upload
- [ ] Reset password (lupa kata sandi)
- [ ] Edit artikel panduan taman topik langsung dari UI admin (saat ini hanya lewat Supabase Table Editor)
- [ ] Testing otomatis (belum ada unit/e2e test)

## Cara melanjutkan

Semua query Supabase dipanggil langsung dari komponen Svelte lewat `src/lib/supabaseClient.js`
(tidak ada layer API server terpisah). Untuk menambah fitur baru, biasanya cukup:

1. Tambah/ubah tabel & policy di `supabase/schema.sql`, lalu jalankan perubahannya di SQL Editor Supabase.
2. Tambah query di halaman/komponen terkait di `src/routes` atau `src/lib/components`.

Untuk mengubah isi artikel panduan tiap taman topik tanpa deploy ulang, cukup edit kolom
`info_intro` dan `info_tips` pada tabel `categories` langsung lewat Supabase Table Editor.

Warna & animasi peri diatur di `src/app.css` (token `--gradient-twilight`, `--accent`, dll)
dan di `src/lib/components/FairyLights.svelte` / `FlyingFairy.svelte`.
