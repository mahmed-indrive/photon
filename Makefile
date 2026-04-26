DOCKER := $(shell which podman 2>/dev/null || which docker)
COMPOSE := $(DOCKER) compose

IMAGE_NAME    := photon
IMAGE_TAG     := new
CONTAINER_NAME := photon
NETWORK       := photon_default

# Matches docker-compose.yaml nominatim/opensearch settings
NOMINATIM_HOST     := nominatim
NOMINATIM_DB       := nominatim
NOMINATIM_USER     := nominatim
NOMINATIM_PASSWORD := password
COUNTRY_CODES      := pk
THREADS            := 4
OPENSEARCH_URL := opensearch:9200
INDEX_NAME := photon
LANGUAGES := en,ur
COUNTRY_CODES := pk
CLUSTER := opensearch
PHOTON_LOGIN := user
PHOTON_PASSWORD := password

.PHONY: build infra infra-down wait-opensearch import import-external serve stop logs

build:
	$(DOCKER) build -t $(IMAGE_NAME):$(IMAGE_TAG) .

infra:
	$(COMPOSE) -f docker-compose.yaml up -d

infra-down:
	$(COMPOSE) -f docker-compose.yaml down

wait-opensearch:
	@echo "Waiting for OpenSearch cluster to reach yellow status..."
	@until curl -sf "http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=5s" 2>/dev/null | grep -qE '"status":"(yellow|green)"'; do \
		sleep 5; \
	done
	@echo "OpenSearch is ready."

import: stop wait-opensearch
	$(DOCKER) run --rm --name $(CONTAINER_NAME) \
		--network $(NETWORK) \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		import \
		-host $(NOMINATIM_HOST) \
		-database $(NOMINATIM_DB) \
		-user $(NOMINATIM_USER) \
		-password $(NOMINATIM_PASSWORD) \
		-transport-addresses $(OPENSEARCH_URL) \
		-languages $(LANGUAGES) \
		-country-codes $(COUNTRY_CODES) \
		-j $(THREADS)

# Import into an external (authenticated) OpenSearch cluster.
# Required env: PHOTON_LOGIN, PHOTON_PASSWORD, CLUSTER, OPENSEARCH_URL
# Override Nominatim creds via NOMINATIM_HOST / NOMINATIM_DB / NOMINATIM_USER / NOMINATIM_PASSWORD.
import-external: stop
	$(DOCKER) run --rm --name $(CONTAINER_NAME) \
		--network $(NETWORK) \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		import \
		-host $(NOMINATIM_HOST) \
		-database $(NOMINATIM_DB) \
		-user $(NOMINATIM_USER) \
		-password $(NOMINATIM_PASSWORD) \
		-transport-addresses $(OPENSEARCH_URL) \
		-cluster $(CLUSTER) \
		-cluster-login $(PHOTON_LOGIN) \
		-cluster-password '$(PHOTON_PASSWORD)' \
		-index-name $(INDEX_NAME) \
		-languages $(LANGUAGES) \
		-country-codes $(COUNTRY_CODES) \
		-j $(THREADS)

serve: stop
	$(DOCKER) run --rm --name $(CONTAINER_NAME) \
		--network $(NETWORK) \
		-p 2322:2322 \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		serve \
		-transport-addresses $(OPENSEARCH_URL)

stop:
	-$(DOCKER) rm -f $(CONTAINER_NAME) 2>/dev/null || true

logs:
	$(DOCKER) logs -f $(CONTAINER_NAME)
