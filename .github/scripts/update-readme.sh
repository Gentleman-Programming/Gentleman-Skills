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
# Extract metadata from SKILL.md
# ============================================================================

extract_skill_name() {
    local skill_file="$1"
    # Try to get name from first H1 heading, fallback to folder name
    local name=$(grep -m1 "^# " "$skill_file" | sed 's/^# //' | sed 's/ Skill$//')
    if [ -z "$name" ]; then
        name=$(basename "$(dirname "$skill_file")")
    fi
    echo "$name"
}

extract_description() {
    local skill_file="$1"
    # Get the line after metadata that starts with ">" (the brief description)
    local desc=$(grep -m1 "^>" "$skill_file" | sed 's/^> //')
    if [ -z "$desc" ]; then
        desc="Community contributed skill"
    fi
    echo "$desc"
}

extract_author() {
    local skill_file="$1"
    # Look for "Author:" or "**Author**:" in the file
    local author=$(grep -i "author" "$skill_file" | head -1 | sed 's/.*@//' | sed 's/[^a-zA-Z0-9_-].*//' | head -c 50)
    if [ -z "$author" ]; then
        # Try to get from git blame
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
    
    # Find all SKILL.md files in community/
    for skill_dir in "$COMMUNITY_DIR"/*/; do
        if [ -d "$skill_dir" ]; then
            local skill_file="$skill_dir/SKILL.md"
            if [ -f "$skill_file" ]; then
                found_skills=true
                local folder_name=$(basename "$skill_dir")
                local name=$(extract_skill_name "$skill_file")
                local desc=$(extract_description "$skill_file")
                local author=$(extract_author "$skill_file")
                
                # Truncate description if too long
                if [ ${#desc} -gt 60 ]; then
                    desc="${desc:0:57}..."
                fi
                
                table+="| [$name](community/$folder_name) | $desc | @$author |\n"
            fi
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
    awk -v new_table="$new_table" '
    BEGIN { in_table = 0; printed = 0 }
    
    # Detect start of community skills section
    /^## Community Skills/ {
        print
        in_table = 1
        next
    }
    
    # If in community section, skip until we find the table header
    in_table == 1 && /^\| Skill \| Description \| Author/ {
        # Print new table
        printf "%s", new_table
        printed = 1
        # Skip old table rows
        while ((getline line) > 0) {
            if (line !~ /^\|/) {
                print line
                break
            }
        }
        in_table = 0
        next
    }
    
    # Print everything else
    { print }
    ' "$README_FILE" > "$tmp_file"
    
    # Replace original file
    mv "$tmp_file" "$README_FILE"
    
    echo "README.md updated successfully!"
}

# ============================================================================
# Main
# ============================================================================

echo "Scanning community skills..."
update_readme
echo "Done!"
