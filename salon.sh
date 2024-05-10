#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "Welcome to My Salon, how can I help you?\n"

function show_services_menu() {
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
        echo -e "$SERVICE_ID) $SERVICE_NAME"
    done
}

function schedule_service() {
    show_services_menu

    read SERVICE_ID_SELECTED

    SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z "$SERVICE_EXISTS" ]]; then
        echo -e "I could not find that service. What would you like today?"
        schedule_service
        return
    fi

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_NAME=$(echo "$SERVICE_NAME" | sed 's/^[ \t]*//; s/[ \t]*$//')

    echo -e "\nWhat's your phone number?:"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed 's/^[ \t]*//; s/[ \t]*$//')

    if [[ -z "$CUSTOMER_NAME" ]]; then
        echo -e "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        
        INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $SERVICE_NAME , $CUSTOMER_NAME?"
    read SERVICE_TIME

    INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


schedule_service

