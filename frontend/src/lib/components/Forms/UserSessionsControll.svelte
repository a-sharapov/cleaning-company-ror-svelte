<script>
  import Loader from "$lib/components/UI/Loader.svelte"
  import { parseUserAgent } from "$lib/components/Utils/Custom.js"
  import { writable } from 'svelte/store'
  
  export let data

  let isMessage = writable(false)
  let loading = writable(true)
  let out = writable({})
  
  if (!!data?.message) {
    isMessage.set(true)
  }

  loading.set(false)
</script>

{#if $loading}
  <Loader />
{/if}
<slot></slot>
{#if $isMessage}
  <p>{data?.message}</p>
{:else if !!data}
{#each data as {id, metrics, login, expires_in}}
  <div class="session-item" data-id="{id}">
    <div class="row">
      <p class="login">Пользователь: <strong>{login}</strong></p>
      <p class="expires_in light">Активна до: <strong>{new Date(expires_in).toLocaleDateString("ru-RU")}, {new Date(expires_in).toLocaleTimeString("ru-RU")}</strong></p>
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
    border: 1px dotted #ccc;
    padding: 20px;
    width: 100%;
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
</style>