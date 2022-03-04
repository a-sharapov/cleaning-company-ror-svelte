<script>
  import Loader from "$lib/components/UI/Loader.svelte"
  import Head from "$lib/components/Seo/Head.svelte"
  import { writable } from 'svelte/store'
  import { goto } from '$app/navigation'
  import { browser } from '$app/env'
  import { prepareFormData, message, user } from '$lib/components/Hooks/Custom.js'

  let title = "Зарегестрироваться"
  let loading = writable(true)

  $message.content = null


  if (browser) {
    $loading = false
  }
  // cabinet data out logic
  // user update logic

  if (!$user && browser) {
    goto("/")
  }
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />

<article id="page-content">
{#if $loading}
  <Loader />
{/if}
{#if $user}
  <section id="cabinet-data-wrapper" data-loading="{$loading}">
    <span class="user-avatar">
      {#if $user.avatar_file_name}
        <img src="{$user.avatar_file_name}" alt="{$user.login}" />
      {:else}
        <span>{$user.login.charAt(0).toUpperCase()}</span>
      {/if}
    </span>
    <h3>
      Привет, {$user.login}
      {#if $user.confirmed}<span class="confirmed">Подтвержен</span>{/if}
      {#if $user.banned}<span class="banned">Забанен</span>{/if}
    </h3>
    <p>Вы создали аккаунт: <strong>{new Date($user.created_at).toLocaleDateString("ru-RU")} в {new Date($user.created_at).toLocaleTimeString("ru-RU")}</strong></p>
    {#if $user.created_at !== $user.updated_at}
    <p>И последний раз обновили данные: <strong>{new Date($user.updated_at).toLocaleDateString("ru-RU")} в {new Date($user.updated_at).toLocaleTimeString("ru-RU")}</strong></p>
    {/if}
    {#if $user.banned}<p>Забанен до: <strong>{new Date($user.blocked_until).toLocaleDateString("ru-RU")}, {new Date($user.blocked_until).toLocaleTimeString("ru-RU")}</strong></p>{/if}
    <hr />
    <form action="/cabinet" method="put" enctype="multipart/form-data">
      
    </form>
  </section>
{:else if !user && browser}
  <p>Зона доступна только авторизованным пользователям, вы будете перенаправленны на главную страницу</p>
{/if}
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
    max-width: 800px;
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
    clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
    margin-bottom: 20px;
    user-select: none;
  }

  .confirmed,
  .banned {
    display: inline-block;
    vertical-align: top;
    height: 14px;
    line-height: 14px;
    font-size: 10px;
    margin: 10px 10px 0;
    background: #ddd;
    padding: 0 4px;
    font-weight: bold;
    text-transform: uppercase;
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
</style>