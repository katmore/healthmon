#!/bin/sh
# wrapper to generate documentation
#

ME_ABOUT='wrapper to peform generate documentation'
ME_USAGE='[<...OPTIONS>] [[--]<...passthru args>]'
ME_COPYRIGHT='Copyright (c) 2018, Doug Bird. All Rights Reserved.'
ME_NAME='phpdox.sh'
ME_DIR="/$0"; ME_DIR=${ME_DIR%/*}; ME_DIR=${ME_DIR:-.}; ME_DIR=${ME_DIR#/}/; ME_DIR=$(cd "$ME_DIR"; pwd)

#
# paths
#
HTML_ROOT=$ME_DIR/web
DOC_ROOT=$ME_DIR/docs
PHPDOX_ROOT=$DOC_ROOT/phpdox
PHPDOX_HTML_ROOT=$PHPDOX_ROOT/html
PHPDOX_SYMLINK=$HTML_ROOT/.phpdox
APP_DIR=$ME_DIR

print_hint() {
   echo "  Hint, try: $ME_NAME --usage"
}

SKIP_PHPDOX=0
OPTION_STATUS=0
while getopts :?qhua-: arg; do { case $arg in
   h|u|a) HELP_MODE=1;;
   -) LONG_OPTARG="${OPTARG#*=}"; case $OPTARG in
      help|usage|about) HELP_MODE=1;;
      skip-phpdox) SKIP_PHPDOX=1;;
      *) >&2 echo "$ME_NAME: unrecognized long option --$OPTARG"; OPTION_STATUS=2;;
   esac ;; 
   *) >&2 echo "$ME_NAME: unrecognized option -$OPTARG"; OPTION_STATUS=2;;
esac } done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
[ "$OPTION_STATUS" != "0" ] && { >&2 echo "$ME_NAME: (FATAL) one or more invalid options"; >&2 print_hint; exit $OPTION_STATUS; }

if [ "$HELP_MODE" ]; then
   echo "$ME_NAME"
   echo "$ME_ABOUT"
   echo "$ME_COPYRIGHT"
   echo ""
   echo "Usage:"
   echo "  $ME_NAME $ME_USAGE"
   echo ""
   echo "Options:"
   echo "  --clean"
   echo "   Erase existing documentation contents before proceeding."
   echo ""
   echo "  --generate-pdf"
   echo "   Use 'wkhtmltopdf' and 'phpunite' to generate a PDF file from the HTML."
   echo ""
   echo "  --generate-md"
   echo "   Use 'html2markdown' to generate a markdown (.md) file from the HTML."
   exit 0
fi

if [ "$SKIP_PHPDOX" = "0" ]; then
   phpdox --version > /dev/null 2>&1 || {
      >&2 echo "$ME_NAME: (FATAL) system is missing the 'phpdox' command"
      exit 1 
   }
fi

if [ "$ME_DIR" != "$(pwd)" ]; then
  cd $ME_DIR || {
     >&2 echo "$ME_NAME: failed to change to app root directory"
     exit 1
  }
fi

REFORMAT_HTML_STATUS=0
reformat_html_status() {
   local message="$1"
   if [ -z "$message" ]; then return $REFORMAT_HTML_STATUS; fi
   local output=
   output="$ME_NAME: error during reformat of HTML"
   if [ ! -z "$message" ]; then
      output="$output: $message"
   fi
   >&2 echo "$output"
   REFORMAT_HTML_STATUS=$ME_ERROR_HTML_COVERAGE_REFORMAT_FAILED
   return $REFORMAT_HTML_STATUS
}

reformat_html() {
   local temp_PHPDOX_HTML_ROOT=
   echo "$ME_NAME: reformat HTML: started"
   [ -d "$PHPDOX_HTML_ROOT" ] || {
      reformat_html_status "directory not found: $PHPDOX_HTML_ROOT"; return $?
   }
   temp_PHPDOX_HTML_ROOT=$(cd "$PHPDOX_HTML_ROOT/../" && pwd) || {
      reformat_html_status "cannot stat parent directory: $PHPDOX_HTML_ROOT"; return $?
   }
   temp_PHPDOX_HTML_ROOT="$temp_PHPDOX_HTML_ROOT/.$(basename $PHPDOX_HTML_ROOT)"
   rm -rf $temp_PHPDOX_HTML_ROOT
   mkdir -p $temp_PHPDOX_HTML_ROOT || {
      reformat_html_status "failed to create temp dir: $temp_PHPDOX_HTML_ROOT"; return $?
   }
   rm -rf $temp_PHPDOX_HTML_ROOT/.html-files
   find $PHPDOX_HTML_ROOT -type f -name '*.*html' > $temp_PHPDOX_HTML_ROOT/.html-files || {
      reformat_html_status "failed to find HTML coverage files, 'find' terminated with exit status $?"; return $?
   }
   cp -Rp $PHPDOX_HTML_ROOT/. $temp_PHPDOX_HTML_ROOT/ || {
      reformat_html_status "failed to copy to temp dir: $temp_PHPDOX_HTML_ROOT"; return $?
   }
   local temp_filename=
   while read filename; do
      temp_filename=$(echo $filename | sed "s|$PHPDOX_HTML_ROOT|\\$temp_PHPDOX_HTML_ROOT|")
      sed "s|$APP_DIR/||g" $filename | sed "s|branch: devel||g" | sed "s|branch: master||g" | sed "s|-dirty||g" > $temp_filename
      #echo "temp_filename: $temp_filename"
      #echo "filename: $filename"
   done < $temp_PHPDOX_HTML_ROOT/.html-files
   echo "temp_PHPDOX_HTML_ROOT: $temp_PHPDOX_HTML_ROOT"
   echo "PHPDOX_HTML_ROOT: $PHPDOX_HTML_ROOT"
   local backup_dir=
   for i in $(seq 1 5); do
      backup_dir="$(dirname $PHPDOX_HTML_ROOT)/.$(basename $PHPDOX_HTML_ROOT)-"$(date "+%Y%m%d%H%M%S")
      [ ! -d "$backup_dir" ] && break
      sleep 1
   done
   mv $PHPDOX_HTML_ROOT $backup_dir || {
      reformat_html_status "failed to create backup coverage, 'mv' terminated with exit status $?"; return $?
   }
   mv $temp_PHPDOX_HTML_ROOT $PHPDOX_HTML_ROOT || {
      reformat_html_status "failed to replace coverage, 'mv' terminated with exit status $?"; return $?
   }
   echo "$ME_NAME: reformat HTML: complete"
}

if [ "$SKIP_PHPDOX" = "0" ]; then
   phpdox "$@" || exit
fi

reformat_html

if [ -d "$PHPDOX_HTML_ROOT" ]; then
   rm -f $PHPDOX_SYMLINK
   ln -s $PHPDOX_HTML_ROOT $PHPDOX_SYMLINK
fi 

reformat_html_status



