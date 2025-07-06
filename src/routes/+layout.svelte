<script lang="ts">
  import "../app.scss";

  let { children } = $props();
</script>

{@render children()}

<style>
  :global(body) {
    font-size: 16px;
  }
</style>
