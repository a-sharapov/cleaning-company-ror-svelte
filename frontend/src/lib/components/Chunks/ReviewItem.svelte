<script>
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'

  export let item
</script>

<div class="review-item">
  {item.json()}
</div>