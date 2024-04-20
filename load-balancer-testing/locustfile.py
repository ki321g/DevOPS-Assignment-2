from locust import HttpUser, task, between
import re
import csv

"""
Performs an HTTP GET request to the `/about` endpoint and extracts relevant information from the response. 

The extracted information includes the current date and time, the instance ID, AWS region, and availability zone. 

This information is then written to a CSV file named `load-balancer-test.csv`.

The `aboutTest` method is decorated with the `@task` decorator, which means it will be executed as a user task during the load test. The method performs the following steps:

1. Sends an HTTP GET request to the `/about` endpoint using the `self.client.get()` method.
2. Extracts the 'Date' header from the response and formats it to remove the day of the week and 'GMT'.
3. Extracts the instance ID, AWS region, and availability zone from the response body and formats the information.
4. Writes the extracted information to a CSV file named `load-balancer-test.csv`. If the file does not exist, it will be created. If the file is empty, a header row will be written.
"""
class LoadBalancerUser(HttpUser):
    wait_time = between(1, 2)

    @task
    def aboutTest(self):
        # Initialize variables to store response details
        reponseDetails = ""
        responseTime = ()
        # Make get request to the /about endpoint
        response = self.client.get("/about")
        # Extract relevant information from the response
        responseTime = list(response.headers.items())[0]

        # Check if the first item of the tuple is 'Date'
        if responseTime[0] == 'Date':
            # Split the string into parts
            parts = responseTime[1].split(', ')

            # Remove the day of the week and 'GMT'
            date_time_string = ' '.join(parts[1].split(' ')[:-1])            
            responseTime = ('Date', date_time_string)
        # Add responseTime to reponseDetails
        reponseDetails = str(responseTime[1]) + ","

        # check if get request was successful
        if response.status_code == 200:
            # Splits the lines of the response
            lines = response.text.splitlines()

            # Loops through the lines and searches each one for INSTANCEID, AWS_REGION or AVAILABILITY_ZONE
            for line in lines:
                if 'INSTANCEID' in line.upper():
                    reponseDetails = reponseDetails + re.sub(r'<strong>|=</strong>|<br>|InstanceID|\s', '', line)
                    reponseDetails = reponseDetails + ","
                    # logging.info(f"Found 'hello' in line: {line}")
                if 'AWS_REGION' in line.upper():
                    reponseDetails = reponseDetails + re.sub(r'<strong>|=</strong>|<br>|AWS_REGION|\s', '', line)
                    reponseDetails = reponseDetails + ","   
                if 'AVAILABILITY_ZONE' in line.upper():                    
                    reponseDetails = reponseDetails + re.sub(r'<strong>|=</strong>|<br>|AVAILABILITY_ZONE|\s', '', line)          

            # Open the file in append mode ('a'). If the file doesn't exist, it will be created.
            with open('load-balancer-test.csv', 'a', newline='') as csvfile:
                writer = csv.writer(csvfile)

                # Write the header only if the file is empty
                if csvfile.tell() == 0:
                    writer.writerow(['DateTime', 'InstanceID', 'AWS_REGION', 'AVAILABILITY_ZONE'])

                # Write the response details
                writer.writerow(reponseDetails.split(','))