<script>
  import Head from "$lib/components/Seo/Head.svelte" 
  import Article from "$lib/components/Chunks/Article.svelte"

  let title = "Порядок без пипидастров!"
  let metaDescription = "Симметричная онлайн-платформа услуг по уборке квартир, офисов и производственных помещений"
</script>

<Head title={title} metaDescription={metaDescription} metaKeywords={null} metaRobots={null} />
<Article>
  <section id="main">
    
  </section>
  <aside slot="sidebar">
    Sidebar
  </aside>
  <section slot="content">
    Article content
  </section>
</Article>