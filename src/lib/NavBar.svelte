<script>
	import { page } from '$app/stores';
	import { signIn, signOut } from '@auth/sveltekit/client';
	import { Button, NavBrand, NavHamburger, Navbar } from 'flowbite-svelte';
</script>

<Navbar let:hidden let:toggle>
	<NavBrand>🥕 Carrot Stats</NavBrand>
	<div class="flex md:order-2">
		{#if $page.data.session}
			{#if $page.data.session.user?.image}
				<span style="background-image: url('{$page.data.session.user.image}')" class="avatar" />
			{/if}
			<span class="signedInText">
				<small>Signed in as</small><br />
				<strong>{$page.data.session.user?.name ?? 'User'}</strong>
			</span>
			<button on:click={() => signOut()} class="button">Sign out</button>
		{:else}
			<Button on:click={() => signIn('github')} size="sm">Sign in</Button>
		{/if}
		<NavHamburger on:click={toggle} />
	</div>
</Navbar>
