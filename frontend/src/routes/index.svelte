<script>
  import Head from "$lib/components/Seo/Head.svelte" 
  import Article from "$lib/components/Chunks/Article.svelte"

  let title = "Главная страница"
  let metaDescription = ""
  let metaKeywords = ""
</script>

<Head title={title} metaDescription={metaDescription} metaKeywords={metaKeywords} />

<Article>
  <h1>Svelte frontend</h1>
  <aside slot="sidebar">
    Sidebar
  </aside>
  <section slot="content">
    Article content
  </section>
</Article>