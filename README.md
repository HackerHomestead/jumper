
# Bulding
sudo docker build -t jumper:latest .

# Running as normal mapping host port to 2222 from the containor's port 22
sudo docker run -p 2222:22 jumper:latest

# Used this to be able to interactivly try things out
sudo docker run -it -p 2222:22 jumper:latest /bin/bash
