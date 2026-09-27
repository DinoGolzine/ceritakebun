import { writable } from 'svelte/store';

// Sesi pengguna saat ini (null jika belum login)
export const user = writable(null);

// true selama pengecekan sesi awal berlangsung
export const authLoading = writable(true);
