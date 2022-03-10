<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { getUserReviews } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  let userReviews = writable(null)
  let loading = writable(true)

  browser && new Promise(async (res) => {
    let result = await getUserReviews($user, user)
    userReviews.set(result)
    res()
  }).finally(() => {
    $loading = false
  })
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $userReviews?.message}
  <p>{$userReviews?.message}</p>
{/if}
{#if Array.isArray($userReviews)}

{/if}