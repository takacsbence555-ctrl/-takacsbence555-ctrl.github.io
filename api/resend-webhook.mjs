// Signature validation uses original Web Request bytes before JSON parsing.
import runtime from '../server/notification-runtime.cjs';
export async function POST(request){return runtime.createNotificationHandlers().webhook(request);}
