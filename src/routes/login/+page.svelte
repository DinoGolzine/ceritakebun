<script>
  import { supabase } from '$lib/supabaseClient';
  import { goto } from '$app/navigation';

  let email = '';
  let password = '';
  let error = '';
  let loading = false;

  async function handleLogin() {
    loading = true;
    error = '';
    const { error: err } = await supabase.auth.signInWithPassword({ email, password });
    loading = false;
    if (err) {
      error = err.message;
    } else {
      goto('/');
    }
  }
</script>

<div class="wrap">
  <div class="card">
    <span class="sparkle">🧚</span>
    <h1>Selamat datang kembali</h1>
    <p class="lead">Masuk untuk menulis cerita dan menanggapi.</p>
    <form on:submit|preventDefault={handleLogin}>
      <label>
        Email
        <input type="email" bind:value={email} autocomplete="email" required />
      </label>
      <label>
        Kata sandi
        <input type="password" bind:value={password} autocomplete="current-password" required />
      </label>
      {#if error}<p class="error">{error}</p>{/if}
      <button type="submit" disabled={loading}>{loading ? 'Memproses…' : 'Masuk'}</button>
    </form>
    <p class="switch">Belum punya akun? <a href="/register">Daftar di sini</a></p>
  </div>
</div>

<style>
  .wrap {
    display: flex;
    justify-content: center;
    padding: 1.5rem 0 3rem;
  }
  .card {
    width: 100%;
    max-width: 400px;
    background: var(--surface);
    border-radius: var(--radius-card);
    padding: 2.1rem 1.9rem;
    box-shadow: var(--shadow-md);
    border: 1px solid var(--line);
    text-align: center;
  }
  .sparkle {
    font-size: 2rem;
    display: block;
    margin-bottom: 0.5rem;
  }
  h1 {
    font-size: 1.65rem;
    margin-bottom: 0.3rem;
  }
  .lead {
    color: var(--ink-soft);
    margin-bottom: 1.5rem;
    font-size: 0.9rem;
  }
  form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    text-align: left;
  }
  label {
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
    font-size: 0.86rem;
    color: var(--ink-soft);
    font-weight: 600;
  }
  input {
    padding: 0.65rem 0.8rem;
    border: 1px solid var(--line);
    border-radius: var(--radius-control);
    font-size: 0.95rem;
    font-weight: 400;
    background: var(--surface);
    color: var(--ink);
  }
  button {
    padding: 0.7rem;
    background: var(--primary);
    color: #fff;
    border: none;
    border-radius: var(--radius-pill);
    cursor: pointer;
    font-size: 0.95rem;
    font-weight: 700;
    box-shadow: var(--shadow-sm);
  }
  button:disabled {
    opacity: 0.6;
    cursor: default;
  }
  .error {
    color: var(--danger);
    font-size: 0.85rem;
    margin: 0;
  }
  .switch {
    margin-top: 1.25rem;
    font-size: 0.86rem;
    color: var(--ink-soft);
  }
</style>
