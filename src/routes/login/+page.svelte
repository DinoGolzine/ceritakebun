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

<div class="form-wrap">
  <h1>Masuk</h1>
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

<style>
  .form-wrap {
    max-width: 380px;
    margin: 0 auto;
  }
  h1 {
    font-size: 1.6rem;
    margin-bottom: 0.3rem;
  }
  .lead {
    color: var(--ink-soft);
    margin-bottom: 1.5rem;
    font-size: 0.92rem;
  }
  form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  label {
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
    font-size: 0.88rem;
    color: var(--ink-soft);
  }
  input {
    padding: 0.6rem 0.75rem;
    border: 1px solid var(--line);
    border-radius: var(--radius-control);
    font-size: 0.95rem;
    background: var(--surface);
    color: var(--ink);
  }
  button {
    padding: 0.65rem;
    background: var(--primary);
    color: #fff;
    border: none;
    border-radius: var(--radius-control);
    cursor: pointer;
    font-size: 0.95rem;
    font-weight: 600;
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
    font-size: 0.88rem;
    color: var(--ink-soft);
  }
</style>
