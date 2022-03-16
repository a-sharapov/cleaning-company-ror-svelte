<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import StarInput from "$lib/components/Forms/StarInput.svelte"
  import { 
    prepareFormData, 
    messageProcessor, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'

  import {  } from "$lib/components/Utils/Requests.js"

  export let company = null
  let loading = writable(true)
  
  const handleOnSubmit = async (event) => {
    event.preventDefault()

  }
  
  browser && loading.set(false)
</script>

<div class="event-request-form-wrapper">
  <slot></slot>
  {#if $loading}
    <Loader />
  {/if}
  <form action="/" method="post" enctype="multipart/form-data" on:submit="{handleOnSubmit}">
    <label data-width="full">
      Оцените компанию от 1 до 5: <StarInput name={"assessment"} />
    </label>
  </form>
  <slot name="after"></slot>
</div>

<style>
  .event-request-form-wrapper {
    display: block;
    clear: both;
    margin: 50px 0;
  }
</style>