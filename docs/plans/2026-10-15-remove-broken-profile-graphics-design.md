# Remove broken profile graphics

The contribution graph and trophies images in the checked-in README and its template both return HTTP 402 (`DEPLOYMENT_DISABLED`). Remove both sections from `README.md` and `templates/README_TEMPLATE.md` so scheduled generation cannot restore them. GitHub's native profile contribution graph remains available; no replacement image service is needed. Verify neither section nor either dead URL remains in the two files.
