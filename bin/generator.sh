#/bin/bash

VERSION="0.1.1"

EXEC_FILE="$0"
BASE_NAME=`basename "$EXEC_FILE"`
PATH_CURRENT=`pwd`
PATH_BASE=${PATH_CURRENT}
{
	if [ "$EXEC_FILE" = "./$BASE_NAME" ] || [ "$EXEC_FILE" = "$BASE_NAME" ]; then
		PATH_BASE=`pwd`
	else
		PATH_BASE=`echo "$EXEC_FILE" | sed 's/'"${BASE_NAME}"'$//'`
	    cd "${PATH_BASE}" > /dev/null 2>&1
	    PATH_BASE=`pwd`
	fi

	cd "${PATH_BASE}/.."
	export PATH_BASE=`pwd`
	cd ${PATH_CURRENT}
}

PATH_BIN="${PATH_BASE}/bin"
PATH_SRC="${PATH_CURRENT}"
PATH_DIST="${PATH_CURRENT}/dist"

function before_convert() {
  mkdir -p ${PATH_DIST}
  mkdir -p ${PATH_SRC}
}

function convert_hls() {

  echo "Convert MP4 to HLS" $@

  # Default Options
  FILE_SOURCE="input.mp4"
  FILE_DIST=""
  BACKGROUND=""
  DELAY=0
  ARGS=()

  while [[ $# -gt 0 ]]
  do
    PARAM="$1"
    case $PARAM in
        -s|--source)
          FILE_SOURCE="$2"
          shift # past argument
          shift # past value
        ;;

        -o|--dist)
          FILE_DIST="$2"
          shift # past argument
          shift # past value
        ;;

        *)    # unknown option
          ARGS+=($1)
          shift # past argument
        ;;
    esac
  done

  # Create Backup
  if [ -e "${PATH_DIST}/${FILE_DIST}/index.m3u8" ]; then
    rm -rf "${PATH_DIST}/${FILE_DIST}.backup"
    mv ${PATH_DIST}/${FILE_DIST} "${PATH_DIST}/${FILE_DIST}.backup"
  fi

  # Generate HLS
  echo "Generating HLS..."
  # info: https://www.keycdn.com/support/how-to-convert-mp4-to-hls
  ffmpeg -i "${PATH_SRC}/${FILE_SOURCE}" -profile:v baseline -level 3.0 -s 640x360 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls "${PATH_DIST}/${FILE_DIST}"
  echo "Generated HLS"
}

function convert_gif() {

  echo "Convert PNGs to GIF" $@

  # Default Options
  FILE_SOURCE="*.png"
  FILE_DIST_NAME="animated"
  BACKGROUND=""
  DELAY=0
  ARGS=()

  while [[ $# -gt 0 ]]
  do
    PARAM="$1"
    case $PARAM in
        -s|--source)
          FILE_SOURCE="$2"
          shift # past argument
          shift # past value
        ;;

        -o|--dist)
          FILE_DIST_NAME="$2"
          shift # past argument
          shift # past value
        ;;

        -b|--background)
          BACKGROUND="$2"
          shift # past argument
          shift # past value
        ;;

        -d|--delay)
          DELAY=$2
          shift # past argument
          shift # past value
        ;;

        *)    # unknown option
          ARGS+=($1)
          shift # past argument
        ;;
    esac
  done

  # Variables
  FILE_DIST="${FILE_DIST_NAME}.gif"
  SEQUENCES=(`find ${PATH_SRC} -type f -name "${FILE_SOURCE}" | sort -t'/' -k2.1 -k2.2r`)
  COUNT="${#SEQUENCES[@]}"
  CONVERT_OPTIONS="-delay 0 -loop 0 -layers optimize-frame -layers optimize-transparency"

  if [ "${BACKGROUND}" != "" ]; then
    CONVERT_OPTIONS+=" -background ${BACKGROUND} -alpha remove -alpha off"
  fi

  if [ "${COUNT}" = "0" ]; then
    echo "Resource Files isn't exists."
    exit 0
  fi

  # Create Backup
  if [ -e "${PATH_DIST}/${FILE_DIST}" ]; then
    rm -rf "${PATH_DIST}/${FILE_DIST}.backup"
    mv ${PATH_DIST}/${FILE_DIST} "${PATH_DIST}/${FILE_DIST}.backup"
  fi

  # Generate GIF
  echo "Generating GIF..."
  # info: http://www.imagemagick.org/script/command-line-options.php?#layers
  convert ${CONVERT_OPTIONS} ${SEQUENCES[*]} "${PATH_DIST}/${FILE_DIST}"
  echo "Generated GIF"

  FILE_SIZE=`du -k "${PATH_DIST}/${FILE_DIST}" | cut -f1`
  echo "FileSize: ${FILE_SIZE}kb"
}

function convert_webp() {

  echo "Convert PNGs to WebP"

  # Default Options
  FILE_SOURCE="*.png"
  FILE_DIST_NAME="animated"
  DELAY=1
  QUALITY=50
  ARGS=()

  while [[ $# -gt 0 ]]
  do
    PARAM="$1"
    case $PARAM in
        -s|--source)
          FILE_SOURCE="$2"
          shift # past argument
          shift # past value
        ;;

        -o|--dist)
          FILE_DIST_NAME="$2"
          shift # past argument
          shift # past value
        ;;

        -q|--quality)
          QUALITY=$2
          shift # past argument
          shift # past value
        ;;

        -d|--delay)
          if [ $2 -ge 1 ]; then
            DELAY=$2
          fi
          shift # past argument
          shift # past value
        ;;

        *)    # unknown option
          ARGS+=($1)
          shift # past argument
        ;;
    esac
  done

  # Variables
  FILE_DIST="${FILE_DIST_NAME}.webp"
  SEQUENCES=(`find ${PATH_SRC} -type f -name "${FILE_SOURCE}" | sort -t'/' -k2.1 -k2.2r`)
  COUNT="${#SEQUENCES[@]}"
  FILE_OPTIONS="-loop 0"
  PRE_OPTIONS="-q ${QUALITY} -d ${DELAY} ${ARGS[*]}"

  if [ "${COUNT}" = "0" ]; then
    echo "Resource Files isn't exists."
    exit 0
  fi

  # Create Backup
  if [ -e "${PATH_DIST}/${FILE_DIST}" ]; then
    rm -rf "${PATH_DIST}/${FILE_DIST}.backup"
    mv ${PATH_DIST}/${FILE_DIST} "${PATH_DIST}/${FILE_DIST}.backup"
  fi

  # Generate WebP
  echo "Generating WebP..."
  img2webp ${FILE_OPTIONS} ${SEQUENCES[*]} -o "${PATH_DIST}/${FILE_DIST}" ${PRE_OPTIONS}
  echo "Generated WebP"

  FILE_SIZE=`du -k "${PATH_DIST}/${FILE_DIST}" | cut -f1`
  echo "FileSize: ${FILE_SIZE}kb"
}

function cli_update() {
  mkdir -p "/usr/local/Cellar/hls-generator"
  rsync -av "${PATH_BASE}/" "/usr/local/Cellar/hls-generator/" --exclude=dist --exclude=src --exclude=.git --exclude=.gitignore
  chmod +x "/usr/local/Cellar/hls-generator/bin/generator.sh"
}

function help() {
  echo "Animation Generator ${VERSION}"
  echo "Copyright: © 2019 ProgDesigner."
  echo "MIT License"
  echo "Usage: mcl generate [options ...] file [ [options ...] file ...] [options ...] file"
  echo ""
  echo "Options Settings:"
  echo "  -s|--source             source path"
  echo "  -o|--dist               distribution path"
  echo ""
  echo "  [image]"
  echo "  -d|--delay value        display the next image after pausing"
  echo "  -q|--quality value      specify the compression factor between 0 and 100. The default is 75."
  echo "  -b|--background color   background color"
  echo "                            for example,"
  echo "                              blue"
  echo "                              \"#ddddff\""
  echo "                              \"rgb(255, 255, 255)\""
  echo ""
}

function generate() {
  COMMAND=$1
  shift

  ARGS=$@

  case ${COMMAND} in
    gif)
      before_convert

      convert_gif $ARGS

      # Open Folder
      open -a "Finder" "${PATH_DIST}"
    ;;

    webp)
      before_convert

      convert_webp $ARGS

      # Open Folder
      open -a "Finder" "${PATH_DIST}"
    ;;

    hls)
      before_convert

      convert_hls $ARGS

      # Open Folder
      open -a "Finder" "${PATH_DIST}"
    ;;

    *)
      help
    ;;
  esac
}

function execute() {
  COMMAND=$1
  shift

  case ${COMMAND} in
    generate)
      generate $@
    ;;

    *)
      help
    ;;
  esac
}

execute $@
