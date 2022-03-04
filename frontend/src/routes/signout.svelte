<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
      const response = await fetch("/api/v1/auth/", {
                                    method: "delete", 
                                    mode: "cors"
                                  });
      return {
        props: {
          logout: response.ok && (await response.json()),
        }
      }
    } catch (e) {
      return {
        status: e.status,
        error: e.message, 
      }
    }
  }
</script>

<script>
  import { goto } from '$app/navigation'
  import { browser } from '$app/env'
  import Head from "$lib/components/Seo/Head.svelte"
  import { message, removeUserFromStorage, user } from '$lib/components/Hooks/Custom.js'

  let title = "Выход из системы"
  export let logout

  $message.content = logout.message
  user.set(false)
  removeUserFromStorage()
  
  browser && new Promise(res => {
	  setTimeout(async () => {
			res()   
		}, 2e3)
  }).then(() => {
    goto("/")
  })
  
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={null} />
<article id="page-content">
  <section id="logoff-wrapper">
    {#if $message?.content}
      {@html $message?.content}
    {/if}
  </section>
</article>

<style>
  article#page-content {
    display: flex;
    flex: 1 0 auto;
    justify-content: center;
    align-items: center;
    height: 100%;
    margin: -20px 0;
    padding: 20px 0 40px;
    background: var(--mf-darkgray);
  }

  #logoff-wrapper {
    display: block;
    max-width: 200px;
    font-size: 18px;
    line-height: 22px;
  }
</style>