<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { getCompanyProfile, setCompanyProfile } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'

  export let countries
  export let services
  export let odds

  let userCompanyProfile = writable(null)
  let loading = writable(true)
  let isLogotype = writable(false)

  let currentProfileData = writable({
    company_name: "New company",
    service_types: [],
    prices: {
      standard: "",
      large: "",
      restroom: "",
    },
    address: {
      country: $user.address?.country ? $user.address?.country : "unselected",
      city: "",
      zip: "",
      state: "",
      street: "",
    }
  })
  let profilePath = writable(`companies`)
  let updateMethod = writable("post")
  let profileServicesCheck = []

  const handleOnSubmit = async (event) => {
    event.preventDefault()
    try {
      $loading = true
      let data = new FormData(event.target)
      
      let result = await setCompanyProfile($user, user, $profilePath, $updateMethod, data)
      message.set(messageProcessor(result))
      if (!Boolean(result?.message)) {
        currentProfileData.set(result)
        profilePath.set(`company/${result.slug}/`)
        $message.type = "success"
        $message.content = "Профиль компании был успешно обновлён"
      } else {
        message.set(messageProcessor(result))
      } 
    } catch (e) {
      $message.type = "error"
      $message.content = e.message
    } finally {
      $loading = false
    }
  }

  const handleRecalc = async (event) => {
    let standard = event.target.value
    $currentProfileData.prices.large = odds?.large ? parseFloat(odds.large * standard).toFixed(2) : parseFloat(1.2 * standard).toFixed(2)
    $currentProfileData.prices.restroom = odds?.restrooms ? parseFloat(odds.restrooms * standard).toFixed(2) : parseFloat(1.4 * standard).toFixed(2)
  }

  browser && new Promise(async (res) => {
    let result = await getCompanyProfile($user, user)
    res(result)
  }).then((result) => {
    userCompanyProfile.set(result)
    if (!Boolean(result.message)) {
      isLogotype.set(!!result.logotype_file_name)
      currentProfileData.set({
        ...$currentProfileData,
        ...result,
      })
      profileServicesCheck = result.service_types
      profilePath.set(`company/${result.slug}/`)
      updateMethod.set("put")
    }
  }).finally(() => {
    $loading = false
  }
  )
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
  {#if $isLogotype}
  <span class="company-logotype">
  Логотип: <img src="/api/v1/logotype/{$currentProfileData.slug}?image={$currentProfileData.logotype_file_name}" alt="{$currentProfileData.company_name}" height="100px" />
  </span>
  {/if}
<form action="/cabinet" enctype="multipart/form-data" method="post" on:submit={handleOnSubmit}>
  {#if $userCompanyProfile?.message}
    <span class="form-message">{$userCompanyProfile?.message}</span>
  {/if}
  <label data-width="full">
    <input type="text" name="company_name" bind:value={$currentProfileData.company_name} required placeholder="Название компании"/>
    <p class="light small">Название в адресной строке: <strong>{$currentProfileData.slug}</strong></p>
  </label>
  <hr />
  <label data-width="full">
    Логотип:<br />
    <input type="file" name="logotype" placeholder="Логотип" />
  </label>
  <hr />
  <label data-width="full">
    <textarea name="description" rows="3" bind:value={$currentProfileData.description} placeholder="Расскажите о компании"></textarea>
  </label>
  <hr />
  <h5>Услуги:</h5>
  {#if services?.content?.elements}
  {#each services?.content?.elements as service }
  <label data-width="half"><input type="checkbox" name="service_types[]" value="{service}" bind:group={profileServicesCheck} />&nbsp;{service}</label>
  {/each}
  {/if}
  <hr />
  <h5>Стоимость услуг:</h5>
  <p>В данном разделе заполняется стоимость в рублях <strong>BYN</strong> исходя из <strong>1 часа</strong> работы.</p>
  <label data-width="full">
    <input type="text" name="prices[standard]" bind:value={$currentProfileData.prices.standard} on:input="{handleRecalc}" required placeholder="Для стандартного помещения (до 20 м&#178;)"/>
  </label>
  <label data-width="half">
    <input type="text" name="prices[large]" bind:value={$currentProfileData.prices.large} required placeholder="Для большого помещения (более 20 м&#178;)"/>
  </label><label data-width="half">
    <input type="text" name="prices[restroom]" bind:value={$currentProfileData.prices.restroom} required placeholder="Для санузлов"/>
  </label>
  <p class="small">В качестве основной цены используется <strong>стоимость уборки простого помещения (до 20 м<sup>2</sup>)</strong>, остальные данные рассчитываются исходя из стандартных коэффициентов, но вы в праве их изменить их. <em>Однако, это может сказаться на количестве заказов.</em></p>
  <hr />
  <h5>Адрес:</h5>
  <label data-width="full">
    <select name="address[country]" bind:value={$currentProfileData.address.country}>
      <option disabled value="unselected">Выберите свою страну из списка</option>
      {#if countries?.content?.elements}
      {#each countries?.content?.elements as coutry }
      <option value="{coutry}">{coutry}</option>
      {/each}
      {/if}
    </select>
  </label>
  <label data-width="half">
    <input type="text" name="address[zip]" bind:value={$currentProfileData.address.zip} placeholder="Индекс" />
  </label><label data-width="half">
    <input type="text" name="address[city]" bind:value={$currentProfileData.address.city} placeholder="Город" />
  </label><label data-width="half">
    <input type="text" name="address[state]" bind:value={$currentProfileData.address.state} placeholder="Область" />
  </label><label data-width="half">
    <input type="text" name="address[street]" bind:value={$currentProfileData.address.street} placeholder="Улица, дом" />
  </label>
  <hr />
  <label data-width="full">
    <button type="submit">Обновить данные</button>
  </label>
</form>

<style>
  label > p strong {
    white-space: nowrap;
  }
  .company-logotype {
    display: block;
    width: fit-content;
    line-height: 100px;
    margin: 0 auto 20px;
    border: 1px dotted #ccc;
    padding: 20px;
  }
  .company-logotype > * {
    vertical-align: middle;
  }
</style>