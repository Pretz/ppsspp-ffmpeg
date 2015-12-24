#!/bin/bash
#build ffmpeg for armv7,armv7s and uses lipo to create fat libraries and deletes the originals
PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/

CC='xcrun -sdk iphoneos clang'

GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --enable-vfp \
   --enable-zlib \
   --enable-static"

MODULES="\
   --disable-filters \
   --disable-programs \
   --disable-network \
   --disable-avfilter \
   --disable-postproc \
   --disable-encoders \
   --disable-protocols \
   --disable-hwaccels \
   --disable-doc"

VIDEO_DECODERS="\
   --enable-decoder=h264 \
   --enable-decoder=mpeg4 \
   --enable-decoder=mpeg2video \
   --enable-decoder=mjpeg \
   --enable-decoder=mjpegb"

AUDIO_DECODERS="\
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=atrac3 \
    --enable-decoder=atrac3p \
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8"

DEMUXERS="\
    --enable-demuxer=h264 \
    --enable-demuxer=m4v \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=mpegps \
    --enable-demuxer=mp3 \
    --enable-demuxer=avi \
    --enable-demuxer=aac \
    --enable-demuxer=pmp \
    --enable-demuxer=oma \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=wav"

PARSERS="\
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegaudio \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=aac_latm"

VIDEO_ENCODERS="\
	  --enable-encoder=mjpeg"

AUDIO_ENCODERS="\
	  --enable-encoder=pcm_s16le"

MUXERS="\
  	--enable-muxer=avi"

./configure \
    --prefix=ios/arm64 \
    --cc="$CC" \
    $GENERAL \
    --sysroot="$PLATFORM/SDKs/iPhoneOS.sdk" \
    --extra-cflags="-arch arm64 -miphoneos-version-min=6.0" \
    --disable-shared \
    --extra-ldflags="-arch arm64 -isysroot $PLATFORM/SDKs/iPhoneOS.sdk -miphoneos-version-min=6.0" \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS} \
    --target-os=darwin \
    --arch=arm64
    

if [ "$?" != "0" ]; then
    exit 1;
fi

make clean
make && make install

if [ "$?" != "0" ]; then
    exit 1;
fi

./configure \
    --prefix=ios/armv7 \
    --cc="$CC" \
    $GENERAL \
    --sysroot="$PLATFORM/SDKs/iPhoneOS.sdk" \
    --extra-cflags="-arch armv7 -mfpu=neon -miphoneos-version-min=6.0" \
    --disable-shared \
    --extra-ldflags="-arch armv7 -isysroot $PLATFORM/SDKs/iPhoneOS.sdk -miphoneos-version-min=6.0" \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
		${MUXERS} \
    ${PARSERS} \
    --target-os=darwin \
    --enable-neon \
    --cpu=cortex-a8 \
    --arch=arm

make clean
make && make install

if [ "$?" != "0" ]; then
    exit 1;
fi

./configure \
    --prefix=ios/armv7s \
    --cc="$CC" \
    $GENERAL \
    --sysroot="$PLATFORM/SDKs/iPhoneOS.sdk" \
    --extra-cflags="-arch armv7s -mfpu=neon -miphoneos-version-min=6.0" \
    --disable-shared \
    --extra-ldflags="-arch armv7s -isysroot $PLATFORM/SDKs/iPhoneOS.sdk -miphoneos-version-min=6.0" \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS} \
    --target-os=darwin \
    --enable-neon \
    --cpu=cortex-a9 \
    --arch=arm

make clean
make && make install

if [ "$?" != "0" ]; then
    exit 1;
fi

cd ios
mkdir -p universal/lib

for LIB in libavformat.a libavutil.a libswresample.a libavcodec.a libswscale.a libavdevice.a
do
  xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/$LIB \
  -arch armv7s armv7s/lib/$LIB \
  -arch arm64 arm64/lib/$LIB \
  -output universal/lib/$LIB
done

cp -r armv7/include universal/

rm -rf armv7 armv7s arm64
