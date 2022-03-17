<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import FormAlert from "$lib/components/Forms/FormAlert.svelte"
  import StarInput from "$lib/components/Forms/StarInput.svelte"
  import { setReview } from "$lib/components/Utils/Requests.js"
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
    try {
      $loading = true
      let data = new FormData(event.target)
      let result = await setReview(data)
      message.set(messageProcessor(result))
    } catch (e) {
      $message.type = "error"
      $message.content = e.message
    } finally {
      $loading = false
    }
  }
  
  browser && loading.set(false)
</script>

<div class="review-form-wrapper">
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
      <input type="text" name="company_name" placeholder="Название компании" readonly={$readonly} bind:value={$companyName} />
    </label>
    <hr />
    <label data-width="full" data-align="center">
      Поставьте оценку: <StarInput name={"assessment"} />
    </label>
    <label data-width="full">
      Отзыв:<br />
      <textarea name="description" rows="3" placeholder="Напишите ваш отзыв"></textarea>
    </label>
    <label data-width="full">
      <button type="submit">Оставить отзыв</button>
    </label>
  </form>
  <slot name="after"></slot>
</div>

<style>
  .review-form-wrapper {
    display: block;
    clear: both;
    padding: 50px 0;
  }

  .review-form-wrapper form {
    display: block;
    max-width: 600px;
    margin: 0 auto;
  }
</style>