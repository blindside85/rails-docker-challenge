# Spina CMS Rails Application

This is a Ruby on Rails application with Spina CMS, set up using Docker for development and deployment.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Docker Commands](#docker-commands)
- [Rationale](#rationale)
- [Resources](#resources)
- [Challenges](#challenges)
- [Some Caveats and Potential Pitfalls](#some-caveats-and-potential-pitfalls)

## Features

- Ruby on Rails application with Spina CMS
- Dockerized for development and production
- PostgreSQL as the database
- Preconfigured for development and production environments

## Prerequisites

Ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (for local development)
- [Bundler](https://bundler.io/) (for local development)

## Setup

### Clone the Repository

```bash
git clone https://github.com/blindside85/rails-docker-challenge.git
cd rails-docker-challenge
```

### Configuration

1. **Create `.env` File:**

   Copy `.env.example` to `.env` and update the environment variables as needed.

   ```bash
   cp .env.example .env
   ```

2. **Database Configuration:**

   Ensure `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME`, and any other needed database-related environment variables are set correctly in your `.env` file.

### Docker Setup

1. **Build the Docker Images:**

   ```bash
   docker-compose build --no-cache
   ```

2. **Start the Services:**

   ```bash
   docker-compose up
   ```

   This will start the Rails application and PostgreSQL database.

3. **Database Operations:**

   ```bash
   docker-compose run app bundle exec rails db:create
   # Optional: run any unprocessed migrations
   docker-compose run app bundle exec rails db:migrate
   ```

4. **Install Spina CMS:**

   ```bash
   docker-compose run app bundle exec rails g spina:install
   ```

5. **Clean Rebuild & Restart Docker Compose:**

   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up
   ```

## Usage

- **Access the Application:**

  Open your browser and go to [http://localhost:3000](http://localhost:3000) for the front-end app. For the admin dashboard, simply visit http://localhost:3000/admin and login with the user details specified in the Spina installation step above.

- **Access the Database:**

  You can connect to the PostgreSQL database using `localhost:5432` with the credentials specified in the `.env` file.

- **View Logs:**

  ```bash
  docker-compose logs
  ```

- **Access the Rails Console:**

  ```bash
  docker-compose run app bundle exec rails console
  ```

## Rationale
- Not much to say here, really. Spina comes with its own selection of tools and frameworks (Tailwind, etc), and I chose not to deviate from the defaults for this exercise.

## Resources
- ChatGPT for non-sensitive "rubber ducking" (troubleshooting build and console errors, primarily)
- Spina's own "[getting started](https://spinacms.com/guides/getting-started/how-to-get-started-with-spina-cms)" docs and [github repo](https://github.com/SpinaCMS/Spina)
- Numerous StackOverflow posts across a wide range of issues, primarily around troubleshooting the app -> PostgreSQL interactions
- Spina's recommended "Rails for Mac" [setup guide](https://gorails.com/setup/macos/14-sonoma) from gorails.com
- I'm probably forgetting a few, but that's the bulk of them

## Challenges
- I ran into the most issues when dealing with getting environment variable values to all the right places at the right times (building and running). Getting the values from my .env file through the docker-compose.yml, through the Dockerfile, and finally into the rails app was much more of a headache than I had anticipated.
- Initially, I wanted to provide the ability for non-Dockerized local dev, but quickly decided:
  - a) that could easily burn more time than I allotted for this challenge
  - b) it would lead to the dreaded local environment inconsistencies that have consumed so many hours in my past, and make developer experience worse

## Some Caveats and Potential Pitfalls
- There's more that could be done to improve the security of the Dockerfile (I tried to note this in the file comments)
- Same goes for the docker-compose.yml
- I feel confident adjustments should be made to the .dockerignore and .gitignore files, I _must_ have missed some
- I would also consider creating a second docker-compose.prd.yml file to facilitate effective differentiating between dev and production. Taking more advantage of `RAILS_ENV`, passing in different secrets from AWS Secrets Manager for the DB connection, and more could all be done better this way
