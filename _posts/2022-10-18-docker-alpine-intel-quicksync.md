---
layout: post
title:  "Aceleración de hardware (Quick Sync de Intel) en docker con Alpine"
tags: [docker, alpine, quicksync, qsv, va, ffmpeg, intel]
---

Si quieres usar Aceleración de Hardware con procesadores Intel es necesario que tengan soporte para [Quick Sync](https://en.wikipedia.org/wiki/Intel_Quick_Sync_Video) y gráfica integrada (iGPU). Normalmente suelen ser los que no tienen una `F` al final del modelo.

En mi caso tengo un servidor con [Plex](https://plex.tv/) y a veces hace Transcode de lo que se visualiza. Por ejemplo si el dispositivo es viejo (no tiene soporte para el formato del video original), la conexión va lenta, o el equipo es lento y no puede reproducir bien el formato original (resolución o codec). En todos estos casos el servidor ofrece al reproductor una versón más _light_.

El problema viene que la diferencia entre usar o no Aceleración de Hardware es brutal. Con ella el procesador no pasa de un 5% de uso, sin ella se pone a más de 90%, y si hay dos clientes que requieren Transcode ya no da de si. Necesitaría una gráfica dedicada, con el consiguiente consumo/calor/ruido extra. De ahí el interés en usar las capacidades del procesador.

PERO, si quieres usar esto desde dentro de un contenedor de Docker... se complica levemente. Tengo ciertos scripts que hacen uso de [ffmpeg](https://ffmpeg.org/) para preprocesar el contenido cuando se añaden a las bibliotecas. Tanto el contenedor ccmo lo que lleva dentro tienen que enterarse del soporte de Quick Sync. Este es un modelo de imágen con [Alpine Linux](https://www.alpinelinux.org/), Python y ffmpeg:

```Dockerfile
FROM python:alpine

WORKDIR /app

RUN apk add --no-cache ffmpeg mediainfo intel-media-driver

RUN apk add --no-cache --virtual .build-deps build-base linux-headers musl-dev python3-dev \
 && pip install --no-cache-dir -r requirements.txt \
 && apk del .build-deps

COPY *.py ./

CMD [ "python3", "main.py" ]
```

Faltan muchas cosas por medio pero el modelo está claro. La clave aquí es el paquete [`intel-media-driver`](https://pkgs.alpinelinux.org/package/edge/community/x86_64/intel-media-driver), que pertenece al repositorio [community](https://wiki.alpinelinux.org/wiki/Repositories#Community).

Ahora para hacer uso de ello bastaría con algo como:

```shell
$ docker build -t alpine_hwa .
$ docker run -it --rm --device /dev/dri:/dev/dri alpine_hwa ffmpeg -hwaccel auto -i ...
```

Se contruye el contenedor y se le da uso. Dos puntos clave:

- `--device /dev/dri:/dev/dri`: Damos visión al contenedor de la "gráfica integrada".
- `-hwaccel auto`: le decimos a `ffmpeg` que use HWA, podríamos decirle directamente que use `vaapi`, pero en este caso es lo mismo, lo derectará solo.

En el caso de tener una tarjeta gráfica NVIDIA en vez de la iGPU del procesador el proceso cambia (más sencillo), pero no lo cubro en este post porque no tengo forma de hacer pruebas.
