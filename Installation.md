# Requirements #

Ada Server Faces has been compiled and tested on the following
platforms:

  * GNAT 2011 on Windows7 (gcc 4.5.3)
  * GNAT 2011 on Ubuntu (gcc 4.5.3)
  * gcc 4.4.3 on Ubuntu
  * gcc 4.6.2 on Ubuntu

You will need:

  * The AWS web server (compiled with SSL support),
  * The XML/Ada library,
  * Ada Util,
  * Ada EL

To build on Windows, you will need the [Mingw32 Msys](http://www.mingw.org/) package.

# Configuration #

On Unix platforms, configure with:

```
  ./configure --prefix=/usr
```

On Windows, you can configure with:

```
  ./configure --prefix=d:/installation/dir
```

# Build #

For all plateform, you should build with make as follows:

```
  make
```

# Manual Build #

In case of problem, you could also build by using gnatmake or gprbuild:

```
  gnatmake -p -Pasf
```