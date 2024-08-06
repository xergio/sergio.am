#! /bin/bash

set -x

# bad start, we should build to a tmp dir
rm -rf _site
mkdir -p _site
touch _site/index.md
buildDate="$(date '+%d %b %Y')"

# $1=file $2=add to index
convert_md_to_html() {
    fileName=$(basename "${1%.*}")
    postDate=$(date '+%d %b %Y' -d "$(stat -c %y "$1" | awk '{print $1}')")
    bodyClass="page"

    if [ $2 -eq 1 ]; then
        bodyClass="post"
        echo "- [$(pandoc --template=pandoc-metadata.json "$1" | jq -r .title)](/$fileName.html) _${postDate}_" >> _site/index.md
    fi

    pandoc --template=tpl-layout.html --highlight-style=zenburn --metadata buildDate="$buildDate" --metadata postDate="$postDate" --metadata bodyClass="$bodyClass" -f markdown -t html5 "$1" > _site/"$fileName".html
}

# posts
for post in _posts/*.md; do
    convert_md_to_html "$post" 1
done

# drafts
if [ $# -eq 1 ]; then
    for post in _drafts/*.md; do
        convert_md_to_html "$post" 1
    done
fi

# pages
for post in ./*.md; do
    convert_md_to_html "$post" 0
done

# index
# is there a better way to invert the file?
echo "$(tac _site/index.md)" > _site/index.md
pandoc --template=tpl-layout.html --metadata isIndex=1 --metadata buildDate="$buildDate" --metadata bodyClass="index" -f markdown -t html5 _site/index.md > _site/index.html

# static files
cp -r static _site/static
cp -r assets _site/assets
cp -r root/* _site/
# concat css
cat static/reset.css static/styles.css > _site/static/css.css
