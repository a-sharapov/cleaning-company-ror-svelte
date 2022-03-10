<script>
  import { browser } from '$app/env'
  import Loader from "$lib/components/UI/Loader.svelte"
  import { parseUserAgent } from "$lib/components/Utils/Custom.js"
  import { getUserSessions, removeSession } from "$lib/components/Utils/Requests.js"
  import { 
    messageProcessor,
    message, 
    user, 
  } from '$lib/components/Hooks/Custom.js'
  import { writable } from 'svelte/store'
  
  let userSessions = writable(null)
  let loading = writable(true)
  
  const handleRemoveSession = async (event) => {
    let sessions
    event.preventDefault()
    try {
      $loading = true
      let token_id = event.target.closest(".session-item").getAttribute("data-id")
      let result = await removeSession(token_id, $user, user)
      message.set(messageProcessor(result))
    } catch (e) {
      $message.type = "error"
      $message.content = e.message
    } finally {
      let result = await getUserSessions($user, user)
      userSessions.set(result)
      $loading = false
    }
  }

  browser && new Promise(async (res) => {
    let result = await getUserSessions($user, user)
    userSessions.set(result)
    res()
  }).finally(() => {
    $loading = false
  })
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $userSessions?.message}
  <p>{$userSessions?.message}</p>
{/if}
{#if Array.isArray($userSessions)}
{#each $userSessions as {id, metrics, login, expires_in}}
  <div class="session-item" data-id="{id}" data-os="{parseUserAgent(metrics.agent)["OS"]}">
    <div class="row">
      <p class="login">Пользователь: <strong>{login}</strong></p>
      <p class="expires_in light">Активна до: <strong>{new Date(expires_in * 1000).toLocaleDateString("ru-RU")}, {new Date(expires_in * 1000).toLocaleTimeString("ru-RU")}</strong></p>
      <p><span class="button" on:click="{handleRemoveSession}">Завершить сеанс</span></p>
    </div><ul class="metrics">
      <li>IP: <strong>{metrics.ip}</strong></li>
      <li>Система: <strong>{parseUserAgent(metrics.agent)["OS"]}</strong></li>
      <li>Браузер: <strong>{parseUserAgent(metrics.agent)["browser"]}</strong></li>
    </ul>
  </div>
{/each}
{/if}

<style>
  .session-item {
    display: block;
    box-sizing: border-box;
    border: 1px dotted #ccc;
    padding: 20px;
    width: 100%;
    margin: 0 0 5px;
    transition: all .2s linear;
  }
  .session-item:hover {
    border: 1px solid #ccc;
    border-bottom-width: 3px;
    box-shadow: 0 2px 12px #00000025;
  }
  .session-item .row {
    display: inline-block;
    width: 50%;
  }
  .session-item .login {
    font-size: 20px;
  }
  .session-item .expires_in {
    font-size: 12px;
  }
  .session-item ul.metrics {
    display: inline-block;
    font-size: 12px;
    margin: 0;
    padding: 0;
    vertical-align: top;
    width: 50%;
    text-align: right;
  }
  .session-item ul.metrics li {
    display: block;
    line-height: 16px;
    margin: 0;
    padding: 0;
  }
  .session-item .button {
    font-size: 12px;
  }
  .session-item {
    background: #fff url(/i/unknown.svg) no-repeat 100% 120%;
    background-size: 200px;
  }
  .session-item[data-os~="Windows"] {
    background: #fff url(/i/windows.svg) no-repeat 100% 120%;
    background-size: 200px;
  }
  .session-item[data-os~="Linux"] {
    background: #fff url(/i/linux.svg) no-repeat 100% 120%;
    background-size: 200px;
  }
  .session-item[data-os~="Macintosh"] {
    background: #fff url(/i/apple.svg) no-repeat 100% 120%;
    background-size: 200px;
  }
</style>