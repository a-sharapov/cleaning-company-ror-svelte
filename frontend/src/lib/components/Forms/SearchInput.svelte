<script>
  import { writable } from 'svelte/store'
  import { getCompaniesByName, getCompanyPartial } from "$lib/components/Utils/Requests.js"
  import { debounce } from "$lib/components/Utils/Custom.js"

  export let name
  export let searchin = "company"
  export let placeholder = name
  export let services
  export let prices
  let selected = writable("")
  let list = writable(null)

  const handleOnInput = debounce(async (event) => {
    let result
    switch (searchin) {
      case "company":
        result = await getCompaniesByName(event.target.value)
        break
    }
    if (result.message) {
      list.set(result.message)
    } else {
      list.set(result)
    }
    (event.target.value === "") && (list.set(null), services.set([]))
  }, 7e2)

  const handleOnClick = async (event) => {
    let value = event.target.getAttribute("data-item")
    selected.set(value)
    list.set(null)
    services.set(await getCompanyPartial(value, "service_types")), 
    prices.set(await getCompanyPartial(value, "prices"))
  }
</script>

<span class="search-input-wrapper">
  <input type="hidden" name="{name}" bind:value="{$selected}" required />
  <input type="text" name="search-input-handler" placeholder="{placeholder}" bind:value="{$selected}" on:input="{handleOnInput}" required />
  <span class="result-list">
    {#if Array.isArray($list)}
      {#each $list as item}
      <span class="result-list-item" data-item="{item}" on:click="{handleOnClick}">{item}</span>
      {/each}
    {:else if $list}
      {$list}
    {/if}
  </span>
</span>

<style>
  :global(.search-input-wrapper) {
    position: relative;
    display: block;
    clear: both;
    width: 100%;
  }
  :global(input[name="search-input-handler"]) {
    padding-right: 40px;
    background: #fff url(/i/magnifier.svg) no-repeat calc(100% - 10px) center;
    background-size: 22px;
  }
  :global(.search-input-wrapper .result-list) {
    position: absolute;
    left: 0;
    right: 0;
    top: 40px;
    max-height: 600px;
    overflow-x: hidden;
    background: #fff;
    padding: 0;
    opacity: 1;
    transition: all .2s linear;
    z-index: 10;
    box-shadow: 0px 4.1px 10px rgb(0 0 0 / 9%), 0px 33px 80px rgb(0 0 0 / 19%);
  }
  :global(.search-input-wrapper .result-list:empty) {
    padding: 0;
    height: 0;
    opacity: 0;
    box-shadow: none;
  }
  :global(.result-list .result-list-item) {
    display: block;
    text-align: left;
    padding: 0 10px;
    line-height: 30px;
  }
  :global(.result-list .result-list-item:nth-of-type(even)) {
    background: var(--mf-gray);
  }
</style>