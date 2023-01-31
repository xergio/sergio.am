---
layout: post
title:  "Abrir la LAN con WireGuard"
tags: [unraid, nas, server, home, linux, lan, wireguard, vpn]
---

Hasta ahora lo típico para acceder a la LAN de casa era abrir el puerto 22 por ejemplo, y de ahí ya acceder a los equipos de la red. Pero he ido cambiando eso por WireGuard.

Dejando a un lado las ventajas de WireGuard frente a otras VPN, las dos mayores ventajas que me han hecho cambiar a este setup son:

- Velocidad de reconexión: cuando cambias de red (por ejemplo el móvil entre antenas), o el portátil entre trabajo/casa, el propio túnel se actualiza él solo al vuelo.
- Menos consumo de red: WireGuard usa menos red, lo que se traduce en menos ping y más tasa de red.

Mi configuración inicial consistía en todos los clientes/_peers_ conectados al servidor VPN que monté en el router. Funcionaba, pero eso me hacía depender de un router con kernel moderno. Por diversas razones ya no puedo tener esa dependencia, además no quiero depende tampoco de tener que abrir puertos. Y para finalizar, me he dado cuenta ahora que el router me limitaba levemente la conexión de la VPN por la velocidad del procesador.

Por eso he pasado a tener la VPN en un VPS externo, y para acceder a la LAN de casa (u otra) lo hago _colándome_ por el túnel, concretamente por el _peer_ del NAS.

Para este setup he recurrido a diferentes artículos de referencia sobre WireGuard. Lo que más me ha ayudado, de lejos, es la [página oficial](https://www.wireguard.com/) y este comentario:

> In other words, when sending packets, the list of allowed IPs behaves as a sort of routing table, and when receiving packets, the list of allowed IPs behaves as a sort of access control list.

Otra página que me ha servido de infinita ayuda es [pirate/wireguard-docs](https://github.com/pirate/wireguard-docs). No solo explica cada caso de uso y parámetro, sino que detalla las tripas de WireGuard.

Entre algunos de los problemas que me salieron fue que uno de los _peers_ tenía baja velocidad de transferencia. Resultó ser por el MTU cuando el _endpoint_ iba por IPv6, explicado [aquí](https://keremerkan.net/posts/wireguard-mtu-fixes/).

Y para acabar, los [tutoriales en el foro de Unraid sobre WireGuard](https://forums.unraid.net/topic/84226-wireguard-quickstart/), sobre todo el de [LAN-to-LAN](https://forums.unraid.net/topic/88906-lan-to-lan-wireguard/), donde vi la idea de crear una ruta estática en casa, algo que soportan todos los routers hoy en día.

El resto es cosa de los comandos `ip` e `iptables` de linux .

# Configuración modelo

Servidor:

```
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
MTU = 1412
PrivateKey = ...
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -A FORWARD -o %i -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o %i -j MASQUERADE
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PreDown = iptables -D FORWARD -i %i -j ACCEPT
PreDown = iptables -D FORWARD -o %i -j ACCEPT
PreDown = iptables -t nat -D POSTROUTING -o %i -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# Name = nas
PublicKey = ...
AllowedIPs = 10.0.0.2/32, 192.168.1.0/24
```

Con esto hacemos que cualquier conexión que nos venga para la LAN de casa (192.168.1.0/24) se mande por el _peer_ 10.0.0.2 (el nas).

Ahora la config del nas:

```
[Interface]
PrivateKey = ...
Address = 10.0.0.2/24
ListenPort = 51820
MTU = 1412
PostUp = iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o br0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o br0 -j MASQUERADE
PostUp = ip -4 route flush table 200
PostUp = ip -4 route add default via 10.0.0.2 table 200
PostUp = ip -4 route add 192.168.1.0/24 via 192.168.1.1 table 200
PostDown = ip -4 route flush table 200
PostDown = ip -4 route add unreachable default table 200
PostDown = ip -4 route add 192.168.1.0/24 via 192.168.1.1 table 200

[Peer]
# Name = vps
PublicKey = ...
Endpoint = 1.2.3.4:51820
AllowedIPs = 10.0.0.0/24, 172.20.0.0/24
PersistentKeepalive = 25
```

Con este `AllowedIPs` hacemos que se vaya por el túnel todo lo de la VPN y lo de la red de los Dockers que hay en el VPS. Para que cualquier equipo conectado al router de casa se le aplica la ruta estática configurada en el mismo, que precisamente manda estos dos rangos a la IP local del nas, dicho de otra forma, 172.20.0.0/24 redireccionado al "gateway" 192.168.1.2 . Y las rutas y reglas de `iptables` sirven precisamente para que cualquiera que venga por el túnel a otro equipo de la LAN, pueda acceder.

El resto de _peers_ de la VPN no necesitan una config especial, por ejemplo al móvil o al portátil les vale con algo así para acceder tanto a la LAN como a los Dockers:

```
[Interface]
PrivateKey = ...
Address = 10.0.0.x/24
ListenPort = 51820

[Peer]
# Name = movil
PublicKey = ...
Endpoint = 1.2.3.4:51820
AllowedIPs = 192.168.1.0/24, 172.20.0.0/24
```

Resumiendo:

- Todos los _peers_ de la VPN pueden hablar entre si, con los contenedores de Docker del VPS, y con los equipos de la LAN de casa (incluido el NAS y el router).
- El VPS y sus contenedores pueden acceder a la LAN y a los _peers_.
- Cualquier equipo de casa, NAS y router incluidos, pueden acceder a los contendores del VPS y al resto de _peers_.

Total, que todos pueden conectar a todos solo por estar a rango de la VPN.

Y lo mejor de este setup es que me puedo llevar el NAS a otra conexión/casa, o cambiar de proveedor/equipos/router, y con un mínimo ajuste (rutas estáticas) todo funcionaría igual.
