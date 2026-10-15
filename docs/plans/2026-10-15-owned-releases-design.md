# Show only owned repositories in Latest Releases

The README generator currently considers all public repositories accessible to the authenticated GitHub user, including organization repositories. Limit `get_latest_releases` to repositories whose owner login matches the authenticated user's login, before requesting each repository's latest release. Keep the existing date sort and result limit. This excludes SupernormalCo and other organizations without maintaining a blocklist.

Remove the stale organization release from the checked-in README. Verify the owner filter with an owned repo and an organization repo, ensuring the latter's release is never fetched. Do not run the full generator just to update this section: it calls external APIs and rewrites unrelated README sections.
