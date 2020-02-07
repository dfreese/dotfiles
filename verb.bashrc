#!/bin/bash

alias cdv="cd ${VERB_HOME}"
alias cdvv="cd ${VERB_HOME}/verb"

export RUNGUI_CREDENTIAL_FILE="${HOME}/credentials/daniel-test.json"

export TESTDIFF_DEFAULT_EXCLUDE="//verb/images/linux/...\
 //verb/sdk:api_test\
 //verb/libraries/gui/mode_switch:bridge_rebooting_view_model_test\
 //verb/libraries/gui/stadium_view/views/verb_system_views:verb_system_view_tests_no_delete_later\
 //verb/libraries/gui/stadium_view/models:unsafe_model_tests\
 //verb/sdk/generator:generator_test\
 //verb/libraries/gui/mode_switch:surgeon_bridge_disconnection_notifier_test\
 //verb/sdk/impl/event_registration/console:console_handler_collection_test\
 //verb/sdk/impl/event_registration/generator:generator_state_handler_collection_test\
 //verb/sdk/impl/event_registration/platform:platform_handler_collection_tests"

