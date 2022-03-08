<script>
  export let message
  export let type

  let currentMessage = writable($message)

  const handleOnClick = (event) => {
    event.target.setAttribute("data-hidden", true)
    currentMessage.set("")
  }
</script>

{#if currentMessage}
  <dialog class="toast" data-type="{type}" data-hidden="false" on:click={handleOnClick}>
    <p class="toast-title">Уведомляем!</p>
    <p>{currentMessage}</p>
  </dialog>
{/if}