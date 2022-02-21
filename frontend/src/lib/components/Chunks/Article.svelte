<script>
</script>

{#if $$slots.content}
<article id="page-content">
  {#if $$slots.sidebar}
    <slot name="sidebar"></slot>
  {/if}
  <slot name="content"></slot>
</article>
{/if}