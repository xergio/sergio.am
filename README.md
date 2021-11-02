
# sergio.am

Notas y apuntes, futuro contenido de static pages en sergio.am

```shell
docker run --rm --volume="$PWD:/srv/jekyll" --volume="$PWD/vendor/bundle:/usr/local/bundle" -it jekyll/jekyll:3.8 jekyll build
docker run --rm --volume="$PWD:/srv/jekyll" --volume="$PWD/vendor/bundle:/usr/local/bundle" -p 4000:4000 -it jekyll/jekyll:3.8 jekyll serve --watch
```

```shell
cd _site
python3 -m http.server 4000
```

http://localhost:4000
