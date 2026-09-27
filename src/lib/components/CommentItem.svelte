<script>
  import { createEventDispatcher } from 'svelte';

  export let comment;
  export let currentUserId = null;

  const dispatch = createEventDispatcher();

  $: authorName = comment.profiles?.display_name || comment.profiles?.email || 'Pengguna';
  $: isOwner = currentUserId && currentUserId === comment.user_id;

  function requestDelete() {
    if (confirm('Hapus tanggapan ini?')) {
      dispatch('delete', comment.id);
    }
  }
</script>

<div class="comment">
  <div class="head">
    <span class="author">{authorName}</span>
    <span class="dot">•</span>
    <span class="date mono">{new Date(comment.created_at).toLocaleString('id-ID', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
    {#if isOwner}
      <button class="delete" type="button" on:click={requestDelete}>Hapus</button>
    {/if}
  </div>
  <p class="content typewriter">{comment.content}</p>
</div>

<style>
  .comment {
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-control);
    padding: 0.9rem 1rem;
    margin-bottom: 0.65rem;
  }
  .head {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.4rem;
    font-size: 0.75rem;
    color: var(--muted);
    margin-bottom: 0.4rem;
  }
  .author {
    color: var(--primary-dark);
    font-weight: 600;
    font-family: var(--font-body);
  }
  .dot {
    opacity: 0.6;
  }
  .content {
    margin: 0;
    white-space: pre-wrap;
    font-size: 0.9rem;
  }
  .delete {
    margin-left: auto;
    background: none;
    border: none;
    color: var(--danger);
    font-size: 0.72rem;
    cursor: pointer;
    padding: 0;
    text-decoration: underline;
  }
</style>
