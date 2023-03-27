latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
new_tag=$latest_tag
# check if the repo has at least a tag
if [ -z "$latest_tag" ]; then
    echo "repository doesn't have any tags yet. Creating new one..."
    # Push the new tag
    new_tag="0.0.1-dev1"
    git tag -a "$new_tag" -m "$new_tag"
    git push origin "$new_tag"
# Check if the latest commit is tagged
elif $(git describe --exact-match HEAD >/dev/null 2>&1); then
    # Check if the tag is live tag MAJOR.MINOR.PATCH-devX
    if [ "$(echo "$latest_tag" | awk -F-dev '{print NF}')" -eq "2" ]; then
        echo "commit is already tagged with -devX, exiting..."
        exit 1
    else 
        # Tag in MAJOR.MINOR.PATCH
        echo "live tag detected. If package was built before this build will fail"
    fi
else
    # The latest commit is not tagged
    if [ "$(echo "$latest_tag" | awk -F-dev '{print NF}')" -eq "1" ]; then
        # Tag is in the MAJOR.MINOR.PATCH format
        # Get the current highest PATCH number
        current_patch=$(echo "$latest_tag" | awk -F. '{print $3}')
        # Get the current highest MINOR number
        current_minor=$(echo "$latest_tag" | awk -F. '{print $2}')
        # Get the current highest MAJOR number
        current_major=$(echo "$latest_tag" | awk -F. '{print $1}' | sort -rn | head -1)
        if [ "$current_patch" -ge "99" ] && [ "$current_minor" -ge "9" ]; then
            new_major=$((current_major + 1))
            new_minor=0
            new_patch=0
        elif [ "$current_patch" -ge "99" ]; then
            new_major=$current_major
            new_minor=$((current_minor + 1))
            new_patch=0
        else
            new_major=$current_major
            new_minor=$current_minor
            new_patch=$((current_patch + 1))
        fi
        new_tag="$new_major.$new_minor.$new_patch-dev1"

    else
        # Tag is in the MAJOR.MINOR.PATCH-DEV format
        # Get the current dev value
        dev=$(echo "$latest_tag" | awk -F-dev '{print $2}')
        # Extract the numeric part of the dev
        dev_number=${dev##*[^0-9]}
        # Increase the number by 1
        new_dev_number=$((dev_number + 1))
        # Get the new tag
        major_minor_patch=$(echo "$latest_tag" | awk -F-dev '{print $1}')
        new_tag="$major_minor_patch-dev$new_dev_number"
    fi
    # Push the new tag
    git tag -a "$new_tag" -m "$new_tag"
    git push origin "$new_tag"
fi
echo $new_tag
