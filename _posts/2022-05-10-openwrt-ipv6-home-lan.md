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

Esta es mi solución: crear un tunel seguro con [WireGuard](https://www.wireguard.com/) entre un VPS cualquiera y el router con OpenWRT. Si has llegado hasta aquí no netesito decirte por qué WireGuard. El router hace de cliente, y el VPS de servidor.

blablabla...
