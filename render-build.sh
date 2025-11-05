#!/usr/bin/env bash

set -o errexit

echo "=== Starting Render Build Process ==="

echo "Installing dependencies..."
bundle install

echo "Precompiling assets..."
bin/rails assets:precompile
bin/rails assets:clean

echo "Setting up database..."
# Try to create database (will fail if it exists, which is fine)
bin/rails db:create 2>/dev/null || echo "Database already exists or creation failed"

# Run migrations
echo "Running database migrations..."
bin/rails db:migrate

# Run seeds only if no projects exist
echo "Checking if seeds need to be run..."
if bin/rails runner "puts Project.count" | grep -q "0"; then
  echo "No projects found, running seeds..."
  bin/rails db:seed
else
  echo "Projects already exist, skipping seeds"
fi

echo "=== Build completed successfully! ==="
