#!/bin/bash

CUR_PATH=$(pwd)
SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $SCRIPT_PATH

function gen-gittag {
    GITSHA=$(git log -1 --format="%h" $1)
    GITDATE_WZONE=$(git log -1 --format="%ai" $1)
    GITDATE=${GITDATE_WZONE:0:19}
    GITTAG="$GITDATE ($GITSHA)"
    echo $GITTAG
}

function prep_tmp_file {
    GITTAG=$(gen-gittag $1)
    echo $1
    sed -i s/"scm-tag"/"$GITTAG"/ /tmp/$1
}

cd ../scripts
for i in $(ls *.gv); do
    cp $i /tmp
    prep_tmp_file $i
    dot -Tsvg /tmp/$i > /tmp/${i%%.gv}.svg
    inkscape -zC -f /tmp/${i%%.gv}.svg -A ../tmp/${i%%.gv}.pdf
    #rm /tmp/${i%%.gv}*
done

cd ../svg
for i in $(ls *.svg); do
    cp $i /tmp
    prep_tmp_file $i
    inkscape -zC -f /tmp/$i -A ../tmp/${i%%.svg}.pdf
    #rm /tmp/$i
done

cd $CUR_PATH
