<script>
  export let label;
  export let value;
  export let icon = '✨';
</script>

<div class="orb">
  <span class="orb-icon">{icon}</span>
  <div>
    <p class="value">{value}</p>
    <p class="label">{label}</p>
  </div>
</div>

<style>
  .orb {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: var(--radius-control);
    padding: 0.7rem 0.9rem;
  }
  .orb-icon {
    font-size: 1.2rem;
  }
  .value {
    margin: 0;
    font-family: var(--font-display);
    font-weight: 700;
    font-size: 1.3rem;
    color: #fff;
    line-height: 1.1;
  }
  .label {
    margin: 0.1rem 0 0;
    font-size: 0.68rem;
    color: rgba(255, 255, 255, 0.78);
  }
</style>
