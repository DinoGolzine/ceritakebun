<script>
  import { categoryColor } from '$lib/categoryColors';

  export let post;

  $: excerpt =
    post.description?.length > 140
      ? post.description.slice(0, 140).trimEnd() + '…'
      : post.description;

  $: authorName = post.profiles?.display_name || post.profiles?.email || 'Penulis';
  $: commentCount = post.comments?.[0]?.count ?? 0;
</script>

<a class="card" href={`/posts/${post.id}`}>
  <div class="cover" class:no-image={!post.image_url}>
    {#if post.image_url}
      <img src={post.image_url} alt="" loading="lazy" />
    {:else}
      <span class="cover-fallback">🌿</span>
    {/if}
    {#if post.categories}
      <span class="badge" style={`--badge-color: ${categoryColor(post.categories.slug)}`}>
        {post.categories.icon}
        {post.categories.name}
      </span>
    {/if}
  </div>

  <div class="body">
    <h3>{post.title}</h3>
    <p class="typewriter">{excerpt}</p>
    <div class="meta mono">
      <span>{authorName}</span>
      <span class="dot">/</span>
      <span>{new Date(post.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })}</span>
      <span class="dot">/</span>
      <span>{commentCount} tanggapan</span>
    </div>
  </div>
</a>

<style>
  .card {
    display: flex;
    flex-direction: column;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    overflow: hidden;
    text-decoration: none;
    color: inherit;
    transition: transform 0.15s ease, border-color 0.15s ease;
    height: 100%;
  }
  .card:hover {
    border-color: var(--primary);
    transform: translateY(-2px);
  }
  .cover {
    position: relative;
    aspect-ratio: 16 / 10;
    background: var(--surface-soft);
    overflow: hidden;
  }
  .cover img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }
  .cover.no-image {
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .cover-fallback {
    font-size: 2.25rem;
    opacity: 0.5;
  }
  .badge {
    position: absolute;
    top: 0.7rem;
    left: 0.7rem;
    background: var(--badge-color, var(--primary));
    color: #fff;
    padding: 0.25rem 0.65rem;
    border-radius: var(--radius-pill);
    font-size: 0.72rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
  }
  .body {
    padding: 1.1rem 1.2rem 1.25rem;
    display: flex;
    flex-direction: column;
    flex: 1;
  }
  h3 {
    font-size: 1.15rem;
    margin-bottom: 0.5rem;
  }
  p {
    margin: 0 0 0.9rem;
    color: var(--ink-soft);
    font-size: 0.88rem;
    flex: 1;
  }
  .meta {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.4rem;
    font-size: 0.72rem;
    color: var(--muted);
  }
  .dot {
    opacity: 0.5;
  }
</style>
