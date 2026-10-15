import importlib.util
import unittest
from datetime import datetime, timezone
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock, patch


class LatestReleasesTests(unittest.TestCase):
    def test_only_fetches_releases_from_owned_public_repositories(self):
        user = Mock(login="program247365")
        owned_release = SimpleNamespace(
            html_url="https://github.com/program247365/looper/releases/tag/v1",
            title="v1",
            tag_name="v1",
            created_at=datetime(2026, 10, 1, tzinfo=timezone.utc),
        )
        owned = Mock(private=False, owner=SimpleNamespace(login="program247365"))
        owned.name = "looper"
        owned.get_latest_release.return_value = owned_release
        organization = Mock(private=False, owner=SimpleNamespace(login="SupernormalCo"))
        private = Mock(private=True, owner=SimpleNamespace(login="program247365"))
        user.get_repos.return_value = [organization, private, owned]

        with patch("github.Github") as github:
            github.return_value.get_user.return_value = user
            spec = importlib.util.spec_from_file_location(
                "build_readme", Path(__file__).resolve().parents[1] / "src/build_readme.py"
            )
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

        releases = module.get_latest_releases()

        self.assertEqual([release["url"] for release in releases], [owned_release.html_url])
        organization.get_latest_release.assert_not_called()
        private.get_latest_release.assert_not_called()
        owned.get_latest_release.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()
