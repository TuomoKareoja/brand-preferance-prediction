############################################################################
# If you don't deploy locally remember to change the username and password #
############################################################################

username = rstudio
password = password
image_name = tuomokareoja/r-datascience-ubiqum
container_name = ubiqum_task2
rstudio_settings_path = user-settings

# Builds and starts the container with above parameters using specified rstudio settings
run:
	docker run --name $(container_name) \
	-p 8787:8787 \
	-v "`pwd`":/home/rstudio/working \
	-e USERNAME=$(username) -e PASSWORD=$(password) -e ROOT=TRUE \
	-d $(image_name)
	# use provided settings. If no settings provided uses defaults
	docker cp $(rstudio_settings_path) $(container_name):/home/rstudio/.rstudio/monitored/user-settings/
	xdg-open http://localhost:8787/

# stops and removes the container
stop:
	docker stop $(container_name)
	docker rm $(container_name)

# prints docker container log
debug:
	docker logs $(container_name)

# starts bash in container
shell:
	docker exec -t -i $(container_name) bash

# copy rstudio settings from container to host (overwrites previous settings!)
settings:
	docker cp $(container_name):/home/rstudio/.rstudio/monitored/user-settings/user-settings $(rstudio_settings_path)
