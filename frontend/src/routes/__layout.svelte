<script>
  import Header from "$lib/components/Chunks/Header.svelte"
  import Footer from "$lib/components/Chunks/Footer.svelte"
  import Nav from "$lib/components/Chunks/Nav.svelte"
  import { page } from '$app/stores'

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
    <nav data-role="header-buttons">
      <a href="/signup" class="button light">Зарегестрироваться</a>
      <a href="/login" class="button">Войти</a>
    </nav>
  </div>
</Header>
<slot></slot>
<Footer>
  <svelte:fragment slot="footer-content"></svelte:fragment>
</Footer>