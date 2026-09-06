#Tive que fazer esse export antes de rodar o virt-install, pois estava dando erro de "libosinfo-1.0.typelib not found"

export GI_TYPELIB_PATH=/usr/local/lib64/girepository-1.0:libosinfo-1.0.typelib

virt-install \
  --name=slackware-15 \
  --vcpus=2 \
  --memory=4096 \
  --disk path=~/home/brusso/Maquinas-Virtuais/slackware-15.qcow2,size=20,format=qcow2 \
  --cdrom=/home/brusso/Downloads/slackware64-15.0-install-dvd.iso \
  --os-variant=detect=on \
  --network network=default \
  --graphics spice \
  --console pty,target_type=serial \
  --boot hd,cdrom



 export GI_TYPELIB_PATH=/usr/local/lib64/girepository-1.0:libosinfo-1.0.typelib

virt-manager