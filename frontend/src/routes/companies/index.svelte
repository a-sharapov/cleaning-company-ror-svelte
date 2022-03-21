<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
      const companies = await fetch(`/api/v1/companies/`, {mode: "cors"})
      const services = await fetch("/api/v1/assets/services/", {mode: "cors"})
      return {
        props: {
          companies: companies.ok && (await companies.json()),
          services: services.ok && (await services.json()),
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
  import CompanyItem from "$lib/components/Chunks/CompanyItem.svelte"
  import { browser } from '$app/env'
  import { writable } from 'svelte/store'
  import { getCompanies } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
    prepareFormData, 
  } from '$lib/components/Hooks/Custom.js'

  export let companies
  export let services
  
  let limit = writable(10)
  let loading = writable(true)
  let title = "Наши партнёры"

  browser && (loading.set(false))
  
  const handleOnFilter = async (event) => {
    event.preventDefault()
    let data = new FormData(event.target)
    let getOpts = "?" + new URLSearchParams(prepareFormData(data, {
      company_name: "",
      city: "",
      street: ""
    })).toString()
    let result = await getCompanies(getOpts)
    companies = result
  }
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"index, follow"} />
<article id="page-content">
  <aside id="companies-filter">
    <form id="page-content-filter" action="/companies" method="get" on:submit="{handleOnFilter}">
      <h4>Отфильтровать по параметрам:</h4>
      <label data-width="half">
        Название комании содержит:<br />
        <input type="text" name="company_name" value="" placeholder="..." />
      </label><label data-width="half">
        Город:<br />
        <input type="text" name="address[city]" value="" placeholder="Частично или полностью" />
      </label><label data-width="half">
        Адрес:<br />
        <input type="text" name="address[street]" value="" placeholder="Частично или полностью" />
      </label><label data-width="half">
        Элементов на странице:<br />
        <select name="limit" bind:value="{$limit}">
          {#each [5,10,15,30,50,100] as item}
          <option value="{item}">{item}</option>
          {/each}
        </select>
      </label>
      <h5>Оказывает услуги:</h5>
      {#if services?.content?.elements}
      {#each services?.content?.elements as service }
      <label data-width="half"><input type="checkbox" name="service_types[]" value="{service}" />&nbsp;{service}</label>
      {/each}
      {/if}
      <hr />
      <label data-width="full" data-align="center">
        <button type="submit">Применить</button>
      </label>
    </form>
  </aside>
  <session id="companies-wrapper" data-loading="{$loading}">
    {#if $loading}
      <Loader />
    {/if}
    {#if companies.message}
      <p>{companies.message}</p>
    {:else if companies.data}
      {#each companies.data as item}
        <CompanyItem {item} />
      {/each}
      <Paging total="{companies.total_pages}" current="{companies.current_page}" processor="{handleOnFilter}"/>
    {/if}
  </session>
</article>

<style>
  #companies-filter,
  #companies-wrapper {
    padding: 50px 0;
  }

  #companies-filter {
    background: #fff;
  }

  #companies-wrapper {
    display: block;
    margin: 0;
  }

  #page-content-filter {
    width: 700px;
    margin: 0 auto;
  }
</style>