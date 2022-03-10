<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { getCompanyProfile } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  let userCompanyProfile = writable(null)
  let loading = writable(true)

  browser && new Promise(async (res) => {
    let result = await getCompanyProfile($user, user)
    userCompanyProfile.set(result)
    res()
  }).finally(() => {
    $loading = false
  })
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $userCompanyProfile?.message}
  <p>{$userCompanyProfile?.message}</p>
{/if}
{#if Array.isArray($userCompanyProfile)}

{/if}