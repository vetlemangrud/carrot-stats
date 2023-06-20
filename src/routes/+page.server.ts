import moment from 'moment';
import prisma from '../lib/prisma';

export async function load() {
	const lastCarrot = await prisma.carrot.findFirst({ orderBy: { timestamp: 'desc' } });
	const timeDiff = lastCarrot ? moment(lastCarrot?.timestamp).fromNow() : 'an eternity ago';
	return { timeDiff };
}
