<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';
  import { user, authLoading } from '$lib/stores/auth';
  import { goto } from '$app/navigation';
  import CommentItem from '$lib/components/CommentItem.svelte';
  import { categoryColor } from '$lib/categoryColors';

  let post = null;
  let comments = [];
  let loading = true;
  let notFound = false;
  let error = '';

  let commentContent = '';
  let submittingComment = false;
  let commentError = '';
  let deletingPost = false;

  $: postId = $page.params.id;
  $: authorName = post?.profiles?.display_name || post?.profiles?.email || 'Penulis';
  $: isPostOwner = $user && post && $user.id === post.user_id;

  async function loadPost() {
    const { data, error: err } = await supabase
      .from('posts')
      .select('*, categories(name, slug, icon), profiles(display_name, email)')
      .eq('id', postId)
      .maybeSingle();
    if (err) {
      error = err.message;
    } else if (!data) {
      notFound = true;
    } else {
      post = data;
    }
  }

  async function loadComments() {
    const { data } = await supabase
      .from('comments')
      .select('*, profiles(display_name, email)')
      .eq('post_id', postId)
      .order('created_at', { ascending: true });
    comments = data ?? [];
  }

  async function handleCommentSubmit() {
    if (!$user) return;
    submittingComment = true;
    commentError = '';
    const { error: err } = await supabase.from('comments').insert({
      post_id: postId,
      user_id: $user.id,
      content: commentContent
    });
    submittingComment = false;
    if (!err) {
      commentContent = '';
      await loadComments();
    } else {
      commentError = err.message;
    }
  }

  async function handleCommentDelete(event) {
    const commentId = event.detail;
    await supabase.from('comments').delete().eq('id', commentId);
    await loadComments();
  }

  async function handleDeletePost() {
    if (!isPostOwner) return;
    if (!confirm('Hapus cerita ini beserta seluruh tanggapannya? Tindakan ini tidak bisa dibatalkan.')) return;

    deletingPost = true;
    try {
      const { error: err } = await supabase.from('posts').delete().eq('id', postId);
      if (err) throw err;

      if (post.image_path) {
        await supabase.storage.from('post-images').remove([post.image_path]);
      }

      goto('/');
    } catch (e) {
      error = e.message ?? 'Gagal menghapus cerita.';
      deletingPost = false;
    }
  }

  onMount(async () => {
    loading = true;
    await loadPost();
    if (post) await loadComments();
    loading = false;
  });
</script>

{#if loading}
  <p class="hint">Memuat…</p>
{:else if notFound}
  <p class="hint">Cerita tidak ditemukan.</p>
{:else if error}
  <p class="error">Gagal memuat: {error}</p>
{:else if post}
  <article class="post">
    {#if post.image_url}
      <img class="cover" src={post.image_url} alt="" />
    {/if}

    <div class="post-body">
      <div class="top-row">
        {#if post.categories}
          <span class="badge" style={`--badge-color: ${categoryColor(post.categories.slug)}`}>
            {post.categories.icon} {post.categories.name}
          </span>
        {/if}
        {#if isPostOwner}
          <button class="delete-post" type="button" on:click={handleDeletePost} disabled={deletingPost}>
            {deletingPost ? 'Menghapus…' : 'Hapus cerita'}
          </button>
        {/if}
      </div>

      <h1>{post.title}</h1>
      <p class="meta mono">
        Oleh <span class="author">{authorName}</span> ·
        {new Date(post.created_at).toLocaleString('id-ID', {
          day: 'numeric',
          month: 'short',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })}
      </p>
      <p class="body">{post.description}</p>
    </div>
  </article>

  <section class="comments">
    <h2>{comments.length} {comments.length === 1 ? 'Tanggapan' : 'Tanggapan'}</h2>

    {#each comments as c (c.id)}
      <CommentItem comment={c} currentUserId={$user?.id ?? null} on:delete={handleCommentDelete} />
    {:else}
      <p class="hint">Belum ada tanggapan. Jadilah yang pertama menanggapi.</p>
    {/each}

    {#if !$authLoading}
      {#if $user}
        <form on:submit|preventDefault={handleCommentSubmit}>
          <textarea bind:value={commentContent} rows="4" placeholder="Tulis tanggapanmu…" required></textarea>
          {#if commentError}<p class="error">{commentError}</p>{/if}
          <button type="submit" disabled={submittingComment}>{submittingComment ? 'Mengirim…' : 'Kirim tanggapan'}</button>
        </form>
      {:else}
        <p class="hint">Silakan <a href="/login">masuk</a> untuk menanggapi.</p>
      {/if}
    {/if}
  </section>
{/if}

<style>
  .post {
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    overflow: hidden;
    margin-bottom: 2rem;
  }
  .cover {
    width: 100%;
    max-height: 420px;
    object-fit: cover;
    display: block;
  }
  .post-body {
    padding: 1.4rem 1.6rem 1.6rem;
  }
  .top-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 0.75rem;
    margin-bottom: 0.75rem;
  }
  .badge {
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    background: var(--badge-color, var(--primary));
    color: #fff;
    padding: 0.2rem 0.7rem;
    border-radius: var(--radius-pill);
    font-size: 0.74rem;
    font-weight: 600;
  }
  .delete-post {
    background: none;
    border: 1px solid var(--danger);
    color: var(--danger);
    padding: 0.35rem 0.8rem;
    border-radius: var(--radius-control);
    font-size: 0.78rem;
    cursor: pointer;
  }
  .delete-post:disabled {
    opacity: 0.6;
    cursor: default;
  }
  h1 {
    font-size: 1.6rem;
    margin-bottom: 0.5rem;
  }
  .meta {
    font-size: 0.76rem;
    color: var(--muted);
    margin: 0 0 1rem;
  }
  .author {
    color: var(--primary-dark);
    font-weight: 600;
  }
  .body {
    white-space: pre-wrap;
    color: var(--ink-soft);
    margin: 0;
    font-size: 0.98rem;
  }
  .comments h2 {
    font-size: 1.05rem;
    margin-bottom: 1rem;
  }
  form {
    display: flex;
    flex-direction: column;
    gap: 0.7rem;
    margin-top: 1.25rem;
  }
  textarea {
    padding: 0.65rem 0.75rem;
    border: 1px solid var(--line);
    border-radius: var(--radius-control);
    font-family: inherit;
    font-size: 0.95rem;
    resize: vertical;
    background: var(--surface);
    color: var(--ink);
  }
  button[type='submit'] {
    padding: 0.6rem 1.4rem;
    background: var(--primary);
    color: #fff;
    border: none;
    border-radius: var(--radius-control);
    cursor: pointer;
    font-weight: 600;
    align-self: flex-start;
  }
  button:disabled {
    opacity: 0.6;
    cursor: default;
  }
  .hint {
    color: var(--ink-soft);
  }
  .error {
    color: var(--danger);
    font-size: 0.85rem;
    margin: 0;
  }
</style>
