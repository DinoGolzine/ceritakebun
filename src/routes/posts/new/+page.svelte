<script>
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { user, authLoading } from '$lib/stores/auth';
  import { goto } from '$app/navigation';

  let categories = [];
  let title = '';
  let description = '';
  let categoryId = '';
  let imageFile = null;
  let imagePreview = '';
  let error = '';
  let loading = false;

  onMount(async () => {
    const { data } = await supabase.from('categories').select('*').order('sort_order');
    categories = data ?? [];
    if (categories.length) categoryId = categories[0].id;
  });

  function handleFileChange(e) {
    const file = e.target.files?.[0] ?? null;
    imageFile = file;
    imagePreview = file ? URL.createObjectURL(file) : '';
  }

  async function handleSubmit() {
    if (!$user) {
      goto('/login');
      return;
    }
    if (!imageFile) {
      error = 'Sertakan satu foto untuk ceritamu.';
      return;
    }

    loading = true;
    error = '';

    try {
      const ext = imageFile.name.split('.').pop();
      const path = `${$user.id}/${crypto.randomUUID()}.${ext}`;
      const { error: uploadErr } = await supabase.storage.from('post-images').upload(path, imageFile);
      if (uploadErr) throw uploadErr;
      const { data: urlData } = supabase.storage.from('post-images').getPublicUrl(path);

      const { data: inserted, error: insertErr } = await supabase
        .from('posts')
        .insert({
          title,
          description,
          category_id: categoryId || null,
          image_url: urlData.publicUrl,
          image_path: path,
          user_id: $user.id
        })
        .select()
        .single();

      if (insertErr) throw insertErr;

      goto(`/posts/${inserted.id}`);
    } catch (e) {
      error = e.message ?? 'Terjadi kesalahan, coba lagi.';
    } finally {
      loading = false;
    }
  }
</script>

<h1>Tulis cerita baru</h1>

{#if !$authLoading && !$user}
  <p class="hint">Silakan <a href="/login">masuk</a> terlebih dahulu untuk menulis cerita.</p>
{:else if $user}
  <form on:submit|preventDefault={handleSubmit}>
    <label>
      Judul
      <input type="text" bind:value={title} maxlength="150" placeholder="Contoh: Cara Membuat Kompos Rumah Tangga" required />
    </label>

    <label>
      Kategori
      <select bind:value={categoryId} required>
        {#each categories as cat (cat.id)}
          <option value={cat.id}>{cat.icon} {cat.name}</option>
        {/each}
      </select>
    </label>

    <label>
      Cerita
      <textarea class="typewriter" bind:value={description} rows="7" placeholder="Ceritakan pengalaman, tutorial, sosok, atau hasil kebunmu…" required></textarea>
    </label>

    <label>
      Foto
      <input type="file" accept="image/*" on:change={handleFileChange} required />
    </label>
    <p class="file-hint">Satu foto wajib disertakan — foto lapangan/hasil kebun bikin ceritamu lebih hidup.</p>

    {#if imagePreview}
      <img class="preview" src={imagePreview} alt="Pratinjau foto" />
    {/if}

    {#if error}<p class="error">{error}</p>{/if}

    <button type="submit" disabled={loading}>{loading ? 'Mengirim…' : 'Terbitkan cerita'}</button>
  </form>
{/if}

<style>
  h1 {
    font-size: 1.6rem;
    margin-bottom: 1.25rem;
  }
  form {
    display: flex;
    flex-direction: column;
    gap: 1.1rem;
    max-width: 560px;
  }
  label {
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
    font-size: 0.88rem;
    color: var(--ink-soft);
  }
  input,
  select,
  textarea {
    padding: 0.6rem 0.75rem;
    border: 1px solid var(--line);
    border-radius: var(--radius-control);
    font-size: 0.95rem;
    font-family: inherit;
    background: var(--surface);
    color: var(--ink);
  }
  textarea {
    resize: vertical;
  }
  .file-hint {
    margin: -0.6rem 0 0;
    font-size: 0.78rem;
    color: var(--muted);
  }
  .preview {
    width: 200px;
    height: 200px;
    object-fit: cover;
    border-radius: var(--radius-control);
    border: 1px solid var(--line);
  }
  button {
    padding: 0.65rem 1.6rem;
    background: var(--primary);
    color: #fff;
    border: none;
    border-radius: var(--radius-control);
    cursor: pointer;
    font-size: 0.95rem;
    font-weight: 600;
    align-self: flex-start;
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
  .hint {
    color: var(--ink-soft);
  }
</style>
