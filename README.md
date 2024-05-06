# DNS Update Script

This script updates DNS records for a specified domain using the Porkbun API. It retrieves the current public IP address, compares it with the existing DNS records, and updates them if necessary.

## Setup

1. **Clone the Repository:**
```bash
  git clone https://github.com/clertonraf/porkbun-ddns.git
  cd porkbun-ddns
```

2. **Create a configuration file named *config.conf* with the following format**
```
apikey=pk1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
secretapikey=sk1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
domain=example.com
```

3. **Execute the following command to run the script**

```bash
./dns_update.sh
```

To run the script without updating the DNS records, use the `--dry-run` option:
```bash
./dns_update.sh --dry-run
```

Please note that the --dry-run option is not applicable when running the script as a systemd service.

## systemd Service

You can set up the script as a systemd service to run it automatically. Here's how:

1. **Create a systemd service unit file**

```bash
sudo nano /etc/systemd/system/dns_update.service
```
Add the following content to the file:

```bash
[Unit]
Description=DNS Update Script

[Service]
Type=simple
ExecStart=/path/to/your/script/dns_update.sh

[Install]
WantedBy=multi-user.target
```
Replace /path/to/your/script/ with the actual path where your script dns_update.sh is located.

2. **Enable and Start the Service**

After saving the changes to dns_update.service, enable and start the service using the following commands

```bash
sudo systemctl daemon-reload
sudo systemctl enable dns_update.service
sudo systemctl start dns_update.service
```

3. **Verify the Service Status**

You can verify that your service is running properly by checking its status
```bash
sudo systemctl status dns_update
```

4. **Schedule the Service to Run Every Hour**
You can use systemd's timer functionality to schedule the service to run every hour. Create a timer unit file named dns_update.timer in the same directory as your service unit file:

```bash
sudo nano /etc/systemd/system/dns_update.timer
```

Add the following content to the file:

```bash
[Unit]
Description=Run DNS Update Script Every Hour

[Timer]
OnCalendar=*-*-* *:00:00
Persistent=true

[Install]
WantedBy=timers.target
```
This configuration will run the service every hour at the beginning of the hour

6. **Enable and Start the Timer**

After saving the changes to dns_update.timer, enable and start the timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable dns_update.timer
sudo systemctl start dns_update.timer
```

# Troubleshooting
- **Permission Errors:** Ensure that the script has the necessary permissions to access and modify the DNS records and log files. You may need to adjust file permissions or run the script with elevated privileges.
- **Failure to Update DNS Records:** Check the log file for any error messages or debug information. Verify that the API credentials and domain information in the *config.conf* file are correct.