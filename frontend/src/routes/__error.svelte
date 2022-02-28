<script context="module">
  export function load({error, status}) {
    return {
      props: { error, status }
    }
  }
</script>

<script>
  export let error
  export let status
</script>

<section id="page-error">
  <h4 class="vintage-subheader">{status}</h4>
  <h1 class="vintage-header">Что-то пошло не так!</h1>
  <hr />
  <p>В настоящее время мы не можем обработать этот запрос, потому что...</p>
  <p><strong>{error.message}</strong></p>
  <p><a href="/" class="backlink">Вернуться на главную страницу...</a></p>
</section>

<style>
  section#page-error {
    text-align: center;
    padding: 70px 0;
  }
  h4.vintage-subheader {
    margin: 0 0 10px;
    padding: 0;
    color: var(--mf-brown);
  }
  h1.vintage-header {
    padding: 0;
    margin: 0 0 100px;
  }
  hr {
    margin: 0 0 60px;
  }
  a.backlink {
    display: inline-block;
    color: var(--mf-brown);
    line-height: 50px;
    padding: 0 30px;
    text-decoration: none;
    margin: 50px 0 0;
    border-radius: 30px;
    text-transform: uppercase;
    background: linear-gradient(to top, var(--mf-gray), #fff);
    box-shadow: 0 4px #c6a39a, 0 5px #fff;
  }
</style>