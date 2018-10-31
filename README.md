Pull a repository from github repository developed in python and deploy 
it in aws with high availability.
API is deployed using gunicorn and nginx.


Deployment Architecture


			
			
Note: 

Go through the variables.tf and configure the module assigning suitable values to the variables.


If you have more than one configuration first add then to the variables.tf as terraform variables.
Then pass them to the template_file's vars section in api.tf file like the "config" variable.
Then modify the app-config.sh.tpl







