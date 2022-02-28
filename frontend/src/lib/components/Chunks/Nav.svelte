<script>
  export let links
  export let role
  export let page
</script>

<nav data-role={role}>
  {#each links as link}
    {#if $page.url.pathname == link.href}
      <span class="menu item">{link.title}</span>
    {:else}
      <a href="{link.href}" class="menu link">{link.title}</a>
    {/if}
  {/each}
</nav>