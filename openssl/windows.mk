SOURCEFILES = ..\core\pubnub_coreapi.c ..\core\pubnub_ccore.c ..\core\pubnub_netcore.c  pbpal_openssl.c pbpal_resolv_and_connect_openssl.c pbpal_add_system_certs_windows.c ..\core\pubnub_alloc_std.c ..\core\pubnub_assert_std.c ..\core\pubnub_generate_uuid.c ..\core\pubnub_blocking_io.c ..\core\pubnub_timers.c ..\core\pubnub_json_parse.c  ..\core\pubnub_proxy.c ..\core\pubnub_proxy_core.c ..\core\pbhttp_digest.c ..\lib\md5\md5.c ..\core\pbntlm_core.c ..\core\pbntlm_packer_sspi.c ..\windows\pubnub_set_proxy_from_system_windows.c  ..\core\pubnub_helper.c pubnub_version_openssl.c  ..\windows\pubnub_generate_uuid_windows.c pbpal_openssl_blocking_io.c ..\lib\base64\pbbase64.c ../core/pubnub_crypto.c ../core/pubnub_coreapi_ex.c pbaes256.c ..\core\c99\snprintf.c

OBJFILES = pubnub_coreapi.obj pubnub_ccore.obj pubnub_netcore.obj  pbpal_openssl.obj pbpal_resolv_and_connect_openssl.obj pbpal_add_system_certs_windows.obj pubnub_alloc_std.obj pubnub_assert_std.obj pubnub_generate_uuid.obj pubnub_blocking_io.obj pubnub_timers.obj pubnub_json_parse.obj pubnub_proxy.obj pubnub_proxy_core.obj pbhttp_digest.obj md5.obj pbntlm_core.obj pbntlm_packer_sspi.obj pubnub_set_proxy_from_system_windows.obj pubnub_helper.obj pubnub_version_openssl.obj pubnub_generate_uuid_windows.obj pbpal_openssl_blocking_io.obj  pbbase64.obj pubnub_crypto.obj pubnub_coreapi_ex.obj pbaes256.obj snprintf.obj

!ifndef OPENSSLPATH
OPENSSLPATH=c:\OpenSSL-Win32
!endif

LIBS=ws2_32.lib rpcrt4.lib $(OPENSSLPATH)\lib\ssleay32.lib $(OPENSSLPATH)\lib\libeay32.lib

CFLAGS = /Zi /MP /D PUBNUB_LOG_LEVEL=PUBNUB_LOG_LEVEL_WARNING /W3 /D PUBNUB_USE_WIN_SSPI=1

# /Zi enables debugging, remove to get a smaller .exe and no .pdb
# /MP uses one compiler (`cl`) process for each input file, enabling faster build

INCLUDES=/I ..\core /I . /I ..\windows\fntest /I ..\core\fntest /I ..\lib\base64 /I ..\core\c99 /I $(OPENSSLPATH)\include

all: pubnub_sync_sample.exe pubnub_crypto_sync_sample.exe cancel_subscribe_sync_sample.exe subscribe_publish_callback_sample.exe pubnub_callback_sample.exe pubnub_fntest.exe pubnub_console_sync.exe pubnub_console_callback.exe

pubnub_sync.lib: $(SOURCEFILES) ..\core\pubnub_ntf_sync.c
	$(CC) -c $(CFLAGS) $(INCLUDES) $(SOURCEFILES) ..\core\pubnub_ntf_sync.c 
	lib $(OBJFILES) pubnub_ntf_sync.obj -OUT:$@

pubnub_callback.lib : $(SOURCEFILES) pubnub_ntf_callback_windows.c pubnub_get_native_socket.c ..\core\pubnub_timer_list.c
	$(CC) -c $(CFLAGS) -DPUBNUB_CALLBACK_API $(INCLUDES) $(SOURCEFILES) pubnub_ntf_callback_windows.c pubnub_get_native_socket.c ..\core\pubnub_timer_list.c
	lib $(OBJFILES) pubnub_ntf_callback_windows.obj pubnub_get_native_socket.obj pubnub_timer_list.obj -OUT:$@
    
pubnub_sync_sample.exe: ..\core\samples\pubnub_sync_sample.c pubnub_sync.lib
	$(CC) $(CFLAGS) $(INCLUDES) ..\core\samples\pubnub_sync_sample.c pubnub_sync.lib $(LIBS)

pubnub_crypto_sync_sample.exe: ..\core\samples\pubnub_crypto_sync_sample.c pubnub_sync.lib
	$(CC) $(CFLAGS) $(INCLUDES) ..\core\samples\pubnub_crypto_sync_sample.c pubnub_sync.lib $(LIBS)

cancel_subscribe_sync_sample.exe: ..\core\samples\cancel_subscribe_sync_sample.c pubnub_sync.lib
	$(CC) $(CFLAGS) $(INCLUDES) ..\core\samples\cancel_subscribe_sync_sample.c pubnub_sync.lib $(LIBS)

pubnub_callback_sample.exe: ..\core\samples\pubnub_callback_sample.c pubnub_callback.lib
	$(CC) $(CFLAGS) -DPUBNUB_CALLBACK_API $(INCLUDES) ..\core\samples\pubnub_callback_sample.c  pubnub_callback.lib $(LIBS)

subscribe_publish_callback_sample.exe: ..\core\samples\subscribe_publish_callback_sample.c pubnub_callback.lib
	$(CC) $(CFLAGS) -DPUBNUB_CALLBACK_API $(INCLUDES) ..\core\samples\subscribe_publish_callback_sample.c  pubnub_callback.lib $(LIBS)

pubnub_fntest.exe: ..\core\fntest\pubnub_fntest.c ..\core\fntest\pubnub_fntest_basic.c ..\core\fntest\pubnub_fntest_medium.c  ..\windows\fntest\pubnub_fntest_windows.c ..\windows\fntest\pubnub_fntest_runner.c pubnub_sync.lib
	$(CC) $(CFLAGS) $(INCLUDES) ..\core\fntest\pubnub_fntest.c ..\core\fntest\pubnub_fntest_basic.c ..\core\fntest\pubnub_fntest_medium.c ..\windows\fntest\pubnub_fntest_windows.c ..\windows\fntest\pubnub_fntest_runner.c pubnub_sync.lib $(LIBS)

CONSOLE_SOURCEFILES=..\core\samples\console\pubnub_console.c ..\core\samples\console\pnc_helpers.c ..\core\samples\console\pnc_readers.c ..\core\samples\console\pnc_subscriptions.c

pubnub_console_sync.exe: $(CONSOLE_SOURCEFILES) ..\core\samples\console\pnc_ops_sync.c  pubnub_sync.lib
	$(CC) /Fe:$@ $(CFLAGS) /D _CRT_SECURE_NO_WARNINGS $(INCLUDES) $(CONSOLE_SOURCEFILES) ..\core\samples\console\pnc_ops_sync.c  pubnub_sync.lib $(LIBS)

pubnub_console_callback.exe: $(CONSOLE_SOURCEFILES) ..\core\samples\console\pnc_ops_callback.c pubnub_callback.lib
	$(CC) /Fe:$@ $(CFLAGS) /D _CRT_SECURE_NO_WARNINGS -D PUBNUB_CALLBACK_API $(INCLUDES) $(CONSOLE_SOURCEFILES) ..\core\samples\console\pnc_ops_callback.c pubnub_callback.lib $(LIBS)
    
clean:
	del *.exe
	del *.obj
	del *.pdb
	del *.il?
	del *.lib
