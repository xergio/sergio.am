---
layout: post
title:  "LVM"
tags: [lvm, disk, discos, partición, volumen, lógico, raspberry pi]
---

[LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)) es una de esas cosas que siempre he visto pero nunca me paré siquiera a ver para qué podía ser útil. Casualmente ahora le he encontrado utilidad de rebote.

Tengo una Raspberry Pi 4 con un disco mecánico (lento) de unos cuantos teras, y otros 3 SSD de diferentes tamaños. Mi idea inicial era usar al menos uno de los SSD para hacer de caché del HDD con [bcache](https://en.wikipedia.org/wiki/Bcache), pero _oh sorpresa_ el kernel de Raspbian no lo trae activado por defecto. Ok, pues recompilo un kernel con eso activado... o no. Mientras compilaba he pensado en el mantenimiento de eso con cada actualización y he pensado "ni de coña pongo mi kernel a estas alturas de la vida".

Buscando alternativas me topo con LVM. No tiene que ver con caché, pero me sirve para lo que busco, que es un paso intermedio del HDD para descargas. Así que he hecho un volumen con dos SSD, para tener espacio suficiente entre descargas, y de ahí pasar al HDD:

```shell
# instalamos lvm2
$ sudo apt install lvm2
# creamos el volumen físico
$ sudo pvcreate /dev/sdb1 /dev/sdc1

WARNING: ext4 signature detected on /dev/sdb1 at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/sdb1.
WARNING: ext4 signature detected on /dev/sdc1 at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/sdc1.
  Physical volume "/dev/sdb1" successfully created.
  Physical volume "/dev/sdc1" successfully created.

$ sudo pvs

  PV         VG Fmt  Attr PSize    PFree
  /dev/sdb1     lvm2 ---    59.62g   59.62g
  /dev/sdc1     lvm2 ---  <111.79g <111.79g
```

```shell
# creamos el grupo de volumen
$ sudo vgcreate ssd_vol /dev/sdb1 /dev/sdc1

  Volume group "ssd_vol" successfully created

$ sudo vgs

  VG      #PV #LV #SN Attr   VSize    VFree
  ssd_vol   2   0   0 wz--n- <171.38g <171.38g
```

```shell
# creamos el volumen lógico
$ sudo lvcreate -l 100%FREE -n ssd_log_vol ssd_vol

  Logical volume "ssd_log_vol" created.

$ sudo lvs

  LV          VG      Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ssd_log_vol ssd_vol -wi-a----- <171.38g
```

```shell
# formateamos el volúmen en ext4 y montamos la unidad
$ sudo mkfs.ext4 /dev/ssd_vol/ssd_log_vol
$ sudo mkdir /mnt/lvm_ssd
$ sudo chown -R pi:pi /mnt/lvm_ssd
$ sudo chmod 775 /mnt/lvm_ssd
$ sudo blkid

...
/dev/sdb1: UUID="L93uQY-2h0N-PJpU-T2lL-NDjc-Am38-1L12jm" TYPE="LVM2_member" PARTUUID="28d1fe50-01"
/dev/sdc1: UUID="ZMaG00-WNI1-jH3R-ycD1-mlwo-cB7M-0fNrTp" TYPE="LVM2_member" PARTUUID="74523e87-01"
/dev/mapper/ssd_vol-ssd_log_vol: UUID="10ff0f01-78dd-47e9-bff3-6ed738e680cf" BLOCK_SIZE="4096" TYPE="ext4"

# añadir al final
$ sudo nano /etc/fstab

UUID=10ff0f01-78dd-47e9-bff3-6ed738e680cf  /mnt/lvm_ssd  ext4  defaults,noatime,commit=30  0  1

$ sudo mount /mnt/lvm_ssd
# test de velocidad
$ dd if=/dev/zero of=/mnt/lvm_ssd/test.img bs=1M count=256 oflag=dsync

268435456 bytes (268 MB, 256 MiB) copied, 3.22186 s, 83.3 MB/s
```

```shell
# como ejemplo, pasamos las descargas en curso de Transmission a esta unidad
$ mkdir /mnt/lvm_ssd/torrents
$ transmission-remote -c /mnt/lvm_ssd/torrents
```

La única pega que le estoy viendo, por ahora, es lo que una vez descargado algo tarda en pasar al HDD (obviamente), pero me gusta la flexibilidad que ofrece LVM.


*NOTA: Actualización 2024:* Dejé de usar esto hace 1 año, funcionó bien pero terminé dejando de usarlo en favor de [mergerfs](https://github.com/trapexit/mergerfs) + [SnapRAID](https://www.snapraid.it/), en un intento de emular lo que hace [unraid](https://unraid.net/) como tengo en el NAS y va PERFECTO.