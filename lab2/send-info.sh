#!/bin/bash
password="password"
remote_server="user@client_ip:/path/"
sshpass -p "$password" scp result_branching.txt result_loops.txt result_functions.txt server_info.txt $remote_server
