<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'

  export let item
  export let width = "normal"
</script>

<div class="review-item" data-id="{item.slug}" data-width={width}>
  <span class="review-body">
    <span class="review-to-company">Отзыв о компании &laquo;{item.company_name}&raquo;</span>
    <span class="review-assessment" data-assessment="{item.assessment}">
      {item.assessment}
    </span>
    <span class="review-description">
      {item.description}
    </span>
  </span>
  <span class="review-author">
    <span class="review-smile" data-assessment="{item.assessment}"></span>
    {item.customer}, <span class="review-created-at">{new Date(item.created_at).toLocaleDateString("ru-RU")}</span>
  </span>
</div>

<style>
  .review-item {
    display: inline-block;
    margin: 0 10px 10px;
    width: calc(100% / 5 - 20px);
    text-align: left;
    vertical-align: top;
  }

  .review-item[data-width="full"] {
    width: calc(100% - 20px);
  }

  .review-body {
    position: relative;
    display: block;
    margin: 0 0 10px;
    background: #fff;
    padding: 10px;
    border-radius: 3px;
    border-bottom: 3px solid var(--mf-darkgray);
    box-shadow: 0px 5px 10px rgb(20 0 0 / 2%), 0px 15px 50px rgb(20 0 0 / 5%);
  }

  .review-body:before,
  .review-body:after {
      content: '';
      border: 10px solid transparent;
      position: absolute;
      left: 10px;
      bottom: -20px;
      transform: scale(.7, 1);
  }

  .review-body:before {
      bottom: -20px;
      border-top-color: var(--mf-darkgray);
      z-index: 1;
      transform: scale(.8, .9);
  }

  .review-body:after {
      border-top-color: #fff;
      bottom: -16px;
      z-index: 2;
  }

  .review-to-company,
  .review-assessment {
    display: block;
    white-space: nowrap;
    clear: both;
  }

  .review-to-company {
    overflow: hidden;
    text-overflow: ellipsis;
    font-weight: bold;
    font-size: 11px;
    color: #999;
  }

  .review-assessment {
    font-weight: bold;
    position: relative;
    padding-left: 105px;
    margin: 0 0 10px;
  }

  .review-assessment:before,
  .review-assessment:after {
    content: "";
    position: absolute;
    display:inline-block;
    height: 20px;
    width: 0;
    background: url(/i/star.svg) repeat-x center left;
    background-size: 20px;
    left: 0;
    top: 2px;
  }

  :global(.review-assessment:after) {
    filter: grayscale(1) brightness(1.2);
  }

  .review-assessment[data-assessment="5"]:before {
    width: 100px;
  }

  .review-assessment[data-assessment="4"]:before {
    width: 80px;
  }
  .review-assessment[data-assessment="4"]:after {
    left: 80px;
    width: 20px;
  }

  .review-assessment[data-assessment="3"]:before {
    width: 60px;
  }
  .review-assessment[data-assessment="3"]:after {
    width: 40px;
    left: 60px;
  }

  .review-assessment[data-assessment="2"]:before {
    width: 40px;
  }
  .review-assessment[data-assessment="2"]:after {
    width: 60px;
    left: 40px;
  }

  .review-assessment[data-assessment="1"]:before {
    width: 20px;
  }
  .review-assessment[data-assessment="1"]:after {
    width: 80px;
    left: 20px;
  }

  .review-created-at {
    font-size: 12px;
    color: #555;
    margin-top: 10px;
  }

  .review-author {
    height: 30px;
    line-height: 30px;
    font-weight: bold;
    font-size: 12px;
    color: #00000080;
    margin: 0 0 0 5px;
  }

  .review-smile {
    display: inline-block;
    vertical-align: middle;
    width: 30px;
    height: 30px;
    border-radius: 16px;
    background: #fff;
    margin: 0 5px 0 0;
    box-shadow: 0 1px 5px #00000030;
  }

  .review-smile[data-assessment="5"],
  .review-smile[data-assessment="4"] {
    background: #fff url(/i/smile-happy.svg) no-repeat center center;
    background-size: contain;
  }
  
  .review-smile[data-assessment="3"] {
    background: #fff url(/i/smile-neutral.svg) no-repeat center center;
    background-size: contain;
  }

  .review-smile[data-assessment="2"],
  .review-smile[data-assessment="1"] {
      background: #fff url(/i/smile-sad.svg) no-repeat center center;
      background-size: contain;
  }

  .review-description {
    display: block;
    margin: 10px 0 5px;
  }
</style>