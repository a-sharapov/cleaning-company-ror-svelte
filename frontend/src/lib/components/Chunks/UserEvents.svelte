<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { getUserEvents } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  let userEvents = writable(null)
  let loading = writable(true)

  browser && new Promise(async (res) => {
    let result = await getUserEvents($user, user)
    userEvents.set(result)
    res()
  }).finally(() => {
    $loading = false
  })
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $userEvents?.message}
  <p>{$userEvents?.message}</p>
{/if}
{#if Array.isArray($userEvents)}

{/if}