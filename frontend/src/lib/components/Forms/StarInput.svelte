<script>
  import { writable } from 'svelte/store'
  export let name
  let assessment = writable("Не указана")
  
  const handleOnMouseOver = (event) => {
    let current = event.target.getAttribute("data-value")
    let allStars = event.target.closest(".star-input").querySelectorAll(".star")
    allStars.forEach(element => {
      element.classList.remove("active")
    })
    for (let i = 1; i <= current; i++) {
      event.target.closest(".star-input").querySelector(`.star[data-value="${i}"]`).classList.add("active")
    }
  }

  const handleOnMouseLeave = (event) => {
    let list = event.target.querySelectorAll(".star.active")
    assessment.set(list[list.length - 1].getAttribute("data-value"))
  }
</script>

<slot></slot>
<span class="star-input" on:mouseleave="{handleOnMouseLeave}">
  <i class="star" data-value="1" on:mouseenter="{handleOnMouseOver}"></i>
  <i class="star" data-value="2" on:mouseenter="{handleOnMouseOver}"></i>
  <i class="star" data-value="3" on:mouseenter="{handleOnMouseOver}"></i>
  <i class="star" data-value="4" on:mouseenter="{handleOnMouseOver}"></i>
  <i class="star" data-value="5" on:mouseenter="{handleOnMouseOver}"></i>
  <input type="hidden" name="{name}" value="{$assessment}" />
</span>

<style>
  :global(.star-input) {
    display: inline-block;
    width: fit-content;
    margin: -3px 0 0;
    vertical-align: middle;
  }
  :global(.star-input > i.star) {
    display: inline-block;
    width: 26px;
    height: 26px;
    margin: 0;
    background: url(/i/star.svg) no-repeat center center;
    background-size: contain;
    filter: grayscale(1) brightness(1.2);
    transition: all .2s linear;
  }
  :global(.star-input > i.star.active) {
    filter: none;
  }
</style>