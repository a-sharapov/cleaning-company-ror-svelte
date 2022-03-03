<script>
  export let message
  export let type
</script>

{#if message}
  <dialog class="toast" data-type="{type}" data-hidden="false" on:click={handleOnClick}>
    <p class="toast-title">Уведомляем!</p>
    <p>{message}</p>
  </dialog>
{/if}