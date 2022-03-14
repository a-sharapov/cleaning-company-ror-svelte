<script>
  import Head from "$lib/components/Seo/Head.svelte"
  import FormAlert from "$lib/components/Forms/FormAlert.svelte"
  import Loader from "$lib/components/UI/Loader.svelte"
  import { goto } from '$app/navigation'
  import { browser } from '$app/env'
  import { writable } from 'svelte/store'
  import { page } from '$app/stores'
  import { message, messageProcessor, setUserInStorage, getUserFromStorage, user } from '$lib/components/Hooks/Custom.js'
  import { confirmUser } from '$lib/components/Utils/Requests.js'

  let showForm = writable(true)
  let loading = writable(false)
  let title = "Активация аккаунта"
  let code = writable($page.url.searchParams.get("code"))

  $message.content = null
  
  const handleOnSubmit = async (event) => {
    event.preventDefault()
    if (!Boolean($code)) { return }
    try {
      $loading = true
      let result = await confirmUser($code)
      if (result.user) {
        if (!setUserInStorage(result.user, false)) {
          throw new Error("Аккаунт активирован, но попытка авторизации завершилась неудачей, вы можете сделать это позже в манульаном режиме")
        }
        $showForm = false
      }
      message.set(messageProcessor(result))
    } catch (e) {
      $message.type = "error"
      $message.content = e.message
      $showForm = true
    } finally {
      user.set(getUserFromStorage())
      $loading = false
    }
  }
  
  browser && new Promise(res => {
	  setTimeout(async () => {
      document.querySelector("button#activation-form-button").click()
			res()
		}, 0)
  })
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />
<article id="page-content">
  <section id="activation-form-wrapper" data-loading="{$loading}">
    {#if $loading}
      <Loader />
    {/if}
    <FormAlert {message} />
    {#if $showForm}
      <h3>Активация аккаунта</h3>
      <p>Введите код активации из письма в поле ниже, если он не был добавлен автоматически</p>
      <hr />
      <form action="/activation" method="get" on:submit={handleOnSubmit}>
        <label data-width="full">
          <input type="text" name="code" bind:value={$code} required placeholder="Код активации"/>
        </label>
        <label data-width="full" data-align="center">
          <button id="activation-form-button" type="submit">Актививровать аккаунт</button>
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
  
  #activation-form-wrapper {
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

  #activation-form-wrapper hr {
    margin: 20px -20px;
    width: calc(100% + 40px);
  }

  #activation-form-wrapper input[name="code"] {
    text-align: center;
    font-size: 16px;
  }

  #activation-form-wrapper button {
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
      0px 15px 164px -19px rgba(0, 0, 0, 0.07);
  }
</style>