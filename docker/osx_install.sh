
VBoxManage createvm --basefolder /Users/xienan/.docker/machine/machines/default --name default --register

VBoxManage modifyvm default --firmware bios --bioslogofadein off --bioslogofadeout off --bioslogodisplaytime 0 --biosbootmenu disabled --ostype Linux26_64 --cpus 1 --memory 2048 --acpi on --ioapic on --rtcuseutc on --natdnshostresolver1 off --natdnsproxy1 off --cpuhotplug off --pae on --hpet on --hwvirtex on --nestedpaging on --largepages on --vtxvpid on --accelerate3d off --boot1 dvd

VBoxManage modifyvm default --nic1 nat --nictype1 82540EM --cableconnected1 on

VBoxManage list hostonlyifs

VBoxManage hostonlyif create


