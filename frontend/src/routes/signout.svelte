<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
      const response = await fetch("/api/v1/auth/", {
                                    method: "delete", 
                                    mode: "cors"
                                  })

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
  import { page } from '$app/stores'
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import Head from "$lib/components/Seo/Head.svelte"
  import { writable } from 'svelte/store'
  import { message, user, removeUserFromStorage } from '$lib/components/Hooks/Custom.js'
  import { removeUser } from '$lib/components/Utils/Requests.js'

  let title = "Выход из системы"
  let loading = writable(true)
  let assets = $page.url.searchParams.get("and")
  export let logout

  $message.content = logout.message
  
  const pocessSignOut = async () => {
    let response
    if (assets === "remove") {
      response = await removeUser($user, user)
    } else {
      response = null
    }
    if (response && !!response.error) {
      $message.type = "warning"
      $message.content = `${$message.content}, ${response.error}`
    } else if (response) {
      $message.content = `${$message.content}, ${response.message}`
    }
    user.set(null)
    removeUserFromStorage()
  }

  if (browser) {
    $loading = false
    pocessSignOut()
    new Promise(async (res) => {
      setTimeout(async () => { 
        res()
        goto("/")
      }, 1e3)
    })
  }  
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />
<article id="page-content">
  <section id="logoff-wrapper">
    {#if $loading}
      <Loader />
    {/if}
    {#if $message?.content}
      <p><img src="/i/info.svg" alt="" width="50px" /></p>
      <br />
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
    background: #fff;
  }

  #logoff-wrapper {
    display: block;
    max-width: 200px;
    font-size: 18px;
    line-height: 22px;
  }
</style>