#/bin/bash

# EXECUTE: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/progdesigner/animation-generator/master/bin/install.sh)"
# EXECUTE: /bin/bash -c "$(curl -fsSL https://www.progdesigner.com/install.sh)"

PATH_LIB="/usr/local/Cellar"
PATH_BIN="/usr/local/bin"
LIB_NAME="animation-generator"
APP_NAME="grip"

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
    if command -v grip > /dev/null; then
      echo "grip is installed"
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

  rm -rf ${PATH_LIB}/${LIB_NAME}
  rm ${PATH_BIN}/${APP_NAME}
  mkdir -p ${PATH_LIB}/${LIB_NAME}
  cd ${PATH_LIB}
  git clone git@github.com:progdesigner/animation-generator.git ${LIB_NAME}

  # rsync -av "${PATH_BASE}/" "/usr/local/Cellar/animation-generator/" --exclude=dist --exclude=src --exclude=.git --exclude=.gitignore

  chmod +x "${PATH_LIB}/${LIB_NAME}/bin/generator.sh"
  cd "/usr/local/bin"
  ln -s "../Cellar/animation-generator/bin/generator.sh" ${APP_NAME}
}

execute $@
