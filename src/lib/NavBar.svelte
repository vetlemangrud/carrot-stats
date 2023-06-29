<script>
	import { page } from '$app/stores';
	import { signIn, signOut } from '@auth/sveltekit/client';
	import {
		Avatar,
		Button,
		Dropdown,
		DropdownDivider,
		DropdownHeader,
		DropdownItem,
		NavBrand,
		NavHamburger,
		Navbar
	} from 'flowbite-svelte';
</script>

<Navbar let:hidden let:toggle>
	<NavBrand>🥕 Carrot Stats</NavBrand>
	<div class="flex md:order-2">
		{#if $page.data.session}
			{#if $page.data.session.user?.image}
				<Avatar id="user-drop" src={$page.data.session.user.image} class="cursor-pointer" />
			{/if}
			<Dropdown triggeredBy="#user-drop">
				<DropdownHeader>
					<span class="block text-sm"> {$page.data.session.user?.name ?? 'User'} </span>
				</DropdownHeader>
				<DropdownItem>Dashboard</DropdownItem>
				<DropdownItem>Settings</DropdownItem>
				<DropdownItem>Earnings</DropdownItem>
				<DropdownDivider />
				<DropdownItem>Sign out</DropdownItem>
			</Dropdown>
			<button on:click={() => signOut()} class="button">Sign out</button>
		{:else}
			<Button on:click={() => signIn('github')} size="sm">Sign in</Button>
		{/if}
		<NavHamburger on:click={toggle} />
	</div>
</Navbar>
