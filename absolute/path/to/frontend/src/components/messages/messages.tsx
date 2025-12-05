const loadMessages = useCallback(async () => {
    return await (await fetch(`/messages/${group}/${page}`, {
        headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`,
            'Content-Type': 'application/json'
        }
    })).json();
}, []);Frontend (4200) → Authenticated Request → Backend (3000)
    ↓ Returns messages data
Frontend renders messages
