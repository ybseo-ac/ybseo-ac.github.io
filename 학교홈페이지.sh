#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

school_destination="${HOME}/public_html"
if [[ ! -d "$school_destination" || ! -w "$school_destination" ]]; then
  echo "학교 홈페이지 폴더에 접근할 수 없습니다: $school_destination" >&2
  exit 1
fi

if command -v bundle3.3 >/dev/null 2>&1; then
  school_bundler=bundle3.3
else
  school_bundler=bundle
fi
command -v "$school_bundler" >/dev/null
command -v rsync >/dev/null

JEKYLL_ENV=production "$school_bundler" exec jekyll build --config _config.yml,_config.school.yml
test -s _site/index.html

# Keep backups outside the public website.
if [[ -f "$school_destination/index.html" ]]; then
  mkdir -p .bundle/school-backups
  school_backup="$(mktemp -d .bundle/school-backups/deploy.XXXXXX)"
  cp -p -- "$school_destination/index.html" "$school_backup/index.html"
  echo "기존 index.html 백업: $PWD/$school_backup/index.html"
fi

# Copy only after a successful build; preserve unrelated files on the server.
rsync -a --chmod=D755,F644 _site/ "$school_destination/"
echo "학교 홈페이지 반영 완료: https://www.cs.toronto.edu/~ybseo/"
