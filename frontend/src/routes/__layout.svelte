<script>
  import Header from "$lib/components/Chunks/Header.svelte"
  import Footer from "$lib/components/Chunks/Footer.svelte"
</script>

<Header>
  
</Header>
<slot></slot>
<Footer>
  <svelte:fragment slot="footer-content"></svelte:fragment>
</Footer>