<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import FormAlert from "$lib/components/Forms/FormAlert.svelte"
  import { getServices } from "$lib/components/Utils/Requests.js" //setEvent
  import { 
    messageProcessor, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import SearchInput from './SearchInput.svelte'

  export let company = null
  export let companySlug = null
  let loading = writable(true)
  let customer = writable("Anonymous")
  let companyName = writable(null)
  let readonly = writable(false)
  let services = writable(null)

  $user.login && customer.set($user.login)
  company && (companyName.set(company), readonly.set(true))

  const handleOnSubmit = async (event) => {
    event.preventDefault()
  }
  browser && (new Promise(async (res) => {
    let result = await getServices(companySlug)
    res(result)
  })).then(data => services.set(data))
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
      <input type="text" name="customer" placeholder="Отображемое имя" readonly={$readonly} bind:value={$customer} />
    </label><label data-width="half">
      Компания:<br />
      {#if $companyName}
      <input type="text" name="company_name" readonly="readonly" placeholder="Название компании" value="{$companyName}"/>
      {:else}
      <SearchInput name="company_name" placeholder="Начните вводить название компании" />
      {/if}
    </label>
    {#if $services}
      {#each $services as service}
        <label data-width="half"><input type="checkbox" name="services[]" value="{service}" />&nbsp;{service}</label>
      {/each}
    {/if}
  </form>
</div>

<style>
  .event-request-form-wrapper {
    display: block;
    clear: both;
    padding: 50px 0;
    background: var(--mf-darkgray)
  }

  .event-request-form-wrapper form {
    display: block;
    max-width: 600px;
    margin: 0 auto;
  }
</style>