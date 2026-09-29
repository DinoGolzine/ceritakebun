<script>
  import { categoryColor } from '$lib/categoryColors';

  export let category;
</script>

<a class="tile" href={`/kategori/${category.slug}`} style={`--accent: ${categoryColor(category.slug)}`}>
  <span class="icon">{category.icon}</span>
  <h3>{category.name}</h3>
  <p>{category.description}</p>
  <span class="link">Masuki taman ini ✨</span>
</a>

<style>
  .tile {
    display: flex;
    flex-direction: column;
    gap: 0.45rem;
    background: var(--surface);
    border-radius: var(--radius-card);
    padding: 1.4rem 1.3rem;
    text-decoration: none;
    color: inherit;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--line);
    position: relative;
    overflow: hidden;
    transition: transform 0.18s ease, box-shadow 0.18s ease;
  }
  .tile::before {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(circle at 85% -10%, var(--accent) 0%, transparent 55%);
    opacity: 0.16;
    pointer-events: none;
  }
  .tile:hover {
    transform: translateY(-3px);
    box-shadow: 0 0 0 1px var(--accent), var(--shadow-md);
  }
  .icon {
    font-size: 1.7rem;
    width: 48px;
    height: 48px;
    border-radius: 14px;
    background: var(--accent);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 0.2rem;
  }
  h3 {
    font-size: 1.2rem;
  }
  p {
    margin: 0;
    color: var(--ink-soft);
    font-size: 0.86rem;
    flex: 1;
  }
  .link {
    margin-top: 0.5rem;
    font-size: 0.8rem;
    font-weight: 700;
    color: var(--accent);
  }
</style>
