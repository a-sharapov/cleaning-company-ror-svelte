<script>
  import { writable } from 'svelte/store'
  export let message = writable(null)
  
  const handleMessageHide = (event) => {
    $message.content = null
  }
</script>

{#if $message?.content}
  <span class="form-message" data-type={$message?.type} on:click="{handleMessageHide}">{@html $message?.content}</span>
{/if}