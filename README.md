
# sergio.am

Notas y apuntes, futuro contenido de static pages en sergio.am

```shell
docker run -it --rm --volume="$PWD:/srv/jekyll:Z" jekyll/jekyll jekyll build
docker run -it --rm --volume="$PWD:/srv/jekyll:Z" -p 4000:4000 jekyll/jekyll jekyll serve
```

```shell
cd _site
python3 -m http.server 4000
```

http://localhost:4000
