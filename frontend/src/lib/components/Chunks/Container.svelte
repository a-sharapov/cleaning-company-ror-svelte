<script>
  import { page } from '$app/stores'

  export let content
  export let assets = null
</script>

{#if assets}
  <p class="message-wrapper">{content}</p>
{:else}
  <slot></slot>
{/if}