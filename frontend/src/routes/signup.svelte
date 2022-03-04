<script>
  import Head from "$lib/components/Seo/Head.svelte"
  import { writable } from 'svelte/store'
  import { prepareFormData, message } from '$lib/components/Hooks/Custom.js'
  import Loader from "$lib/components/UI/Loader.svelte"

  let title = "Зарегестрироваться"
  let user = writable({
    login: "",
    role: "client",
    password: "",
    _password: "",
    email: "",
    phone: "",
  })
  let showForm = writable(true)
  let loading = writable(false)

  $message.content = null
  
  const handleOnSubmit = async (event) => {
    event.preventDefault()
    if ($user.password !== $user._password) {
      $message.content = "Пароли не совпадают!"
      $message.type = "error"
    } else {
      $message.content = null
      $message.type = "info"
      try {
        $loading = true
        let data = new FormData(event.target),
            preparedData = prepareFormData(data, $user, "_password")
        
        let result = await fetch("/api/v1/users/", {
                                  method: event.target.getAttribute("method"),
                                  cache: 'no-cache',
                                  mode: 'cors',
                                  body: preparedData
                                  }).then(response => response.json());
        let assets = ""
        if (result.error) {
          throw new Error(result.error)
        }
        if (result.assets) {
          Array.isArray(result.assets) ? assets = `<ul><li>${result.assets.join("</li><li>")}</li></ul>` : assets = `<p>${result.assets}</p>`
          $message.type = "error"
          $message.content = `<p>${result.message}:</p>`+ assets
        } else {
          $message.type = "success"
          $message.content = `<p>${result.message}</p>`
        }
        $showForm = false
      } catch (e) {
        $message.type = "error"
        $message.content = e.message
        $showForm = true
      } finally {
        $loading = false
      }
    }
  }
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={"noindex, nofollow"} />

<article id="page-content">
  <section id="signup-form-wrapper" data-loading="{$loading}">
    {#if $loading}
      <Loader />
    {/if}
    {#if $message?.content}
      <span class="form-message" data-type={$message?.type}>{@html $message?.content}</span>
    {/if}
    {#if $showForm}
    <h3>Зарегеструйтесь!</h3>
    <p>И получите доступ к личному кабинету с расширенным функционалом</p>
    <hr />
    <form action="/signup" method="post" on:submit={handleOnSubmit}>
      <label data-width="full">
        <input type="text" name="login" bind:value={$user.login} required placeholder="Имя пользователя"/>
      </label>
      <label data-width="full">
        <input type="password" name="password" bind:value={$user.password} required placeholder="Пароль" />
      </label>
      <label data-width="full">
        <input type="password" name="_password" bind:value={$user._password} required placeholder="Повторите пароль" />
      </label>
      <hr />
      <p>Я регестрируюсь как:</p>
      <label data-width="full">
        <select name="role" bind:value={$user.role}>
          <option value="client">Клиент</option>
          <option value="company">Компания</option>
        </select>
      </label>
      <p class="small">
        {#if $user.role == "client"}
          Роль <strong>Клиент</strong> позволяет получить доступ к личному кабинету, осуществлять заказ услуг, а также отслеживать их статус, оставлять отзывы о компаниях, планировать события и получать уведомления на телефон и/или по электронной почте.
        {:else if $user.role == "company"}
          Роль <strong>Компания</strong> позволяет создать и настроить профиль компании и вести деятельность от её имени, а также, использовать все функции пользователя. Однако, действия комании, подразумевает более строгую систему модерации.
        {/if}
      </p>
      <hr />
      <label data-width="full">
        <input type="text" name="email" bind:value={$user.email} placeholder="Адрес электронной почты *" />
      </label>
      <p align="center">и<span class="light small">&nbsp;/&nbsp;</span>или</p>
      <label data-width="full">
        <input type="text" name="phone" bind:value={$user.phone} placeholder="Номер телефона *" />
      </label>
      <p>&nbsp;</p>
      <label data-width="full" data-align="center">
        <button type="submit">Зарегестрироваться</button>
      </label>
      <hr />
      <p>Поля, отмеченные <strong>*</strong> необходимы для подтверждения вашего аккаунта. Должно быть заполнено хотя бы одно поле.</p>
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
  
  #signup-form-wrapper {
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

  #signup-form-wrapper hr {
    margin: 20px -20px;
    width: calc(100% + 40px);
  }

  #signup-form-wrapper button {
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