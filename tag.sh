set -x
highest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
new_tag=$highest_tag
# Check if the latest commit is tagged
if git describe --exact-match HEAD >/dev/null 2>&1; then
    # Check if the tag is live tag MAJOR.MINOR.PATCH-devX
    if [ "$(echo "$highest_tag" | awk -F- '{print NF}')" -eq "2" ]; then
        echo "dev package has been already built"
        exit 1
    fi
else
    # the latest commit is not tagged
    if [ "$(echo "$highest_tag" | awk -F- '{print NF}')" -eq "1" ]; then
        # Tag is in the MAJOR.MINOR.PATCH format
        # Get the current highest PATCH number
        highest_patch=$(echo "$highest_tag" | awk -F. '{print $3}')
        # Get the current highest MINOR number
        highest_minor=$(echo "$highest_tag" | awk -F. '{print $2}')
        # Get the current highest MAJOR number
        highest_major=$(echo "$highest_tag" | awk -F. '{print $1}' | sort -rn | head -1)
        if [ "$highest_patch" -eq "99" ] && [ "$highest_minor" -eq "9" ]; then
            new_major=$((highest_major + 1))
            new_minor=0
            new_patch=0
        elif [ "$highest_patch" -eq "99" ]; then
            new_major=$highest_major
            new_minor=$((highest_minor + 1))
            new_patch=0
        else
            new_major=$highest_major
            new_minor=$highest_minor
            new_patch=$((highest_patch + 1))
        fi
        new_tag="$new_major.$new_minor.$new_patch-dev1"

    else
        # Tag is in the MAJOR.MINOR.PATCH-DEV format
        # Get the current dev value
        dev=$(echo "$highest_tag" | awk -F- '{print $2}')
        # Extract the numeric part of the dev
        dev_number=${dev##*[^0-9]}
        # Increase the number by 1
        new_dev_number=$((dev_number + 1))
        # Get the new tag
        new_tag="$major_minor_patch-dev$new_dev_number"
    fi
    # Push the new tag
    git tag -a "$new_tag" -m "$new_tag"
    git push origin "$new_tag"
fi
echo "new tag $new_tag"
set +x
