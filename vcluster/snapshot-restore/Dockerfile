# Use an official Nginx runtime as a parent image
FROM nginx:latest

# Set the working directory to /usr/share/nginx/html
WORKDIR /usr/share/nginx/html

# Copy the image to the container
COPY html/ .

# Expose port 80 for HTTP traffic
EXPOSE 80

# Command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
