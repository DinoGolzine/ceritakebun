<div class="fairy-wrap" aria-hidden="true">
  <svg class="fairy" viewBox="0 0 60 60" width="48" height="48">
    <g class="wing-group wing-left-group" transform="rotate(-18 18 27)">
      <ellipse class="wing" cx="18" cy="27" rx="14" ry="9" fill="var(--pink)" opacity="0.9" />
    </g>
    <g class="wing-group wing-right-group" transform="rotate(18 42 27)">
      <ellipse class="wing" cx="42" cy="27" rx="14" ry="9" fill="var(--pink)" opacity="0.9" />
    </g>

    <path d="M30 25 C 26 25 24 31 26 39 C 27 45 33 45 34 39 C 36 31 34 25 30 25 Z" fill="var(--primary)" />
    <circle cx="30" cy="18" r="7" fill="#fbd9c7" />
    <path d="M23 16 C 23 8 37 8 37 16 C 34 13 26 13 23 16 Z" fill="var(--primary-dark)" />

    <circle class="trail" cx="41" cy="42" r="1.6" fill="var(--accent)" />
    <circle class="trail trail-2" cx="46" cy="46" r="1.1" fill="var(--accent)" />
    <circle class="trail trail-3" cx="50" cy="49" r="0.8" fill="var(--accent)" />
  </svg>
</div>

<style>
  .fairy-wrap {
    position: absolute;
    top: 14%;
    left: -70px;
    animation: fly-across 17s linear infinite;
    filter: drop-shadow(0 4px 10px rgba(0, 0, 0, 0.25));
  }
  .wing {
    transform-box: fill-box;
    transform-origin: center;
    animation: flutter 0.28s ease-in-out infinite alternate;
  }
  .wing-right-group .wing {
    animation-delay: 0.05s;
  }
  .trail {
    animation: shimmer 1.4s ease-in-out infinite;
  }
  .trail-2 {
    animation-delay: 0.2s;
  }
  .trail-3 {
    animation-delay: 0.4s;
  }

  @keyframes fly-across {
    0% {
      transform: translate(0, 0) rotate(-6deg);
    }
    22% {
      transform: translate(26vw, -26px) rotate(4deg);
    }
    45% {
      transform: translate(52vw, 14px) rotate(-5deg);
    }
    68% {
      transform: translate(78vw, -18px) rotate(4deg);
    }
    100% {
      transform: translate(112vw, 6px) rotate(-6deg);
    }
  }
  @keyframes flutter {
    from {
      transform: scaleX(1);
    }
    to {
      transform: scaleX(0.55);
    }
  }
  @keyframes shimmer {
    0%,
    100% {
      opacity: 0.15;
    }
    50% {
      opacity: 0.9;
    }
  }
</style>
