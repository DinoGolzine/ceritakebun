<script>
  // Posisi & waktu tetap (bukan Math.random) supaya render server & client konsisten.
  const sparks = [
    { left: '6%', top: '18%', size: 6, delay: '0s', duration: '4.2s' },
    { left: '16%', top: '62%', size: 4, delay: '0.6s', duration: '3.4s' },
    { left: '27%', top: '30%', size: 5, delay: '1.3s', duration: '4.8s' },
    { left: '38%', top: '78%', size: 3, delay: '0.3s', duration: '3.9s' },
    { left: '49%', top: '14%', size: 6, delay: '1.8s', duration: '4.3s' },
    { left: '60%', top: '55%', size: 4, delay: '0.9s', duration: '3.6s' },
    { left: '71%', top: '22%', size: 5, delay: '1.5s', duration: '4.6s' },
    { left: '81%', top: '68%', size: 3, delay: '0.5s', duration: '3.5s' },
    { left: '90%', top: '38%', size: 5, delay: '2.1s', duration: '4.1s' },
    { left: '12%', top: '88%', size: 4, delay: '1.1s', duration: '3.9s' },
    { left: '95%', top: '80%', size: 3, delay: '0.2s', duration: '3.3s' },
    { left: '55%', top: '90%', size: 4, delay: '1.6s', duration: '4.4s' }
  ];
</script>

<div class="fairy-lights" aria-hidden="true">
  {#each sparks as s, i (i)}
    <span
      class="spark"
      style={`left:${s.left}; top:${s.top}; width:${s.size}px; height:${s.size}px; animation-delay:${s.delay}; animation-duration:${s.duration};`}
    ></span>
  {/each}
</div>

<style>
  .fairy-lights {
    position: absolute;
    inset: 0;
    pointer-events: none;
    overflow: hidden;
  }
  .spark {
    position: absolute;
    border-radius: 50%;
    background: var(--accent);
    box-shadow: 0 0 6px 2px rgba(240, 185, 77, 0.75);
    opacity: 0;
    animation-name: twinkle;
    animation-timing-function: ease-in-out;
    animation-iteration-count: infinite;
  }
  @keyframes twinkle {
    0%,
    100% {
      opacity: 0;
      transform: translateY(0) scale(0.75);
    }
    50% {
      opacity: 0.95;
      transform: translateY(-12px) scale(1.15);
    }
  }
</style>
