# Use Amazon Linux 2 base image with Node.js
FROM public.ecr.aws/lambda/nodejs:14

# Copy function code into the container
COPY app.js ${LAMBDA_TASK_ROOT}

# Set the entry point for Lambda
CMD ["app.handler"]
