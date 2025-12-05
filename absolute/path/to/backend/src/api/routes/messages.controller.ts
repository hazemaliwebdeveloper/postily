@Controller('/messages')
export class MessagesController {
    // ... existing code ...

    @Get('/health')
    healthCheck() {
        return { status: 'OK', message: 'Messages endpoint is active' };
    }
}