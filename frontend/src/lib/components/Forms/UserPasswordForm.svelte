<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { writable } from 'svelte/store'
  import { 
    prepareFormData,
    messageProcessor, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { setPasswordDirectly } from "$lib/components/Utils/Requests.js"

  let loading = writable(true)
  let current = writable({
    password: "",
    _password: "",
  })

  const handleSubmit = async (event) => {
    event.preventDefault()

    if ($current.password !== $current._password) {
      $message.content = "Пароли не совпадают!"
      $message.type = "error"
    } else {
      try {
        $loading = true
        let data = new FormData(event.target)
        let preparedData = prepareFormData(data, {_password: "",})

        let result = await setPasswordDirectly($user, user, preparedData)
        message.set(messageProcessor(result))
      } catch (e) {
        $message.type = "error"
        $message.content = e.message
      } finally {
        $loading = false
      }
    }
  }

  browser && loading.set(false)
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
<form action="/cabinet" method="put" on:submit="{handleSubmit}">
  <label data-width="half">
    <input type="password" name="password" required bind:value={$current.password} placeholder="Новый пароль" />
  </label><label data-width="half">
    <input type="password" name="_password" required bind:value={$current._password} placeholder="Повторите новый пароль" />
  </label>
  <label data-width="full">
    <button type="submit">Обновить пароль</button>
  </label>
</form>
<slot name="after"></slot>