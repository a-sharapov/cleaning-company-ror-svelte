<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import FormAlert from "$lib/components/Forms/FormAlert.svelte"
  import {  } from "$lib/components/Utils/Requests.js" //setEvent
  import { 
    messageProcessor, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'

  export let company = null
  let loading = writable(true)
  let customer = writable("Anonymous")
  let companyName = writable("")
  let readonly = writable(false)

  $user.login && customer.set($user.login)
  company && (companyName.set(company), readonly.set(true))

  const handleOnSubmit = async (event) => {
    event.preventDefault()
  }

  browser && loading.set(false)
</script>

<div class="event-request-form-wrapper">
  {#if $loading}
    <Loader />
  {/if}
  <form method="post" enctype="multipart/form-data" on:submit="{handleOnSubmit}">
    <FormAlert {message} />
    <slot></slot>
  
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