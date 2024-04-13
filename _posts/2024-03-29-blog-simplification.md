---
title:  "Simplificando el blog, aun más"
---

El otro día fui a escribir un post y resulta que [Jekyll](https://jekyllrb.com/) no montaba el sitio por no séquépaquete desactualizado por la versión de ruby nosequé. Excusa perfecta para deshacerme de ello y simplificar más aun esto.

Como prácticamente esto son 4 `.md` mal contados, por poco pensé "mira, los publico tal cual", pero con una búsqueda rápida descubrí [pandoc](https://pandoc.org/), un simple conversor, entre ellos de `.md` a `.html`. PERFECTO.

Así que he creado [un script básico](https://sergio.am/code/sergio.am/src/branch/main/build.sh) para pasar todos los Markdown a HTML, y he cambiado el [CI/CD](https://sergio.am/code/sergio.am/src/branch/main/.drone.yml).

Además, para no cambiar nada más, he seguido el formato de Jekyll en la medida de lo posible.

Igual a futuro añado más cosas, pero algo me dice que de hecho quitaré algo. Tags? _pa qué_, RSS? Tal vez... (alguien lo usa???), comentario? nah... que me manden [un mail](/about.html). Y ojo que igual hasta quito el CSS, es lo que más tiempo me ha llevado y casi casi me lo cepillo.

En fin, por eso, que más sencillo aun.
