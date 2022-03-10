<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { getCompanyReviews, getCompanyProfile } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  let userCompanyReviews = writable(null)
  let loading = writable(true)

  browser && new Promise(async (res) => {
    let companyProfile = await getCompanyProfile($user, user)
    let result = {message: "В данный момент профиль компании ещё не заполнен, поэтому запрос событий не произведён"}

    if (companyProfile && !companyProfile.message) {
      result = await getCompanyReviews($user, user, company_name)
    }
    userCompanyReviews.set(result)
    res()
  }).finally(() => {
    $loading = false
  })
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $userCompanyReviews?.message}
  <p>{$userCompanyReviews?.message}</p>
{/if}
{#if Array.isArray($userCompanyReviews)}

{/if}