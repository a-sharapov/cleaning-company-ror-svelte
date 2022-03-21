<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import ReviewItem from "$lib/components/Chunks/ReviewItem.svelte"
  import Paging from "$lib/components/Chunks/Paging.svelte"
  import { getCompanyReviews, getCompanyProfile } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  let userCompanyReviews = writable(null)
  let loading = writable(true)

  const handleOnMore = async (event) => {
    let companyProfile = await getCompanyProfile($user, user)
    let next = event.target.getAttribute("data-page")
    let result = await getCompanyReviews(companyProfile.company_name, next)
    userCompanyReviews.set(result)
  }

  browser && new Promise(async (res) => {
    let companyProfile = await getCompanyProfile($user, user)
    let result = {message: "В данный момент профиль компании ещё не заполнен, поэтому запрос событий не произведён"}
    if (companyProfile && !companyProfile.message) {
      result = await getCompanyReviews(companyProfile.company_name)
    }
    res(result)
  }).then(async (data) => {
    userCompanyReviews.set(data)
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
{#if $userCompanyReviews?.data?.length > 0}
  {#each $userCompanyReviews.data as item}
  <ReviewItem {item} width={"full"} />
  {/each}
  <Paging total="{$userCompanyReviews.total_pages}" current="{$userCompanyReviews.current_page}" processor="{handleOnMore}" />
{/if}