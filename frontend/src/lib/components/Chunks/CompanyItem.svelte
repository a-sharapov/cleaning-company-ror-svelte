<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import { getRaiting } from "$lib/components/Utils/Requests.js"

  export let item
  let assessment = writable(null)

  browser && new Promise(async (res) => {
  let result = await getRaiting(item.slug)
  assessment.set(result)
  res()
  })
</script>

<div class="company-item">
  {#if !!item.logotype_file_name}
    <img class="company-logo" src="/api/v1/logotype/{item.slug}?image={item.logotype_file_name}" alt="{item.company_name}" width="80%" />
  {/if}
  {#if !!item.address.city}
    <span class="company-location">{item.address.city}</span>
  {:else}
    <span class="company-location">{item.address.country}</span>
  {/if}
  <h4 class="company-header">{item.company_name}</h4>
  {#if $assessment}
    <span class="company-assessment">
      <span>{$assessment.assessment.toFixed(2)}</span> 
      {#if $assessment.count > 0}
      ({$assessment.count} Оценок)
      {:else}
      (Пока нет оценок)
      {/if}
    </span>
  {/if}
  <p class="company-description">{item.description}</p>
  {#if item.service_types.length > 0}
  <span class="company-services">
    {item.service_types.join(", ")}
  </span>
  {/if}
  {#if item.prices.standard > 0 && item.prices.standard !== ""}
  <span class="company-prices">
    <span class="company-prices-header">Стоимость услуг</span>
    <span class="price-standard">Помещение до 20 м<sup>2</sup> &ndash; {item.prices.standard} <span class="price-bulk">BYN / час</span></span>
    <span class="price-large">Помещение от 20 м<sup>2</sup> &ndash; {item.prices.large} <span class="price-bulk">BYN / час</span></span>
    <span class="price-restroom">Санузлы &ndash; {item.prices.restroom} <span class="price-bulk">BYN / час</span></span>
  </span>
  {/if}
  <p>
    <a href="/companies/{item.slug}" class="button">Перейти к профилю</a>
  </p>
</div>

<style>
  .company-item {
    position: relative;
    display: inline-block;
    box-sizing: border-box;
    vertical-align: top;
    margin: 5px;
    padding: 20px;
    width: 220px;
    font-size: 14px;
    background: #fff;
    border-radius: 2px;
    border-bottom: 5px solid var(--mf-gray);
    box-shadow:
      0px 4.1px 10px rgba(0, 0, 0, 0.09),
      0px 33px 80px rgba(0, 0, 0, 0.19);
  }
  .company-item .company-logo {
    margin: -70px auto 0;
  }
  .company-item .company-location {
    position: absolute;
    right: 0;
    top: 10px;
    z-index: 2;
    font-size: 10px;
    background: var(--mf-red);
    color: #fff;
    text-shadow: 0 1px 0 #00000040;
    padding: 0 10px;
  }
  .company-item .company-header {
    font-weight: bold;
    font-size: 22px;
    color: var(--mf-darkred);
  }
  .company-item .company-services,
  .company-item .company-prices {
    display: block;
    margin: 10px -20px 0;
    padding: 10px;
    background: var(--mf-gray);
    color: #533;
  }
  .company-item .company-prices {
    background: var(--mf-darkgray);
    margin-top: 0;
    margin-bottom: 20px;
  }
  .company-item .company-prices > span {
    display: block;
  }
  .company-prices-header {
    font-weight: bold;
  }
</style>