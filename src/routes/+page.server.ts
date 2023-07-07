import moment from 'moment';
import prisma from '../util/prisma';
import { fail } from '@sveltejs/kit';

export async function load() {
	const lastCarrot = await prisma.carrot.findFirst({
		orderBy: { timestamp: 'desc' },
		where: { devourer: { email: 'vmangrud@gmail.com' } }
	});
	const timeDiff = lastCarrot ? moment(lastCarrot?.timestamp).fromNow() : 'an eternity ago';
	return { timeDiff };
}
export const actions = {
	default: async (event) => {
		const session = await event.locals.getSession();
		if (!session || !session.user?.email) {
			return fail(403);
		}
		await prisma.carrot.create({
			data: {
				devourer: { connect: { email: session.user.email } }
			}
		});
	}
};
