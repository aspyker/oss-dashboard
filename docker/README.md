# build the image
docker build -t aspyker/oss-dashboard .

# run bash in the image, passing in the GH_ACCESS_TOKEN
docker run -t -i -v /tmp:/oss-dashboard/output/tmp -e "GH_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" aspyker/oss-dashboard /bin/bash

# then run the tool and copy the output back to the Docker host
then run ruby refresh-dashboard.rb config-dashboard.yml
cp output/www/* output/tmp/.

# TODO
clean up Dockerfile
understand the Gemfile
remove the first xslt lib from Gemfile

