<script lang="ts">
  import { base } from "$app/paths";
  import SdfCanvas from "$lib/sdf-canvas.svelte";

  type Link = { label: string; color: string; url: string; icon?: string };

  let links: Link[] = [
    {
      label: "GitHub",
      color: "#010409",
      url: "https://github.com/JanikHelbig",
      icon: "github.svg",
    },
    {
      label: "Bluesky",
      color: "#0a7aff",
      url: "https://bsky.app/profile/helbig.dev",
      icon: "bluesky.svg",
    },
    {
      label: "LinkedIn",
      color: "#0b66c3",
      url: "https://linkedin.com/in/janik-helbig",
      icon: "linkedin_white.png",
    },
      {
          label: "helbigjanik@gmail.com",
          color: "#808080",
          url: "mailto:helbigjanik@gmail.com",
          icon: "email.svg",
      }
  ];

  function yearsSince(year: number, month: number): number {
      return new Date(Date.now() - Date.UTC(year, month)).getUTCFullYear() - 1970;
  }
</script>

{#snippet linkButton(link: Link)}
    <a class="link" style:background-color={link.color} href={link.url}>
        {#if link.icon}
            <div class="link__icon" style:mask-image="url(icons/{link.icon})"></div>
        {/if}
        {link.label}
    </a>
{/snippet}

<div class="wrapper">
    <div class="wrapper__content">
        <SdfCanvas width="8rem" height="8rem" />
        <div>
            <h1>Hallo!</h1>
            <p>My name is Janik Helbig.</p>
            <p>I enjoy programming and game development, both professionally and recreationally.</p>
            <p>I have more than {yearsSince(2019, 6)} years of experience with Unity and C#, but have also dabbled in Godot, C++ and plenty of other technologies.</p>
            <p>My passion is making code <strong>go fast</strong> and <strong>look cool</strong>!</p>
            <div class="links">
                {#each links as link}
                    {@render linkButton(link)}
                {/each}
            </div>
        </div>
    </div>
</div>

<style lang="scss">
  @use "/src/app";

  .wrapper {
    display: flex;
    justify-content: center;
    align-items: center;

    min-height: 100vh;
    padding: 2rem;
  }

  .wrapper__content {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    align-items: center;
    width: auto;
    max-width: 700px;

    @media screen and (min-width: app.$breakpoint-md) {
      flex-direction: row;
    }
  }

  h1 {
    margin-top: 0;
  }

  .links {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    margin-top: 2rem;
  }

  .link {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 0.5rem;

    text-decoration: none;
    font-weight: 600;

    height: 2rem;
    padding: 0.5rem;

    color: var(--theme-color-white);
    border-radius: 0.125rem;

    &__icon {
      mask-size: contain;
      mask-repeat: no-repeat;
      background-color: var(--theme-color-white);
      height: 100%;
      aspect-ratio: 1/1;
    }
  }
</style>
