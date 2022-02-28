<script>
  import Logotype from "$lib/components/Chunks/Logotype.svelte"
</script>

<header>
  <Logotype />
  {#if $$slots.headerNav}
    <slot name="headerNav"></slot>
  {/if}
  <slot name="headerContent"></slot>
</header>