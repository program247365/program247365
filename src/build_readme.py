import os
import re
import json
import requests
import feedparser
from datetime import datetime, timedelta
from dateutil import parser
from github import Github
import random
import time

# Initialize
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
g = Github(GITHUB_TOKEN)
user = g.get_user()

# Optional API keys
SPOTIFY_CLIENT_ID = os.environ.get("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.environ.get("SPOTIFY_CLIENT_SECRET")

class ProgressTracker:
    def __init__(self):
        self.steps = []
        self.current_step = 0
        self.start_time = None
    
    def add_step(self, description):
        """Add a step to the progress tracker"""
        self.steps.append(description)
    
    def list_steps(self):
        """List all steps that will be executed"""
        print("🚀 README Builder - Execution Plan")
        print("=" * 50)
        for i, step in enumerate(self.steps, 1):
            print(f"{i:2d}. {step}")
        print("=" * 50)
        print()
    
    def start(self):
        """Start the progress tracking"""
        self.start_time = time.time()
        print("⏱️  Starting execution...\n")
    
    def next_step(self, description=None):
        """Move to the next step and show progress"""
        self.current_step += 1
        if description:
            step_desc = description
        else:
            step_desc = self.steps[self.current_step - 1]
        
        elapsed = time.time() - self.start_time
        print(f"✅ [{self.current_step:2d}/{len(self.steps)}] {step_desc} (⏱️  {elapsed:.1f}s)")
    
    def complete(self):
        """Mark the process as complete"""
        total_time = time.time() - self.start_time
        print(f"\n🎉 All steps completed in {total_time:.1f} seconds!")

# Initialize progress tracker
progress = ProgressTracker()

def get_latest_releases(num=5):
    """Get latest releases from your repositories"""
    releases = []
    
    for repo in user.get_repos():
        if repo.private:
            continue
            
        try:
            latest_release = repo.get_latest_release()
            if latest_release:
                releases.append({
                    'name': repo.name,
                    'url': latest_release.html_url,
                    'description': latest_release.title or latest_release.tag_name,
                    'created_at': latest_release.created_at
                })
        except:
            pass
    
    # Sort by date and get latest
    releases.sort(key=lambda x: x['created_at'], reverse=True)
    return releases[:num]

def get_latest_commits(num=5):
    """Get latest commits from public repositories"""
    commits = []
    
    for repo in user.get_repos():
        if repo.private:
            continue
            
        try:
            repo_commits = repo.get_commits()
            for commit in repo_commits[:1]:  # Just latest from each repo
                commits.append({
                    'repo': repo.name,
                    'message': commit.commit.message.split('\n')[0],
                    'url': commit.html_url,
                    'date': commit.commit.author.date
                })
        except:
            pass
    
    commits.sort(key=lambda x: x['date'], reverse=True)
    return commits[:num]

def get_blog_posts(feed_url='https://kbr.sh/rss/', num=5):
    """Fetch latest blog posts from RSS feed"""
    try:
        feed = feedparser.parse(feed_url)
        posts = []
        
        for entry in feed.entries[:num]:
            posts.append({
                'title': entry.title,
                'url': entry.link,
                'date': parser.parse(entry.published).strftime('%b %d, %Y')
            })
        
        return posts
    except:
        return []

def get_github_stats():
    """Get GitHub statistics"""
    stats = {
        'public_repos': user.public_repos,
        'followers': user.followers,
        'following': user.following,
        'public_gists': user.public_gists
    }
    
    # Calculate total stars
    total_stars = sum(repo.stargazers_count for repo in user.get_repos() if not repo.private)
    stats['total_stars'] = total_stars
    
    # Get language stats
    languages = {}
    for repo in user.get_repos():
        if repo.private:
            continue
        
        repo_languages = repo.get_languages()
        for lang, bytes_count in repo_languages.items():
            languages[lang] = languages.get(lang, 0) + bytes_count
    
    # Get top 5 languages
    top_languages = sorted(languages.items(), key=lambda x: x[1], reverse=True)[:5]
    stats['top_languages'] = [lang[0] for lang in top_languages]
    
    # Calculate contribution stats
    stats['total_commits'] = sum(repo.get_commits().totalCount for repo in user.get_repos() if not repo.private)
    
    return stats

def get_featured_projects():
    """Get featured projects with more details"""
    featured = []
    
    # Define featured repos
    featured_repos = ['hackertuah', 'tailwindcss-now', 'dotfiles', 'random-quotes']
    
    for repo_name in featured_repos:
        try:
            repo = user.get_repo(repo_name)
            featured.append({
                'name': repo.name,
                'description': repo.description,
                'stars': repo.stargazers_count,
                'forks': repo.forks_count,
                'language': repo.language,
                'url': repo.html_url
            })
        except:
            pass
    
    return featured

def get_coding_stats():
    """Generate coding activity stats"""
    # This would integrate with WakaTime or similar service
    # For now, return mock data based on recent commits
    
    now = datetime.now()
    week_ago = now - timedelta(days=7)
    
    weekly_commits = 0
    for repo in user.get_repos():
        if repo.private:
            continue
        try:
            commits = repo.get_commits(since=week_ago)
            weekly_commits += sum(1 for _ in commits)
        except:
            pass
    
    return {
        'weekly_commits': weekly_commits,
        'daily_average': round(weekly_commits / 7, 1)
    }

def get_random_greeting():
    """Get a random greeting based on time of day"""
    hour = datetime.now().hour
    
    if 5 <= hour < 12:
        greetings = ["Good morning!", "Rise and shine!", "Morning, fellow developer!"]
    elif 12 <= hour < 17:
        greetings = ["Good afternoon!", "Hope you're having a great day!", "Afternoon vibes!"]
    elif 17 <= hour < 22:
        greetings = ["Good evening!", "Evening, coder!", "Hope you had a productive day!"]
    else:
        greetings = ["Hello, night owl!", "Burning the midnight oil?", "Late night coding session?"]
    
    return random.choice(greetings)

def format_featured_projects(projects):
    """Format featured projects as a grid"""
    if not projects:
        return ""
    
    markdown = '<p align="center">\n'
    
    for i, project in enumerate(projects):
        if i % 2 == 0 and i > 0:
            markdown += '</p>\n<p align="center">\n'
        
        markdown += f'''  <a href="{project['url']}">
    <img src="https://github-readme-stats.vercel.app/api/pin/?username=program247365&repo={project['name']}&theme=tokyonight" alt="{project['name']}" />
  </a>\n'''
    
    markdown += '</p>\n'
    return markdown

def replace_content(content, marker, replacement):
    """Replace content between markers"""
    pattern = f"<!-- {marker} starts -->.*<!-- {marker} ends -->"
    replacement_content = f"<!-- {marker} starts -->\n{replacement}\n<!-- {marker} ends -->"
    return re.sub(pattern, replacement_content, content, flags=re.DOTALL)

def main():
    # Define all steps
    progress.add_step("Read README template file")
    progress.add_step("Fetch latest GitHub releases")
    progress.add_step("Fetch latest GitHub commits")
    progress.add_step("Fetch blog posts from RSS feed")
    progress.add_step("Calculate GitHub statistics")
    progress.add_step("Get featured projects")
    progress.add_step("Calculate coding activity stats")
    progress.add_step("Generate random greeting")
    progress.add_step("Format all data sections")
    progress.add_step("Update README content")
    progress.add_step("Write updated README to file")
    
    # List all steps first
    progress.list_steps()
    
    # Start execution
    progress.start()
    
    # Step 1: Read template
    progress.next_step()
    with open('templates/README_TEMPLATE.md', 'r') as f:
        readme = f.read()
    
    # Step 2: Get latest releases
    progress.next_step()
    releases = get_latest_releases()
    
    # Step 3: Get latest commits
    progress.next_step()
    commits = get_latest_commits()
    
    # Step 4: Get blog posts
    progress.next_step()
    blog_posts = get_blog_posts()
    
    # Step 5: Get GitHub stats
    progress.next_step()
    stats = get_github_stats()
    
    # Step 6: Get featured projects
    progress.next_step()
    featured = get_featured_projects()
    
    # Step 7: Get coding stats
    progress.next_step()
    coding_stats = get_coding_stats()
    
    # Step 8: Get random greeting
    progress.next_step()
    greeting = get_random_greeting()
    
    # Step 9: Format all data sections
    progress.next_step()
    
    # Format releases
    releases_md = ""
    if releases:
        for release in releases:
            releases_md += f"- 🚀 [{release['name']}]({release['url']}) - {release['description']}\n"
    else:
        releases_md = "- 🔜 No recent releases\n"
    
    # Format commits
    commits_md = ""
    for commit in commits[:5]:
        commit_date = commit['date'].strftime('%b %d')
        commits_md += f"- 💻 [{commit['repo']}]({commit['url']}) - {commit['message']} ({commit_date})\n"
    
    # Format blog posts
    blog_md = ""
    if blog_posts:
        blog_posts.sort(key=lambda x: parser.parse(x['date']), reverse=True)
        
        for post in blog_posts[:5]:
            blog_md += f"- 📝 [{post['title']}]({post['url']}) - {post['date']}\n"
    
    # Format stats
    stats_md = f"""
<p align="center">
  <img src="https://github-readme-stats.vercel.app/api?username=program247365&show_icons=true&theme=tokyonight&hide_border=true" alt="GitHub Stats" />
</p>

<p align="center">
  <img src="https://github-readme-streak-stats.herokuapp.com/?user=program247365&theme=tokyonight&hide_border=true" alt="GitHub Streak" />
</p>

<details>
<summary>📊 More Stats</summary>
<br>

- **Total Stars Earned:** {stats['total_stars']} ⭐
- **Total Commits (Public):** {stats['total_commits']} 
- **Followers:** {stats['followers']} 
- **Following:** {stats['following']}
- **Public Repositories:** {stats['public_repos']}
- **Public Gists:** {stats['public_gists']}
- **Top Languages:** {', '.join(stats['top_languages'][:3])}

</details>

### 📈 This Week's Coding Stats
- **Commits:** {coding_stats['weekly_commits']} total ({coding_stats['daily_average']} per day)
- **Most Active Language:** {stats['top_languages'][0] if stats['top_languages'] else 'N/A'}
"""
    
    # Format featured projects
    featured_md = format_featured_projects(featured)
    
    # Step 10: Update README content
    progress.next_step()
    readme = replace_content(readme, "greeting", greeting)
    readme = replace_content(readme, "recent_releases", releases_md)
    readme = replace_content(readme, "recent_commits", commits_md)
    readme = replace_content(readme, "recent_blog_posts", blog_md)
    readme = replace_content(readme, "github_stats", stats_md)
    readme = replace_content(readme, "featured_projects", featured_md)
    
    # Add last updated timestamp
    readme = replace_content(readme, "last_updated", 
                           f"*Last updated: {datetime.now().strftime('%B %d, %Y at %I:%M %p')} EST*")
    
    # Step 11: Write updated README
    progress.next_step()
    with open('README.md', 'w') as f:
        f.write(readme)
    
    # Complete the process
    progress.complete()
    print(f"📝 README updated successfully at {datetime.now().strftime('%B %d, %Y at %I:%M %p')} EST")

if __name__ == "__main__":
    main()
