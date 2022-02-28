<script>
  import init from "$lib/config/main.js"
  const { siteTitle } = init

  const year = new Date().getFullYear();
</script>

<footer>
  <p align="center"><img src="/i/logo.png" alt="{siteTitle}" width="150px" id="footer-logo" /></p>
  <p class="footer-copyright">{year} &copy; Все права соблюдены</p>
  <p>Симметричная онлайн-платформа услуг по уборке квартир, офисов и производственных помещений в Республике Беларусь</p>
  <hr />
  <nav data-role="footer-navigation-links">
    <a href="/howitworks">Как здесь все устроено?</a>
    <a href="/agreement">Пользовательское соглашение</a>
    <a href="/privacy">Политика конфиденциальности</a>
  </nav>
  <slot name="footerContent"></slot>
</footer>