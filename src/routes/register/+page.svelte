<script>
  import { supabase } from '$lib/supabaseClient';
  import { goto } from '$app/navigation';

  let displayName = '';
  let email = '';
  let password = '';
  let error = '';
  let info = '';
  let loading = false;

  async function handleRegister() {
    loading = true;
    error = '';
    info = '';
    const { data, error: err } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { display_name: displayName } }
    });
    loading = false;
    if (err) {
      error = err.message;
      return;
    }
    if (data.session) {
      goto('/');
    } else {
      info = 'Pendaftaran berhasil. Silakan cek email untuk verifikasi, lalu masuk.';
    }
  }
</script>

<div class="form-wrap">
  <h1>Daftar</h1>
  <p class="lead">Buat akun untuk mulai menulis cerita kebunmu.</p>
  <form on:submit|preventDefault={handleRegister}>
    <label>
      Nama tampilan
      <input type="text" bind:value={displayName} autocomplete="name" required />
    </label>
    <label>
      Email
      <input type="email" bind:value={email} autocomplete="email" required />
    </label>
    <label>
      Kata sandi
      <input type="password" bind:value={password} minlength="6" autocomplete="new-password" required />
    </label>
    {#if error}<p class="error">{error}</p>{/if}
    {#if info}<p class="info">{info}</p>{/if}
    <button type="submit" disabled={loading}>{loading ? 'Memproses…' : 'Daftar'}</button>
  </form>
  <p class="switch">Sudah punya akun? <a href="/login">Masuk di sini</a></p>
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
  .info {
    color: var(--primary-dark);
    font-size: 0.85rem;
    margin: 0;
  }
  .switch {
    margin-top: 1.25rem;
    font-size: 0.88rem;
    color: var(--ink-soft);
  }
</style>
