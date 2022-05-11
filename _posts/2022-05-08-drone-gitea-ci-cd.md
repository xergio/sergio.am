---
layout: post
title:  "CI/CD con Gitea + Drone"
---
[Drone CI](https://www.drone.io/) es un sistema de CI/CD autónomo y autogestinado que puede asemejarse a lo que es Gitlab CI, Github Actions, Travis CI, etc. En mi caso, al usar [Gitea](https://gitea.io/), me viene perfecto para dar soporte de CI a mis proyectos.

Tengo ambos sistemas corriendo en Docker, y a mayores tengo un [runner](https://docs.drone.io/runner/overview/) en cada servidor donde quiero tener funcionando cosas desatendidas.

Desde un simple archivo `.drone.yml` puedo configurar tanto la _build_ del proyecto como el despliegue del mismo, ya que al tener también mi propio [registro de Docker](https://docs.docker.com/registry/) (lo que viene siendo un DockerHub privado), entre los tres puedo montar la imágen con Drone, _push_ al registro y despliegue de la nueva imágen para finalizar en el servidor que toque.

Y todo "privado".

## Caso de uso

El ejemplo es este mismo blog. Cuando creo/edito una entrada, o literalmente cualquier archivo del mismo, al _commitear_ los cambios a _git_ se ejecuta un _pipeline_ en el runner que corresponda, reconstruye el sitio y crea una imágen del resultado final, lo manda al registro, y se despliega la nueva imágen. Con prácticamente 0 downtime, rollbacks, versionado y código 100% visible y disponible.

El resumen del archivo [.drone.yml](https://sergio.am/code/sergio.am/src/branch/main/.drone.yml) sería:

1. Bla
2. blo
3. lala
4. lslslsls

## Web server

Como el contenido hay que servirlo desde alguna parte, tengo la siguiente configuración en el _vhost_ de nginx de `sergio.am` para que haga distinción entre el contenido del blog y el de Gitea, ya que se sirven desde el mismo dominio:

```nginx
server {
    ...
    ...
}
```

## Planes a futuro

Mi idea a futuro es tener el blog servido desde algún alojamiento gratuito como puede ser Github Pages, o Netlify, o cualquier CDN que lo permita.

De forma más inmediata cambiaré el _setup_ del servidor que mueve todo para que pase _cacheado_ con Cloudflare, pero para ello tengo que cambiar bastante la infraestructura, ya que el proxy de Cloudflare no permite más conexiones que HTTP/S, y ahora mismo tanto HTTP/S como SSH van a la misma conexión, por lo que al activar el proxy pierdes la conectividad SSH.

La alternativa de Cloudflare Tunnel es viable, pero un poco _overkill_ para mi sencillo entorno. Por ello prefiero separar SSH y HTTP/S, aunque ello me lleve un tiempo de cambios aquí y allá.
