-- Disposable CI database only. Every credential here is deliberately public test data.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create role authenticator login noinherit password 'ci-only-never-production';
grant anon,authenticated,service_role to authenticator;
create schema auth;
grant usage on schema public to anon,authenticated,service_role;
