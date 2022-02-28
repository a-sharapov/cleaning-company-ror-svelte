<script>
  import init from "$lib/config/main.js"
  const { siteTitle } = init
</script>

<header>
  <img src="/i/logo.png" alt="{siteTitle}" width="350px" id="sitelogo" />
  <slot name="header-content"></slot>
  {#if $$slots.headerNav}
    <slot name="headerNav"></slot>
  {/if}
</header>