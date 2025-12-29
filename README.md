# Car Rental App

A comprehensive car rental management system built with Ruby on Rails 7. This application handles the entire rental lifecycle, from car listings and customer verification to bookings, payments, and invoicing.

## Features

- **User Roles**: Separate interfaces for Customers, Vendors, and Admin users.
- **Car Management**: Detailed car listings with extensive attributes (brand, model, category, etc.).
- **Bookings & Interactivity**: Real-time availability checks and booking management.
- **Payments**: Integrated Stripe payment processing for secure transactions.
- **Maps & Location**: Google Places integration for location services.
- **Authentication**: Secure login via Devise and Google OAuth2.
- **Document Generation**: PDF and DOCX parsing/generation for invoices and contracts.
- **Storage**: Amazon S3 integration for handling car images and document uploads.
- **Modern UI**: built with Tailwind CSS and Hotwire (Turbo + Stimulus) for a responsive, SPA-like feel.

## Tech Stack

- **Backend Framework**: Ruby on Rails 7.2
- **Frontend**: Hotwire (Turbo & Stimulus), Tailwind CSS
- **Database**: PostgreSQL
- **Caching & Realtime**: Redis (Action Cable, Kredis)
- **Web Server**: Puma
- **Testing**: RSpec, Capybara, Selenium

## Prerequisites

Ensure you have the following installed on your system:

- **Ruby**: Version 3.x (check `.ruby-version` if available)
- **PostgreSQL**: Database server
- **Redis**: For caching and Action Cable
- **Git**: Version control

## Setup & Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd car_rental_app
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Database Setup:**
   Run the setup script which handles database creation, migration, and seeding:
   ```bash
   bin/setup
   ```
   *Alternatively, you can run:*
   ```bash
   bin/rails db:prepare
   ```

## Environment Variables

This project uses **Dotenv** and **Figaro** for managing environment variables. You can verify the required keys in `.env.example`.

### Development Setup
Create a `.env` file in the root directory (or `config/application.yml` for Figaro) and add the following keys:

#### Core
- `RAILS_MAX_THREADS`: (Optional) Default is 5.
- `FROM_EMAIL`: (Optional) Default sender email for mailers.

#### Authentication (Google OAuth)
- `GOOGLE_CLIENT_ID`: Your Google Cloud Console Client ID.
- `GOOGLE_CLIENT_SECRET`: Your Google Cloud Console Client Secret.

#### Payments (Stripe)
- `STRIPE_PUBLISHABLE_KEY`: Stripe Publishable Key.
- `STRIPE_SECRET_KEY`: Stripe Secret Key.

#### Maps (Google Places)
- `GOOGLE_PLACES_API_KEY`: Google Maps JavaScript/Places API Key.
- `GOOGLE_PLACE_ID`: Default Place ID for location referencing.

#### Storage (AWS S3)
- `AWS_ACCESS_KEY_ID`: AWS Access Key.
- `AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key.
- Note: The bucket name is currently configured as `wheels-on-rent-app` in `config/storage.yml`.

### Production Setup
In addition to the keys above, production requires:
- `DATABASE_URL`: Connection string for the PostgreSQL database.
- `RAILS_MASTER_KEY`: Decryption key for `credentials.yml.enc`.
- `RAILS_ENV`: Set to `production`.

## Running the Application

To start the application locally with Tailwind CSS compilation:

```bash
bin/dev
```

This uses `Procfile.dev` to start both the Rails server and the Tailwind watcher.
Access the app at `http://localhost:3000`.

## Testing

To run the test suite:

```bash
bundle exec rspec
```
