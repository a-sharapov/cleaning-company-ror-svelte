<script>
  export let errors
</script>

{#if errors}
  <dialog class="toast" data-type="{errors.type}">
    {errors.message}  
  </dialog>
{/if}