# ДЗ№6 NFS

## Разворачиваем стенд

Для стенде берем box CentOS 8 с репозитария CentOS

nfs-utils провижится из скрипта bootstrap.sh для сервера и из Vagrantfile для клиента

Команды настройки сервера:
```
systemctl enable --now nfs-server
firewall-cmd --add-service={nfs,nfs3,rpc-bind,mountd} --permanent
firewall-cmd --reload
mkdir -p /srv/share/upload
chown -R nobody:nobody /srv/share
chmod 0777 /srv/share/upload
cat << EOF > /etc/exports
/srv/share 192.168.56.41/32(rw,sync,root_squash)
EOF
exportfs -av
```

Команды натройки клиента:
```
systemctl enable firewalld --now
systemctl status firewalld
echo "192.168.56.40:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
```
## Troubleshooting

**Клиент:**
```
mount -vvvv -t nfs -o vers=3 192.168.56.40:/srv/share /mnt
mount.nfs: timeout set for Sun May 29 19:39:29 2022
mount.nfs: trying text-based options 'vers=3,addr=192.168.56.40'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 192.168.56.40 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 192.168.56.40 prog 100005 vers 3 prot UDP port 20048

mount -vvvv -t nfs -o vers=3 proto=udp 192.168.56.40:/srv/share /mnt
mount.nfs: timeout set for Sun May 29 19:40:43 2022
mount.nfs: trying text-based options 'vers=3,proto=udp,addr=192.168.56.40'
mount.nfs: prog 100003, trying vers=3, prot=17
mount.nfs: portmap query failed: RPC: Program not registered
mount.nfs: trying text-based options 'vers=3,proto=udp,addr=192.168.56.40'
mount.nfs: prog 100003, trying vers=3, prot=17
mount.nfs: portmap query failed: RPC: Program not registered
mount.nfs: trying text-based options 'vers=3,proto=udp,addr=192.168.56.40'
mount.nfs: prog 100003, trying vers=3, prot=17
mount.nfs: portmap query failed: RPC: Program not registered
mount.nfs: requested NFS version or transport protocol is not supported

```
**Сервер:**
```
rpcinfo -p
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  39086  status
    100024    1   tcp  59513  status
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100021    1   udp  33894  nlockmgr
    100021    3   udp  33894  nlockmgr
    100021    4   udp  33894  nlockmgr
    100021    1   tcp  41927  nlockmgr
    100021    3   tcp  41927  nlockmgr
    100021    4   tcp  41927  nlockmgr
```

**NFS работает только по tcp!**

Добавляем строку `vers3=y` в `/etc/nfs.conf` и рестартуем NFS `systemctl restart nfs-server`

**Проверяем с клиента что udp открыт:**
```
rpcinfo -p 192.168.56.40
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  39086  status
    100024    1   tcp  59513  status
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
    100021    1   udp  46567  nlockmgr
    100021    3   udp  46567  nlockmgr
    100021    4   udp  46567  nlockmgr
    100021    1   tcp  39481  nlockmgr
    100021    3   tcp  39481  nlockmgr
    100021    4   tcp  39481  nlockmgr

```

**Проверяем монтирование:**
```
root@nfsclient:~^G[root@nfsclient ~]# umount /mnt
root@nfsclient:~^G[root@nfsclient ~]#  mount | grep /mnt
systemd-1 on ^[[01;31m^[[K/mnt^[[m^[[K type autofs (rw,relatime,fd=40,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=17732)
root@nfsclient:~^G[root@nfsclient ~]# ls /mnt/
upload
root@nfsclient:~^G[root@nfsclient ~]# ls /mnt/upload/
checkfile

```

# Выводы
+ UDP по умолчанию не открыт в CentOS 8.4(Default NFS4.2 TCP)
+ Получен опыт troubleshuting'а
+ Для разнообразия client провижится через `Vagrantfile`
+ Увеличены timeout на ожидание загрузки vm
