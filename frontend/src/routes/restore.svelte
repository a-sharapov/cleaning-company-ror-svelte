<script>
  import Head from "$lib/components/Seo/Head.svelte"
  import Loader from "$lib/components/UI/Loader.svelte"
  import { writable } from 'svelte/store'
  import { message } from '$lib/components/Hooks/Custom.js'

  let showForm = writable(true)
  let loading = writable(false)
  let title = "Восстановление доступа"
  let code = writable("")

  $message.content = null
  
  const handleOnSubmit = async (event) => {
    event.preventDefault()
    try {
      $loading = true
      let result = await fetch(`/api/v1/restore/${$code}/`, {
                              method: event.target.getAttribute("method"),
                              cache: 'no-cache',
                              mode: 'cors',
                              }).then(response => response.json())
      message.set(messageProcessor(result))
    } catch (e) {
      $message.type = "error"
      $message.content = e.message
      $showForm = true
    } finally {
      $loading = false
    }
  }
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />
<article id="page-content">
  <section id="restoration-form-wrapper" data-loading="{$loading}">
    {#if $loading}
    <Loader />
    {/if}
    {#if $message?.content}
      <span class="form-message" data-type={$message?.type}>{@html $message?.content}</span>
    {/if}
    {#if $showForm}
      <h3>Ре-активация аккаунта</h3>
      <p>Введите код активации из письма, которое вы получили при регистрации, в поле ниже. Новый пароль будет сгенерирован и отправлен вам на электронную почту и/или SMS</p>
      <hr />
      <form action="/activation" method="put" on:submit={handleOnSubmit}>
        <label data-width="full">
          <input type="text" name="code" bind:value={$code} required placeholder="Код активации"/>
        </label>
        <label data-width="full" data-align="center">
          <button type="submit">Отправить</button>
        </label>
      </form>
    {/if}
  </section>
</article>

<style>
  article#page-content {
    display: flex;
    flex: 1 0 auto;
    justify-content: center;
    align-items: center;
    height: 100%;
    margin: -20px 0;
    padding: 20px 0 40px;
    background-color: var(--mf-lightgray);
    background-image:  linear-gradient(135deg, var(--mf-darkgray) 25%, transparent 25%), linear-gradient(225deg, var(--mf-darkgray) 25%, transparent 25%), linear-gradient(45deg, var(--mf-darkgray) 25%, transparent 25%), linear-gradient(315deg, var(--mf-darkgray) 25%, var(--mf-lightgray) 25%);
    background-position:  10px 0, 10px 0, 0 0, 0 0;
    background-size: 20px 20px;
    background-repeat: repeat;
  }
  
  #restoration-form-wrapper {
    display: block;
    height: max-content;
    background: #fff;
    text-align: left;
    max-width: 340px;
    padding: 20px;
    margin: 70px auto;
    border-bottom: 5px solid var(--mf-lightgray);
    box-shadow:
            0px 2.9px 40.3px rgba(0, 0, 0, 0.005),
            0px 8.4px 59.5px rgba(0, 0, 0, 0.011),
            0px 17.9px 72.1px rgba(0, 0, 0, 0.019),
            0px 35px 84.2px rgba(0, 0, 0, 0.029),
            0px 69.3px 103.2px rgba(0, 0, 0, 0.043),
            0px 167px 164px rgba(0, 0, 0, 0.07);
  }

  #restoration-form-wrapper hr {
    margin: 20px -20px;
    width: calc(100% + 40px);
  }

  #restoration-form-wrapper input[name="code"] {
    text-align: center;
    font-size: 16px;
  }

  #restoration-form-wrapper button {
    height: 40px;
    font-weight: bold;
    letter-spacing: 3px;
    border: 3px solid var(--mf-darkgray);
    box-shadow:
      0px 6.8px 3.4px -19px rgba(0, 0, 0, 0.017),
      0px 10.1px 7.5px -19px rgba(0, 0, 0, 0.019),
      0px 11.3px 13px -19px rgba(0, 0, 0, 0.024),
      0px 11.3px 22.3px -19px rgba(0, 0, 0, 0.034),
      0px 11.1px 42px -19px rgba(0, 0, 0, 0.049),
      0px 15px 164px -19px rgba(0, 0, 0, 0.07)
    ;
  }
</style>