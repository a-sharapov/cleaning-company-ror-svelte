<script>
</script>

<article id="page-content">
  <slot></slot>
  {#if $$slots.sidebar}
    <slot name="sidebar"></slot>
  {/if}
  {#if $$slots.content}
    <slot name="content"></slot>
  {/if}
</article>