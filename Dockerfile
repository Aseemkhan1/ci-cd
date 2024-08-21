# Use the official NGINX base image
FROM nginx:latest

# Copy the custom HTML file into the container
COPY index.html /usr/share/nginx/html/

# Copy the image file into the container
COPY lion_image.jpg /usr/share/nginx/html/
COPY tiger_image.jpg /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start NGINX when the container launches
CMD ["nginx", "-g", "daemon off;"]
