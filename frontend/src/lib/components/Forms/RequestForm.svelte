<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import FormAlert from "$lib/components/Forms/FormAlert.svelte"
  import { getCompanyPartial } from "$lib/components/Utils/Requests.js" //setEvent
  import { 
    messageProcessor, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import SearchInput from './SearchInput.svelte'

  export let company = null
  let loading = writable(true)
  let customer = writable("Anonymous")
  let companyName = writable(null)
  let readonly = writable(false)
  let services = writable([])
  let prices = writable({})

  $user.login && customer.set($user.login)
  company && (companyName.set(company), readonly.set(true))

  const handleOnSubmit = async (event) => {
    event.preventDefault()

  }

  browser && (new Promise(async (res) => {
    let services = await getCompanyPartial(company, "service_types")
    let prices = await getCompanyPartial(company, "prices")
    res({services, prices})
  }).then(data => {
    services.set(data.services)
    prices.set(data.prices)
  }))
  browser && loading.set(false)
</script>

<div class="event-request-form-wrapper">
  {#if $loading}
    <Loader />
  {/if}
  <form method="post" enctype="multipart/form-data" on:submit="{handleOnSubmit}">
    <FormAlert {message} />
    <slot></slot>
    <label data-width="half">
      Пользователь:<br />
      <input type="text" name="customer" placeholder="Отображемое имя" readonly={$readonly} bind:value={$customer} required />
    </label><label data-width="half">
      Компания:<br />
      {#if $companyName}
      <input type="text" name="company_name" readonly="readonly" placeholder="Название компании" value="{$companyName}" required />
      {:else}
      <SearchInput name="company_name" placeholder="Начните вводить название компании" {services} {prices} />
      {/if}
    </label>
    {#if $services.length > 0}
      <div class="form-row">
        <hr />
        <h5>Выберите необходимые услуги:</h5>
        {#each $services as service}
          <label data-width="half"><input type="checkbox" name="services[]" value="{service}" />&nbsp;{service}</label>
        {/each}
        <hr />
      </div>
    {/if}
    <div class="form-row">
    <h5>Информация об обьекте:</h5>
    <label data-width="third">
      Комнаты до 20 м<sup>2</sup>:<br /><input type="number" name="assets[standard]" data-price={$prices?.standard} value="1" min="0" max="100" />
    </label><label data-width="third">
      Комнаты от 20 м<sup>2</sup>:<br /><input type="number" name="assets[large]" data-price={$prices?.large} value="0" min="0" max="100" />
    </label><label data-width="third">
      Санузлы:<br /><input type="number" name="assets[restroom]" data-price={$prices?.restroom} value="0" min="0" max="100" />
    </label>
    </div>
    
    <hr />
    <label data-width="full" data-align="center">
      <button type="submit">Заказать уборку</button>
    </label>
  </form>
</div>

<style>
  .event-request-form-wrapper {
    display: block;
    clear: both;
    padding: 50px 0;
    background: var(--mf-gray)
  }

  .event-request-form-wrapper form {
    display: block;
    max-width: 600px;
    margin: 0 auto;
  }

  .event-request-form-wrapper form .form-row {
    text-align: left;
  }

  .event-request-form-wrapper form button[type="submit"] {
    height: 50px;
    font-weight: bold;
    padding: 0 25px;
    letter-spacing: 3px;
    border: 5px solid #fff;
    border-radius: 30px;
    box-shadow: 0px 6.8px 3.4px -19px rgb(0 0 0 / 2%), 0px 10.1px 7.5px -19px rgb(0 0 0 / 2%), 0px 11.3px 13px -19px rgb(0 0 0 / 2%), 0px 11.3px 22.3px -19px rgb(0 0 0 / 3%), 0px 11.1px 42px -19px rgb(0 0 0 / 5%), 0px 15px 164px -19px rgb(0 0 0 / 7%);
  }
</style>