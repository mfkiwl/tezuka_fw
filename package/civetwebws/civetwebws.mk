################################################################################
#
# civetwebws
#
################################################################################

CIVETWEBWS_VERSION = 1.16
CIVETWEBWS_SITE = $(call github,civetweb,civetweb,v$(CIVETWEBWS_VERSION))
CIVETWEBWS_LICENSE = MIT
CIVETWEBWS_LICENSE_FILES = LICENSE.md

CIVETWEBWS_CONF_OPTS = TARGET_OS=LINUX WITH_IPV6=1 \
	$(if $(BR2_INSTALL_LIBSTDCPP),WITH_CPP=1)
CIVETWEBWS_COPT = -DHAVE_POSIX_FALLOCATE=0
CIVETWEBWS_LIBS = -lpthread -lm
CIVETWEBWS_SYSCONFDIR = /etc
CIVETWEBWS_HTMLDIR = /var/www
CIVETWEBWS_INSTALL_OPTS = \
	DOCUMENT_ROOT="$(CIVETWEBWS_HTMLDIR)" \
	CONFIG_FILE2="$(CIVETWEBWS_SYSCONFDIR)/civetweb.conf" \
	HTMLDIR="$(TARGET_DIR)$(CIVETWEBWS_HTMLDIR)" \
	SYSCONFDIR="$(TARGET_DIR)$(CIVETWEBWS_SYSCONFDIR)"

ifeq ($(BR2_TOOLCHAIN_HAS_SYNC_4),)
CIVETWEBWS_COPT += -DNO_ATOMICS=1
endif

ifeq ($(BR2_PACKAGE_CIVETWEBWS_WITH_LUA),y)
CIVETWEBWS_CONF_OPTS += WITH_LUA=1
CIVETWEBWS_LIBS += -ldl
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
CIVETWEBWS_COPT += -DNO_SSL_DL
CIVETWEBWS_LIBS += `$(PKG_CONFIG_HOST_BINARY) --libs openssl`
CIVETWEBWS_DEPENDENCIES += openssl host-pkgconf
else
CIVETWEBWS_COPT += -DNO_SSL
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
CIVETWEBWS_CONF_OPTS += WITH_ZLIB=1
CIVETWEBWS_LIBS += -lz
CIVETWEBWS_DEPENDENCIES += zlib
endif

ifeq ($(BR2_PACKAGE_CIVETWEBWS_SERVER),y)
CIVETWEBWS_BUILD_TARGETS += build
CIVETWEBWS_INSTALL_TARGETS += install
endif

ifeq ($(BR2_PACKAGE_CIVETWEBWS_LIB),y)
CIVETWEBWS_COPT += -DUSE_WEBSOCKET
CIVETWEBWS_INSTALL_STAGING = YES
CIVETWEBWS_INSTALL_TARGETS += install-headers

ifeq ($(BR2_STATIC_LIBS)$(BR2_STATIC_SHARED_LIBS),y)
CIVETWEBWS_BUILD_TARGETS += lib
CIVETWEBWS_INSTALL_TARGETS += install-lib
endif

ifeq ($(BR2_SHARED_LIBS)$(BR2_STATIC_SHARED_LIBS),y)
CIVETWEBWS_BUILD_TARGETS += slib
CIVETWEBWS_INSTALL_TARGETS += install-slib
endif

endif # BR2_PACKAGE_CIVETWEBWS_LIB

define CIVETWEBWS_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEBWS_BUILD_TARGETS) \
		$(CIVETWEBWS_CONF_OPTS) \
		COPT="$(CIVETWEBWS_COPT)" LIBS="$(CIVETWEBWS_LIBS)"
endef

define CIVETWEBWS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEBWS_INSTALL_TARGETS) \
		PREFIX="$(STAGING_DIR)/usr" \
		$(CIVETWEBWS_INSTALL_OPTS) \
		$(CIVETWEBWS_CONF_OPTS) \
		COPT='$(CIVETWEBWS_COPT)'
endef

define CIVETWEBWS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/include
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEBWS_INSTALL_TARGETS) \
		PREFIX="$(TARGET_DIR)/usr" \
		$(CIVETWEBWS_INSTALL_OPTS) \
		$(CIVETWEBWS_CONF_OPTS) \
		COPT='$(CIVETWEBWS_COPT)'
endef

$(eval $(generic-package))
