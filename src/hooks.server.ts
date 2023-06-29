import { SvelteKitAuth } from '@auth/sveltekit';
import GitHub from '@auth/core/providers/github';
import CredentialsProvider from '@auth/core/providers/credentials';
import { GITHUB_ID, GITHUB_SECRET } from '$env/static/private';

export const handle = SvelteKitAuth({
	providers: [
		GitHub({ clientId: GITHUB_ID, clientSecret: GITHUB_SECRET }),
		CredentialsProvider({
			async authorize(credentials, req) {
				// Add logic here to look up the user from the credentials supplied
				return { id: '1', name: 'Mr. Dev Man', email: 'mrdevman@example.com' };
			}
		})
	]
});
