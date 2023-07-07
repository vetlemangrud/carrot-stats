<script>
	import { enhance } from '$app/forms';
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
	<NavBrand href="/">🥕 Carrot Stats</NavBrand>
	<div class="flex md:order-2">
		{#if $page.data.session}
			<Avatar
				id="user-drop"
				src={$page.data.session.user?.image ?? undefined}
				class="cursor-pointer"
			/>
			<Dropdown triggeredBy="#user-drop">
				<DropdownHeader>
					<span class="block text-sm"> {$page.data.session.user?.name ?? 'User'} </span>
				</DropdownHeader>
				<form method="POST">
					<DropdownItem class="button" type="submit">Devour Carrot</DropdownItem>
				</form>
				<DropdownDivider />
				<DropdownItem on:click={() => signOut()} class="button">Sign out</DropdownItem>
			</Dropdown>
		{:else}
			<Button on:click={() => signIn('github')} size="sm">Sign in</Button>
		{/if}
	</div>
</Navbar>
