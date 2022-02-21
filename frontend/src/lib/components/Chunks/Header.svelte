<script>
</script>

<header>
  <slot name="header-content"></slot>
  {#if $$slots.sidebar}
    <slot name="header-nav"></slot>
  {/if}
</header>