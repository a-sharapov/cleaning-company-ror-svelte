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

<article id="page-error">
  <h4 class="vintage-subheader">Что-то пошло не так!</h4>
  <h1 class="vintage-header">{status}</h1>
  <hr />
  <p>В настоящее время мы не можем обработать этот запрос, потому что...</p>
  <p class="error-message"><strong>{error.message}</strong></p>
</article>

<style>
  article#page-error {
    text-align: center;
    padding: 150px 0 50px;
  }
  h4.vintage-subheader {
    margin: 0 0 50px;
    padding: 0;
    color: var(--mf-brown);
  }
  h1.vintage-header {
    padding: 0;
    margin: 0 0 100px;
    font-size: 150px;
  }
  hr {
    margin: 0 0 60px;
  }
  p.error-message {
    display: inline-block;
    margin: 20px auto;
    background: #ffffff70;
    padding: 20px 30px;
    border: 1px dotted #00000050;
  }
</style>