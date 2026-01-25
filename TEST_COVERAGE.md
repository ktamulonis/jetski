# Test Coverage Report

- Stream subscribe/unsubscribe behavior (`Jetski::Stream.subscribe`, `unsubscribe`) [covered]
- Stream broadcast payload formatting as SSE data (`Jetski::Stream.broadcast`) [covered]
- Stream broadcast error handling (unsubscribe on writer error) [covered]
- Stream shutdown lifecycle (`signal_shutdown`, `shutdown_signaled?`, `reset_shutdown!`, `shutdown!`, `wait_for_shutdown`) [covered]

- Events publish/subscribe basic behavior (`Jetski::Events.subscribe`, `publish`) [covered]
- Events reset helper (`Jetski::Events.reset!`) [covered]

- Model patch updates attributes (`Jetski::Model.patch`) [covered]
- Model patch doesn't mutate existing instance [covered]
- Model patch emits events (`:model_patched`) [covered]
- Model patch broadcasts stream payload [covered]
- Model append updates field and handles nil [covered]
- Model append emits events/broadcasts with correct payload [covered]
- Model CRUD: `create`, `find`, `all`, `destroy!`, `destroy_all!` [covered]
- Model delegation (`count`, `first`, `last`) [covered]
- Model attribute definition + `attribute_names`/`db_attribute_values` [covered]
- Model `column_names` / `define_attribute_methods` [covered]
- Model `inspect` output format [covered]

- Router parser auto-routes for CRUD actions (`Jetski::Router::Parser.compile_routes`) [covered]
- Router parser custom route options (`root`, `path`, `request_method`) [covered]
- Router mounts stream endpoint (`/stream`) [covered]
- Router mounts assets (CSS/JS/images) [covered]
- Router mounts `/reactive-form.js` helper [covered]
- Router 404 handling for mismatched URL in host base [covered]

- Host::Controller path param extraction for `show/edit/destroy` [covered]
- Host::Controller body parsing (JSON, form-encoded, raw) [covered]
- Host::Controller render behavior (auto-render on GET, skip when rendered) [covered]
- Host::Crud URL->action resolution (index/create/new/show/edit/update/destroy) [covered]

- BaseController `render` (text, json, view) [covered]
- BaseController `redirect_to` [covered]
- BaseController cookie helpers (`set_cookie`, `get_cookie`) [covered]
- ViewRenderer ERB rendering + layout injection + asset tags [covered]
- ViewHelpers (render partials, link/button/input helpers, url processing) [covered]

- Autoloader loads models and builds kinship graph [covered]
- Relations generation: `has_many`/`belongs_to` method definition and behavior [covered]

- Database::Base `create_table_sql` and `sql_data_type` [covered]
- Database::Interface create/add/exists helpers [covered]

- CLI `jetski new` template generation + substitutions [covered]
- CLI `routes` output [covered]
- CLI `server` port handling + shutdown path [covered]
- CLI generators/destroyers (controller/model/resource) [covered]
- CLI db migrate/seed flows [covered]
