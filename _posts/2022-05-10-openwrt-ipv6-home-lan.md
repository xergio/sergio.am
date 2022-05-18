---
layout: post
title:  "Conectividad IPv6 sobre túnel WireGuard y OpenWRT"
---
La situación actual en España es que ningún operador de internet da IPv6. Y yo quiero IPv6. No por nada especial, simplemente por tener esa alternativa de conexión, probar cosas, aprender, etc. Y como lo quiero, lo he hecho, ejemplo de petición a [ipv6.google.com](https://ipv6.google.com/):

![https://ipv6.google.com](https://xrg.io/x/4c0t/49Zy.png)

O un ping:

![ping6 google.com](https://xrg.io/x/4c0t/Khg.png)

Antes de seguir, recomiendo la lectura de estos [hilos sobre IPv6](https://twitter.com/weareDMNTRs/status/1485600456583921670) de [@weareDMNTRs](https://twitter.com/weareDMNTRs). Aunque llevo tiempo interesándome por todo esto, sus hilos me dieron mucha claridad en el asunto. 

En casa tengo _bridgeado_ el router de la operadora para que delegue todo a mi router _pofesional_, un [Linksys WRT3200ACM](https://www.linksys.com/es/wireless-routers/wrt-wireless-routers/linksys-wrt3200acm-ac3200-mu-mimo-gigabit-wifi-router/p/p-wrt3200acm/) con [OpenWRT](https://openwrt.org/) como sistema operativo.

## Opciones

Llegados a este punto hay alternativas para dar conectividad IPv6 hacia el mundo a todos los dispositivos de casa, la más sencilla de ellas es usar [Tunnelbroker.net](https://tunnelbroker.net/) de HE.net. Aunque funciona y sirve para lo que digo, no es conveniente para tener un tunel UP todo el día: a veces falla, tiene demasiada latencia, el protocolo es [6in4](https://en.wikipedia.org/wiki/6in4), y dicho todo esto ya no hace falta decir nada más.

Aunque mi solución no es perfecta tampoco (mirad el ping), solo por la estabilidad y poder aprovechar casi casi el 100% del ancho de banda, renta. Mi solución tampoco es 100% gratuita, ojo, pero como tengo servidores por todas partes puedo aprovecharme de ello, ya que me sirve literalmente cualquier proveedor (hoy en día raro es que no den IPv6 en servidores).

## VPS barato + WireGuard + OpenWRT

Esta es mi solución: crear un tunel seguro con [WireGuard](https://www.wireguard.com/) entre un VPS cualquiera y el router con OpenWRT. Si has llegado hasta aquí no necesito decirte por qué WireGuard. El router hace de cliente, y el VPS de servidor. Configuración standart. La clave de sacar todo el tráfico IPv6 por el tunel es el siguiente, `/etc/config/network`:

```
config interface 'WG'
        option proto 'wireguard'
        option listen_port '51820'
        option private_key 'priv.key...'
        list addresses '10.11.12.2/24'
        list addresses 'fdbc:f607:7749::2/64'

config wireguard_WG
        option description 'WireGuard'
        option endpoint_port '51820'
        option route_allowed_ips '1'
        option public_key 'pub.key...'
        option endpoint_host '1.2.3.4'
        option persistent_keepalive '25'
        list allowed_ips '10.11.12.0/24'
        list allowed_ips '::/0'
```

El segundo `list addresses` del _interface_, y el `list allowed_ips`. Hay que darle al interface una IPv6 en el servidor también:

```ini
[Peer]
# Name = peer_openwrt
PublicKey = pub.key...
AllowedIPs = 10.11.12.2/32,fdbc:f607:7748::2,fdb9:f2e5:ccc0::/48
```

Además el interface del servidor necesita IPv6 también:

```ini
[Interface]
Address = 10.11.12.1/24, fdbc:f607:7748::1/64
```

Y las reglas de `iptables` para IPv4 y 6:

```ini
PostUp = iptables  -A FORWARD -i %i -j ACCEPT
PostUp = iptables  -A FORWARD -o %i -j ACCEPT
PostUp = ip6tables -A FORWARD -i %i -j ACCEPT
PostUp = ip6tables -A FORWARD -o %i -j ACCEPT
PostUp = iptables  -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PreDown = iptables  -D FORWARD -i %i -j ACCEPT
PreDown = iptables  -D FORWARD -o %i -j ACCEPT
PreDown = ip6tables -D FORWARD -i %i -j ACCEPT
PreDown = ip6tables -D FORWARD -o %i -j ACCEPT
PreDown = iptables  -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

"Y ya está"! 3 años para conseguir que esto funcione, para que a las dos semanas cambie de operadora y me den IPv6 nativo 🥲
