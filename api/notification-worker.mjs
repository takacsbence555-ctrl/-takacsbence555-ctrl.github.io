// Inert until operator-approved secure server configuration. No scheduler is configured.
import runtime from '../server/notification-runtime.cjs';
export async function POST(request){return runtime.createNotificationHandlers().worker(request);}
