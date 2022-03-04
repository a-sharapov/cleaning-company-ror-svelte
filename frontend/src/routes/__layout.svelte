<script>
  import Header from "$lib/components/Chunks/Header.svelte"
  import Footer from "$lib/components/Chunks/Footer.svelte"
  import Nav from "$lib/components/Chunks/Nav.svelte"
  import { page } from '$app/stores'
  import { user } from '$lib/components/Hooks/Custom.js'

  let links = [
    {
      href: "/",
      title: "Главная страница"
    },
    {
      href: "/companies",
      title: "Компании"
    },
    {
      href: "/reviews",
      title: "Отзывы"
    },
    {
      href: "/map",
      title: "Компании на карте"
    }
  ]
</script>

<Header>
  <div class="header-row-wrapper" slot="headerNav">
    <Nav links={links} page={page} role={"header-menu"} />
    {#if $user}
    <nav data-role="header-buttons">
      <span class="user-profile-info">Привет,&nbsp;{$user.login}!&nbsp;</span>
      <a href="/cabinet" class="button light">Бюро</a>
      <a href="/signout" class="button">Выйти</a>
    </nav>
    {:else}
    <nav data-role="header-buttons">
      <a href="/signup" class="button light">Зарегестрироваться</a>
      <a href="/login" class="button">Войти</a>
    </nav>
    {/if}
  </div>
</Header>
<slot></slot>
<Footer>
  <svelte:fragment slot="footer-content"></svelte:fragment>
</Footer>

<style>
  nav[data-role="header-buttons"] {
    float: right;
  }
</style>