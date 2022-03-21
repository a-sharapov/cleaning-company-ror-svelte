<script context="module">
  export async function load({params, fetch, session, stuff}) {
    try {
      const companies = await fetch("/api/v1/companies/?limit=10", {mode: "cors"})
      const reviews = await fetch("/api/v1/reviews/?limit=10", {mode: "cors"})

      return {
        props: {
          reviews: {
            data: reviews.ok && (await reviews.json()),
          },
          companies: {
            data: companies.ok && (await companies.json()),
          }
        }
      }
    } catch (e) {
      return {
        status: e.status,
        error: e.message, 
      }
    }
  }
</script>
<script>
  import Head from "$lib/components/Seo/Head.svelte"
  import Article from "$lib/components/Chunks/Article.svelte"
  import CompanyItem from "$lib/components/Chunks/CompanyItem.svelte"
  import ReviewItem from "$lib/components/Chunks/ReviewItem.svelte"
  import RequestForm from "$lib/components/Forms/RequestForm.svelte"
  import Loader from "$lib/components/UI/Loader.svelte"

  export let companies
  export let reviews

  let title = "Порядок без пипидастров!"
</script>

<Head {title} metaDescription={null} metaKeywords={null} metaRobots={null} />
<Article>
  <section id="banner">
    <img src="/i/girl.png" alt="Марафеткина" width="350px" class="banner-image" />
    <div class="row">
      <h1 class="vintage-header"><span>&starf;</span> Профессионалы <span>&starf;</span></h1>
      <h1 class="vintage-header">Без пипидастров!</h1>
      <span class="pipidastra-wrapper">
        <img src="/i/pipidastra.png" alt="Pipidastra" width="70px"/>
      </span>
    </div>
  </section>
  <section id="feature-list">
    <ul class="plain-list">
      <li>
        <span class="icon-wrapper">
          <img src="/i/icons/timer-outline.svg" alt="Мы готовы к работе 24/7" width="60px" />
        </span>
        <h3>В любое время!</h3>
        <hr />
        <p>Мы готовы к работе 24/7</p>
      </li>
      <li>
        <span class="icon-wrapper">
          <img src="/i/icons/thumbs-up-outline.svg" alt="Стоимость не изменяется с момента заказа" width="60px" />
        </span>
        <h3>Точность и обязательность</h3>
        <hr />
        <p>Стоимость не изменяется с момента заказа</p>
      </li>
      <li>
        <span class="icon-wrapper">
          <img src="/i/icons/shield-checkmark-outline.svg" alt="Оперативно решим любую неловкую ситуацию" width="60px" />
        </span>
        <h3>Сервис с гарантией</h3>
        <hr />
        <p>Оперативно решим любую неловкую ситуацию</p>
      </li>
    </ul>
  </section>
  <section id="companies">
    <h2>Компании:</h2>
    {#if companies?.data?.message}
      <p class="ligher">{companies.data.message}</p>
    {:else if !companies?.data?.message && companies.data}
      {#each companies.data.data as item}
        <CompanyItem {item} />
      {/each}
    {:else}
      <Loader />
    {/if}
    <hr />
    <p>В разделе &laquo;Компании&raquo; вы можете рассмотреть все предложения и подобрать подходящую компанию по параметрам</p>
    <p><a href="/companies" class="button">Перейти в раздел</a></p>
  </section>
  <section id="reviews">
    <h2>Отзывы:</h2>
    {#if reviews?.data?.message}
      <p class="ligher">{reviews.data.message}</p>
    {:else if !reviews?.data?.message && reviews.data}
      {#each reviews.data.data as item}
        <ReviewItem {item} />
      {/each}
    {:else}
      <Loader />
    {/if}
  </section>
  <section id="request-event">
    <RequestForm>
      <h4>Знаете название компании? Оставьте заявку прямо в этой форме:</h4>
    </RequestForm>
  </section>
</Article>

<style>
  section#banner {
    position: relative;
    padding: 20px 0 50px;
    margin: -20px 0 0;
    height: 400px;
    background: repeating-conic-gradient(var(--mf-gray) 0deg 15deg, var(--mf-darkgray) 0deg 30deg) var(--mf-gray);
    max-width: 100%;
    clip-path: polygon(0 0, 100% 0, 100% 100%, 0 90%);
    box-shadow: inset 0 -20px 120px #00000020;
    z-index: 2;
  }

  section#banner img.banner-image {
    display: inline-block;
    vertical-align: bottom;
    position: relative;
    top: auto;
    bottom: -10px;
  }

  section#banner .row {
    display: inline-block;
    width: 600px;
    vertical-align: bottom;
  }

  section#banner .row h1:first-of-type {
    background: var(--mf-red);
    color: #fff;
    text-shadow: 4px 5px var(--mf-red), 6px 7px var(--mf-darkbrown);
    margin: 0 0 -20px;
    padding: 5px 0 14px;
    font-size: 45px;
  }

  section#banner .row h1+h1 {
    margin-bottom: 0;
  }

  section#banner .pipidastra-wrapper {
    position: relative;
    display: inline-block;
    height: 80px;
    width: 80px;
    border-radius: 60px;
    text-align: center;
    border: 5px solid var(--mf-red);
    margin: 20px 0 50px;
  }

  section#banner .pipidastra-wrapper:before {
    content: "";
    position: absolute;
    left: -5px;
    top: calc(50% - 2px);
    width: 78px;
    height: 5px;
    background: var(--mf-red);
    z-index: 2;
    transform: rotate(30deg);
  }

  section#banner .pipidastra-wrapper img {
    position: relative;
    top: -20px;
  }

  section#feature-list {
    background: #fff;
    max-width: 100%;
    margin: -50px 0 0;
    padding: 70px 0;
    clip-path: polygon(0 0, 100% 0, 100% 95%, 0% 100%);
  }

  ul.plain-list {
    display: block;
    margin: 0 auto;
    padding: 0;
    max-width: 1400px;
  }

  ul.plain-list li {
    display: inline-block;
    box-sizing: border-box;
    padding: 15px 20px 0;
    vertical-align: top;
    width: calc(100% / 3 - 10px);
    letter-spacing: 1px;
  }

  ul.plain-list li h3 {
    font-weight: bold;
    color: #fff;
    letter-spacing: 0;
    margin: 0;
    text-shadow: 1px 0 1px var(--mf-darkbrown), 0 1px 1px var(--mf-darkbrown), -1px 0 1px var(--mf-darkbrown), 0 -1px 1px var(--mf-darkbrown);
  }

  ul.plain-list li hr {
    height: 0;
    width: 30px;
    margin: 15px auto;
    border: none;
    border-top: 2px dotted var(--mf-darkbrown);
    opacity: .5;
  }

  ul.plain-list li .icon-wrapper {
    position: relative;
    box-sizing: border-box;
    display: block;
    width: 120px;
    height: 120px;
    line-height: 120px;
    margin: 0 auto 20px;
    padding: 0;
    text-align: center;
    background: repeating-conic-gradient(var(--mf-gray) 0deg 15deg, var(--mf-darkgray) 0deg 30deg) var(--mf-gray);
    clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
  }

  ul.plain-list li .icon-wrapper img {
    display: inline-block;
    vertical-align: middle;
    filter: invert(1) brightness(.4) sepia(1)  hue-rotate(-40deg) drop-shadow(0 0 1px #fff);
  }

  ul.plain-list li:nth-child(2) .icon-wrapper img {
    margin-top: -10px;
  }

  section#companies {
    max-width: 100%;
    background: var(--mf-darkgray);
    margin: -20px 0 0;
    padding: 50px;
  }

  section#reviews {
    padding: 50px;
  }

  section#companies h2,
  section#reviews h2 {
    position: relative;
    padding: 0;
    margin: 0 0 30px;
    text-shadow: 0 5px var(--mf-gray), 0 7px #c6a39a;
  }

  section#companies h2:after,
  section#reviews h2:after {
    display: block;
    clear: both;
    content: "";
    margin: 30px auto 0;
    width: 50px;
    height: 2px;
    border-top: 2px dotted  var(--mf-brown);
    box-shadow: 0 1px 0 #ffffff40;
  }
</style>