#!/bin/bash
#
# ralph schmieder <ralph.schmieder@gmail.com>
#
# inspired by
# https://stackoverflow.com/questions/20433867/git-ahead-behind-info-between-master-and-branch?lq=1


function show_help() {
    cat <<-EOF
	Usage: $0 [options]

	shows the number of commits the current working branch 
	is ahead and behind of another branch. By default, this is
	compared against the master branch. The branch to compare
	can be specified by the -b/--branch option.

    -b/--branch    specify branch to compare to (default=master)
    -j/--json      provide JSON output
    -o/--origin    if given, compares to origin (default is local)
    -h/--help      shows this
	EOF
}


BRANCH="master"
ORIGIN=""

# command line parsing
POSITIONAL=()
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -o|--origin)
        ORIGIN="origin/"
        shift # past argument
        ;;
        -j|--json)
        JSON="YES"
        shift # past argument
        ;;
        -b|--branch)
        BRANCH="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        show_help
        exit
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


onbranch=$(git rev-parse --abbrev-ref HEAD)
out=$(git rev-list --left-right --count ${ORIGIN}${BRANCH}...${ORIGIN}${onbranch})
test $? -gt 0 && exit

if [ -z "$JSON" ]; then
    echo -n "comparing to $ORIGIN${BRANCH}: "
    echo $out | awk '{print "⬅" $1 " ➡" $2 }'
else
    echo $out | sed -E "s/([0-9]+) ([0-9]+)/{\"behind\": \1, \"ahead\": \2}/"
fi

