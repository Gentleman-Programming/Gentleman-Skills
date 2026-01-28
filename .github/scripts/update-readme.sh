#!/bin/bash
# ============================================================================
# Update README with Community Skills
# ============================================================================
# This script scans community/ folder and updates the README.md table
# with all community skills found.
#
# Called by GitHub Actions when a new community skill is merged.
# ============================================================================

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README_FILE="$REPO_ROOT/README.md"
COMMUNITY_DIR="$REPO_ROOT/community"

# ============================================================================
# Extract metadata from SKILL.md (YAML frontmatter)
# ============================================================================

extract_skill_name() {
    local skill_file="$1"
    # Get name from YAML frontmatter
    local name=$(sed -n '/^---$/,/^---$/p' "$skill_file" | grep "^name:" | sed 's/^name:[[:space:]]*//')
    if [ -z "$name" ]; then
        # Fallback to folder name
        name=$(basename "$(dirname "$skill_file")")
    fi
    echo "$name"
}

extract_description() {
    local skill_file="$1"
    # Extract description from YAML frontmatter (handles multi-line with >)
    # Get everything between description: and the next key (metadata:, ---, or other key:)
    local desc=$(sed -n '/^---$/,/^---$/p' "$skill_file" | \
        awk '/^description:/{found=1; sub(/^description:[[:space:]]*>?[[:space:]]*/, ""); if(length>0) print; next}
             found && /^[a-zA-Z_-]+:/{exit}
             found && /^---$/{exit}
             found{gsub(/^[[:space:]]+/, ""); print}' | \
        tr '\n' ' ' | sed 's/[[:space:]]*$//' | sed 's/[[:space:]]\+/ /g')

    if [ -z "$desc" ]; then
        desc="Community contributed skill"
    fi

    # Remove "Trigger:" part if present (keep only the main description)
    desc=$(echo "$desc" | sed 's/[[:space:]]*Trigger:.*$//')

    echo "$desc"
}

extract_author() {
    local skill_file="$1"
    # Get author from metadata.author in YAML frontmatter
    local author=$(sed -n '/^---$/,/^---$/p' "$skill_file" | \
        grep "^[[:space:]]*author:" | head -1 | sed 's/.*author:[[:space:]]*//' | sed 's/[[:space:]]*$//')

    if [ -z "$author" ]; then
        # Fallback to git log
        author=$(git log --format='%an' -1 -- "$skill_file" 2>/dev/null || echo "Community")
    fi
    echo "$author"
}

# ============================================================================
# Generate community skills table
# ============================================================================

generate_community_table() {
    local table="| Skill | Description | Author |\n"
    table+="|-------|-------------|--------|\n"

    local found_skills=false

    # Find all SKILL.md files in community/ and sort alphabetically
    for skill_dir in $(find "$COMMUNITY_DIR" -maxdepth 1 -type d ! -name community | sort); do
        local skill_file="$skill_dir/SKILL.md"
        if [ -f "$skill_file" ]; then
            found_skills=true
            local folder_name=$(basename "$skill_dir")
            local name=$(extract_skill_name "$skill_file")
            local desc=$(extract_description "$skill_file")
            local author=$(extract_author "$skill_file")

            # Truncate description if too long
            if [ ${#desc} -gt 80 ]; then
                desc="${desc:0:77}..."
            fi

            table+="| [$name](community/$folder_name) | $desc | @$author |\n"
        fi
    done

    if [ "$found_skills" = false ]; then
        table+="| *Coming soon* | Be the first to contribute! | - |\n"
    fi

    echo -e "$table"
}

# ============================================================================
# Update README.md
# ============================================================================

update_readme() {
    local new_table=$(generate_community_table)

    # Create a temporary file
    local tmp_file=$(mktemp)

    # Use awk to replace the community skills table
    # Matches tables with 3 OR 4 columns (handles legacy format with Votes column)
    awk -v new_table="$new_table" '
    BEGIN { in_section = 0; table_replaced = 0 }

    # Detect start of community skills section
    /^## Community Skills/ {
        print
        in_section = 1
        next
    }

    # In community section, look for table header
    in_section == 1 && /^\| Skill \| Description \| Author/ {
        # Print new table (without trailing newline since printf handles it)
        printf "%s", new_table
        table_replaced = 1
        # Skip old table rows (including header separator)
        while ((getline line) > 0) {
            if (line !~ /^\|/) {
                # Print blank line before next section, then the line we read
                print ""
                print line
                break
            }
        }
        in_section = 0
        next
    }

    # Print everything else
    { print }

    END {
        if (table_replaced == 0) {
            print "WARNING: Could not find Community Skills table to update" > "/dev/stderr"
        }
    }
    ' "$README_FILE" > "$tmp_file"

    # Replace original file
    mv "$tmp_file" "$README_FILE"

    echo "README.md updated successfully!"
}

# ============================================================================
# Main
# ============================================================================

echo "Scanning community skills..."
echo "Found directories in community/:"
ls -la "$COMMUNITY_DIR" || true
echo ""

update_readme
echo "Done!"
