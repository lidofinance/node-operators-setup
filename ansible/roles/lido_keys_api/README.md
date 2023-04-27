# Ansible role for Keys API

#### Github: `https://github.com/lidofinance/lido-keys-api`

#### Dockerhub: `lidofinance/lido-keys-api`

## Project-specific variables

- `lido_keys_api_compose_project` (string) - Project name (optional, default: 'lido-keys-api')

## App-specific variables

- `lido_keys_api_image_tag` (string) - Image tag (optional, default: ':latest')
- `lido_keys_api_log_level` (string) - Log level (optional, default: 'debug')
- `lido_keys_api_log_format` (string) - Log format (json | simple) (optional, default: 'json')
- `lido_keys_api_db_username` (string) - DB Username (optional, default: 'lido_keys_api')
- `lido_keys_api_db_password` (string) - DB Password (**required**)
- `lido_keys_api_chain_id` (int) - Chain ID (**required**)
- `lido_keys_api_el_rpc_url_list` (array<string>) - Execution RPC list (**required**)
- `lido_keys_api_cl_api_url_list` (array<string>) - Consensus RPC list (**required**)
- `lido_keys_api_http_port` (int) - (optional, default: 3000)
- `lido_keys_api_http_ext_port` (int) - (optional, default: 3000)
- `lido_keys_api_node_env` (string) - (optional, default: 'production')
- `lido_keys_api_cors_whitelist_regexp` (string) - (optional, default: '^(.+)$$')
- `lido_keys_api_global_cache_ttl` (int) - (optional, default: 1)
- `lido_keys_api_provider_json_rpc_max_batch_size` (int) - (optional, default: 100)
- `lido_keys_api_provider_concurrent_requests` (int) - (optional, default: 5)
- `lido_keys_api_provider_batch_aggregation_wait_ms` (int) - (optional, default: 10)
- `lido_keys_api_validator_registry_enable` (bool) - (optional, default: true)

## Other variables

See `./defaults/main.yml`
