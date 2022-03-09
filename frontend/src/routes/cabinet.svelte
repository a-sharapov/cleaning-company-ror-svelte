<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
        const countries = await fetch("/api/v1/assets/countries/", {mode: "cors"})
        return {
          props: {
            countryList: countries.ok && (await countries.json()),
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
  import Loader from "$lib/components/UI/Loader.svelte"
  import Placeholder from "$lib/components/chunks/Placeholder.svelte"
  import Head from "$lib/components/Seo/Head.svelte"
  import { writable } from 'svelte/store'
  import { goto } from '$app/navigation'
  import { browser } from '$app/env'
  import { prepareFormData, getUserFromStorage, setUserInStorage, messageProcessor, message, user, remembered, retryFetch } from '$lib/components/Hooks/Custom.js'

  let title = `Личный кабинет - ${$user.login}`
  let removeConfirmationWindowShow = writable(false)
  let loading = writable(true)
  let currentUserData
  let retry = writable(true)

  user.subscribe(data => {
    currentUserData = writable({
      ...data
    })
  })

  delete $currentUserData.access_token
  delete $currentUserData.address
  let currentUserAddress = writable({
      zip: "",
      country: "unselected",
      city: "",
      state: "",
      street: "",
      ...$user.address
  })
  export let countryList

  $message.content = null

  let tabsContent = writable({
    userReviews: null,
    userEvents: null,
    companyProfile: null,
    companyEvents: null,
    companyReviews: null,
  })

  browser && new Promise(async (res) => {
    let data = {}

    let companyProfileRequest = await retryFetch(
      `/api/v1/${$user.login}/company/`,
      {
        method: "get",
        cache: 'no-cache',
        mode: 'cors',
        headers: {
          'Authorization': `Bearer ${$user.access_token}`,
        }
      },
      user
    )
    data.companyProfile = companyProfileRequest

    if (companyProfileRequest && !companyProfileRequest.message) {
      let companyEventsRequest = await retryFetch(
        `/api/v1/events/?company_name=${companyProfileRequest.company_name}`,
        {
          method: "get",
          cache: 'no-cache',
          mode: 'cors',
          headers: {
            'Authorization': `Bearer ${$user.access_token}`,
          }
        },
        user
      )
      data.companyEvents = companyEventsRequest
      let companyReviewRequest = await retryFetch(
        `/api/v1/reviews/?company_name=${companyProfileRequest.company_name}`,
        {
          method: "get",
          cache: 'no-cache',
          mode: 'cors',
          headers: {
            'Authorization': `Bearer ${$user.access_token}`,
          }
        },
        user
      )
      data.companyReviews = companyReviewRequest
    } else {
      data.companyEvents = {message: "В данный момент профиль компании ещё не заполнен, поэтому запрос событий не произведён"}
      data.companyReviews = {message: "В данный момент профиль компании ещё не заполнен, поэтому запрос отзывов не произведён"}
    }
    
    let userEventsRequest = await retryFetch(
      `/api/v1/reviews/?customer=${$user.login}`,
      {
        method: "get",
        cache: 'no-cache',
        mode: 'cors',
        headers: {
          'Authorization': `Bearer ${$user.access_token}`,
        }
      },
      user
    )
    data.userEvents = userEventsRequest
    let userReviewsRequest = await retryFetch(
      `/api/v1/events/?customer=${$user.login}`,
      {
        method: "get",
        cache: 'no-cache',
        mode: 'cors',
        headers: {
          'Authorization': `Bearer ${$user.access_token}`,
        }
      },
      user
    )
    data.userReviews = userReviewsRequest

    res(data)
  }).then((data) => {
    Object.keys(data).map((response) => {
      data[response].message ? $tabsContent[response] = data[response].message : $tabsContent[response] = data[response]
    })
  }).finally(() => {
    $loading = false
  })

  const handleTabSwitch = (event) => {
    if (browser) {
      let index = event.target.getAttribute("data-tab")
      let all = document.querySelectorAll(".tab, .tab-contller")
      all.forEach(element => element.classList.remove("active"))
      let mustActive = document.querySelectorAll(`.tab[data-tab="${index}"], .tab-contller[data-tab="${index}"]`)
      mustActive.forEach(element => element.classList.add("active"))
    }
  }

  const handleProfileUpdate = async (event) => {
    event.preventDefault()
    let removeEmpty = {password: "", avatar: "", phone: "", description: ""}

      try {
        $loading = true
        let data = new FormData(event.target),
          preparedData = prepareFormData(data, removeEmpty)

          let result = await retryFetch(`/api/v1/user/${$user.login}/`,
            {
              method: event.target.getAttribute("method"),
              cache: 'no-cache',
              mode: 'cors',
              headers: {
                'Authorization': `Bearer ${$user.access_token}`,
              },
              body: preparedData
            },
            user
          )
          
          message.set(messageProcessor(result))
          setUserInStorage({...$user, ...result.user}, remembered())
        } catch (e) {
          $message.type = "error"
          $message.content = e.message
        } finally {
          user.set(getUserFromStorage())
          $loading = false
          $retry = true
        }
  }

  const handleOnProfileRemove = () => {
    removeConfirmationWindowShow.set(!$removeConfirmationWindowShow)
  }

  if (!$user && browser) {
    goto("/")
  }
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />
{#if $removeConfirmationWindowShow}
  <dialog class="window" data-header="false">
    <p>Вы действительно хотите удалить свой аккаунт?</p>
    <p>&nbsp;</p>
    <p>
      <a class="button" href="/signout?and=remove">Удалить</a>
      <span class="button white" on:click="{handleOnProfileRemove}">Отменить</span>
    </p>
  </dialog>
{/if}
<article id="page-content">
  <section id="cabinet-data-wrapper" data-loading="{$loading}">
    {#if $loading}
      <Loader />
    {/if}
    {#if $user}
    <aside id="cabinet-left">
      <span class="user-avatar">
        {#if $user.avatar_file_name}
          <img src="/api/avatar/{$user.login}?image={$user.avatar_file_name}" alt="{$user.login}" height="100%" />
        {:else}
          <span>{$user.login.charAt(0).toUpperCase()}</span>
        {/if}
      </span>
      <h3>
        Привет, <span class="user-nickname">{$user.login}</span>
        {#if $user.confirmed}<span class="confirmed" title="Аккаунт подтвержен">&#10003;</span>{/if}
        {#if $user.banned}<span class="banned" title="Аккаунт заблокирован">&#10008;</span>{/if}
      </h3>
      <hr />
      <nav data-role="tab-controll-menu">
        <span on:click="{handleTabSwitch}" class="tab-contller active" data-tab="0">Профиль</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="2">События</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="1">Отзывы</span>
        {#if $user.role === "company"}
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="4">Профиль компании</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="5">Cобытия компании</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="6">Отзывы о компании</span>
        {/if}
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="3">Удаление</span>
      </nav>
      <hr />
      <p>Вы создали аккаунт: <br /><strong>{new Date($user.created_at).toLocaleDateString("ru-RU")} в {new Date($user.created_at).toLocaleTimeString("ru-RU")}</strong></p>
      {#if $user.created_at !== $user.updated_at}
      <p>И последний раз обновили данные: <br /><strong>{new Date($user.updated_at).toLocaleDateString("ru-RU")} в {new Date($user.updated_at).toLocaleTimeString("ru-RU")}</strong></p>
      {/if}
      {#if $user.banned}<p>Заблокирован до: <br /><strong>{new Date($user.blocked_until).toLocaleDateString("ru-RU")}, {new Date($user.blocked_until).toLocaleTimeString("ru-RU")}</strong></p>{/if}
      </aside>
    <aside id="cabinet-tabs">
      {#if $message?.content}
      <span class="form-message" data-type={$message?.type}>{@html $message?.content}</span>
      {/if}
      <div class="tab active" data-tab="0">
        <h3>Данные профиля:</h3>
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
            <select name="address[country]" bind:value={$currentUserAddress.country}>
              <option disabled value="unselected">Выберите свою страну из списка</option>
              {#if countryList?.content?.elements}
              {#each countryList?.content?.elements as coutry }
              <option value="{coutry}">{coutry}</option>
              {/each}
              {/if}
            </select>
          </label>
          <label data-width="half">
            <input type="text" name="address[zip]" bind:value={$currentUserAddress.zip} placeholder="Индекс" />
          </label><label data-width="half">
            <input type="text" name="address[city]" bind:value={$currentUserAddress.city} placeholder="Город" />
          </label><label data-width="half">
            <input type="text" name="address[state]" bind:value={$currentUserAddress.state} placeholder="Область" />
          </label><label data-width="half">
            <input type="text" name="address[street]" bind:value={$currentUserAddress.street} placeholder="Улица, дом" />
          </label>
          <hr />
          <label data-width="full">
            <button type="submit">Обновить данные</button>
          </label>
        </form>
      </div>
      {#if $user.role === "company"}
      <div class="tab" data-tab="4">
        <Placeholder content={$tabsContent.companyProfile} />
      </div>
      <div class="tab" data-tab="5">
        <Placeholder content={$tabsContent.companyEvents} />
      </div>
      <div class="tab" data-tab="6">
        <Placeholder content={$tabsContent.companyReviews} />
      </div>
      {/if}
      <div class="tab" data-tab="1">
        <Placeholder content={$tabsContent.userEvents} />
      </div>
      <div class="tab" data-tab="2">
        <Placeholder content={$tabsContent.userReviews} />
      </div>
      <div class="tab" data-tab="3">
        <h4>Удаление аккаунта</h4>
        <p>Вы можете удалить ваш аккаунт в любое время или прямо сейчас. Но, если вы вдруг поменяете своё мнение, вы не сможете его восстановить.</p>
        <p>&nbsp;</p>
        <p><span class="button" on:click="{handleOnProfileRemove}">Удалить аккаунт</span></p>
      </div>
    </aside>
    {:else if !user && browser}
      <p>Зона доступна только авторизованным пользователям, вы будете перенаправленны на главную страницу</p>
    {/if}
  </section>
</article>

<style>
  article#page-content {
    background: #fff;
    display: flex;
    flex: 1 0 auto;
    justify-content: center;
    align-items: center;
    height: 100%;
    padding: 5px 0 20px !important;
    margin: -20px 0;
  }
  #cabinet-data-wrapper {
    text-align: left;
    margin: 50px auto;
    width: 100%;
    max-width: 900px;
  }

  .user-nickname {
    font-weight: bold;
    white-space: nowrap;
  }

  .user-avatar,
  .user-avatar > span,
  .user-avatar > img {
    display: block;
    width: 100px;
    height: 100px;
    margin: 0;
    padding: 0;
  }

  .user-avatar > span {
    text-align: center;
    line-height: 90px;
    font-weight: bold;
    font-size: 60px;
    color: #fff;
    text-shadow: none;
  }
  
  .user-avatar {
    display: inline-block;
    background: var(--mf-darkgray);
    margin-bottom: 20px;
    user-select: none;
    border-radius: 5px;
    overflow: hidden;
    box-shadow: 0px 3px 12px #00000005;
  }

  .confirmed,
  .banned {
    display: inline-block;
    vertical-align: top;
    height: 14px;
    line-height: 14px;
    font-size: 10px;
    margin: 10px 10px 0 0;
    background: #ddd;
    padding: 0 4px;
    font-weight: bold;
    text-transform: uppercase;
    cursor: help;
  }

  .confirmed {
    background: #00a100;
    color: #fff;
    text-shadow: 0 1px 0 #00000030;
  }

  .banned {
    background: #a10000;
    color: #fff;
    text-shadow: 0 1px 0 #00000030;
  }
  

  aside#cabinet-left,
  aside#cabinet-tabs {
    display: inline-block;
    vertical-align: top;
    box-sizing: border-box;
    padding: 0;
  }

  aside#cabinet-left {
    width: 300px;
    position: relative;
    text-align: right;
    padding-right: 20px;
  }

  aside#cabinet-left hr {
    position: relative;
    right: -20px;
  }

  aside#cabinet-left:after {
    content: "";
    display: block;
    position: absolute;
    right: 0;
    top: 0;
    margin: 0;
    padding: 0;
    height: 100%;
    width: 2px;
    background: linear-gradient(to bottom, var(--mf-darkgray), transparent);
  }

  aside#cabinet-tabs {
    width: calc(100% - 305px);
  }

  nav[data-role="tab-controll-menu"] {
    position: relative;
    display: block;
    clear: both;
    right: -20px;
    text-align: right;
  }

  nav[data-role="tab-controll-menu"] > span {
    position: relative;
    display: block;
    padding: 5px 20px;
    text-transform: uppercase;
    cursor: pointer;
    text-decoration: underline;
  }

  nav[data-role="tab-controll-menu"] > span.active {
    font-weight: bold;
    color: var(--mf-red);
    border-right: 2px solid var(--mf-red);
    background: linear-gradient(to left, var(--mf-darkgray), transparent);
    cursor: default;
    text-decoration: none;
    z-index: 2;
  }

  aside#cabinet-tabs > .tab {
    display: none;
  }

  aside#cabinet-tabs > .tab.active {
    display: block;
    padding: 20px;
  }

  span.form-message {
    margin: 0 20px 20px;
    width: calc(100% - 40px);
  }

  span.button.white {
    float: right;
    color: #333;
    background-color: var(--mf-darkgray);
    text-shadow: 0 1px 0 #fff;
  }
</style>