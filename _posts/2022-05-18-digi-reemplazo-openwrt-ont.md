---
layout: post
title:  "Digi: Remplazar router y ONT ZTE por OpenWRT y Ufiber"
---
La mayor parte del procedimiento se consigue siguiendo este link de Bandaancha: [Cómo cambiar la ONT ZTE F601 v7 por un Ufiber Loco sobre fibra Digi](https://bandaancha.eu/foros/como-cambiar-zte-f601-v7-ufiber-loco-1743790) ([cache](/assets/digi-openwrt-ont/Cómo cambiar la ONT ZTE F601 v7 por un Ufiber Loco sobre fibra Digi 💡.pdf))

Digi, a día de hoy, uno de los equipos que instala para su fibra Smart es el router ZTE ZXHN H3600 ([manual](/assets/digi-openwrt-ont/ZTE_ZXHN_H3600_Manual_de_usuario.pdf) y [guia](/assets/digi-openwrt-ont/Guia-FIBRA_ZTE_H3600_WiFi6.pdf)) + ONT ZTE F601 v7 ([manual](/assets/digi-openwrt-ont/ZXHN-F601-PON-ONT-User-Manual.pdf)).

Por lo mismo que dicen ahí, prefiero tener mis equipos, que para eso los pillé en su día. Controlas las actualizaciones, las configuraciones, etc.

![ont](/assets/digi-openwrt-ont/ont.png)

Lo que yo tengo ahora mismo es:

- ONT [Ubiquiti UFiber Loco](https://store.ui.com/collections/operator-ufiber/products/ufiber-loco) (vaya nombre)
  - Hardware: v1.0
  - Firmware: 4.4.1
- Router [Linksys WRT3600ACM](https://www.linksys.com/es/wireless-routers/wrt-wireless-routers/linksys-wrt3200acm-ac3200-mu-mimo-gigabit-wifi-router/p/p-wrt3200acm/)
  - Hardware: ARMv7 Processor rev 1 (v7l)
  - Firmware: OpenWrt 21.02.0 r16279-5cc0535800 / LuCI openwrt-21.02 branch git-21.231.26241-422c175.

Ok, nada del otro mundo.

Una vez te ponen la fibra, llamas para que te envie los datos PPPoE y te saquen del CG-NAT (1€ al mes). Te mandan los datos y configuramos OpenWRT.

Esto es solo para poder acceder al ONT desde la LAN. El ONT lo tengo en la IP 192.168.100.1:

```
config interface 'ONT'
        option proto 'static'
        option device 'wan'
        option ipaddr '192.168.100.2'
        option netmask '255.255.255.0'
```

En `Network > Interface > Devices` creamos uno nuevo para la VLAN de Digi, la `20`:

```
config device
        option type '8021q'
        option ifname 'wan'
        option vid '20'
        option name 'wan.20'
```

![vlan](/assets/digi-openwrt-ont/vlan.png)

Ya solo queda configurar la WAN para que se identifique contra la OLT:

```
config interface 'wan'
        option proto 'pppoe'
        option username '1234567@digi'
        option password 'PaSS'
        option device 'wan.20'
```

En `username` y `password` ponemos lo que nos ha mandado Digi por correo.

Y ya está, IPv6 de forma nativa...

![ipv6](/assets/digi-openwrt-ont/ipv6.png)

Buenos tests (ya daba por hecho que no iba a llegar al Gb, esta mañana si he estado en >900Mbps):

![speedtest](/assets/digi-openwrt-ont/speedtest.png)

Y todo esto por 26€, comparado a los 54 de Movistar y sus 600Mbps, teléfono fijo obligatorio, y OLT (en mi zona) Alcatel que no permite poner otra OLT que no sea Alcatel. Eso si, Movistar ha funcionado perfecto este año y medio, no voy a negarlo. Y de 10 las gestiones para darlo de alta de un amigo. PERO, 54€...

Aun no tengo la portabilidad del móvil completada, pero Digi usa la red de Movistar y dudo que aprecie diferencias.
