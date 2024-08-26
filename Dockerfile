# Use the official NGINX base image
FROM nginx:latest

# Copy the custom HTML file into the container
COPY index.html /usr/share/nginx/html/

# Copy the image file into the container
COPY Dev1.jpg /usr/share/nginx/html/
COPY Dev2.jpg /usr/share/nginx/html/
COPY Dev3.jpg /usr/share/nginx/html/


# Expose port 80
EXPOSE 80

# Start NGINX when the container launches
CMD ["nginx", "-g", "daemon off;"]
