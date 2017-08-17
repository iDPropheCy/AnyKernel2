# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
do.bb=0
do_310_fixes=0
device.name1=A0001
device.name2=bacon
device.name3=One A0001
device.name4=One
device.name5=OnePlus
} # end properties

# shell variables
block=/dev/block/platform/msm_sdcc.1/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk


## AnyKernel install
dump_boot;

if [ $do_310_fixes == 1 ]; then
### 3.10 ramdisk fixes (works only in d0a4383 osm0sis anykernel2 and newer)

## fstab

if [ -f fstab.bacon ]; then
  fstab="fstab.bacon";
  if [ -z "$(grep -o 'f2fs    nosuid' $fstab)" ]; then
    backup_file $fstab;
  fi;
elif [ -f fstab.qcom ]; then
  fstab="fstab.qcom";
  if [ -z "$(grep -o 'f2fs    nosuid' $fstab)" ]; then
    backup_file $fstab;
  fi;
fi;

# apply fstab changes

if [ -n $fstab ]; then
  replace_string $fstab "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    nosuid" "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    noatime,nosuid" "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    nosuid";
  replace_string $fstab "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    nosuid" "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    noatime,nosuid" "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    nosuid";
  replace_string $fstab "/devices/*/xhci-hcd.0.auto/usb" "/devices/platform/xhci-hcd" "/devices/*/xhci-hcd.0.auto/usb";
  replace_string $fstab "voldmanaged=usb:auto" "voldmanaged=usbdisk:auto" "voldmanaged=usb:auto";
fi;

## init.recovery.bacon.rc

if [ -f init.recovery.bacon.rc ]; then
  qcomrecovery="init.recovery.bacon.rc";
  if [ -z "$(grep -o 'cpubw.47' $qcomrecovery)" ]; then
    backup_file $qcomrecovery;
  fi;
fi;

# apply init.recovery.bacon.rc changes

if [ -n $qcomrecovery ]; then
  replace_string $qcomrecovery "cpubw.47" "cpubw.40" "cpubw.47";
fi;

## init.qcom.power.rc 

if [ -f init.qcom.power.rc ]; then
  qcompower="init.qcom.power.rc";
  if [ -z "$(grep -o 'cpubw.47' $qcompower)" ]; then
    backup_file $qcompower;
  fi;
fi;

# apply init.qcom.power.rc changes 
if [ -n $qcompower ]; then
  replace_string $qcompower "cpubw.47" "cpubw.40" "cpubw.47";
fi;

## init.bacon.rc

if [ -f init.bacon.rc ]; then
  qcomdevice="init.bacon.rc";
  if [ -z "$(grep -o 'group gps inet' $qcomdevice)" ]; then
    backup_file $qcomdevice;
  fi;
elif [ -f init.oppo.common.rc ]; then
  qcomdevice="init.oppo.common.rc";
  if [ -z "$(grep -o 'group gps inet' $qcomdevice)" ]; then
    backup_file $qcomdevice;
  fi;
fi;

# apply init.bacon.rc changes

if [ -n $qcomdevice ]; then
  replace_string $qcomdevice "group gps inet" "group gps qcom_oncrpc inet" "group gps inet";
  if [[ -z "$(grep -o 'group radio system' $qcomdevice)" && -z "$(grep -o 'service qmuxd /system/bin/qmuxd\n    class main\n    user root' $qcomdevice)" ]]; then
    replace_section $qcomdevice "service netmgrd /system/bin/netmgrd" "group radio" "service netmgrd /system/bin/netmgrd\n    class main\n    user root\n    group radio system";
    replace_section $qcomdevice "service qmuxd /system/bin/qmuxd" "user radio" "service qmuxd /system/bin/qmuxd\n    class main\n    user root";
  fi;
fi;

### 3.10 ramdisk fixes (works only in d0a4383 osm0sis anykernel2 and newer)
fi;

write_boot;

## end install

