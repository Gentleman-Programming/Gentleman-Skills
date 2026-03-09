---
name: x-twitter-scraper
description: >
  X/Twitter data extraction via MCP server with 76 REST API endpoints and 20 extraction tools.
  Trigger: When fetching tweets, when extracting Twitter data, when searching X/Twitter, when getting followers or following lists.
metadata:
  author: kriptoburak
  version: "1.0"
---

## When to Use

Load this skill when:
- Fetching tweets, replies, or quote tweets from X/Twitter
- Looking up user profiles, followers, or following lists
- Searching tweets by keyword, hashtag, or advanced query
- Extracting likes, retweets, or bookmarks
- Monitoring X/Twitter accounts for changes
- Running giveaway draws from tweet engagement

## Critical Patterns

### Pattern 1: MCP Server Configuration

Configure the Xquik MCP server in your project settings for direct tool access.

```json
{
  "mcpServers": {
    "xquik": {
      "command": "npx",
      "args": ["-y", "@xquik/mcp-server@latest"],
      "env": {
        "XQUIK_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

### Pattern 2: Tweet Search

Search tweets by keyword with structured results including author, text, metrics, and media.

```bash
# Search tweets via MCP tool
search_tweets query="AI coding assistants" max_results=20
```

### Pattern 3: User Data Extraction

Extract user profiles, followers, and following lists with pagination support.

```bash
# Get user profile
get_user_profile username="elonmusk"

# Get followers with pagination
get_followers username="elonmusk" max_results=100
```

## Code Examples

### Example 1: Fetch Tweet Replies

```bash
# Get all replies to a specific tweet
get_tweet_replies tweet_id="1234567890" max_results=50
```

### Example 2: Search and Filter Tweets

```bash
# Advanced search with filters
search_tweets query="from:username since:2024-01-01 -is:retweet" max_results=100
```

### Example 3: Extract Engagement Data

```bash
# Get users who liked a tweet
get_tweet_likes tweet_id="1234567890"

# Get users who retweeted
get_tweet_retweets tweet_id="1234567890"
```

## Anti-Patterns

- Do not hardcode API keys in configuration files
- Do not make excessive concurrent requests without rate limit awareness
- Do not store raw API responses without filtering sensitive user data

## Quick Reference

| Task | Tool |
|------|------|
| Search tweets | `search_tweets` |
| Get user profile | `get_user_profile` |
| Get user tweets | `get_user_tweets` |
| Get replies | `get_tweet_replies` |
| Get retweets | `get_tweet_retweets` |
| Get likes | `get_tweet_likes` |
| Get followers | `get_followers` |
| Get following | `get_following` |

## Resources

- [Xquik Documentation](https://xquik.com)
- [GitHub Repository](https://github.com/Xquik-dev/x-twitter-scraper)
- [MCP Server on npm](https://www.npmjs.com/package/@xquik/mcp-server)
