<script>
  import Loader from "$lib/components/UI/Loader.svelte"
  import Head from "$lib/components/Seo/Head.svelte"
  import { goto } from '$app/navigation'
  import { browser } from '$app/env'
  import { writable } from 'svelte/store'
  import { message, user, setUserInStorage, getUserFromStorage, messageProcessor } from '$lib/components/Hooks/Custom.js'

  let title = "Авторизироваться"
  let loading = writable(false)
  let showForm = writable(true)
  let auth = writable({
    login: "",
    password: "",
    checked: "",
  })

  $message.content = null

  const handleOnSubmit = async (event) => {
    event.preventDefault()
    try {
      $loading = true
      let data = new FormData(event.target)
      let result = await fetch("/api/v1/auth/", {
                              method: event.target.getAttribute("method"),
                              cache: 'no-cache',
                              mode: 'cors',
                              body: data,
                              }).then(response => response.json())

      if (result.error) {
        throw new Error(result.error)
      }
      if (result.user) {
        $message.type = "success"
        $message.content = `<p>${result.message}</p>`
        if (!setUserInStorage(result.user, data.get("remember_me"))) {
          throw new Error("Попытка авторизации завершилась неудачей, проверьте настройки безопасности системы и браузера")
        }
        $showForm = false
        browser && new Promise(res => {
          setTimeout(async () => {
            goto("/cabinet")
            res()
          }, 5e2)
        })
      } else {
        if (result.assets) {
          let assets
          Array.isArray(result.assets) ? assets = `<ul><li>${result.assets.join("</li><li>")}</li></ul>` : assets = `<p>${result.assets}</p>`
          $message.type = "error"
          $message.content = `<p>${result.message}:</p>`+ assets
        } else {
          $message.type = "info"
          $message.content = `<p>${result.message}</p>`
        }
      }
    } catch (e) {
      $message.type = "error"
      $message.content = e.message
      $showForm = true
    } finally {
      user.set(getUserFromStorage())
      $loading = false
    }
  }
</script>

<Head title={title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />
<article id="page-content">
  <section id="login-form-wrapper" data-loading="{$loading}">
    {#if $user && !$message?.content}
      <h3>Вы успешно авторизованы на этом устройстве</h3>
      <p>Если вам необходимо авторизоваться снова, воспользуйтесь кнопкой в основном меню приложения.</p>
    {:else}
      {#if $loading}
        <Loader />
      {/if}
      {#if $message?.content}
        <span class="form-message" data-type={$message?.type}>{@html $message?.content}</span>
      {/if}
      {#if $showForm}
        <h3>Войдите!</h3>
        <p>Для того, чтобы использовать все возможности приложения</p>
        <hr />
        <form action="/login" method="post" on:submit={handleOnSubmit}>
          <label data-width="full">
            <input type="text" name="login" bind:value={$auth.login} required placeholder="Имя пользователя" />
          </label>
          <label data-width="full">
            <input type="password" name="password" bind:value={$auth.password} required placeholder="Пароль" />
          </label>
          <label data-width="full">
            <input type="checkbox" name="remember_me" value="true" bind:checked={$auth.checked} />&nbsp;Запомните этот комьютер
          </label>
          <label data-width="full" data-align="center">
            <button type="submit">Войти</button>
          </label>
        </form>
        <hr />
        <p align="center">Нет аккаунта? <a href="/signup">Зарегестрируйтесь!</a></p>
        <p align="center">Забыли пароль? <a href="/restore">Сгенерируйте новый!</a></p>
      {/if}
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
    background-image:  linear-gradient(135deg, var(--mf-darkgray) 25%, transparent 25%), linear-gradient(225deg, var(--mf-darkgray) 25%, transparent 25%), linear-gradient(45deg, var(--mf-darkgray) 25%, transparent 25%), linear-gradient(315deg, var(--mf-darkgray) 25%, var(--mf-lightgray) 25%);
    background-position:  10px 0, 10px 0, 0 0, 0 0;
    background-size: 30px 130px;
    background-repeat: repeat;
  }

  #login-form-wrapper {
    display: block;
    height: max-content;
    background: #fff;
    text-align: left;
    max-width: 340px;
    padding: 20px;
    margin: 20px auto;
    border-bottom: 5px solid var(--mf-lightgray);
    box-shadow:
            0px 2.9px 40.3px rgba(0, 0, 0, 0.005),
            0px 8.4px 59.5px rgba(0, 0, 0, 0.011),
            0px 17.9px 72.1px rgba(0, 0, 0, 0.019),
            0px 35px 84.2px rgba(0, 0, 0, 0.029),
            0px 69.3px 103.2px rgba(0, 0, 0, 0.043),
            0px 167px 164px rgba(0, 0, 0, 0.07);
  }

  #login-form-wrapper hr {
    margin: 20px -20px;
    width: calc(100% + 40px);
  }

  #login-form-wrapper button {
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