import feedparser
import json
from datetime import datetime

def sync_blog_posts():
    """Sync blog posts and create a JSON cache"""
    
    sources = [
        {'name': 'Personal Blog', 'url': 'https://kbr.sh/index.xml'},
        # Add more RSS feeds here
    ]
    
    all_posts = []
    
    for source in sources:
        try:
            feed = feedparser.parse(source['url'])
            for entry in feed.entries[:10]:
                post = {
                    'title': entry.title,
                    'url': entry.link,
                    'date': entry.published,
                    'source': source['name'],
                    'summary': entry.get('summary', '')[:200] + '...'
                }
                all_posts.append(post)
        except Exception as e:
            print(f"Error fetching {source['name']}: {e}")
    
    # Sort by date
    all_posts.sort(key=lambda x: x['date'], reverse=True)
    
    # Save to JSON
    with open('blog_posts.json', 'w') as f:
        json.dump(all_posts, f, indent=2)
    
    print(f"✅ Synced {len(all_posts)} blog posts")

if __name__ == "__main__":
    sync_blog_posts()
