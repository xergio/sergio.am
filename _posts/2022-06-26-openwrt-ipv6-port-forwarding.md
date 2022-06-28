---
layout: post
title:  "Abrir puertos con IPv6 dinámica en OpenWRT"
tags: [abrir, puertos, openwrt, ipv6, digi, port, forwarding, traffic, rules, dyndns, docker]
---

Con IPv6 no usamos NAT, por lo tanto no existe redirección de puertos (Port Forwarding). Hay tantas IPs disponibles que incluso los equipos dentro de la LAN tienen una IP "pública". Lo que nos suelen dar las operadoras/proveedores de internet es un rango de IPs, un `/64` es lo más común, por lo tanto tenemos la opción de alojar 2<sup>64</sup> (18,446,744,073,709,551,616) direcciones en nuestra red. Ese rango `/64` corresponde por convenio a una LAN. Si lo que tenemos es un servidor (dedicado normalmente, con los VPS no pasa) es posible que nos den una `/56` (256 LANs) o una `/48` (65,536 LANs).

Ejemplo con IPv4:

- IP de casa desde fuera: `1.2.3.4`.
- A su vez el router desde dentro es la `192.168.1.1` (puerta de enlace).
- El resto de equipos de la LAN estarán en el rango `/24` normalmente (hasta la `192.168.1.255`).
- Para abrir un puerto le decimos al router que el puerto X lo mande al puerto Y de una de las IPs de dentro.

Ok, ahora con IPV6 tenemos lo siguiente:

- IP de casa desde fuera `2001:2:3:4::/64` (seguramente veamos la `2001:2:3:4::2`).
- El router dará a cada equipo conectado una IP de ese rango, la `::2` sería el router en si.
    - Para evitar colisiones chugas lo típico es usar la MAC del equipo conectado para formar la IPv6, por ejemplo quedaría algo como `2001:2:3:4:5:6:7:8`.
- Para abrir un puerto solo le decimos al router "permite el tráfico de la IP Z al puerto X". Incluso podemos obviar el puerto, pero no es recomendable.

Dicho lo cual, si queremos "abrir" un puerto a un equipo de nuestra LAN gestionada con OpenWRT tenemos que recurrir a las [Reglas de Tráfico (Traffic Rules)](https://openwrt.org/docs/guide-user/firewall/fw3_configurations/fw3_ipv6_examples). El tráfico va a venir directamente a una IP "de dentro", por lo tanto podemos servir el mismo puerto 80 (por ejemplo) con la misma conexión desde diferentes máquinas. En la práctica serán dos direcciones diferentes, pero antes con IPv4 no podíamos hacer fácilmente esto, ya que la IP de entrada era la misma.

Esto está bien, pero al igual que con IPv4 se complica levemente con IP dinámica. No mucho. Por suerte OpenWRT implementa una forma de especificar IPs sin conocer el prefijo, la parte `/64` que nos asigna la operadora.

Puesto que el sufijo será constante mientras se mantenga la MAC, sabemos que aunque cambie la IP de la operadora el sufijo se mantiene. En el caso de antes de una IP `2001:2:3:4:5:6:7:8`, la IP asignada por la operadora es `2001:2:3:4::/64` y ese equipo concreto siempre empezará por lo que nos asignen y terminará por `5:6:7:8`, así que podemos asignar una regla a la IP `::5:6:7:8/-64`.

BOOM!

Vamos con un ejemplo real, con una RaspberryPi que tengo en casa.

- IPv6 de casa: `2a0c:5a80:2301:2d00::/64` (de Digi, quienes tienen asignado, entre otros, un peazo rango `2a0c:5a80::/29` como [AS57269](https://db-ip.com/as57269-digi-spain-telecom-slu))
- OpenWRT me pilla la `2a0c:5a80:2302:2d00::2`.
- A la Raspi le asigna la `2a0c:5a80:2301:2d00:243e:d63d:943f:d8c1`.

De primeras, un escaneo de puertos a cualquiera de esas IPs da todo cerrado: `nmap -6 -sV 2a0c:5a80:2301:2d00:243e:d63d:943f:d8c1`. Pero vamos a permitir el tráfico en OpenWRT:

```shell
uci add firewall rule
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].dest="lan"
uci set firewall.@rule[-1].dest_ip="::243e:d63d:943f:d8c1/-64"
uci set firewall.@rule[-1].dest_port="22"
uci set firewall.@rule[-1].family="ipv6"
uci set firewall.@rule[-1].proto="tcp udp"
uci set firewall.@rule[-1].name="ssh6-raspi2"
uci commit firewall
/etc/init.d/firewall restart
````

O desde el interface en Network > Firewall > Traffic Rules...

![Firewall](/assets/traffic-rules/firewall.png)

Así quedaría la línea de la regla una vez añadida:

![Rule](/assets/traffic-rules/rule.png)

Volvemos a mirar los puertos y...:

```shell
$ nmap -6 -sV 2a0c:5a80:2301:2d00:243e:d63d:943f:d8c1
Starting Nmap 7.80 ( https://nmap.org ) at 2022-06-27 11:48 UTC
Nmap scan report for 2a0c:5a80:2301:2d00:243e:d63d:943f:d8c1
Host is up (0.032s latency).
Not shown: 999 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.4p1 Raspbian 5+b1 (protocol 2.0)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Y si intentamos usarlo, efectivamente...

```shell
$ ssh -T piuser@2a0c:5a80:2301:2d00:243e:d63d:943f:d8c1
piuser@2a0c:5a80:2301:2d00:243e:d63d:943f:d8c1: Permission denied (publickey).
```

**Funciona**. De la misma forma, si intentamos conectar a cualquier otra IP, incluida la `::2` del router, no funcionará porque no hemos permitido ese tráfico. Tendremos que hacer esto para cada puerto que queramos abrir, de cualquier IP de la LAN.

# DynDNS

Aquí se presenta un problema. Bueno, dos. Si instalas algo tipo [ddclient](https://github.com/ddclient/ddclient), la IP que llevará el dominio que actualices irá con la IP de ese dispositivo. Por eso, la solución que he tenido es instalar uno en cada IP que quiero que tenga acceso desde fuera.

El segundo problema es que no todos los proveedores de DynDNS tienen soporte para IPv6. Así que buscando he terminado usando algo muy sencillito, [dynv6](https://dynv6.com). Un simple cron y a correr.

# Bonus: Docker

Docker es un poco asá con IPv6. Técnicamente tiene soporte pero no fue diseñado para ello. Mejor dicho, está diseñado para usar NAT, ya que directamente crea una VLAN interna para los contenedores. Así que con IPv6 la cabra tira para el monte.

Si se tiene una instalación limpia se puede hacer funcionar sin mayor problema, añadiendo lo siguiente al `/etc/docker/daemon.json`:

```json
{
  "experimental" : true,
  "ipv6":true,
  "fixed-cidr-v6":"fd00:fe0:b0b0:dead::/80",
  "ip6tables":true
}
```

Y `sudo systemctl restart docker.service`. La IPv6 me la invento, ya que será la IP que dará a los contenedores y luego internamente hará sus pirulas/NATing. Solo con esto me ha funcionado:

```shell
$ docker run --rm -it busybox ping6 sergio.am
PING sergio.am (2a06:98c1:3121::5): 56 data bytes
64 bytes from 2a06:98c1:3121::5: seq=0 ttl=56 time=3.384 ms
64 bytes from 2a06:98c1:3121::5: seq=1 ttl=56 time=3.213 ms
```

PERO, en el servidor he tenido que recurrir a una ñapa terrible para que funcionse, [docker-ipv6nat](https://github.com/robbertkl/docker-ipv6nat). Mientras las cosas esten como están en docker, eso es necesario.


