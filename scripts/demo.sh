#!/bin/sh

#  Cmds.sh
#  bsync
#
#  Created by Benoit Pereira da silva on 11/01/2016.
#  Copyright © 2016 Benoit Pereira da silva. All rights reserved.


##########################
# HOW TO USE THIS DEMO ? #
##########################

# 1 Copy bsync to /usr/local/bin/
# 2 Create the folders ~/Desktop/Samples/Assets/ on your Desktop.
# 3 Copy some medias in this folder and sub folders...
# 4 run this script . demo.sh

# DEMO

clear

# Make the script to on error
set -e

# CONST

PATH_TO_CONTENT_TO_COPY=~/Desktop/Samples/assets

SALT=xyx38-d890x-899h-123e-30x6-3234e
SECRET_KEY=XODVBRkNGMUYtRDI1RS00Mjc2LTlGM0EtMTU1N0Q22838
TREE_ID=TREE-DEMO1 # the tree id will become a local folder
DIRECTIVES_FILENAME=directives.bsync
EMAIL=demo@bartlebys.org
PASSWORD=123456

#API_BASE_URL=https://pereira-da-silva.com/clients/lylo/www/api/v1/
#API_BASE_URL=https://api.lylo.tv/www/api/v1/
#API_BASE_URL=https://dev.api.lylo.tv/www/api/v1/
API_BASE_URL=http://yd.local/api/v1/

# the base url is ~/Desktop/UP_SYNC_DEMO/ and the treeiD
BASE_UP_FOLDER=~/Desktop/UP_SYNC_DEMO
UP_FOLDER_PATH=${BASE_UP_FOLDER}/${TREE_ID}
UP_DIRECTIVES_PATH=${BASE_UP_FOLDER}/${DIRECTIVES_FILENAME}

BASE_DOWN_FOLDER=~/Desktop/DOWN_SYNC_DEMO
DOWN_FOLDER_PATH=${BASE_DOWN_FOLDER}/${TREE_ID}
DOWN_DIRECTIVES_PATH=${BASE_DOWN_FOLDER}/${DIRECTIVES_FILENAME}

echo ""
echo "Run destructive installer on server"
echo ""

curl ${API_BASE_URL}/generated_destructiveInstaller.php

echo ""
echo "Creation of dummy content..."
echo ""

rm -rf ${BASE_UP_FOLDER}
mkdir -p ${UP_FOLDER_PATH}
touch ${UP_FOLDER_PATH}/file1.txt
echo "Eureka 1" > ${UP_FOLDER_PATH}/file1.txt

mkdir ${UP_FOLDER_PATH}/SubFolderA/
touch ${UP_FOLDER_PATH}/SubFolderA/file2.txt
echo "Eureka 2" > ${UP_FOLDER_PATH}/SubFolderA/file2.txt

cp -rf ${PATH_TO_CONTENT_TO_COPY} ${UP_FOLDER_PATH}

########################
# FIRST PHASE UP-SYNC
########################


echo ""
echo "########################"
echo "# FIRST PHASE UP-SYNC"
echo "########################"
echo ""

# Create a data space

echo "Create data space"
SPACE_ID=$(bsync create-uid)
echo $SPACE_ID

# Create a user

echo "Create a user"
USER_ID=$(bsync create-user \
    --api $API_BASE_URL \
    --spaceUID ${SPACE_ID} \
    --password $PASSWORD \
    --email $EMAIL \
    --secretKey $SECRET_KEY \
    --salt $SALT)
echo $USER_ID

# Let's create the synchronization directives

bsync create-directives \
        --file ${UP_DIRECTIVES_PATH} \
        --source ${UP_FOLDER_PATH} \
        --destination ${API_BASE_URL}BartlebySync/tree/${TREE_ID} \
        --user ${USER_ID} \
        --password ${PASSWORD} \
        --salt ${SALT} \
        --secretKey ${SECRET_KEY} \
        --automatic-trees-creation \
        -v
        # To be supported soon
        # --hashMapViewName userName


# Let's reveal the synchronization directives

echo ""
echo "reveal-directives"
echo ""

bsync reveal-directives \
        --file ${UP_DIRECTIVES_PATH}\
        --salt ${SALT} \
        --secretKey ${SECRET_KEY} \
        -v

# Let's run the synchronization directives

echo ""
echo "run"
echo ""

bsync run \
        --file ${UP_DIRECTIVES_PATH} \
        --salt ${SALT} \
        --secretKey ${SECRET_KEY} \
        --verbose

##########################
# SECOND PHASE DOWN-SYNC
##########################

echo ""
echo "########################"
echo "# SECOND PHASE DOWN-SYNC"
echo "########################"
echo ""


# Let's create the synchronization directives
# notice that folde paths should not end with a /


rm -rf ${BASE_DOWN_FOLDER}
mkdir -p ${DOWN_FOLDER_PATH}

bsync create-directives \
    --file ${DOWN_DIRECTIVES_PATH} \
    --source ${API_BASE_URL}BartlebySync/tree/${TREE_ID} \
    --destination ${DOWN_FOLDER_PATH} \
    --user ${USER_ID} \
    --password ${PASSWORD} \
    --salt ${SALT} \
    --secretKey ${SECRET_KEY} \
    --automatic-trees-creation \
    -v \
    # To be supported soon
    # --hashMapViewName userName

echo ""
echo "reveal-directives"
echo ""

bsync reveal-directives \
    --file ${DOWN_DIRECTIVES_PATH} \
    --salt ${SALT} \
    --secretKey ${SECRET_KEY} \
    -v

echo ""
echo "run"
echo ""

bsync run \
    --file ${DOWN_DIRECTIVES_PATH} \
    --salt ${SALT} \
    --secretKey ${SECRET_KEY} \
    --verbose

echo ""
echo "bye"
echo ""

