#! /bin/bash

set -x

rm -rf _site-tmp
mkdir -p _site-tmp
touch _site-tmp/index.md
buildDate="$(date '+%d %b %Y')"

# $1=file $2=add to index
convert_md_to_html() {
    ls -la "$1"
    fileName=$(basename "${1%.*}")
    postDate=$(date '+%d %b %Y' -d "$(stat -c %y "$1" | awk '{print $1}')")
    bodyClass="page"

    if [ $2 -eq 1 ]; then
        bodyClass="post"
        echo "- [$(pandoc --template=pandoc-metadata.json "$1" | jq -r .title)](/$fileName.html) _${postDate}_" >> _site-tmp/index.md
    fi

    pandoc --template=tpl-layout.html --highlight-style=zenburn --metadata buildDate="$buildDate" --metadata postDate="$postDate" --metadata bodyClass="$bodyClass" -f markdown -t html5 "$1" > _site-tmp/"$fileName".html
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
echo "$(tac _site-tmp/index.md)" > _site-tmp/index.md
pandoc --template=tpl-layout.html --metadata isIndex=1 --metadata buildDate="$buildDate" --metadata bodyClass="index" -f markdown -t html5 _site-tmp/index.md > _site-tmp/index.html

# static files
cp -r static _site-tmp/static
cp -r assets _site-tmp/assets
cp -r root/* _site-tmp/
# concat css
cat static/reset.css static/styles.css > _site-tmp/static/css.css

rm -rf _site
mv _site-tmp _site
