<script>
  import SEO from "$lib/components/Seo/index.svelte"
  import Header from "$lib/components/Chunks/Header.svelte"
  import Footer from "$lib/components/Chunks/Footer.svelte"
  import Article from "$lib/components/Chunks/Article.svelte"
</script>

<SEO title={"Главная страница"} metaDescription={"SEO описание"} metaKeywords={"SEO ключи"} />

<Header>
  <h1 slot="header-content">Svelte frontend</h1>
</Header>
<Article>
  <aside slot="sidebar">
    Sidebar
  </aside>
  <section slot="content">
    Article content
  </section>
  
</Article>
<Footer>
  <svelte:fragment slot="footer-content">
    Footer content
  </svelte:fragment>
</Footer>