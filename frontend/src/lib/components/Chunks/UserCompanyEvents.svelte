<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { getCompanyEvents, getCompanyProfile } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  let userCompanyEvents = writable(null)
  let loading = writable(true)

  browser && new Promise(async (res) => {
    let companyProfile = await getCompanyProfile($user, user)
    let result = {message: "В данный момент профиль компании ещё не заполнен, поэтому запрос отзывов не произведён"}

    if (companyProfile && !companyProfile.message) {
      result = await getCompanyEvents($user, user, companyProfile.company_name)
    }
    userCompanyEvents.set(result)
    res()
  }).finally(() => {
    $loading = false
  })
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $userCompanyEvents?.message}
  <p>{$userCompanyEvents?.message}</p>
{/if}
{#if Array.isArray($userCompanyEvents)}

{/if}