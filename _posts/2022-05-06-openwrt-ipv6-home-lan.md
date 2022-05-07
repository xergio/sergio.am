---
layout: post
title:  "Conectividad IPv6 sobre túnel WireGuard y OpenWRT"
---
Primer post, sin mucho que contar para variar. Al menos habrá un bonito _commit_ y muchas cosas por limpiar.

La chuleta para hacer andar esto es la siguiente:

```shell
docker run -it --rm --volume="$PWD:/srv/jekyll:Z" jekyll/jekyll jekyll build
docker run -it --rm --volume="$PWD:/srv/jekyll:Z" -p 4000:4000 jekyll/jekyll jekyll serve
```

O bien, si ya está _buildeado_:

```shell
cd _site
python3 -m http.server 4000
```

Y acceder a <http://localhost:4000>. Así de simple por ahora.
