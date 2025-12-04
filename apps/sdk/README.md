# Pozmixal NodeJS SDK

This is the NodeJS SDK for [Pozmixal](https://pozmixal.com).

You can start by installing the package:

```bash
npm install @pozmixal/node
```

## Usage
```typescript
import Pozmixal from '@pozmixal/node';
const pozmixal = new Pozmixal('your api key', 'your self-hosted instance (optional)');
```

The available methods are:
- `post(posts: CreatePostDto)` - Schedule a post to Pozmixal
- `postList(filters: GetPostsDto)` - Get a list of posts
- `upload(file: Buffer, extension: string)` - Upload a file to Pozmixal
- `integrations()` - Get a list of connected channels
- `deletePost(id: string)` - Delete a post by ID

Alternatively you can use the SDK with curl, check the [Pozmixal API documentation](https://docs.pozmixal.com/public-api) for more information.