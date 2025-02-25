# Use an official AWS Lambda Node.js runtime as the base image
FROM public.ecr.aws/lambda/nodejs:14

# Set the working directory in the container
WORKDIR /var/task

# Copy the application code into the container
COPY app.js package.json ./

# Install dependencies (if any)
RUN npm install

# Set the Lambda handler
CMD ["app.handler"]
