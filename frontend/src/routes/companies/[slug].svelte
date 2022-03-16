<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
      const company = await fetch(`/api/v1/company/${params.slug}/`, {mode: "cors"})
      if (company.status === 404) {
        let { message } = await company.json()
        throw {
          status: 404,
          message,
        }
      }
      return {
        props: {
          company: company.ok && (await company.json())
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
  import Loader from "$lib/components/UI/Loader.svelte"
  import Head from "$lib/components/Seo/Head.svelte"
  import ReviewItem from "$lib/components/Chunks/ReviewItem.svelte"
  import ReviewForm from "$lib/components/Forms/ReviewForm.svelte"
  import RequestForm from "$lib/components/Forms/RequestForm.svelte"
  import { browser } from '$app/env'
  import { writable } from 'svelte/store'
  import { getRaiting, getCompanyReviews } from "$lib/components/Utils/Requests.js"

  export let company
  let title = company.company_name ? company.company_name : "..."
  let companyReviews = writable(null)
  let companyAssessment = writable("Неизвестна")
  let loading = writable(true)

  browser && (loading.set(false))
  browser && new Promise(async (res) => {
    let raiting = await getRaiting(company.slug)
    let reviews = await getCompanyReviews(company.slug)
    companyAssessment.set(raiting)
    companyReviews.set(reviews)
    res()
  })
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />
<article id="page-content">
  <section id="company-data-wrapper" data-loading="{$loading}">
    {#if $loading}
      <Loader />
    {/if}
    {#if company.message}
      <div class="scree-message">
        {company.message}
      </div>
    {:else}
      {#if company.logotype_file_name}
        <aside id="logo-wrapper">
          <img src="{`/api/v1/logotype/${company.slug}?image=${company.logotype_file_name}`}" class="logotype-cover" alt="{company.company_name}" width="200%" height="auto"/>
          <img src="{`/api/v1/logotype/${company.slug}?image=${company.logotype_file_name}`}" alt="{company.company_name}" width="auto" height="150px"/>
          <h1>Профиль компании <strong>&laquo;{company.company_name}&raquo;</strong></h1>
        </aside>
      {:else}
        <h1>Профиль компании <strong>&laquo;{company.company_name}&raquo;</strong></h1>
      {/if}
      <div class="row half-row">
        <h4>Предоставляемые услуги</h4>
        {#if company.service_types?.length > 0}
        <ul class="company-services">
          {#each company.service_types as service}
            <li>{service}</li>
          {/each}
        </ul>
        {:else}
        <p>Компания ещё не указала, какие услуги она предоставляет</p>
        {/if}
      </div><div class="row half-row">
        <h4>Стоимость услуг</h4>
        {#if company.prices?.standard > 0 && company.prices?.standard !== ""}
        <ul class="company-prices">
          <li>Помещение до 20 м<sup>2</sup> &ndash; {company.prices.standard} <span class="price-bulk">BYN / час</span></li>
          <li>Помещение от 20 м<sup>2</sup> &ndash; {company.prices.large} <span class="price-bulk">BYN / час</span></li>
          <li>Санузлы &ndash; {company.prices.restroom} <span class="price-bulk">BYN / час</span></li>
        </ul>
        {:else}
        <p>Компание ещё не установила стоимость своих услуг</p>
        {/if}
      </div>
      <div class="row">
        <h4>Срденяя оценка</h4>
        <span class="company-assessment">
          <span>{$companyAssessment.assessment?.toFixed(2)}</span> 
          {#if $companyAssessment.count > 0}
          ({$companyAssessment.count} Оценок)
          {:else}
          (Пока нет оценок)
          {/if}
        </span>
      </div>
      <div class="row">
        <h4>Отзывы о компании</h4>
        {#if $companyReviews?.message}
          <p>{$companyReviews?.message}</p>
        {:else if !$companyReviews?.message && $companyReviews?.data}
          {#each $companyReviews.data as item}
          <ReviewItem {item} />
          {/each}
        {/if}
      </div>
      <RequestForm company={company.company_name}>
        <h4>Оставьте заявку на проведение уборки</h4>
      </RequestForm>
      <ReviewForm company={company.company_name}>
        <h4>Оцените работу компании</h4>
      </ReviewForm>
    {/if}
  </section>
</article>

<style>
  section#company-data-wrapper {
    margin: 20px 0;
  }
  #logo-wrapper {
    position: relative;
    display: block;
    width: 100%;
    padding: 20px 0;
    margin: -20px 0 0;
    height: 250px;
    overflow: hidden;
    background: #fefefe;
    text-shadow: 0 1px 0 #ffffff80;
  }
  #logo-wrapper > * {
    position: relative;
    z-index: 2;
  }
  #logo-wrapper .logotype-cover {
    position: absolute;
    left: -50%;
    top: -700px;
    z-index: 1;
    filter: blur(30px);
    opacity: .3;
  }
  .row {
    display: block;
    clear: both;
    padding: 20px 0;
  }
  .row.half-row {
    display: inline-block;
    vertical-align: top;
    padding: 40px 20px;
    width: 50%;
  }
  .row:nth-of-type(even) {
    background: #fff;
  }
  ul.company-services, 
  ul.company-prices {
    text-align: left;
    display: block;
    margin: 0 auto;
    width: fit-content;
  }
  ul.company-services li, 
  ul.company-prices li {
    list-style-type: square;
  }
  ul.company-services li::marker, 
  ul.company-prices li::marker {
    color: var(--mf-red)
  }
</style>