---
layout: post
title:  "Clasificar clientes con diferentes opciones DHCP en OpenWRT"
tags: [openwrt, dhcp, tag, ip, iphone, android, pihole, dns]
---
Si en tu red local usas cosas como [Pi-hole](https://pi-hole.net/) para filtrar los DNS y bloquear publicidad/malware/etc, y por casualidad tienes algún dispositivo iOS (Apple), vas a tener una notificación permanente de que "La red no es segura". Algo tiene que ver el [DoH](https://en.wikipedia.org/wiki/DNS_over_HTTPS), que se ve que viene activado por defecto, y al "falsear los DNS" se entera.

Mi solución ha sido drástica: los iPhone no usan Pi-hole en mi red. Para ello hay que crear un _tag_ con las opciones pertinentes, y un Static Lease tageando ese dispositivo. Lo explican en la documentación de OpenWRT: [Client classifying and individual options](https://openwrt.org/docs/guide-user/base-system/dhcp_configuration#client_classifying_and_individual_options) (no se puede hacer via admin, no tienen implementados los _tags_):

```shell
uci set dhcp.nopi="tag"
uci set dhcp.nopi.dhcp_option="6,8.8.8.8,1.1.1.1"

uci add dhcp host
uci set dhcp.@host[-1].name="pepito-iphone"
uci set dhcp.@host[-1].mac="AA:BB:CC:DD:FF:11"
uci set dhcp.@host[-1].ip="192.168.1.20"
uci set dhcp.@host[-1].tag="nopi"

uci commit dhcp

/etc/init.d/dnsmasq restart
```

No he probado a no darle in IP concreta, seguramente no haga ni falta.

Se reconecta a la WiFi y pista, nuevas opciones DHCP para él solito, y aquí no ha pasado nada.
