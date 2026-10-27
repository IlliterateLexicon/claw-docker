from alpine as build 
	run apk add --no-cache xz gcompat

	# create decompression script
	workdir /rootfs/
	run echo -en "[ -f /copy.tar.xz ] && ( xz -d /copy.tar.xz; cd /copy; busybox tar -xf /copy.tar; busybox rm /copy.tar; busybox cp -rf /copy/* /) || true" > /rootfs/claw.sh && chmod +x /rootfs/claw.sh

	# copy libc 
	workdir /rootfs/lib 
	run cp -a /lib/*musl-*.so.1  ./
	run cp /usr/lib/liblzma.so.5 ./

	# copy busybox and xz
	workdir /rootfs/bin
	run cp /bin/busybox /usr/bin/xz ./ 
	run ln -s /bin/busybox ./sh

from build as musl
	# copy rootfs and copy, compress copy to copy.tar.xz
	copy --from=build /rootfs /
	copy --from=copy  /copy   /copy/
	workdir /copy
	run tar c ./ | xz -9 > /rootfs/copy.tar.xz

from build as gcompat
	# copy rootfs and copy, compress copy to copy.tar.xz
	copy --from=build /rootfs /rootfs/
	copy --from=copy  /copy   /copy/

	# install gcompat
	workdir /copy/lib/
	workdir /lib/
	run cp -a \ 
		./libgcompat.so.0 \
		./libc.so.6 \
		./libcrypt.so.1 \
		./libm.so.6 \
		./libpthread.so.0 \
		./libresolv.so.2 \
		./librt.so.1 \
		./libutil.so.1 \
	/copy/lib

	workdir /copy
	run tar c ./ | xz -e9 > /rootfs/copy.tar.xz

# create claw image 
from scratch as claw
copy --from=musl /rootfs/ /
workdir /copy
cmd [ "sh", "-c", "" ]

from scratch as claw_gcompat
copy --from=gcompat /rootfs/ /
workdir /copy
cmd [ "sh", "-c", "busybox echo -en \"claw (gcompat) working! copied $(busybox du -hs copy.tar.xz ) file from additional_contexts:copy\""]
