# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tu_vocabulario_session',
  :secret      => '01a8c3fad1bb4e8c53ed6fb3e80f9d6129090570e1ee7792b589f797b35a602c934b5c868624ce2e3c6cd04d5fe2153706e5e5fefbd3d881003cc1058148a673'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
