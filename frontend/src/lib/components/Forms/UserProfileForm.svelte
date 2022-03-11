<script>
  import { writable } from 'svelte/store'

  import { 
    prepareFormData, 
    getUserFromStorage, 
    setUserInStorage, 
    messageProcessor, 
    message, 
    user, 
    remembered 
  } from '$lib/components/Hooks/Custom.js'

  import { 
    updateUserProfile,
  } from '$lib/components/Utils/Requests.js'

  let loading = writable(true)
  export let countries

  let currentUserData = writable({
    address: {
      country: "unselected",
      city: "",
      zip: "",
      state: "",
      street: "",
    },
    ...getUserFromStorage(),
  })

  delete $currentUserData.access_token

  const handleProfileUpdate = async (event) => {
    event.preventDefault()
    let removeEmpty = {password: "", avatar: "", phone: "", description: ""}

      try {
        $loading = true
        let data = new FormData(event.target)
        
        let result = await updateUserProfile($user, user, prepareFormData(data, removeEmpty))
          message.set(messageProcessor(result))
          setUserInStorage({...$user, ...result.user}, remembered())
        } catch (e) {
          $message.type = "error"
          $message.content = e.message
        } finally {
          let userFromStore = getUserFromStorage()
          user.set(userFromStore)
          currentUserData.set(userFromStore)
          $loading = false
        }
  }
</script>

<form action="/cabinet" method="put" enctype="multipart/form-data" on:submit={handleProfileUpdate}>
  <label data-width="half">
    <input type="text" name="login" bind:value={$currentUserData.login} required placeholder="Имя пользователя"/>
  </label><label data-width="half">
    <input type="text" name="email" bind:value={$currentUserData.email} placeholder="Адрес ээлектронной почты"/>
  </label><label data-width="half">
    <input type="text" name="phone" bind:value={$currentUserData.phone} placeholder="Контактный телефон (без +)"/>
  </label><label data-width="half">
    <input type="file" name="avatar" placeholder="Аватар" />
  </label>
  <hr />
  <label data-width="full">
    <textarea name="description" rows="3" bind:value={$currentUserData.description} placeholder="Расскажите о себе"></textarea>
  </label>
  <hr />
  <h5>Адрес:</h5>
  <label data-width="full">
    <select name="address[country]" bind:value={$currentUserData.address.country}>
      <option disabled value="unselected">Выберите свою страну из списка</option>
      {#if countries?.content?.elements}
      {#each countries?.content?.elements as coutry }
      <option value="{coutry}">{coutry}</option>
      {/each}
      {/if}
    </select>
  </label>
  <label data-width="half">
    <input type="text" name="address[zip]" bind:value={$currentUserData.address.zip} placeholder="Индекс" />
  </label><label data-width="half">
    <input type="text" name="address[city]" bind:value={$currentUserData.address.city} placeholder="Город" />
  </label><label data-width="half">
    <input type="text" name="address[state]" bind:value={$currentUserData.address.state} placeholder="Область" />
  </label><label data-width="half">
    <input type="text" name="address[street]" bind:value={$currentUserData.address.street} placeholder="Улица, дом" />
  </label>
  <hr />
  <label data-width="full">
    <button type="submit">Обновить данные</button>
  </label>
</form>