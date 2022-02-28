<script>
  const year = new Date().getFullYear();
</script>

<footer>
  <p class="footer-copyright">&laquo;Марафеткина&raquo; &copy; {year} Все права соблюдены</p>
  <p>Симметричная онлайн-платформа услуг по уборке квартир, офисов и производственных помещений в Республике Беларусь</p>
  <hr />
  <nav data-role="footer-navigation-links">
    Как здесь все устроено?
    Пользовательское соглашение
    Политика конфиденциальности
  </nav>
  <slot name="footer-content"></slot>
</footer>