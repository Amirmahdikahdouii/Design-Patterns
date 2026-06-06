#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBSITE="$ROOT/website"
CONTENT="$WEBSITE/content"
STATIC_IMAGES="$WEBSITE/static/images"
BASE_URL_PATH="/Design-Patterns"

rm -rf "$CONTENT" "$STATIC_IMAGES"
mkdir -p "$CONTENT/docs" "$STATIC_IMAGES/shared"

to_slug() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
}

category_slug() {
  local dir="$1"
  case "$dir" in
    Creational-Patterns) echo "creational" ;;
    Structural-Patterns) echo "structural" ;;
    Behavioral-Patterns) echo "behavioral" ;;
    *) echo "$(to_slug "$dir" | sed 's/-patterns$//')" ;;
  esac
}

extract_title() {
  local file="$1"
  sed -n 's/^# //p' "$file" | head -n 1
}

write_front_matter() {
  local title="$1"
  local weight="$2"
  local source_path="${3:-}"
  local collapse="${4:-}"

  cat <<EOF
---
title: "$title"
weight: $weight
EOF
  if [[ -n "$source_path" ]]; then
    echo "source_path: \"$source_path\""
  fi
  if [[ -n "$collapse" ]]; then
    echo "bookCollapseSection: $collapse"
  fi
  echo "---"
  echo
}

rewrite_links_with_python() {
  python3 - "$1" "$2" <<'PY'
import re
import sys

path, image_prefix = sys.argv[1], sys.argv[2]
base = "/Design-Patterns"

def slug(name: str) -> str:
    return name.lower().replace("_", "-")

with open(path, encoding="utf-8") as f:
    text = f.read()

text = re.sub(
    r"\]\(\./assets/([^)]+)\)",
    lambda m: f"]({base}/images/{image_prefix}{m.group(1)})",
    text,
)

for category, section in [
    ("Creational-Patterns", "creational"),
    ("Structural-Patterns", "structural"),
    ("Behavioral-Patterns", "behavioral"),
]:
    text = re.sub(
        rf"\]\(\./{re.escape(category)}/([^/)]+)/README\.md\)",
        lambda m, section=section: f"](/docs/{section}/{slug(m.group(1))}/)",
        text,
    )

text = text.replace("](./README.md)", "](/)")
text = text.replace("](./docs/fundamentals/)", "](/docs/fundamentals/)")

print(text, end="")
PY
}

split_root_readme() {
  local home_file="$1"
  local fundamentals_file="$2"

  python3 - "$ROOT/README.md" "$home_file" "$fundamentals_file" <<'PY'
import sys

readme, home_file, fundamentals_file = sys.argv[1:4]
with open(readme, encoding="utf-8") as f:
    lines = f.readlines()

split_at = None
for i, line in enumerate(lines):
    if line.strip() == "## OOP basics":
        split_at = i
        break

if split_at is None:
    raise SystemExit("Could not find '## OOP basics' section in README.md")

with open(home_file, "w", encoding="utf-8") as f:
    f.write("".join(lines[:split_at]).rstrip() + "\n")

with open(fundamentals_file, "w", encoding="utf-8") as f:
    f.write("".join(lines[split_at:]).rstrip() + "\n")
PY
}

copy_assets() {
  local src_dir="$1"
  local dest_dir="$2"
  if [[ -d "$src_dir" ]]; then
    mkdir -p "$dest_dir"
    cp -r "$src_dir/." "$dest_dir/"
  fi
}

append_pattern_links() {
  local section="$1"
  local category_dir="$2"
  local buffer="$3"

  if [[ ! -d "$ROOT/$category_dir" ]]; then
    return
  fi

  {
    echo ""
    echo "### $(echo "$section" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Patterns"
    echo ""
  } >> "$buffer"

  local pattern
  while IFS= read -r pattern; do
    local name slug title
    name="$(basename "$pattern")"
    slug="$(to_slug "$name")"
    title="$(extract_title "$pattern/README.md")"
    echo "- [$title](/docs/$section/$slug/)" >> "$buffer"
  done < <(find "$ROOT/$category_dir" -mindepth 1 -maxdepth 1 -type d | sort)
}

HOME_BUFFER="$(mktemp)"
FUNDAMENTALS_BUFFER="$(mktemp)"
trap 'rm -f "$HOME_BUFFER" "$FUNDAMENTALS_BUFFER"' EXIT

split_root_readme "$HOME_BUFFER" "$FUNDAMENTALS_BUFFER"

if ! grep -q "### Structural Patterns" "$HOME_BUFFER"; then
  append_pattern_links "structural" "Structural-Patterns" "$HOME_BUFFER"
fi

mkdir -p "$CONTENT/docs/fundamentals"
{
  write_front_matter "Design Patterns" 1 "README.md"
  rewrite_links_with_python "$HOME_BUFFER" "shared/"
} > "$CONTENT/_index.md"

{
  write_front_matter "Fundamentals" 10 "README.md"
  rewrite_links_with_python "$FUNDAMENTALS_BUFFER" "shared/"
} > "$CONTENT/docs/fundamentals/_index.md"

copy_assets "$ROOT/assets" "$STATIC_IMAGES/shared"

declare -A SECTION_INTROS=(
  [creational]="Creational patterns provide various object creation mechanisms, which increase flexibility and reuse of existing code."
  [structural]="Structural patterns explain how to assemble objects and classes into larger structures, while keeping these structures flexible and efficient."
  [behavioral]="Behavioral patterns take care of effective communication and the assignment of responsibilities between objects."
)

declare -A SECTION_WEIGHT=(
  [creational]=20
  [structural]=30
  [behavioral]=40
)

for category_dir in "$ROOT"/*-Patterns; do
  [[ -d "$category_dir" ]] || continue

  category_name="$(basename "$category_dir")"
  section="$(category_slug "$category_name")"
  section_weight="${SECTION_WEIGHT[$section]:-50}"

  mkdir -p "$CONTENT/docs/$section"

  intro="${SECTION_INTROS[$section]:-}"
  {
    write_front_matter "$(echo "$section" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') Patterns" "$section_weight" "" "false"
    if [[ -n "$intro" ]]; then
      echo "$intro"
      echo
    fi
  } > "$CONTENT/docs/$section/_index.md"

  weight=10
  while IFS= read -r pattern_dir; do
    readme="$pattern_dir/README.md"
    [[ -f "$readme" ]] || continue

    pattern_name="$(basename "$pattern_dir")"
    slug="$(to_slug "$pattern_name")"
    title="$(extract_title "$readme")"
    source_path="${category_name}/${pattern_name}/README.md"
    image_prefix="${section}/${slug}/"

    mkdir -p "$CONTENT/docs/$section/$slug"
    {
      write_front_matter "$title" "$weight" "$source_path"
      rewrite_links_with_python "$readme" "$image_prefix"
    } > "$CONTENT/docs/$section/$slug/_index.md"

    copy_assets "$pattern_dir/assets" "$STATIC_IMAGES/$image_prefix"
    weight=$((weight + 10))
  done < <(find "$category_dir" -mindepth 1 -maxdepth 1 -type d | sort)
done

echo "Synced content to $CONTENT"
echo "Synced images to $STATIC_IMAGES"
