<script>
  export let post;
</script>

<a class="mini" href={`/posts/${post.id}`}>
  <div class="thumb" class:no-image={!post.image_url}>
    {#if post.image_url}
      <img src={post.image_url} alt="" loading="lazy" />
    {:else}
      <span>🍃</span>
    {/if}
  </div>
  <div class="info">
    <h4>{post.title}</h4>
    {#if post.categories}
      <span class="cat">{post.categories.icon} {post.categories.name}</span>
    {/if}
  </div>
</a>

<style>
  .mini {
    display: flex;
    align-items: center;
    gap: 0.65rem;
    text-decoration: none;
    color: inherit;
    padding: 0.45rem;
    border-radius: var(--radius-control);
    transition: background 0.15s ease;
  }
  .mini:hover {
    background: var(--primary-light);
  }
  .thumb {
    width: 50px;
    height: 50px;
    border-radius: 13px;
    overflow: hidden;
    flex-shrink: 0;
    background: var(--primary-light);
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }
  .info {
    min-width: 0;
  }
  h4 {
    margin: 0 0 0.15rem;
    font-family: var(--font-display);
    font-weight: 600;
    font-size: 0.92rem;
    line-height: 1.3;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .cat {
    font-size: 0.68rem;
    color: var(--primary-dark);
    font-weight: 700;
  }
</style>
