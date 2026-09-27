<script>
  import { onMount } from 'svelte';
  import '../app.css';
  import { supabase } from '$lib/supabaseClient';
  import { user, authLoading } from '$lib/stores/auth';
  import { goto } from '$app/navigation';

  onMount(() => {
    supabase.auth.getSession().then(({ data }) => {
      $user = data.session?.user ?? null;
      $authLoading = false;
    });

    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
      $user = session?.user ?? null;
    });

    return () => listener.subscription.unsubscribe();
  });

  async function handleLogout() {
    await supabase.auth.signOut();
    $user = null;
    goto('/');
  }
</script>

<div class="shell">
  <header class="topbar">
    <a class="brand" href="/">
      <span class="mark">🌾</span>
      <span>
        Cerita Kebun
        <span class="tagline mono">catatan lapangan &amp; pengalaman berkebun</span>
      </span>
    </a>
    <nav>
      {#if !$authLoading}
        {#if $user}
          <a class="ghost" href="/posts/new">Tulis Cerita</a>
          <span class="who mono">{$user.email}</span>
          <button class="ghost" on:click={handleLogout}>Keluar</button>
        {:else}
          <a class="ghost" href="/login">Masuk</a>
          <a class="solid" href="/register">Daftar</a>
        {/if}
      {/if}
    </nav>
  </header>

  <main>
    <slot />
  </main>

  <footer>
    <p>Cerita Kebun — ruang berbagi cerita, tips, dan hasil kebun dari para pekebun.</p>
  </footer>
</div>

<style>
  .shell {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }
  .topbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.9rem 1.75rem;
    background: var(--primary);
    flex-wrap: wrap;
    gap: 0.75rem;
  }
  .brand {
    display: flex;
    align-items: center;
    gap: 0.45rem;
    font-family: var(--font-display);
    font-weight: 600;
    font-size: 1.2rem;
    color: #fff;
    text-decoration: none;
    line-height: 1.25;
  }
  .mark {
    font-size: 1.1rem;
  }
  .tagline {
    display: block;
    font-size: 0.65rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.6);
    text-transform: lowercase;
    letter-spacing: 0.02em;
  }
  nav {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    flex-wrap: wrap;
  }
  .who {
    color: rgba(255, 255, 255, 0.75);
    font-size: 0.82rem;
    margin-right: 0.2rem;
  }
  .ghost,
  .solid {
    font-size: 0.85rem;
    text-decoration: none;
    padding: 0.4rem 0.85rem;
    border-radius: var(--radius-control);
    cursor: pointer;
    font-family: inherit;
    border: 1px solid transparent;
  }
  .ghost {
    color: #fff;
    background: transparent;
    border-color: rgba(255, 255, 255, 0.4);
  }
  .ghost:hover {
    border-color: #fff;
  }
  .solid {
    background: var(--accent);
    color: #2c1c05;
    font-weight: 600;
  }
  main {
    flex: 1;
    max-width: 880px;
    margin: 0 auto;
    padding: 2.25rem 1.25rem 3rem;
    width: 100%;
  }
  footer {
    text-align: center;
    padding: 1.25rem;
    font-size: 0.78rem;
    color: var(--muted);
    border-top: 1px solid var(--line);
  }
</style>
