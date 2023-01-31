---
layout: post
title:  "Unraid: servidor NAS en casa"
tags: [unraid, nas, server, home, linux, raid]
---

[Unraid](https://unraid.net) es una distribución de Linux para montar una NAS. Además podrás poner en marcha VMs y contenedores de Docker, instalar apps, o usarlo como una distribución más (con sus matices).

La característica principal de este SO es la forma que tiene de gestionar los discos. Tiene algo muy similar a un [MergerFS](https://github.com/trapexit/mergerfs) + [SnapRAID](https://www.snapraid.it/), que no es más que la unión de varios discos con uno para [paridad](https://en.wikipedia.org/wiki/Parity_drive). Y no solo eso, sino que al NO SER UN RAID puedes ver el contenido de los discos desde cualquier otro equipo. Quiero decir, que quitas un disco del equipo, lo pinchas en otro, y ves el contenido qeu ha caido en ese disco concreto. Podrás si quieres copiarlo, o borrar lo que tiene, reemplazarlo por otro igual o mayor (sin superar el disco de paridad), etc. Casi casi es un [JBOD](https://en.wikipedia.org/wiki/Non-RAID_drive_architectures#JBOD) "seguro".

La diferencia con [SHR de Synology](https://kb.synology.com/en-eu/DSM/tutorial/What_is_Synology_Hybrid_RAID_SHR) es que en Unraid se usa [FUSE](https://github.com/libfuse/libfuse) por encima de los discos, y SHR usa [LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)). Eso da un poco más de performance, pero se pierde la "ventaja" de no usar RAID (si es que queremos verlo como ventaja).

Ok, basta de introducciones y a ver qué cacharro he montado. Este cacharro es la evolución durante años de tener discos por USB con Raspis, NUCs, y ahora ya un sistema hecho y derecho con los discos conectados por SATA. Más seguro, más versátil, y más rápido (y caro, si, pero lo compensa). Podría haber usado LSI/SAS pero para uso doméstico no me he atrevido.

# Hardware

Unraid lo tengo instalado en un *Kingston DataTraveler SE9* de 32GB. Es USB2, como recomiendan. Unraid se carga en memoria, no se instala en disco.

Para la caja uso una *Fractal Design Node 804*. Es cuadrada y con dos "cámaras", una para los componentes y otra para los discos. De lo mejorcito que he probado en mucho tiempo.

La placa base es una *MSI B560M PRO*. Si, una placa de escritorio, lo he preferido sobre la típica Supermicro por un tema de precio + disponibilidad + futura reutilización. Además tiene red de 2.5Gbit y buenas VRMs de alimentación. Chipset B560 para socket LGA1200.

Procesador *Intel Core i3-10105* de 10th generación. Buen precio, potente, "bajo" voltaje y soporte para Quick Sync, necesario para hacer Transcode con Plex, por ejemplo.

Memoria RAM *Kingston FURY Beast DDR4 2666MHz 8GB CL16*. Nada del otro mundo, no es ECC.

Fuente de alimentación *EVGA 500 GD v2 500W 80+ Gold*. Una 80+ Gold "barata", aquí seguramente haya mejores opciones.

Ventilación de CPU *NOX HUMMER H-212*. Silencioso y enfría muy muy bien, muchísimo mejor que el ventilador de stock. Y barato.

Tarjeta de expansión *PCIe SATA3 x1 6ports*. Puesto que tengo 10 discos SATA, necesito más tomas que las que trae la placa.

Tema discos, actualmente esta es la configuración de inicio para aprovechar los discos que ya tengo:

- Disco de paridad: Toshiba N300 4TB 7200RPM
- Discos de datos:
    - 5x 4TB Seagate IronWolf 5900RPM
    - 2x 3TB Seagate IronWolf 5200RPM
    - 2x 1TB WD Red 5200RPM
- Discos de cache:
    - appdata y system: Crucial MX500 250GB
    - descargas: Crucial MX500 1TB

Por último, un *HDMI Dummy Plug* para que no se desactive la iGPU del procesador.

# Software

Como ya he dicho, he empezado con *Unraid*, versión 6.11.0.

Plugins esenciales:

- Auto Turbo Write Mode: permite duplicar la escritura de paridad cuando todos los discos están encendidos. Sobre todo apra mover los datos inicialmente, esto es esencial.
- Fix Common Problems: el nombre lo dice. Te avisa de cosas que no van bien.
- My Servers: Cloud de unraid, sincroniza la key.
- Unassigned Devices: aumenta las opciones de la pantalla _Main_.
- User Scripts: yo lo uso para crear crones.

Contenedores principales:

- nginx
- iperf3
- qBittorrent
- Plex

VM de momento no tengo ninguna, ni creo que vaya a usar.
