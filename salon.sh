#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo "How may I help you?" 

# get services
SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
LIST_SERVICES() {
  # display services
  echo -e "\nHere are the services we have:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU() {
  LIST_SERVICES

  # ask for service
  echo -e "\nWhich service would you like? Please enter its number."
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    echo "That is not a valid service number."
    MAIN_MENU
  else
    # confirm selected valid service number
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # if not valid service number
    if [[ -z $SERVICE_ID ]]
    then
      # send to main menu
      echo "That is not a valid service number."
      MAIN_MENU
    else
      GET_INFO
    fi
  fi
}

# get customer info
GET_INFO() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # get appointment time
  echo -e "\nWhat time will your appointment be?"
  read SERVICE_TIME

  # create appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")

  # get bike info
  SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  
  # finish
  echo -e "\nI have put you down for a$SERVICE_INFO at $SERVICE_TIME,$CUSTOMER_NAME."
}

MAIN_MENU