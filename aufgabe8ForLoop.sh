#!/bin/bash
# https://www.shellcheck.net << such a nice tool!

# Set a current start_time and store it. %s gives us the time since Unix Epoch
start_time=$(date +%s)
# Thanks ShellCheck. Using one line of code is much easier to type than typing multiple lines.
monitoring_config_element_id="1"

# Create an entry
# $1 and $2 are positioanl parameters for arguments.
create_entry() {
  local timestamp=$1
  local value=$2
  # We convert the Unix Timestamp to something more convenient.
  local formatted_timestamp=$(date -u -d @"$timestamp" +"%Y-%m-%dT%H:%M:%S")
  # The text we are entering to the sensor-values.json, but formatted as readable.
  echo "  {
    \"monitoringConfigElementID\": \"$monitoring_config_element_id\",
    \"timestamp\": \"$formatted_timestamp\",
    \"value\": \"$value\"
  }"
}

# Create the output_file.json as sensor-values since it is like that in the Aufgabe 7.
output_file="sensor-values.json"

# Start writing in the JSON Array/File, create the file if it is non-existent.
echo "[" > $output_file

# Start from 0 to 100.
first_entry=true
for i in {0..100}; do
  # Set the timestamp to start_time, which we set at the start. 
  # Then add multiply it with the current iteration number and add it to the timestamp.
  timestamp=$(($start_time + 2 * $i))

  # Call the create_entry() function with $1 and $2 positional parameters. 
  #$1 being the timestamp we just calculated, and $2 being the iteration number.
  # Since we start from the heart rate 0 and increase it by one every iteration, we log it as value.
  entry=$(create_entry $timestamp $i)

  # Put a comma if the entry is not the first entry.
  if $first_entry; then
    first_entry=false
  else
    echo "," >> $output_file
  # Close the if else with fi
  fi
  echo "$entry" >> $output_file
done

# Do the reverse
for i in {99..0}; do
  timestamp=$(($start_time + 2 * (200 - $i)))
  entry=$(create_entry $timestamp $i)
  if $first_entry; then
    first_entry=false
  else
    echo "," >> $output_file
  fi
  echo "$entry" >> $output_file
done

# End of the JSON Array
echo "]" >> $output_file

# Tell the user that the operation is finished
echo "The sensor values are logged in $output_file!"

# Delete the '#' after done with testing. We are not using variables in the places of userName and password since we only have one patient at the moment.
curl -u "patientUsername:patientPassowrd" -X POST -H "Content-Type: application/json" -d @$output_file http://IPAddress/patients/3/sensor-values


: <<'COMMENT_END'
multiple line comments are cool
Curl variables can be modified by following code, i think. And don't we need to save the hashed_password and the protected userName locally so we have access to it??
 
userName="usernamePatient"
password="passwordPatient"
server_address="IPAddressOfTheServer" # Server IP never changes in our case.
port="PortOfTheServer" # Port also stays the same.
patient_id="patientID"

curl -u "$username:$password" \
     -X POST \
     -H "Content-Type: application/json" \
     -d @"$output_file" \
     http://"$server_address":"$port"/patients/"$patient_id"/sensor-values
COMMENT_END
