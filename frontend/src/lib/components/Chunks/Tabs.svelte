<script>
  import { browser } from '$app/env'
  export let tabs

  const handleTabSwitch = (event) => {
    if (browser) {
      let index = event.target.getAttribute("data-target"),
          all = document.querySelectorAll(".tabs, .tab, .tab-controlls li"),
          mustActive = document.querySelectorAll(`ul.tab-controlls li[data-target="${index}"], .tabs .tab[data-id="${index}"]`)

      all.forEach(element => element.classList.remove("active"))
      mustActive.forEach(element => element.classList.add("active"))
    }
  }
  
  if (browser) {
    document.querySelectorAll(".tabs > .tab")[0].classList.add("active")
    document.querySelectorAll("ul.tab-controlls > .li")[0].classList.add("active")
  }
</script>

<div class="tab-wrapper">
  <ul class="tab-controlls">
    {#each tabs as tab }
    <li data-target="{tab.id}" on:click="{handleTabSwitch}">
      {tab.title}
    </li>
    {/each}
  </ul>
  <div class="tabs">
    {#each tabs as tab }
    <div class="tab" data-id="{tab.id}">
      {@html tab.content}
    </div>
    {/each}
  </div>
</div>

<style>
  .tab-wrapper,
  .tabs,
  .tabs > .tab {
    display: block;
    width: 100%;
    margin: 0;
  }

  ul.tab-controlls {
    display: block;
    width: 100%;
    margin: 0;
    padding: 0;
  }

  ul.tab-controlls > li {
    display: inline-block;
    margin: 0 10px;
    padding: 0;
  }

  ul.tab-controlls > li.active {
    font-weight: bold;
  }
</style>