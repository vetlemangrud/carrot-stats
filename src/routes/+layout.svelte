<script>
	import NavBar from '$lib/NavBar.svelte';

	// Finally, your application's global stylesheet (sometimes labeled 'app.css')
	import '../app.css';
</script>

<div class="h-screen flex flex-col justify-between">
	<NavBar />
	<slot />
	<footer>{' '}</footer>
</div>
