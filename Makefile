CC =      arm-apple-darwin-gcc \
		  -I./PurpleSupport/include/ \
		  -I./PurpleSupport/include/libxml2 \
		  -I./PurpleSupport/include/glib-2.0 \
		  -I./PurpleSupport/include/glib-2.0/glib \
		  -I./PurpleSupport/include/glib-2.0/gmodule \
		  -I/usr/local/arm-apple-darwin/include
LD = $(CC)
LDFLAGS =  -framework Message \
          -framework CoreFoundation \
          -framework Foundation \
          -framework UIKit \
          -framework IOKit \
          -framework LayerKit \
          -framework CoreGraphics \
          -framework CoreTelephony \
          -framework GraphicsServices \
          -framework CoreSurface \
          -framework Celestial \
          -framework CoreAudio \
          -framework Message \
        	-framework WebCore \
        	-framework WebKit \
          -L./PurpleSupport/lib \
      	  -lobjc \
      	  -lz \
		  -lpurple \
		  -loscar \
		  -lqq \
		  -lgg \
		  -lzephyr \
		  -lirc \
		  -ljabber \
		  -lglib-2.0 \
		  -lgmodule-2.0 \
		  -lxml2 \
		  -lmsn  

#CFLAGS = -DDEBUG

all:	mGadu package

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
	
mGadu: main.o ApolloApp.o EyeCandy.o Preferences.o Buddy.o Event.o User.o LoginCell.o LoginView.o ProtocolManager.o \
	UserManager.o BuddyCell.o BuddyListView.o BuddyAddView.o BuddyEditView.o BuddyStatusView.o ViewController.o \
	AccountEditView.o AccountTypeSelector.o Conversation.o ConversationView.o SendBox.o ShellKeyboard.o ConvWrapper.o \
	PurpleInterface.o ApolloCore.o ApolloNotificationController.o AddressBook.o sqlite3.o ImportView.o PrefsView.o ArchiveView.o
			$(LD) $(LDFLAGS) -o $@ $^	./PurpleSupport/lib/libintl.a ./PurpleSupport/lib/libgnt.a ./PurpleSupport/lib/libiconv.a ./PurpleSupport/lib/libresolv.a 

clean:
	rm -f *.o mGadu

package:
	rm -rf mGadu.app
	mkdir -p mGadu.app/Plugins
	cp mGadu ./mGadu.app/
#	cp ./Plugins/ssl-gnutls.so ./mGadu.app/Plugins/
#	cp ./Plugins/ssl.so ./mGadu.app/Plugins/
	cp ./PurpleSupport/hosts ./mGadu.app/
	cp resources/*.plist ./mGadu.app/
	cp resources/images/*.png ./mGadu.app/
	cp resources/sounds/* ./Media/
#	chmod 755 ./mGadu.app/Apollo
#	chmod 755 ./mGadu.app/vibrator

