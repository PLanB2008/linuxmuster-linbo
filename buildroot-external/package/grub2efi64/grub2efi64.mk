################################################################################
#
# grub2efi64
#
################################################################################

GRUB2EFI64_VERSION = 2.02
GRUB2EFI64_SOURCE = grub-$(GRUB2EFI64_VERSION).tar.gz
GRUB2EFI64_SITE = ftp://ftp.gnu.org/gnu/grub
GRUB2EFI64_LICENSE = GPLv3
GRUB2EFI64_LICENSE_FILES = COPYING

GRUB2EFI64_CONF_ENV = \
	CPP="$(TARGET_CC) -E"
GRUB2EFI64_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --disable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=efi --target=x86_64
GRUB2EFI64_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

define GRUB2EFI64_CLEANUP
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/*.image
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/*.module
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/kernel.exec
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/gdb_grub
	rm -fv $(TARGET_DIR)/usr/lib/grub/x86_64-efi/gmodule.pl
	rm -fv $(TARGET_DIR)/etc/bash_completion.d/grub
	rmdir -v $(TARGET_DIR)/etc/bash_completion.d/
endef
GRUB2EFI64_POST_INSTALL_TARGET_HOOKS += GRUB2EFI64_CLEANUP


HOST_GRUB2EFI64_MODS = all_video boot chain configfile cpuid echo net ext2 extcmd fat \
	gettext gfxmenu gfxterm gzio http ntfs linux linux16 loadenv minicmd net part_gpt \
	part_msdos png progress read reiserfs search sleep terminal test tftp \
	efi_gop efi_uga efinet

HOST_GRUB2EFI64_ISOMODS = iso9660 usb

HOST_GRUB2EFI64_FONT = unicode

HOST_GRUB2EFI64_CONF_ENV = \
	$(HOST_CONFIGURE_OPTS) \
	CPP="$(HOSTCC) -E" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fno-stack-protector" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	NM="$(TARGET_NM)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	STRIP="$(TARGET_CROSS)strip"

HOST_GRUB2EFI64_CONF_OPTS = --disable-nls --disable-efiemu --disable-mm-debug \
	--disable-cache-stats --disable-boot-time --enable-grub-mkfont \
	--disable-grub-mount --enable-device-mapper \
	--disable-liblzma --disable-libzfs --with-platform=efi --target=x86_64
HOST_GRUB2EFI64_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -Wno-error"

# Grub2 netdir and iso creation
ifeq ($(BR2_x86_64),y)
define HOST_GRUB2EFI64_NETDIR_INSTALLATION
	mkdir -p $(BASE_DIR)/boot/grub
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_GRUB2EFI64_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_GRUB2EFI64_MODS) $(HOST_GRUB2EFI64_ISOMODS)" \
		-d $(HOST_DIR)/lib/grub/x86_64-efi
	mv $(BASE_DIR)/boot/grub/x86_64-efi/core.efi $(BASE_DIR)/boot/grub/x86_64-efi/core.iso
	$(HOST_DIR)/bin/grub-mknetdir \
		--fonts="$(HOST_GRUB2EFI64_FONT)" \
		--net-directory=$(BASE_DIR) \
		--subdir=/boot/grub \
		--modules="$(HOST_GRUB2EFI64_MODS)" \
		-d $(HOST_DIR)/lib/grub/x86_64-efi
endef
HOST_GRUB2EFI64_POST_INSTALL_HOOKS += HOST_GRUB2EFI64_NETDIR_INSTALLATION
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
