---
title: Qué es esto?
permalink: /about/
layout: page
comments: false
---

Esto podría resumirse en un cementerio de textos que de vez en cuando (de año en año) actualizo, abandono, actualizo, abandono, etc.

No es la primera vez que monto algo así, ni será la última. Por eso, para mi yo del futuro, voy a dejar unas premisas, unos _por qués_, y unos _cómos_ para no reinventar la rueda ni recorrer caminos ya andados (y fallidos).

## Contacto

Lo primero, cómo puedes encontrarme:

- [correo@sergio.am](mailto:correo@sergio.am?subject=sergio.am), es lo más cómodo, el tradicional email.
- [Telegram](https://t.me/sxergio), ahí seguro que también lo veo.

Así de simple, cualquier otro método seguramente pierda el mensaje.

## Premisas

Este sitio tiene como objetivo:

- documentar
- explicar
- recordar

...cosas que voy descubriendo, trasteando o montando para mi día a día.

Y todo ello tiene que ser:

- sencillo
- mantenible
- portable
- autosuficiente

## Por qué

He tenido muchos por qué, pero a día de hoy es simplemente por recordar a futuro cómo he hecho alguna cosa. Todo lo que hago suele ser un mix de cosas que busco, aprendo y experimento, y cuando pasa el tiempo se me olvida el camino recorrido.

Así que a veces necesito un rinconcito donde anotarme cosas, y si encima sirven para que otra persona, mejor. Al igual que me han servidor a mi los textos de otros, es una pqueña forma de devolver el favor.

## Cómo

Ya tengo una edad donde no me apetece recordar cómo he montado las cosas básicas, por lo cada vez lo simplifico y recorto más.

Actualmente es tan sencillo como escribir unos `.md` y con un script muy sencillo los convierto a `.html` con [pandoc](https://pandoc.org/). YA ESTÁ.

Lo textos los edito via terminal, o con el editor de turno, o directamente desde [Gitea](https://github.com/go-gitea/gitea). Según me de o dónde me pille. En el fondo es un repo de Git con un puñado de archivos. Con un simple `post-hook` reconstruyo el sitio y ya.

Y poco más, todo esto puedo luego publicarlo desde un simple nginx, sitios como GitHub Pages o Cloudflare, una RasPi, da igual. Son archivos estáticos que se sirven hasta por señales de humo.
