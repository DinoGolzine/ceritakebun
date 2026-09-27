# Progress

Status: MVP jalan end-to-end. Tampilan dikembalikan ke layout original (bukan versi dashboard
yang sempat dibuat), dengan tema warna coklat dan font mesin ketik pada paragraf cerita.
Skema database tidak berubah — kalau Supabase-mu sudah pernah menjalankan `schema.sql`, tidak
perlu dijalankan ulang.

## Sudah dibuat

- [x] Setup project SvelteKit + adapter-vercel + integrasi Supabase client
- [x] Skema database (`supabase/schema.sql`): tabel `categories`, `profiles`, `posts`, `comments`
- [x] 4 kategori awal sudah di-seed sesuai urutan: Pengalaman Lapangan, Tips & Tutorial,
      Profil & Sosok, Hasil Bumi & Olahan (masing-masing dengan ikon emoji)
- [x] Row Level Security: cerita & tanggapan bisa dibaca semua orang, hanya bisa ditambahkan
      oleh user yang login, hanya pemilik yang bisa update/delete miliknya
- [x] Relasi `user_id` pada `posts`/`comments` mengacu ke `profiles` (bukan langsung `auth.users`)
      supaya nama penulis bisa ditampilkan lewat join otomatis Supabase
- [x] Trigger otomatis membuat baris `profiles` saat user baru mendaftar (untuk nama tampilan)
- [x] Storage bucket publik `post-images` + policy upload (harus login) & baca (publik)
- [x] Registrasi & login dengan email/password (Supabase Auth)
- [x] Header dengan status login, tombol masuk/daftar/keluar, tombol "Tulis Cerita"
- [x] Halaman beranda: hero, filter kategori (dengan ikon), grid cerita ala majalah 2 kolom
      (foto sampul, badge kategori berwarna, judul, cuplikan, penulis, tanggal, jumlah tanggapan)
- [x] Form tulis cerita: judul, pilih kategori, isi cerita, **foto wajib** dengan preview sebelum kirim
- [x] Halaman detail cerita: foto sampul besar, badge kategori, isi lengkap, nama penulis & tanggal
- [x] **Tombol "Hapus cerita"** muncul hanya untuk pemilik cerita — menghapus baris database,
      foto di storage, dan seluruh tanggapan di dalamnya (cascade)
- [x] Daftar tanggapan + form kirim tanggapan (butuh login)
- [x] **Tombol "Hapus" pada tiap tanggapan** muncul hanya untuk pemilik tanggapan tersebut
- [x] **Layout dikembalikan ke versi original** (hero + filter kategori + grid 2 kolom, tanpa
      dashboard/sidebar/ilustrasi)
- [x] **Tema warna diganti coklat** (lihat token `--primary`, `--accent`, `--cat-*` di `app.css`)
- [x] **Font paragraf cerita diganti gaya mesin ketik** (Special Elite, lewat kelas `.typewriter`) —
      dipakai pada cuplikan di kartu, isi lengkap cerita, dan tanggapan
- [x] README dengan langkah setup Supabase & dua cara deploy ke Vercel (CLI & GitHub), termasuk
      catatan soal batas pengiriman email Supabase saat testing

## Belum dibuat / bisa dikembangkan lagi

- [ ] Edit cerita/tanggapan dari UI (RLS sudah mengizinkan pemilik update, tinggal buat formnya)
- [ ] Pencarian cerita berdasarkan kata kunci
- [ ] Paginasi / infinite scroll untuk grid cerita (saat ini memuat semua sekaligus)
- [ ] Upload lebih dari satu foto per cerita (saat ini hanya satu foto sampul)
- [ ] Foto pada tanggapan (saat ini tanggapan hanya teks)
- [ ] Like / bookmark cerita
- [ ] Halaman profil pengguna (daftar cerita & tanggapan miliknya)
- [ ] Notifikasi saat cerita ditanggapi
- [ ] Kompresi/resize gambar sebelum upload
- [ ] Reset password (lupa kata sandi)
- [ ] Halaman kategori tersendiri dengan URL (saat ini filter kategori hanya di beranda)
- [ ] Testing otomatis (belum ada unit/e2e test)

## Cara melanjutkan

Semua query Supabase dipanggil langsung dari komponen Svelte lewat `src/lib/supabaseClient.js`
(tidak ada layer API server terpisah). Untuk menambah fitur baru, biasanya cukup:

1. Tambah/ubah tabel & policy di `supabase/schema.sql`, lalu jalankan perubahannya di SQL Editor Supabase.
2. Tambah query di halaman/komponen terkait di `src/routes` atau `src/lib/components`.
