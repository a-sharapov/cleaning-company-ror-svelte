<script>
  export let current = 1
  export let total
  export let processor

  let pages = []
  let counter = 1
  while (counter <= total) {
    pages.push(counter)
    counter++
  }
</script>

<nav aria-label="pagination">
  {#if current > 1 && current <= total}
    <span class="page previous" data-page="{current-1}" on:click="{processor}">Предыдущая</span>
  {/if}
  {#each pages as page}
    {#if page === current}
      <span class="page active">{page}</span>
    {:else}
      <span class="page" data-page="{page}" on:click="{processor}">{page}</span>
    {/if}
  {/each}
  {#if total > 1 && current < total}
    <span class="page next" data-page="{current+1}" on:click="{processor}">Следующая</span>
  {/if}
</nav>

<style>
  nav[aria-label="pagination"] {
    display: block;
    width: 100%;
    padding: 10px;
  }

  nav > span {
    cursor: pointer;
    padding: 0 2px;
    margin: 0 5px;
    border-bottom: 1px dotted var(--mf-red);
    transition: all .2s linear;
  }

  nav > span.active {
    padding: 0 7px;
    font-weight: block;
    background: var(--mf-red);
    color: #fff;
    text-shadow: 0 1px 0 #22000040;
    border-radius: 3px;
    border: none;
  }
</style>