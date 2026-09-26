// Warna aksen per kategori untuk badge, dipetakan lewat slug.
// Dipisah dari komponen supaya konsisten dipakai di kartu, halaman detail, dan filter.
const COLORS = {
  'pengalaman-lapangan': 'var(--cat-green)',
  'tips-tutorial': 'var(--cat-rust)',
  'profil-sosok': 'var(--cat-teal)',
  'hasil-bumi-olahan': 'var(--cat-gold)'
};

export function categoryColor(slug) {
  return COLORS[slug] ?? 'var(--primary)';
}
