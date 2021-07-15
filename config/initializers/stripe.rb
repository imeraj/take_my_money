Stripe.api_key = Rails.application.credentials.stripe_secret_key
raise "Missing Stripe API Key" unless Stripe.api_key