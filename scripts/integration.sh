#! /bin/bash

set -e

cd kuby_test/

cat <<'EOF' > .prebundle_config
Prebundler.configure do |config|
  config.storage_backend = Prebundler::S3Backend.new(
    client: Aws::S3::Client.new(
      region: 'default',
      credentials: Aws::Credentials.new(
        ENV['PREBUNDLER_ACCESS_KEY_ID'],
        ENV['PREBUNDLER_SECRET_ACCESS_KEY']
      ),
      endpoint: 'https://us-east-1.linodeobjects.com',
      http_continue_timeout: 0
    ),
    bucket: 'prebundler',
    region: 'us-east-1'
  )
end
EOF

# bootstrap app for use with kuby
bundle exec bin/rails g kuby
cat <<EOF > kuby.rb
class VendorPhase < Kuby::Docker::Layer
  def apply_to(dockerfile)
    dockerfile.copy('vendor/kuby-previews', 'vendor/kuby-previews')
  end
end

require 'kuby/kind'
require 'kuby/previews'
require 'kuby/prebundler'

Kuby.define('Kubytest') do
  shared = -> do
    docker do
      image_url 'localhost:5000/kubytest'

      credentials do
        username "foobar"
        password "foobar"
        email "foo@bar.com"
      end

      # have to insert after setup phase b/c prebundler replaces the existing bundler phase
      insert :vendor_phase, VendorPhase.new(environment), after: :setup_phase
    end

    kubernetes do
      add_plugin :prebundler

      add_plugin :rails_app do
        tls_enabled false
        manage_database false
        hostname 'kubytest.io'
      end

      provider :kind do
        use_kubernetes_version '${K8S_VERSION}'
      end
    end
  end

  preview_environment(:staging) do
    instance_exec(&shared)

    configure_preview do
      name 'foo'
      ttl exactly(2).minutes
      sweep_interval every(1).minute
    end

    kubernetes do
      configure_plugin :rails_app do
        hostname 'staging.kubytest.io'
      end
    end
  end
end
EOF
cat <<'EOF' > config/database.yml
default: &default
  adapter: cockroachdb
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost
development:
  <<: *default
  database: kubytest_development
staging:
  <<: *default
  database: kubytest_staging
EOF
cat <<'EOF' > config/routes.rb
Rails.application.routes.draw do
  root to: 'home#index'
end
EOF
cat <<'EOF' > app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
  end
end
EOF
mkdir app/views/home/
touch app/views/home/index.html.erb

# start docker registry (we need something that speaks the Docker API)
docker run -d -p 5000:5000 --name registry registry:2

export GLI_DEBUG=true

# build and push
bundle exec kuby -e staging build \
  -a PREBUNDLER_ACCESS_KEY_ID=${PREBUNDLER_ACCESS_KEY_ID} \
  -a PREBUNDLER_SECRET_ACCESS_KEY=${PREBUNDLER_SECRET_ACCESS_KEY}

# setup cluster
bundle exec kuby -e staging setup
bundle exec kuby -e staging setup

# find kubectl executable
kubectl=$(bundle show kubectl-rb)/vendor/kubectl

# export kubeconfig
kind get kubeconfig --name kubytest > .kubeconfig
export KUBECONFIG=.kubeconfig

# find ingress IP
ingress_ip=$($kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq -r .spec.clusterIP)

# deploy!
bundle exec kuby -e staging deploy

# attempt to hit the app
curl -vvv http://$ingress_ip \
  -H 'Host: staging.kubytest.io' \
  --fail \
  --connect-timeout 5 \
  --max-time 10 \
  --retry 5 \
  --retry-max-time 40
