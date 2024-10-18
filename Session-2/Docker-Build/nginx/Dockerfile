# Use the official Nginx image from the Docker Hub
FROM nginx:alpine

# Remove the default Nginx configuration file
RUN rm /usr/share/nginx/html/index.html

# Copy the custom HTML file to the Nginx web directory
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
