<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
      const reviews = await fetch(`/api/v1/reviews/`, {mode: "cors"})
      return {
        props: {
          reviews: reviews.ok && (await reviews.json()),
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
  import Head from "$lib/components/Seo/Head.svelte"
  import Loader from "$lib/components/UI/Loader.svelte"
  import Paging from "$lib/components/Chunks/Paging.svelte"
  import ReviewItem from "$lib/components/Chunks/ReviewItem.svelte"
  import { browser } from '$app/env'
  import { writable } from 'svelte/store'
  import { getReviews } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
    prepareFormData, 
  } from '$lib/components/Hooks/Custom.js'

  export let reviews
  
  let limit = writable(10)
  let loading = writable(true)
  let title = "Отзывы о компаниях"

  browser && (loading.set(false))
  
  const getReviewsWithData = async (data, appendix = "") => {
    loading.set(true)
    let getOpts = "?" + new URLSearchParams(prepareFormData(data, {
      })).toString()
    let result = await getReviews(getOpts + appendix).then(loading.set(false))
    return result
  }
  
  const handleOnFilter = async (event) => {
    event.preventDefault()
    let data = new FormData(event.target)
    let result = await getReviewsWithData(data)
    reviews = result
  }

  const handleOnPaging = async (event) => {
    event.preventDefault()
    let next = event.target.getAttribute("data-page")
    let data = new FormData(document.getElementById("page-content-filter"))
    let result = await getReviewsWithData(data, `&page=${next}`)
    reviews = result
  }
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"index, follow"} />
<article id="page-content">
  <aside id="reviews-filter">
    <form id="page-content-filter" action="/reviews" method="get" on:submit="{handleOnFilter}">
      <h4>Отфильтровать по параметрам:</h4>
      <label data-width="third">
        Название комании содержит:<br />
        <input type="text" name="company_name" value="" placeholder="..." />
      </label><label data-width="third">
        Оценки:<br />
        <select name="review_type">
          <option value="">Все</option>
          <option value="5,4">Только положительные</option>
          <option value="3">Только смешанные</option>
          <option value="2,1">Только отрицательные</option>
        </select>
      </label><label data-width="third">
        Элементов на странице:<br />
        <select name="limit" bind:value="{$limit}">
          {#each [5,10,15,30,50,100] as item}
          <option value="{item}">{item}</option>
          {/each}
        </select>
      </label>
      <label data-width="full" data-align="center">
        <button type="submit">Применить</button>
      </label>
    </form>
  </aside>
  <section id="reviews-wrapper" data-loading="{$loading}">
    <div class="row">
      {#if $loading}
      <Loader />
      {/if}
      {#if reviews?.message}
        <p>{reviews.message}</p>
      {:else if reviews?.data}
        {#each reviews.data as item}
          <ReviewItem {item} />
        {/each}
        <Paging total="{reviews.total_pages}" current="{reviews.current_page}" processor="{handleOnPaging}" />
      {/if}
    </div>
  </section>
</article>

<style>
  #reviews-filter,
  #reviews-wrapper {
    padding: 50px 0;
  }

  #reviews-filter {
    background: #fff;
  }

  #reviews-wrapper {
    display: block;
    margin: 0;
  }

  #page-content-filter {
    width: 700px;
    margin: 0 auto;
  }

  .row {
    display: block;
    width: 100%;
    max-width: 1400px;
    margin: 0 auto;
  }
</style>