<script>
  import init from "$lib/config/main.js"
  import { page } from '$app/stores'
  const { siteTitle } = init
</script>

{#if $page.url.pathname != "/"}
  <a href="/" class="logowrapper">
    <img src="/i/logo.png" alt="{siteTitle}" width="250px" id="sitelogo" />
  </a>
{:else}
  <span class="logowrapper">
    <img src="/i/logo.png" alt="{siteTitle}" width="250px" id="sitelogo" />
  </span>
{/if}