#/bin/bash

# EXECUTE: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/progdesigner/hls-convertor/master/bin/install.sh)"
# EXECUTE: /bin/bash -c "$(curl -fsSL https://www.progdesigner.com/install.sh)"

PATH_LIB="/usr/local/Cellar"
PATH_BIN="/usr/local/bin"
LIB_NAME="hls-convertor"
APP_NAME="mcl"

function execute() {
  COMMAND="$0"
  SKIP=0
  OPTIONS=()

  if [ "$COMMAND" == "--skip" ]; then
    SKIP=1
  fi

  while [[ $# -gt 0 ]]
  do
    PARAM="$1"
    case $PARAM in
      --skip)
        SKIP=1
        shift # past value
      ;;

      *) # unknown option
        OPTIONS+=($1)
        shift # past argument
      ;;
    esac
  done


  if [ $SKIP -lt 1 ]; then
    if command -v mcl > /dev/null; then
      echo "mcl is installed"
      exit 0
    fi
  fi

  if command -v brew > /dev/null; then
    echo "brew is installed"
  else
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
  fi

  if brew ls --versions webp > /dev/null; then
    echo "WebP is installed"
  else
    brew install webp
  fi

  if brew ls --versions imagemagick > /dev/null; then
    echo "ImageMagick is installed"
  else
    brew install webp imagemagick
  fi

  if brew ls --versions ffmpeg > /dev/null; then
    echo "ffmpeg is installed"
  else
    xcode-select --install

    brew install ffmpeg --with-fdk-aac --with-tools
  fi

  rm -rf ${PATH_LIB}/${LIB_NAME}
  rm ${PATH_BIN}/${APP_NAME}
  mkdir -p ${PATH_LIB}/${LIB_NAME}
  cd ${PATH_LIB}
  git clone https://github.com/progdesigner/hls-convertor.git ${LIB_NAME}

  # rsync -av "${PATH_BASE}/" "/usr/local/Cellar/hls-convertor/" --exclude=dist --exclude=src --exclude=.git --exclude=.gitignore

  chmod +x "${PATH_LIB}/${LIB_NAME}/bin/generator.sh"
  cd "/usr/local/bin"
  ln -s "../Cellar/hls-convertor/bin/generator.sh" ${APP_NAME}
}

execute $@
