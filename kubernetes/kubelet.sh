#!/bin/sh
mount --bind /opt/cni /rootfs/opt/cni
mount --bind /etc/cni /rootfs/etc/cni
until kubelet --kubeconfig=/var/lib/kubeadm/kubelet.conf \
	      --require-kubeconfig=true \
	      --pod-manifest-path=/var/lib/kubeadm/manifests \
	      --allow-privileged=true \
	      --cluster-dns=10.96.0.10 \
	      --cluster-domain=cluster.local \
	      --cgroups-per-qos=false \
	      --enforce-node-allocatable= \
	      --network-plugin=cni \
	      --cni-conf-dir=/etc/cni/net.d \
	      --cni-bin-dir=/opt/cni/bin ; do
    if [ ! -e /dev/sr0 ] ; then
	sleep 1
    else
	mount -o ro /dev/sr0 /mnt && kubeadm join --skip-preflight-checks $(cat /mnt/config)
    fi
done
