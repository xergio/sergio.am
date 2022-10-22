---
layout: post
title:  "Migrar almacenamiento de Docker y WSL de disco"
tags: [migrate, docker, wsl, data, windows, disk]
---

Docker en Windows usa un disco virtual para guardar su información de imágenes, por ejemplo. Este "disco" crece y lo suyo es sacarlo de `C:`. El procedimiento es el mismo para mover una imágen de Linux sobre WSL, ya que básicamente usan el mismo subsistema. Por ejemplo, para mover estos datos a un disco `M:`:

```shell
cd m:
wsl --shutdown
wsl --export docker-desktop-data docker-desktop-data.tar
wsl --unregister docker-desktop-data
wsl --import docker-desktop-data docker-desktop-data docker-desktop-data.tar --version 2
```

Y para migrar por ejemnplo una imágen de Ubuntu:

```shell
cd m:
wsl --shutdown
wsl --export Ubuntu ubuntu.tar
wsl --unregister Ubuntu
wsl --import Ubuntu Ubuntu ubuntu.tar
```

El `export` e `import` tardan un poquito, en mi caso eran unos cuantos gigas, e incluso usando un m.2 ha tardado un poquillo en ejecutarlos.
