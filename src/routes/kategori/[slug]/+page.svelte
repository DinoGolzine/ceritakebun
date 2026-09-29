<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import PostCard from '$lib/components/PostCard.svelte';
  import CategoryCard from '$lib/components/CategoryCard.svelte';
  import FairyLights from '$lib/components/FairyLights.svelte';
  import { categoryColor } from '$lib/categoryColors';

  let category = null;
  let posts = [];
  let otherCategories = [];
  let loading = true;
  let notFound = false;
  let error = '';

  $: slug = $page.params.slug;
  $: accent = category ? categoryColor(category.slug) : 'var(--primary)';

  async function loadCategory() {
    const { data, error: err } = await supabase.from('categories').select('*').eq('slug', slug).maybeSingle();
    if (err) {
      error = err.message;
    } else if (!data) {
      notFound = true;
    } else {
      category = data;
    }
  }

  async function loadPosts() {
    if (!category) return;
    const { data } = await supabase
      .from('posts')
      .select('id, title, description, image_url, created_at, profiles(display_name, email), comments(count)')
      .eq('category_id', category.id)
      .order('created_at', { ascending: false });
    posts = data ?? [];
  }

  async function loadOtherCategories() {
    const { data } = await supabase.from('categories').select('*').neq('slug', slug).order('sort_order');
    otherCategories = data ?? [];
  }

  onMount(async () => {
    loading = true;
    await loadCategory();
    if (category) {
      await Promise.all([loadPosts(), loadOtherCategories()]);
    }
    loading = false;
  });
</script>

{#if loading}
  <p class="hint">Memuat…</p>
{:else if notFound}
  <p class="hint">Taman topik tidak ditemukan.</p>
{:else if error}
  <p class="error">Gagal memuat: {error}</p>
{:else if category}
  <section class="banner" style={`--accent: ${accent}`}>
    <FairyLights />
    <div class="banner-inner">
      <span class="banner-icon">{category.icon}</span>
      <div>
        <p class="eyebrow">Taman Topik ✦ Panduan &amp; Forum</p>
        <h1>{category.name}</h1>
        <p class="tagline">{category.description}</p>
      </div>
      <a class="cta" href={`/posts/new?kategori=${category.slug}`}>✨ Tulis Cerita di Taman Ini</a>
    </div>
  </section>

  <div class="layout">
    <div class="main-col">
      <section class="info-article">
        <h2>📜 Tentang Taman Ini</h2>
        <p class="intro">{category.info_intro}</p>
        {#if category.info_tips?.length}
          <ul class="tips">
            {#each category.info_tips as tip}
              <li>
                <span class="leaf" style={`--accent: ${accent}`}>🌿</span>
                <span>{tip}</span>
              </li>
            {/each}
          </ul>
        {/if}
      </section>

      <section class="forum">
        <div class="forum-head">
          <h2>💬 Cerita &amp; Tanya Jawab</h2>
          <a class="cta-outline" href={`/posts/new?kategori=${category.slug}`} style={`--accent: ${accent}`}>+ Tulis Cerita</a>
        </div>

        {#if posts.length === 0}
          <div class="empty">
            <p>Belum ada cerita di taman ini.</p>
            <a class="cta-outline" href={`/posts/new?kategori=${category.slug}`} style={`--accent: ${accent}`}>Jadilah yang pertama menabur cerita</a>
          </div>
        {:else}
          <div class="grid">
            {#each posts as post (post.id)}
              <PostCard {post} />
            {/each}
          </div>
        {/if}
      </section>
    </div>

    <aside class="sidebar">
      <div class="panel">
        <h3>Taman Lainnya</h3>
        <div class="other-cats">
          {#each otherCategories as cat (cat.id)}
            <CategoryCard category={cat} />
          {/each}
        </div>
      </div>
    </aside>
  </div>
{/if}

<style>
  .banner {
    position: relative;
    display: flex;
    align-items: center;
    background: var(--accent);
    border-radius: var(--radius-card);
    padding: 1.9rem 2rem;
    color: #fff;
    margin-bottom: 2rem;
    overflow: hidden;
  }
  .banner-inner {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 1.25rem;
    width: 100%;
  }
  .banner-icon {
    font-size: 2rem;
    width: 66px;
    height: 66px;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.22);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  .banner-inner > div:nth-child(2) {
    flex: 1;
    min-width: 200px;
  }
  .eyebrow {
    margin: 0 0 0.3rem;
    font-size: 0.72rem;
    letter-spacing: 0.06em;
    color: rgba(255, 255, 255, 0.85);
    font-weight: 700;
  }
  .banner h1 {
    color: #fff;
    font-size: 1.7rem;
    margin-bottom: 0.35rem;
  }
  .tagline {
    margin: 0;
    color: rgba(255, 255, 255, 0.92);
    font-size: 0.9rem;
    max-width: 50ch;
  }
  .cta {
    background: #fff;
    color: var(--ink);
    text-decoration: none;
    padding: 0.65rem 1.3rem;
    border-radius: var(--radius-pill);
    font-size: 0.85rem;
    font-weight: 800;
    white-space: nowrap;
  }

  .layout {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 1.75rem;
    align-items: start;
  }
  @media (max-width: 900px) {
    .layout {
      grid-template-columns: 1fr;
    }
  }

  .info-article {
    background: var(--surface);
    border-radius: var(--radius-card);
    padding: 1.6rem 1.8rem;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--line);
    margin-bottom: 2rem;
  }
  .info-article h2 {
    font-size: 1.2rem;
    margin-bottom: 0.75rem;
  }
  .intro {
    color: var(--ink-soft);
    font-size: 0.96rem;
    margin: 0 0 1.1rem;
  }
  .tips {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 0.65rem;
  }
  .tips li {
    display: flex;
    gap: 0.6rem;
    align-items: flex-start;
    font-size: 0.9rem;
    color: var(--ink);
  }
  .leaf {
    flex-shrink: 0;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: color-mix(in srgb, var(--accent) 20%, white);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.8rem;
    margin-top: 0.05rem;
  }

  .forum-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 1.1rem;
    flex-wrap: wrap;
  }
  .forum-head h2 {
    font-size: 1.2rem;
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
    background: var(--accent, var(--primary));
    color: #fff;
    text-decoration: none;
    padding: 0.55rem 1.2rem;
    border-radius: var(--radius-control);
    font-size: 0.85rem;
    font-weight: 700;
    white-space: nowrap;
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
    margin-bottom: 1rem;
  }
  .other-cats {
    display: flex;
    flex-direction: column;
    gap: 0.7rem;
  }

  .hint {
    color: var(--ink-soft);
  }
  .error {
    color: var(--danger);
  }
</style>
