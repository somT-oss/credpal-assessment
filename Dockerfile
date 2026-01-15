#build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

# install dependencies including devDependencies if needed for build steps
RUN npm install

COPY . .

# production stage
FROM node:18-alpine

WORKDIR /app

#create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# copy only necessary files from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./

# switch to non-root user
USER appuser

EXPOSE 3000

CMD ["npm", "start"]
