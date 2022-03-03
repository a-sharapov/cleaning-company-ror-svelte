<script>
  import init from "$lib/config/main.js"
  
  const { siteLanguage, siteTitle, themeColor, defaultKeywords } = init
 
  export let title
  export let metaDescription
  export let metaKeywords
  export let metaRobots

  const keyWords = metaKeywords ? metaKeywords : defaultKeywords
  const robots = metaRobots ? metaRobots : "index, follow"
  const description = metaDescription ? metaDescription : "Симметричная онлайн-платформа услуг по уборке квартир, офисов и производственных помещений"
  const pageTitle = `${title} :: ${siteTitle}`
</script>

<svelte:head>
	<meta http-equiv="Content-language" content="{siteLanguage}" />
  <meta name="description" content="{description}" />
	<meta name="keywords" content="{keyWords}" />
	<meta name="robots" content="{robots}" />
	<meta name="theme-color" content="{themeColor}" />
	<meta name="msapplication-navbutton-color" content="{themeColor}" />
  <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1" />
  <title>{pageTitle}</title>
</svelte:head>