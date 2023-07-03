import { SvelteKitAuth } from '@auth/sveltekit';
import GitHub from '@auth/core/providers/github';
import CredentialsProvider from '@auth/core/providers/credentials';
import { GITHUB_ID, GITHUB_SECRET } from '$env/static/private';
import { PrismaAdapter } from '@auth/prisma-adapter';
import prisma from './util/prisma';

export const handle = SvelteKitAuth({
	adapter: PrismaAdapter(prisma),
	providers: [
		GitHub({ clientId: GITHUB_ID, clientSecret: GITHUB_SECRET }),
		CredentialsProvider({
			async authorize() {
				// Add logic here to look up the user from the credentials supplied
				return { id: '1', name: 'Mr. Dev Man', email: 'mrdevman@example.com' };
			}
		})
	]
});
