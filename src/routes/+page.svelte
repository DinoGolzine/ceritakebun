<script>
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import PostCard from '$lib/components/PostCard.svelte';
  import CategoryCard from '$lib/components/CategoryCard.svelte';
  import SidebarPostMini from '$lib/components/SidebarPostMini.svelte';
  import StatOrb from '$lib/components/StatOrb.svelte';
  import FairyLights from '$lib/components/FairyLights.svelte';
  import FlyingFairy from '$lib/components/FlyingFairy.svelte';

  let categories = [];
  let latestPosts = [];
  let picturePosts = [];
  let stats = { totalPosts: 0, totalComments: 0, weekPosts: 0 };
  let loading = true;
  let error = '';

  async function loadCategories() {
    const { data } = await supabase.from('categories').select('*').order('sort_order');
    categories = data ?? [];
  }

  async function loadLatestPosts() {
    const { data, error: err } = await supabase
      .from('posts')
      .select(
        'id, title, description, image_url, created_at, category_id, categories(name, slug, icon), profiles(display_name, email), comments(count)'
      )
      .order('created_at', { ascending: false })
      .limit(8);
    if (err) {
      error = err.message;
    } else {
      latestPosts = data ?? [];
    }
  }

  async function loadPicturePosts() {
    const { data } = await supabase
      .from('posts')
      .select('id, title, image_url, categories(name, slug, icon)')
      .order('created_at', { ascending: false })
      .limit(5);
    picturePosts = data ?? [];
  }

  async function loadStats() {
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
    const [pRes, cRes, wRes] = await Promise.all([
      supabase.from('posts').select('*', { count: 'exact', head: true }),
      supabase.from('comments').select('*', { count: 'exact', head: true }),
      supabase.from('posts').select('*', { count: 'exact', head: true }).gte('created_at', sevenDaysAgo)
    ]);
    stats = {
      totalPosts: pRes.count ?? 0,
      totalComments: cRes.count ?? 0,
      weekPosts: wRes.count ?? 0
    };
  }

  onMount(async () => {
    loading = true;
    await Promise.all([loadCategories(), loadLatestPosts(), loadPicturePosts(), loadStats()]);
    loading = false;
  });
</script>

<section class="hero">
  <FairyLights />
  <FlyingFairy />
  <div class="hero-inner">
    <p class="eyebrow">✨ taman peri untuk para pekebun ✨</p>
    <h1>Cerita, tips, dan hasil kebun — ditemani peri-peri kecil di setiap sudut taman.</h1>
    <p class="lead">
      Bagikan pengalaman lapangan, tutorial praktis, sosok pekebun inspiratif, atau hasil
      olahan panenmu. Yang lain bisa ikut menanggapi.
    </p>
    <a class="cta" href="/posts/new">Mulai menulis cerita</a>

    <div class="orb-row">
      <StatOrb icon="📖" label="cerita" value={stats.totalPosts} />
      <StatOrb icon="💬" label="tanggapan" value={stats.totalComments} />
      <StatOrb icon="🌙" label="minggu ini" value={stats.weekPosts} />
      <StatOrb icon="🗺️" label="taman topik" value={categories.length} />
    </div>
  </div>
</section>

<section class="categories-section">
  <h2>4 Taman Topik</h2>
  <p class="section-lead">Masuki tiap taman untuk membaca panduan singkatnya sekaligus forum tanya jawabnya.</p>
  <div class="cat-grid">
    {#each categories as cat (cat.id)}
      <CategoryCard category={cat} />
    {/each}
  </div>
</section>

<div class="layout">
  <div class="main-col">
    <h2>Cerita Terbaru</h2>
    {#if error}
      <p class="error">Gagal memuat cerita: {error}</p>
    {/if}
    {#if loading}
      <p class="hint">Memuat cerita…</p>
    {:else if latestPosts.length === 0}
      <div class="empty">
        <p>Belum ada cerita. Jadilah peri pertama yang menabur cerita di sini!</p>
        <a class="cta-outline" href="/posts/new">Tulis cerita pertama</a>
      </div>
    {:else}
      <div class="grid">
        {#each latestPosts as post (post.id)}
          <PostCard {post} />
        {/each}
      </div>
    {/if}
  </div>

  <aside class="sidebar">
    <div class="panel">
      <h3>Jelajahi Taman</h3>
      <ul class="cat-nav">
        {#each categories as cat (cat.id)}
          <li>
            <a href={`/kategori/${cat.slug}`}>
              <span class="mini-icon">{cat.icon}</span>
              {cat.name}
            </a>
          </li>
        {/each}
      </ul>
    </div>

    <div class="panel">
      <h3>Cerita Bergambar</h3>
      <div class="pic-list">
        {#each picturePosts as p (p.id)}
          <SidebarPostMini post={p} />
        {:else}
          <p class="hint small">Belum ada cerita.</p>
        {/each}
      </div>
    </div>

    <div class="panel cta-panel">
      <h3>Punya cerita kebun?</h3>
      <p>Tulis pengalaman, tips, atau hasil panenmu — foto boleh disertakan, boleh juga tidak.</p>
      <a class="cta-outline block" href="/posts/new">✨ Tulis Cerita</a>
    </div>
  </aside>
</div>

<style>
  .hero {
    position: relative;
    background: var(--gradient-twilight);
    border-radius: var(--radius-card);
    padding: 2.5rem 2rem 2rem;
    color: #fff;
    margin-bottom: 2rem;
    overflow: hidden;
  }
  .hero-inner {
    position: relative;
    z-index: 1;
  }
  .eyebrow {
    color: var(--accent);
    font-size: 0.8rem;
    letter-spacing: 0.04em;
    margin: 0 0 0.7rem;
    font-weight: 700;
  }
  .hero h1 {
    font-size: 2.1rem;
    color: #fff;
    margin-bottom: 0.75rem;
    max-width: 34ch;
  }
  .lead {
    color: rgba(255, 255, 255, 0.85);
    font-size: 0.98rem;
    margin: 0 0 1.4rem;
    max-width: 48ch;
  }
  .cta {
    display: inline-block;
    background: var(--accent);
    color: #3a2705;
    text-decoration: none;
    padding: 0.7rem 1.6rem;
    border-radius: var(--radius-pill);
    font-size: 0.92rem;
    font-weight: 800;
    box-shadow: var(--shadow-sm);
  }
  .orb-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0.6rem;
    margin-top: 1.75rem;
  }
  @media (max-width: 640px) {
    .orb-row {
      grid-template-columns: repeat(2, 1fr);
    }
    .hero h1 {
      font-size: 1.6rem;
    }
  }

  .categories-section {
    margin-bottom: 2rem;
  }
  .categories-section h2 {
    font-size: 1.5rem;
    margin-bottom: 0.3rem;
  }
  .section-lead {
    color: var(--ink-soft);
    font-size: 0.9rem;
    margin: 0 0 1.1rem;
  }
  .cat-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1rem;
  }
  @media (max-width: 900px) {
    .cat-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }
  @media (max-width: 480px) {
    .cat-grid {
      grid-template-columns: 1fr;
    }
  }

  .layout {
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 1.75rem;
    align-items: start;
  }
  @media (max-width: 900px) {
    .layout {
      grid-template-columns: 1fr;
    }
  }
  .main-col h2 {
    font-size: 1.3rem;
    margin-bottom: 1rem;
  }
  .grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.1rem;
  }
  @media (max-width: 640px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }
  .hint {
    color: var(--muted);
  }
  .hint.small {
    font-size: 0.85rem;
  }
  .error {
    color: var(--danger);
  }
  .empty {
    text-align: center;
    padding: 2.5rem 1rem;
    background: var(--surface);
    border: 1px dashed var(--line);
    border-radius: var(--radius-card);
  }
  .empty p {
    color: var(--ink-soft);
    margin-bottom: 0.9rem;
  }
  .cta-outline {
    display: inline-block;
    background: var(--primary);
    color: #fff;
    text-decoration: none;
    padding: 0.6rem 1.3rem;
    border-radius: var(--radius-control);
    font-size: 0.9rem;
    font-weight: 700;
  }
  .cta-outline.block {
    display: block;
    text-align: center;
  }

  .sidebar {
    display: flex;
    flex-direction: column;
    gap: 1.1rem;
  }
  .panel {
    background: var(--surface);
    border-radius: var(--radius-card);
    padding: 1.25rem;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--line);
  }
  .panel h3 {
    font-size: 1.02rem;
    margin-bottom: 0.9rem;
  }
  .cat-nav {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }
  .cat-nav a {
    display: flex;
    align-items: center;
    gap: 0.55rem;
    padding: 0.5rem 0.6rem;
    border-radius: var(--radius-control);
    text-decoration: none;
    color: var(--ink-soft);
    font-size: 0.87rem;
    font-weight: 600;
  }
  .cat-nav a:hover {
    background: var(--primary-light);
    color: var(--primary-dark);
  }
  .mini-icon {
    width: 28px;
    height: 28px;
    border-radius: 8px;
    background: var(--primary-light);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  .pic-list {
    display: flex;
    flex-direction: column;
    gap: 0.15rem;
  }
  .cta-panel {
    background: var(--primary-light);
    border-color: transparent;
  }
  .cta-panel p {
    font-size: 0.85rem;
    color: var(--ink-soft);
    margin: 0 0 1rem;
  }
</style>
