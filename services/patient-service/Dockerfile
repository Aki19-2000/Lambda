FROM public.ecr.aws/lambda/nodejs:14

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the application code
COPY . .

# Command to run the app
CMD ["app.handler"]
