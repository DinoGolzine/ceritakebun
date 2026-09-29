<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
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

    const preselectSlug = $page.url.searchParams.get('kategori');
    const preselect = preselectSlug ? categories.find((c) => c.slug === preselectSlug) : null;
    categoryId = preselect ? preselect.id : categories[0]?.id ?? '';
  });

  function handleFileChange(e) {
    const file = e.target.files?.[0] ?? null;
    imageFile = file;
    imagePreview = file ? URL.createObjectURL(file) : '';
  }

  function clearImage() {
    imageFile = null;
    imagePreview = '';
  }

  async function handleSubmit() {
    if (!$user) {
      goto('/login');
      return;
    }

    loading = true;
    error = '';

    try {
      let imageUrl = null;
      let imagePath = null;

      if (imageFile) {
        const ext = imageFile.name.split('.').pop();
        const path = `${$user.id}/${crypto.randomUUID()}.${ext}`;
        const { error: uploadErr } = await supabase.storage.from('post-images').upload(path, imageFile);
        if (uploadErr) throw uploadErr;
        const { data: urlData } = supabase.storage.from('post-images').getPublicUrl(path);
        imageUrl = urlData.publicUrl;
        imagePath = path;
      }

      const { data: inserted, error: insertErr } = await supabase
        .from('posts')
        .insert({
          title,
          description,
          category_id: categoryId || null,
          image_url: imageUrl,
          image_path: imagePath,
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

<h1>🧚 Tulis cerita baru</h1>
<p class="lead">Taburkan ceritamu ke taman — foto boleh disertakan, boleh juga tidak.</p>

{#if !$authLoading && !$user}
  <p class="hint">Silakan <a href="/login">masuk</a> terlebih dahulu untuk menulis cerita.</p>
{:else if $user}
  <form on:submit|preventDefault={handleSubmit}>
    <label>
      Judul
      <input type="text" bind:value={title} maxlength="150" placeholder="Contoh: Cara Membuat Kompos Rumah Tangga" required />
    </label>

    <label>
      Taman Topik
      <select bind:value={categoryId} required>
        {#each categories as cat (cat.id)}
          <option value={cat.id}>{cat.icon} {cat.name}</option>
        {/each}
      </select>
    </label>

    <label>
      Cerita
      <textarea bind:value={description} rows="7" placeholder="Ceritakan pengalaman, tutorial, sosok, atau hasil kebunmu…" required></textarea>
    </label>

    <label class="file-field">
      Foto <span class="optional">(opsional)</span>
      <div class="file-drop">
        <input type="file" accept="image/*" on:change={handleFileChange} />
        {#if imagePreview}
          <img class="preview" src={imagePreview} alt="Pratinjau foto" />
          <button type="button" class="remove-image" on:click|stopPropagation={clearImage}>Hapus foto</button>
        {:else}
          <span class="file-drop-hint">✨ Klik untuk pilih foto (boleh dilewati)</span>
        {/if}
      </div>
    </label>

    {#if error}<p class="error">{error}</p>{/if}

    <button type="submit" disabled={loading}>{loading ? 'Mengirim…' : 'Terbitkan cerita'}</button>
  </form>
{/if}

<style>
  h1 {
    font-size: 1.8rem;
    margin-bottom: 0.3rem;
  }
  .lead {
    color: var(--ink-soft);
    font-size: 0.92rem;
    margin: 0 0 1.5rem;
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
    font-weight: 600;
  }
  .optional {
    font-weight: 400;
    color: var(--muted);
  }
  input,
  select,
  textarea {
    padding: 0.65rem 0.8rem;
    border: 1px solid var(--line);
    border-radius: var(--radius-control);
    font-size: 0.95rem;
    font-family: inherit;
    font-weight: 400;
    background: var(--surface);
    color: var(--ink);
  }
  textarea {
    resize: vertical;
  }
  .file-drop {
    position: relative;
    border: 1.5px dashed var(--line);
    border-radius: var(--radius-card);
    padding: 1.25rem;
    text-align: center;
    background: var(--primary-light);
  }
  .file-drop input[type='file'] {
    position: absolute;
    inset: 0;
    opacity: 0;
    cursor: pointer;
    border: none;
    padding: 0;
  }
  .file-drop-hint {
    font-size: 0.85rem;
    color: var(--primary-dark);
    font-weight: 600;
  }
  .preview {
    width: 100%;
    max-width: 240px;
    aspect-ratio: 4 / 3;
    object-fit: cover;
    border-radius: var(--radius-control);
    margin: 0 auto;
    display: block;
  }
  .remove-image {
    position: relative;
    z-index: 1;
    margin-top: 0.7rem;
    background: none;
    border: none;
    color: var(--danger);
    font-size: 0.78rem;
    text-decoration: underline;
    cursor: pointer;
  }
  button[type='submit'] {
    padding: 0.7rem 1.6rem;
    background: var(--primary);
    color: #fff;
    border: none;
    border-radius: var(--radius-pill);
    cursor: pointer;
    font-size: 0.95rem;
    font-weight: 700;
    align-self: flex-start;
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
  .hint {
    color: var(--ink-soft);
  }
</style>
