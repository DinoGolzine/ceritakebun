// Warna aksen per kategori untuk badge & kartu, dipetakan lewat slug.
const COLORS = {
  'pengalaman-lapangan': 'var(--cat-1)',
  'tips-tutorial': 'var(--cat-2)',
  'profil-sosok': 'var(--cat-3)',
  'hasil-bumi-olahan': 'var(--cat-4)'
};

export function categoryColor(slug) {
  return COLORS[slug] ?? 'var(--primary)';
}
