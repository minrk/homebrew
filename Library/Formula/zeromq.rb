require 'formula'

class Zeromq <Formula
  url 'http://download.zeromq.org/zeromq-2.1.1.tar.gz'
  head 'git://github.com/zeromq/zeromq2.git'
  homepage 'http://www.zeromq.org/'
  md5 '987079513e4816979e4e3bd52ac4b0a7'

  def options
    [['--universal', 'Build as a Universal Intel binary.']]
  end

  def build_fat
    # make 32-bit
    arch = "-arch i386"
    system "CFLAGS=\"$CFLAGS #{arch}\" CXXFLAGS=\"$CXXFLAGS #{arch}\" ./configure --disable-dependency-tracking --prefix=#{prefix}"
    system "make"
    system "mv src/.libs src/libs-32"
    system "make clean"

    # make 64-bit
    arch = "-arch x86_64"
    system "CFLAGS=\"$CFLAGS #{arch}\" CXXFLAGS=\"$CXXFLAGS #{arch}\" ./configure --disable-dependency-tracking --prefix=#{prefix}"
    system "make"
    system "mv src/.libs/libzmq.1.dylib src/.libs/libzmq.64.dylib"

    # merge UB
    system "lipo", "-create", "src/libs-32/libzmq.1.dylib", "src/.libs/libzmq.64.dylib", "-output", "src/.libs/libzmq.1.dylib"
  end

  def install
    system "./autogen.sh" if ARGV.build_head?

    if ARGV.include? '--universal'
      build_fat
    else
      system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    end

    system "make install"
  end

  def caveats; <<-EOS.undent
    To install the zmq gem on 10.6 with the system Ruby on a 64-bit machine,
    you may need to do:
      $ ARCHFLAGS="-arch x86_64" gem install zmq -- --with-zmq-dir=#{HOMEBREW_PREFIX}

    If you want to later build the Java bindings from https://github.com/zeromq/jzmq,
    you will need to obtain the Java Developer Package from Apple ADC
    at http://connect.apple.com/.

    The Python bindings can be installed with:
      $ easy_install pyzmq
    or get development versions from http://github.com/zeromq/pyzmq.
    EOS
  end
end