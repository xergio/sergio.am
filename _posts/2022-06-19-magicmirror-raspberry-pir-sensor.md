---
layout: post
title:  "MagicMirror con sensor de movimiento"
---
Un MagicMirror no es más que un "espejo" con una pantalla detrás que muestra información "impresa" en el espejo. Y digo "espejo" porque esto no se hace con un espejo normal, sino con un vinilo unidireccional, como el de los cristales de las salas de interrogatorios de las pelis.

Para que este vinilo funcione se necesita un requisito imprescindible: que la parte de detrás del reflejo sea oscuro, o más escruto que lo de en frente. Si este vinilo lo pones en una ventana normal, de día verás tu reflejo al haber más luz fuera que dentro, pero si iluminas el interior, o fuera es de noche, se ve todo el interior. O gran parte.

He aprovechado una RaspberryPi 3b+ que no le daba uso ya para hacer este tinglado. Lo que se necesita, a grandes rasgos:

### Una raspi

Recomiendo usar Raspbian de 64bits. El resto de la instalación es standart. Le instalamos [MagicMirror](https://magicmirror.builders/) como dicen la documentación. No entraré en detalles de eso, no he hecho nada fuera de lo común.

### Un monitor/pantalla

Voy a usar un monitor viejo, solo tiene DVI así que le he puesto un adaptador HDMI-DVI. Lo he desmontado/destripado y me quedaré solo con la pantalla en si y la circuitería.

### Sensor de movimiento

Para encender/apagar la pantalla. No tiene sentido tenerla encendida el 100% del tiempo, solo cuando vea que me acerco. [He pillado este](https://www.amazon.es/gp/product/B07CNBYRQ7/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&th=1). Cableado:

![wiring](/assets/magicmirror/pir_wiring.png)

Yo he usado [los pines 4, 6 y 8](https://gpiozero.readthedocs.io/en/stable/recipes.html#pin-numbering), por quedar juntos. El pin 8 es el GPIO14.

[Mucha info sobre cómo usar el PIR con la Raspi](https://projects.raspberrypi.org/en/projects/physical-computing/11).

### Cables

Jumper cables, un alargo, un ladrón. Hay que conectar el sensor a la raspi, la raspi y el monitor a la luz, la raspi a la pantalla, etc. Cables por todos lados.

# Configuración de la Raspi

A parte [meter en el arranque el MM²](https://docs.magicmirror.builders/configuration/autostart.html) y de [desactivar el protector de pantalla](https://github.com/MichMich/MagicMirror/wiki/Configuring-the-Raspberry-Pi#disabling-the-screensaver), he tenido que usar `vcgencmd` en vez de `tvservice`:

```
tvservice is not supported when using the vc4-kms-v3d driver.
Similar features are available with standard linux tools
such as modetest from libdrm-tests.
```

Se podríá usar otro driver, pero entonces Electron se come la raspi.

Pero es lo mismo, `vcgencmd display_power 0` para apagar la pantalla, `1` para encender. [Montones de info aquí](https://forum.magicmirror.builders/topic/6291/howto-turn-on-off-your-monitor-time-based-pir-button-app).

# `pir.py`

Esto leerá el sensor y controlará la pantalla en consecuencia:

```python
#! /usr/bin/python

import os
import time
from gpiozero import MotionSensor
from datetime import datetime

pir = MotionSensor(14)
print('up!')

while True:
    pir.wait_for_motion()
    os.system('vcgencmd display_power 1')
    pir.wait_for_no_motion()
    os.system('vcgencmd display_power 0')
```

A parte, para que estoy quede fino, he configurado el sensor en modo H (re-trigger), que viene a ser que si el sensor está UP, y vuelve a haber movimiento, se resetea el tiempo de espera. [En la docu del sensor lo explican](/assets/magicmirror/Bewegungsmelder_Modul_Datenblatt.pdf) (o algo así).






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
