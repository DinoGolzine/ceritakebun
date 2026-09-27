<script>
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import PostCard from '$lib/components/PostCard.svelte';

  let categories = [];
  let posts = [];
  let loading = true;
  let selectedCategory = null;
  let error = '';

  async function loadCategories() {
    const { data } = await supabase.from('categories').select('*').order('sort_order');
    categories = data ?? [];
  }

  async function loadPosts() {
    loading = true;
    error = '';
    let query = supabase
      .from('posts')
      .select(
        'id, title, description, image_url, created_at, category_id, categories(name, slug, icon), profiles(display_name, email), comments(count)'
      )
      .order('created_at', { ascending: false });

    if (selectedCategory) {
      query = query.eq('category_id', selectedCategory);
    }

    const { data, error: err } = await query;
    if (err) {
      error = err.message;
    } else {
      posts = data ?? [];
    }
    loading = false;
  }

  function selectCategory(id) {
    selectedCategory = selectedCategory === id ? null : id;
    loadPosts();
  }

  onMount(async () => {
    await loadCategories();
    await loadPosts();
  });
</script>

<section class="hero">
  <p class="eyebrow mono">jurnal &amp; forum berkebun</p>
  <h1>Cerita, tips, dan hasil kebun — dari pekebun untuk pekebun.</h1>
  <p class="lead typewriter">
    Bagikan pengalaman lapangan, tutorial praktis, sosok pekebun inspiratif, atau hasil
    olahan panenmu. Yang lain bisa ikut menanggapi.
  </p>
</section>

{#if categories.length}
  <div class="categories">
    {#each categories as cat (cat.id)}
      <button
        type="button"
        class:active={selectedCategory === cat.id}
        on:click={() => selectCategory(cat.id)}
      >
        <span class="icon">{cat.icon}</span>
        {cat.name}
      </button>
    {/each}
  </div>
{/if}

{#if error}
  <p class="error">Gagal memuat cerita: {error}</p>
{/if}

{#if loading}
  <p class="hint">Memuat cerita…</p>
{:else if posts.length === 0}
  <div class="empty">
    <p>Belum ada cerita di kategori ini.</p>
    <a class="cta" href="/posts/new">Jadilah yang pertama bertanya</a>
  </div>
{:else}
  <div class="list">
    {#each posts as post (post.id)}
      <PostCard {post} />
    {/each}
  </div>
{/if}

<style>
  .hero {
    margin-bottom: 1.75rem;
  }
  .eyebrow {
    color: var(--accent);
    font-size: 0.78rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin: 0 0 0.6rem;
  }
  .hero h1 {
    font-size: 1.9rem;
    margin-bottom: 0.75rem;
  }
  .lead {
    color: var(--ink-soft);
    max-width: 46ch;
    font-size: 0.95rem;
  }
  .categories {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-bottom: 1.75rem;
  }
  .categories button {
    padding: 0.4rem 0.95rem;
    border-radius: var(--radius-pill);
    border: 1px solid var(--line);
    background: var(--surface);
    color: var(--primary-dark);
    cursor: pointer;
    font-size: 0.84rem;
  }
  .categories button.active {
    background: var(--primary);
    border-color: var(--primary);
    color: #fff;
  }
  .list {
    display: flex;
    flex-direction: column;
    gap: 0.8rem;
  }
  .hint {
    color: var(--muted);
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
  .cta {
    display: inline-block;
    background: var(--primary);
    color: #fff;
    text-decoration: none;
    padding: 0.55rem 1.2rem;
    border-radius: var(--radius-control);
    font-size: 0.9rem;
  }
</style>
