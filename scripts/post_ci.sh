CHANNEL="bartlebys"
REPOSITORY="Bartleby"
MESSAGE=$(git log --oneline -1)
REVISION=$(git rev-parse HEAD)

if [[ ( ${XCS_ERROR_COUNT} != 0 ) || ( ${XCS_TEST_FAILURE_COUNT} != 0 ) ]]
then
    COLOR="danger"
elif [[ ( ${XCS_WARNING_COUNT} != 0 ) || ( ${XCS_ANALYZER_WARNING_COUNT} != 0 ) ]]
then
    COLOR="warning"
else
    COLOR="good"
    exit 0
fi

PAYLOAD="{ \
    \"channel\": \"$CHANNEL\", \
    \"username\": \"Xcode CI\", \
    \"attachments\": [ \
    { \
        \"fallback\": \"${XCS_BOT_NAME}: ${XCS_INTEGRATION_RESULT}\", \
        \"color\": \"$COLOR\", \
        \"pretext\": \"\", \
        \"author_name\": \"$MESSAGE\", \
        \"author_link\": \"https://github.com/Bartlebys/$REPOSITORY/commit/$REVISION\", \
        \"author_icon\": \"\", \
        \"title\": \"${XCS_BOT_NAME}: ${XCS_INTEGRATION_RESULT}\", \
        \"title_link\": \"xcbot://xcodeci.lylo.tv/botID/${XCS_BOT_ID}/integrationID/${XCS_INTEGRATION_ID}\", \
        \"text\": \"\", \
        \"fields\": [ \
        { \
            \"title\": \"Errors\", \
            \"value\": \"${XCS_ERROR_COUNT}\", \
            \"short\": true \
        }, \
        { \
            \"title\": \"Warnings\", \
            \"value\": \"${XCS_WARNING_COUNT}\", \
            \"short\": true \
        }, \
        { \
            \"title\": \"Tests failed\", \
            \"value\": \"${XCS_TEST_FAILURE_COUNT} / ${XCS_TESTS_COUNT}\", \
            \"short\": true \
        }, \
        { \
            \"title\": \"Analyser warnings\", \
            \"value\": \"${XCS_ANALYZER_WARNING_COUNT}\", \
            \"short\": true \
        } \
        ], \
        \"image_url\": \"\", \
        \"thumb_url\": \"\" \
    } \
    ], \
    \"icon_emoji\": \":ghost:\" \
}"
echo $PAYLOAD
curl -X POST --data-urlencode "payload=${PAYLOAD}" --url https://hooks.slack.com/services/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
