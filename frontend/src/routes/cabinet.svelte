<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
        const countries = await fetch("/api/v1/assets/countries/", {mode: "cors"})
        const services = await fetch("/api/v1/assets/services/", {mode: "cors"})
        const odds = await fetch("/api/v1/assets/odds/", {mode: "cors"})
        return {
          props: {
            countries: countries.ok && (await countries.json()),
            services: services.ok && (await services.json()),
            odds: odds.ok && (await odds.json()),
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
  import Head from "$lib/components/Seo/Head.svelte"
  import UserProfileForm from "$lib/components/Forms/UserProfileForm.svelte"
  import FormAlert from "$lib/components/Forms/FormAlert.svelte"
  import UserPasswordForm from "$lib/components/Forms/UserPasswordForm.svelte"
  import UserSessions from "$lib/components/Chunks/UserSessions.svelte"
  import UserEvents from "$lib/components/Chunks/UserEvents.svelte"
  import UserReviews from "$lib/components/Chunks/UserReviews.svelte"
  import UserCompanyReviews from "$lib/components/Chunks/UserCompanyReviews.svelte"
  import UserCompanyEvents from "$lib/components/Chunks/UserCompanyEvents.svelte"
  import UserCompanyProfile from "$lib/components/Chunks/UserCompanyProfile.svelte"
  import { writable } from 'svelte/store'
  import { goto } from '$app/navigation'
  import { browser } from '$app/env'
  import { 
    removeUserFromStorage, 
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { 
    getAvatarByUser, 
    getUserByLogin, 
  } from '$lib/components/Utils/Requests.js'

  let title = `Личный кабинет - ${$user.login}`
  let removeConfirmationWindowShow = writable(false)
  let loading = writable(true)
  let isUser = writable(true)
  let isAvatar = writable(false)

  export let countries
  export let services
  export let odds

  $message.content = null

  browser && new Promise(async (res) => {

    let userProfileRequest = await getUserByLogin($user.login)
    !!userProfileRequest.message && isUser.set(false)

    let userProfileAvatar = await getAvatarByUser($user)
    userProfileAvatar.ok && isAvatar.set(true)
    
    res()
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

  const handleOnProfileRemove = () => {
    removeConfirmationWindowShow.set(!$removeConfirmationWindowShow)
  }

  isUser.subscribe(async (current) => {
    if (current === false) {
      let response = await fetch(
        "/api/v1/auth/", 
        {
          method: "delete", 
          mode: "cors"
        }
      ).then((response) => {
        response.ok && setTimeout(async () => { 
          removeUserFromStorage()
          user.set(null)
          goto("/") 
        }, 1e3)
      })
    }
  })

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
        {#if $isAvatar}
          <img src="/api/v1/avatar/{$user.login}?image={$user.avatar_file_name}" alt="{$user.login}" height="100%" />
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
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="7">Активные сессии</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="9">Изменть пароль</span>
        {#if $user.role === "company"}
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="4">Профиль компании</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="6">Отзывы о компании</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="5">Календарь</span>
        <span on:click="{handleTabSwitch}" class="tab-contller" data-tab="8">Графики</span>
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
      <FormAlert {message} />
      <div class="tab active" data-tab="0">
        <h3>Данные профиля:</h3>
        <UserProfileForm {countries}/>
      </div>
      {#if $user.role === "company"}
      <div class="tab" data-tab="4">
        <UserCompanyProfile {countries} {services} {odds}>
          <h3>Профиль компании:</h3>
        </UserCompanyProfile>
      </div>
      <div class="tab" data-tab="5">
        <UserCompanyEvents>
          <h3>Календарь:</h3>
        </UserCompanyEvents>
      </div>
      <div class="tab" data-tab="6">
        <UserCompanyReviews>
          <h3>Отзывы о комании:</h3>
        </UserCompanyReviews>
      </div>
      <div class="tab" data-tab="8">
        Графики
      </div>
      {/if}
      <div class="tab" data-tab="1">
        <UserReviews>
          <h3>Отзывы:</h3>
        </UserReviews>
      </div>
      <div class="tab" data-tab="2">
        <UserEvents>
          <h3>События:</h3>
        </UserEvents>
      </div>
      <div class="tab" data-tab="7">
        <UserSessions>
          <h3>Активные сессии:</h3>
        </UserSessions>
      </div>
      <div class="tab" data-tab="9">
        <UserPasswordForm>
          <h3>Изменть пароль:</h3>
          <div slot="after">
            <hr />
            <p>Пароль пользователя также может быть изменён в любой момент с помощью <a href="/restore">фомы восстановления доступа</a>, однако вам необходимо иметь уникальный код из письма активации.</p>
            <p>В этом случае новый пароль будет сгенерирован автоматически и отправлен по SMS/email.</p>
          </div>
        </UserPasswordForm>
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