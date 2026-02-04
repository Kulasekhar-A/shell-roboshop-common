#!/bin/bash

app_name=payment
source ./common.sh

check_root
app_setup
python_setup
systemd_setup

restart_setup
print_total_time