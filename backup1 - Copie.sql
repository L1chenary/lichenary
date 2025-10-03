--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_id text NOT NULL,
    client_secret_hash text NOT NULL,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: observation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.observation (
    id integer NOT NULL,
    image_filename character varying(300) NOT NULL,
    date_time timestamp without time zone NOT NULL,
    location character varying(300) NOT NULL,
    latitude double precision,
    longitude double precision,
    species character varying(150),
    pollution_level integer,
    is_approved boolean,
    user_id integer
);


--
-- Name: observation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.observation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: observation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.observation_id_seq OWNED BY public.observation.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(256) NOT NULL,
    is_approved boolean
);


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: observation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.observation ALTER COLUMN id SET DEFAULT nextval('public.observation_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: observation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.observation (id, image_filename, date_time, location, latitude, longitude, species, pollution_level, is_approved, user_id) FROM stdin;
30	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754043984/rbeaqybowhlh8nehzgln.jpg	2025-07-31 12:11:00	Pârâu Mare, Mureș	46.7620212	25.0056267	Flavoparmelia Caperata	5	t	35
21	https://res.cloudinary.com/dkaff7r7k/image/upload/v1753963072/ovyjsk4lskm4ohfiww3j.jpg	2025-07-31 14:40:00	Parcul Central Cluj-Napoca	46.770944	23.581028	Flavoparmelia caperata	5	t	29
40	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046869/nb6dntyahsvddporv7pz.jpg	2025-08-01 11:45:00	Parcul ,,Crâng" Buzău	45.1475322	26.8026948	Physcia adscendens	9	t	6
27	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754043038/aqxneql6gjkgbgmd8emu.jpg	2025-07-30 18:55:00	Ibănești-Pădure, Mureș	46.762023	25.005473	Melanelixia glabratula	6	t	35
25	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754037248/pxut3u39xbvd6z5qc1ui.heic	2025-08-01 11:32:00	Buzău, Parcul Crâng	45.1474617	26.8031538	Caloplaca Citrina	9	f	20
37	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046690/qlnz4z5lolajtmrmlann.jpg	2025-08-01 11:36:00	Parcul ,,Crâng" Buzău	45.1476469	26.8032496	Phaeophyscia orbicularis	8	t	6
42	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754047213/dq6qq4fhqbwcj5jqtkw1.jpg	2025-08-01 12:07:00	Buzau, Parcul Crang	45.1469642	26.8014583	Phaeophyscia orbicularis	8	t	20
36	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046096/qywji4wxmrvzs1kmq84p.jpg	2025-08-01 11:24:00	Parcul ,,Crâng" Buzău	45.1475773	26.8034558	Xanthoria parietina	10	t	6
34	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754045951/wsatl651fthpjlzlroae.jpg	2025-08-01 11:19:00	Parcul ,,Crâng" Buzău	45.147753	26.8034558	Caloplaca citrina	9	t	6
39	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046822/rsumocfdrdo4w1hrz6ii.jpg	2025-08-01 11:52:00	Buzau, Parcul Crang	45.1472971	26.80228	Xanthoria Parietina	10	t	20
41	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046979/hcgzfkuyavguzcsgkmfx.jpg	2025-08-01 23:57:00	Buzau, Parcul Crang	45.1471344	26.8023927	Xanthoria parietina	10	t	20
45	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754047564/wn0mx7xnllydssqboqh6.jpg	2025-08-01 12:22:00	Buzau, Parcul Crang	45.14707	26.802254	Flavoparmelia caperata	5	t	20
44	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754047404/nhhb3nds8cl2y1gybrlu.jpg	2025-08-01 12:17:00	Buzau, Parcul Crang	45.146259	26.7996072	Caloplaca Citrina	9	t	20
35	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046080/mg5wpyvtvti4de4u42fx.jpg	2025-08-01 11:44:00	Buzau, Parcul Crang	45.1475133	26.8029006	Xanthoria parietina	10	t	20
43	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754047276/h0qskp7efjbcgxetsxdh.jpg	2025-08-01 12:15:00	Buzau, Parcul Crang	45.146408	26.8000022	Xanthoria parietina	10	t	20
46	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754049333/jeq60ubqhuv9no3hqysw.png	2025-08-01 11:57:00	Parcul Crâng, Buzău, România	45.1454692	26.7974658	Xanthoria parietina	10	t	37
33	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754045940/uouavk0yvufnfd2bvi1a.jpg	2025-08-01 11:38:00	Buzau, Parcul Crang	45.1474816	26.8030776	Xanthoria parietina	10	t	20
29	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754043684/tz0omyjg8v76af9usuzo.jpg	2025-07-31 12:05:00	Pârâu Mare, Mureș	46.762564	25.005663	Xanthoria parietina	10	t	35
28	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754043431/i1ci5ak8aw4slhskji3t.jpg	2025-07-31 12:06:00	Pârâu Mare, Mureș	46.761529	25.005673	Flavoparmelia caperata	5	t	35
31	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754044477/cwdqfljonsadqruku4ot.jpg	2025-07-31 12:00:00	Pârâu Mare, Mureș	46.762169	25.004497	Parmelia sulcata	7	t	35
50	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754051495/mphovphsidcfhw0622f8.jpg	2025-08-01 11:56:00	Parcul Crâng, Buzău, România	45.145512	26.7973927	Phaeophyscia orbicularis	8	t	37
48	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754050286/fulq8fs8guicahutkton.jpg	2025-08-01 12:00:00	Parcul Crâng, Buzău, România	45.1454728	26.7979741	Phaeophyscia orbicularis	8	t	37
57	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052446/dkqebjlfykjilxuod4fy.jpg	2025-08-01 11:56:00	Buzău, Parcul Crâng	45.1471058	26.8023337	Xantoria Parietina	10	t	9
56	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052195/soewrzjznxuomstbgahg.jpg	2025-08-01 11:52:00	Buzău, Parcul Crâng	45.1470793	26.8020758	Flavoparmelia caperata	5	t	9
55	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052193/h06x5jafwguwrj8q1vok.jpg	2025-08-01 11:52:00	Buzău, Parcul Crâng	45.1470793	26.8020758	Flavoparmelia Caperta	5	t	9
49	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754051030/mnecvwllnivvehhjxdmt.jpg	2025-08-01 11:50:00	Parcul Crâng, Buzău, România	45.1448002	26.7961522	Xanthoria parietina	10	t	37
54	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052066/s7jmjvp1ub2kttkad2c2.jpg	2025-08-01 11:50:00	Buzău, Parcul Crâng	45.1472044	26.8022975	Parmelia Sulcata	7	t	9
51	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754051721/bmffw4m2h4vgxt45tub5.jpg	2025-08-01 11:39:00	Buzău, Parcul Crâng	45.1475076	26.8032302	Xantoria Parietina	10	t	9
53	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052039/vem4hifugtptpsx26myz.jpg	2025-08-01 11:29:00	Parcul Crâng, Buzău, România	45.144634	26.7958045	Parmelia sulcata	7	t	37
10	https://res.cloudinary.com/dkaff7r7k/image/upload/v1753459166/acdhqd1fmvix8psv6ny2.jpg	2025-07-04 18:58:00	Parcul I. C. Brătianu, Buzău	45.15109	26.81158	Flavoparmelia caperata	5	t	1
52	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754051869/pvb1i2pgmwpxs7eayyqf.jpg	2025-08-01 11:45:00	Buzău, Parcul Crâng	45.1473849	26.8027645	Parmelia Sulcata	7	t	9
38	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754046694/w48gewsozro2yzhuhkrt.jpg	2025-08-01 12:06:00	Buzau, Parcul Crang	45.147012	26.801764	Phaeophyscia orbicularis	8	t	20
32	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754045037/pajoq2lhlwykbpsu6jzn.jpg	2025-07-31 12:10:00	Pârâu Mare, Mureș	46.761846	25.006196	Evernia prunastri	4	t	35
63	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754053283/rir8mbpjaeelwunqhrp3.jpg	2025-08-01 12:18:00	Buzău, Parcul Crâng	45.1464853	26.8002774	Parmelia Sulcata	7	t	9
58	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052651/wwhdqv07k0wahq7nvp0b.jpg	2025-08-01 15:49:00	Buzău, Parcul Crâng	45.1470023	26.8027343	Flavoparmelia Caperata	5	t	9
19	https://res.cloudinary.com/dkaff7r7k/image/upload/v1753461799/bp70mldsoqyfmg5pktjz.jpg	2025-07-01 07:29:00	Parcul Crâng, Buzău	45.14598	26.7974	Xanthoria parietina	10	t	1
23	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754037009/eoa2yvbv9soyr4jz01or.jpg	2025-08-01 11:29:00	Parcul Crâng Buzau	45.146379	26.797703	Xanthoria parietina	10	t	1
22	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754036754/dgcqkhhxozmfin0mhf4r.jpg	2025-08-01 11:24:00	Parcul Crâng Buzau	45.146463	26.798588	Parmelia sulcata	7	t	1
62	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754053108/ptof7k1tjzkx5ppsi7pi.jpg	2025-08-01 12:14:00	Buzău, Parcul Crâng	45.1464898	26.8005158	Flavoparmelia Caperata	5	t	9
61	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754053005/hlecx4g29ltbjvbbnday.jpg	2025-08-01 12:12:00	Buzău, Parcul Crâng	45.1463399	26.8003683	Xanthoria Parietina	10	t	9
47	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754049933/cyxqqqbnlbs1vdfmo2ay.jpg	2025-08-01 12:01:00	Parcul Crâng, Buzău, România	45.145599	26.7981457	Parmelia sulcata	7	t	37
73	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754078197/s9bqum55kcdlzgwzaict.jpg	2025-08-01 11:35:00	Parcul ,,Crâng" Buzău	45.1476469	26.8032496	Candelaria concolor	7	t	6
78	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754080470/zhywo1fikzxhvywpwvmz.jpg	2025-08-01 11:52:00	Parcul “Crâng”, Buzău	45.1478062	26.8033043	Lecanora conizaeoides	10	t	43
71	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754077957/nqfbp1ythqnkrughwl3a.jpg	2025-08-01 11:28:00	Parcul ,,Crâng" Buzău	45.1478062	26.8033043	Physcia adscendens ( gri)	9	t	6
75	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754078952/aaagrhunlqzicins0qyf.jpg	2025-08-01 11:37:00	Parcul “Crâng” Buzău	45.1471789	26.8015977	Phaeophyscia orbicularis	8	t	43
65	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754075161/aeonreawy06nxceuevhg.jpg	2025-08-01 11:28:00	Parcul “Crâng”, Buzău	45.1463659	26.7994446	Xanthoria parietina	10	t	43
70	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754077527/pslbpkv4ajrbw2bmf45w.jpg	2025-08-01 12:28:00	Parcul ,,Crâng" Buzău	45.1478062	26.8033043	Candelaria concolor (portocaliu)	7	t	6
89	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754123019/dkbxwc4mqhvrbdsdkfjd.jpg	2025-08-01 13:53:00	Parcul Marghiloman, Buzău	45.14776	26.84644	Xanthoria parietina	10	t	34
67	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754075726/oq530pgss3hbtlqxqof6.jpg	2025-08-01 11:06:00	Parcul “Crâng”, Buzău	45.145552	26.793247	Candelaria concolor	7	t	43
68	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754076984/m5awg6hn6cnl5leeyfrj.jpg	2025-08-01 11:36:00	Parcul ,,Crâng" Buzău	45.1476469	26.8032496	Flavoparmelia caperata	5	t	6
77	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754079910/pifgdktmw5z9zmqgpzrn.jpg	2025-08-01 12:22:00	Parcul “Crâng”, Buzău	45.1465908	26.7978758	Hypogymnia physodes	5	t	43
81	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754120745/br6zwyryz7odmcqd1myt.jpg	2025-08-01 11:40:00	Parcul Crâng, Buzău	45.1478022	26.8033603	Polycauliona candelaria	8	f	8
86	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754122578/ianhseai0ia0j1dxihpw.jpg	2025-08-01 13:31:00	Parcul Marghiloman, Buzău	45.147369	26.846042	Xanthoria parietina	10	f	34
94	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754123778/opqmtdax7kn9ianmv32l.jpg	2025-08-01 12:01:00	Parcul Crâng, Buzău	45.1476405	26.8026897	Hypogimnia physodes	5	f	8
76	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754079324/yzww0zsnkv6hlrrbb5ye.jpg	2025-08-01 12:27:00	Parcul “Crâng”, Buzău	45.1460604	26.7959225	Polycauliona candelaria	8	t	43
87	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754122747/smui9arpeoj3ljvhmmcz.jpg	2025-08-01 13:34:00	Parcul Marghiloman, Buzău	45.147125	26.846033	Xanthoria parietina	10	t	34
84	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754121532/kotlabw4ywagdvjvng5z.jpg	2025-08-01 13:26:00	Parcul Marghiloman, Buzău	45.14653	26.84484	Xanthoria parietina	10	t	34
83	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754121332/beucsabpf7brvdpldsiy.jpg	2025-08-01 13:24:00	Parcul Marghiloman, Buzău	45.14655	26.84496	Xanthoria parietina	10	t	34
90	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754123041/l1olx6t4gzw21oeaw3mk.jpg	2025-08-01 11:47:00	Parcul Crâng, Buzău	45.1476405	26.8026897	Xanthoria parietina	10	t	8
92	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754123451/gpcupcuzrxnqmmuis51z.jpg	2025-08-01 11:47:00	Parcul Crâng, Buzău	45.1476405	26.8026897	Parmelia sulcata	7	t	8
79	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754116775/ybwtcnfwfrbqgyhswvmu.jpg	2025-08-01 11:30:00	Parcul Crâng, Buzău	45.1478062	26.8033043	Xanthoria parietina	10	t	8
82	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754120873/true9dep0h4ihz13yyjh.jpg	2025-08-01 13:15:00	Parcul Marghiloman, Buzău	45.14807	26.84266	Polycauliona candelaria	8	t	34
85	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754122358/cktsz5kpiedx55qubk71.jpg	2025-08-01 13:31:00	Parcul Marghiloman, Buzău	45.147369	26.84605	Hypogymnia physodes	5	t	34
97	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754233894/e9cevzlp4fvog5zrazbv.jpg	2025-08-01 11:19:00	Parcul Crâng, Buzău	45.1471981	26.803424	Caloplaca citrina	9	f	33
98	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754234114/ntijtg2lt2t46yzb5qj4.jpg	2025-08-01 11:28:00	Parcul Crâng, Buzău	45.1464047	26.7997973	Caloplaca citrina	9	f	33
96	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754220982/b49tbmvbryexu0p0tooa.jpg	2025-08-03 14:22:00	Mănăștur, Cluj-Napoca, Cluj	46.7553974	23.5528938	Flavoparmelia caperata	5	t	30
88	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754122885/xs1fsxgzkjickqvn4dus.jpg	2025-08-01 13:51:00	Parcul Marghiloman, Buzău	45.14762	26.84652	Xanthoria parietina	10	t	34
64	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754062846/s2n81c7whj5klieujcvs.jpg	2025-07-31 17:18:00	Pârâu Mare, Mureș	46.7620213	25.00463	Physcia stellaris	8	t	35
93	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754123712/ux9phpl4psn0kildjbvy.jpg	2025-08-01 12:00:00	Parcul Crâng, Buzău	45.1476405	26.8026897	Hypogymnia physodes	5	t	8
69	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754077231/h7jrm9r4ffoe0ap4bz0w.jpg	2025-08-01 11:57:00	Parcul Crâng, Buzău	45.1477407	26.80296	Polycauliona candelaria	8	t	6
91	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754123180/lgkrgujmqms4056klaup.jpg	2025-08-01 11:47:00	Parcul Crâng, Buzău	45.1476405	26.8026897	Caloplaca citrina	9	t	8
106	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754402885/ap85tecnjjm39ig8rvos.jpg	2025-07-31 12:09:00	Pârâu Mare, Mureș	46.7620209	25.0056271	Flavoparmelia Caperata	5	t	35
103	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754402472/jrqdmvv6cup8uhbmoaln.jpg	2025-07-31 13:28:00	Pârâu Mare, Mureș	46.7620214	25.0056265	Evernia Prunastri	4	t	35
104	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754402561/vk8wk0zsgexubs94venv.jpg	2025-07-30 16:14:00	Pârâu Mare, Mureș	46.7620212	25.0056271	Xanthoria Parietina	10	t	35
80	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754120327/gncdxupfwxx14xamph50.jpg	2025-08-01 11:35:00	Parcul Crâng, Buzău	45.1479	26.803465	Polycauliona candelaria	8	t	8
102	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754250103/ezqrecqloez4lril4w6l.jpg	2025-08-03 19:08:00	Faleză Năvodari	44.3071701	28.628809	Xanthoria parietina	10	t	22
95	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754214494/byxqnnyhspgijy9vzc8m.jpg	2025-08-03 12:47:00	Strada Primăverii, Mănăștur, Cluj-Napoca, Cluj	46.7546835	23.553279	Lepraria incana	6	t	30
107	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754408184/jmqmznrg4ove8lav24wo.jpg	2025-08-03 19:39:00	Faleză Năvodari, Constanța, România	44.3243129	28.6376469	Caloplaca saxicola	9	t	22
133	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754900008/frrumjphnddemg68mfmc.jpg	2025-08-04 11:11:00	Păltiniș, Sibiu	45.67376	23.93398	Hypogymnia physodes	5	t	43
132	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754899737/o5yoqusmrh0o4hhdf6vh.jpg	2025-08-04 11:06:00	Păltiniș, Sibiu	45.67323	23.93848	Hypogymnia physodes	5	t	43
131	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754899485/hqcacf9mvxwkbpcsemie.jpg	2025-08-04 11:00:00	Păltiniș, Sibiu	45.67083	23.93961	Evernia prunastri	4	t	43
130	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754899047/flclvdv4ht9tofmncxdh.jpg	2025-08-04 10:55:00	Păltiniș, Sibiu	45.67202	23.93859	Pseudevernia furfuracea	3	t	43
129	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754898567/s4caj4bci5emewxlnpwd.jpg	2025-08-04 10:41:00	Păltiniș, Sibiu	45.67209	23.93923	Evernia prunastri	4	t	43
125	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754638929/hcrzae209g0cn65f67i1.jpg	2025-08-06 18:20:00	Sat Vizireni, Buzău	45.0500363	27.1951864	Xanthoria parietina	10	t	37
127	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754639284/cfkhets4b38qkji5h4pv.jpg	2025-08-06 18:22:00	Sat Vizireni, Buzău	45.05055	27.19216	Xanthoria parietina	10	t	37
108	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754409107/zoiv7ymo4qrrrl7053pv.jpg	2025-08-04 18:06:00	“La butoaie”, Mamaia, Constanța	44.2623767	28.6188192	Xanthoria parietina	10	t	22
128	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754661127/oz74jgyjamhdwagosewl.jpg	2025-08-06 14:29:00	Parcul Tăbăcăriei, Constanța, România	44.2054586	28.6332863	Xanthoria parietina	10	t	22
126	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754639181/yxv7taixlkcednrvs7no.jpg	2025-08-06 18:20:00	Sat Vizireni, Buzău	45.04872	27.1935	Candelaria concolor	7	t	37
134	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754902029/gaejpenbs5vqw6cw4zdn.jpg	2025-08-04 11:42:00	Păltiniș, Sibiu	45.65918	23.93707	Pseudevernia furfuracea	3	t	43
113	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754511747/mklh6lk8mmtslat180cx.jpg	2025-08-06 19:00:00	Parcul Detunata, Cluj-Napoca	46.7662332	23.6257033	Xanthoria parietina	10	t	30
121	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754572386/tqcmpdx24ab62mwpx9rs.jpg	2025-08-07 16:11:00	Parcul Primăverii, Cluj-Napoca	46.7579845	23.5575893	Parmelia sulcata	7	t	30
120	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754572091/mt54rhdvuqt3b9bf3edd.jpg	2025-08-07 16:07:00	Parcul Primăverii, Cluj-Napoca	46.7579845	23.5575893	Xanthoria parietina	10	t	30
101	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754235258/sl3nzaryytozw4cm1dx7.jpg	2025-08-01 12:15:00	Parcul Crâng, Buzău	45.1465773	26.8002892	Xanthoria parietina	10	t	33
119	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754571908/saltk1ph9cvggxiseef0.jpg	2025-08-07 16:04:00	Parcul Primăverii, Cluj-Napoca	46.7579004	23.5575092	Xanthoria parietina	10	t	30
116	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754571134/wtl5hb5izrhzfpuez0ml.jpg	2025-08-07 15:50:00	Parcul Primăverii, Cluj-Napoca	46.7577199	23.557413	Xanthoria parietina	10	t	30
118	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754571485/bk7uevzirxprafgxs1ta.jpg	2025-08-07 15:47:00	Parcul Primăverii, Cluj-Napoca	46.7572357	23.5568276	Flavoparmelia caperata	5	t	30
117	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754571295/oyxdqvtjgoa6e6psok6e.jpg	2025-08-07 15:41:00	Mănăștur, Cluj-Napoca	46.7556103	23.5534815	Xanthoria parietina	10	t	30
110	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754501703/ok51l4xu2y98h4xo8fda.jpg	2025-08-06 19:46:00	Parcul Detunata, Cluj-Napoca	46.7647687	23.625076	Xanthoria parietina	10	t	30
122	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754572629/iz0maenb8scyvfq6z4ut.jpg	2025-08-07 16:06:00	Parcul Primăverii, Cluj-Napoca	46.75817	23.55753	Polycauliona candelaria	8	t	30
115	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754512842/ikrwsg1vvduw6trh4xeu.jpg	2025-08-06 19:26:00	Gheorgheni, Cluj-Napoca	46.7647576	23.6269063	Xanthoria parietina	10	t	30
112	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754511079/fcsnscjcepb0ommysbmf.jpg	2025-08-06 19:31:00	Gheorgheni, Cluj-Napoca	46.76511	23.62671	Xanthoria parietina	10	t	30
109	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754497160/acdiyekgdpqkik5mxtmv.jpg	2025-08-06 19:14:00	Parcul Detunata, Cluj-Napoca	46.7655491	23.6282739	Flavoparmelia caperata	5	t	30
114	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754512554/rqhdy6gidscaqeaiyynp.jpg	2025-08-06 18:58:00	Gheorgheni, Cluj-Napoca	46.767229	23.6297816	Xanthoria parietina	10	t	30
124	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754595954/h669yexqxm1jp2ysqqx4.jpg	2025-08-07 19:51:00	Mănăștur, Cluj-Napoca	46.7546148	23.5527513	Lecanora conizaeoides	10	t	30
111	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754502326/qu3juqwxnev1eiy0jlgy.jpg	2025-08-06 18:34:00	Baza Sportivă Gheorgheni, Cluj-Napoca	46.7696364	23.635763	Parmelia sulcata	7	t	30
99	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754234539/tnjlhopwce2zchroie6s.jpg	2025-08-01 11:45:00	Parcul Crâng, Buzău	45.1474374	26.8027021	Phaeophyscia orbicularis	8	t	33
100	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754234794/tzmb0pt2ohnqwegbpmor.jpg	2025-08-01 12:10:00	Parcul Crâng, Buzău	45.14643	26.8008927	Polycauliona candelaria	8	t	33
105	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754402777/ockjj91mflbkjmxev11e.jpg	2025-07-31 11:55:00	Pârâu Mare, Mureș	46.762023	25.0056264	Parmelia sulcata	7	t	35
139	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754903451/rhcsqrypepnsvuhjlzev.jpg	2025-08-04 12:07:00	Păltiniș, Sibiu	45.67029	23.93591	Pseudevernia furfuracea	3	t	43
138	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754903177/zg77gxj7fjymjrjayraf.jpg	2025-08-04 12:03:00	Păltiniș, Sibiu	45.66894	23.93455	Ramalina farinacea	4	t	43
137	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754902874/liuq1q7iqjqxtbmbyiqd.jpg	2025-08-04 11:57:00	Păltiniș, Sibiu	45.66185	23.93559	Pseudevernia furfuracea	3	t	43
136	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754902573/zwdkvt8tyqpcpn4vxwx7.jpg	2025-08-04 11:51:00	Păltiniș, Sibiu	45.66035	23.93525	Cladonia rangiferina	1	t	43
135	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754902271/fpmo7uajpfgraiihhsuv.jpg	2025-08-04 11:47:00	Păltiniș, Sibiu	45.65985	23.93775	Evernia prunastri	4	t	43
152	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908068/x4abxmfckgla9w3aevvm.jpg	2025-08-05 13:26:00	Păltiniș, Sibiu	45.67811	23.97375	Evernia prunastri	4	t	43
149	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754907750/npf5c0lklaaaptcen4az.jpg	2025-08-04 13:19:00	Păltiniș, Sibiu	45.67137	23.96209	Pseudevernia furfuracea	3	t	43
148	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754907495/ycfkav7xs3f7fwcjyrft.jpg	2025-08-04 13:17:00	Păltiniș, Sibiu	45.67825	23.96124	Dibaeis baeomyces	2	t	43
146	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754907301/qwkqmoas5ezox9pdwkjy.jpg	2025-08-04 13:13:00	Păltiniș, Sibiu	45.67923	23.94265	Dibaeis baeomyces	2	t	43
144	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754906751/ednov7obmvarnjbly92z.jpg	2025-08-04 13:04:00	Păltiniș, Sibiu	45.67541	23.94188	Cladonia fimbriata	2	t	43
142	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754906410/nehvvygjanbrerr3c8ti.jpg	2025-08-04 12:57:00	Păltiniș, Sibiu	45.67679	23.94463	Cladonia fimbriata	2	t	43
157	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908725/d5hfa9szlty1euvy7h4v.jpg	2025-08-05 13:36:00	Păltiniș, Sibiu	45.67381	23.95622	Parmelia sulcata	7	f	43
164	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909467/md0mpbgtywphjfhi1rbs.jpg	2025-08-05 13:49:00	Păltiniș, Sibiu	45.67295	23.96295	Hypogymnia physodes	5	t	43
162	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909250/p7ae0ipzy1za3jfpokao.jpg	2025-08-05 13:46:00	Păltiniș, Sibiu	45.67272	23.96021	Hypogymnia physodes	5	t	43
161	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909105/j5sroamulrgc1ivbmwet.jpg	2025-08-05 13:44:00	Păltiniș, Sibiu	45.67097	23.95873	Hypogymnia physodes	5	t	43
160	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909007/ghq3nj0klvi9v5qxihak.jpg	2025-08-05 13:42:00	Păltiniș, Sibiu	45.66966	23.95641	Hypogymnia physodes	5	t	43
159	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908915/jmwmrrk1eznjljzjdb0j.jpg	2025-08-05 13:39:00	Păltiniș, Sibiu	45.67202	23.95398	Hypogymnia physodes	5	t	43
156	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908724/rhbdvvnley7gnsdlpwkw.jpg	2025-08-05 13:36:00	Păltiniș, Sibiu	45.67381	23.95622	Parmelia sulcata	7	t	43
171	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754910880/nimsxodvwzsd61izqd49.jpg	2025-08-09 16:21:00	Grădina Zoologică Sibiu	45.76337	24.12392	Flavoparmelia caperata	5	t	43
170	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754910709/qvhgveinb3tk8uy1wgzc.jpg	2025-08-09 16:15:00	Grădina Zoologică Sibiu	45.76349	24.12347	Flavoparmelia caperata	5	t	43
168	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754910144/itnpk63b2ifdf3kh3ih6.jpg	2025-08-10 20:03:00	Parcul Tineretului, Buzău	45.1627417	26.8342288	Xanthoria parietina	10	t	37
167	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754910017/cpe9b3mcrqe8wjt6z1gv.jpg	2025-08-10 20:02:00	Parcul Tineretului, Buzău	45.1627939	26.8341289	Xanthoria parietina	10	t	37
166	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909760/phfgib4u0azztjnbgxm6.jpg	2025-08-10 19:49:00	Parcul Tineretului, Buzău	45.1627381	26.8331465	Xanthoria parietina	10	t	37
165	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909569/cd58tcvipmhpxa9z7dw0.jpg	2025-08-10 19:45:00	Parcul Tineretului, Buzău	45.1629355	26.8336236	Xanthoria parietina	10	t	37
163	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754909457/uw7jowhbw8z97cvvs5ii.jpg	2025-08-10 19:43:00	Parcul Tineretului, Buzău	45.162775	26.8334014	Xanthoria parietina	10	t	37
158	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908821/n71qshtowyaupelvrnjz.jpg	2025-08-10 19:41:00	Parcul Tineretului, Buzău	45.1620216	26.83259	Xanthoria parietina	10	t	37
155	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908636/f4wvptyhx962dxwwzpvk.jpg	2025-08-10 19:38:00	Parcul Tineretului, Buzău	45.1617315	26.8311238	Xanthoria parietina	10	t	37
154	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908439/ykhxvt3dim2eauacv6qt.jpg	2025-08-10 19:36:00	Parcul Tineretului, Buzău	45.1618814	26.8310762	Xanthoria parietina	10	t	37
151	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908057/qxe2pjzuezxivu5xwvsk.jpg	2025-08-10 19:35:00	Parcul Tineretului, Buzău	45.1619812	26.8309324	Xanthoria parietina	10	t	37
153	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754908208/smk9ri6ruxyko1xofg68.jpg	2025-08-10 19:35:00	Parcul Tineretului, Buzău	45.1621	26.8307	Candelaria concolor	7	t	37
150	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754907810/ljolrkdusicvake5vr6m.jpg	2025-08-10 19:25:00	Strada Sporturilor, Buzău	45.159418	26.829541	Xanthoria parietina	10	t	37
147	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754907447/snnake0hcetondh5ihjp.jpg	2025-08-10 19:24:00	Strada Sporturilor, Buzău	45.1595126	26.8297083	Xanthoria parietina	10	t	37
145	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754907291/vttdstjidvrfzq7qrvl1.jpg	2025-08-10 19:22:00	Strada Sporturilor, Buzău	45.159676	26.8298927	Caloplaca citrina	9	t	37
143	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754906464/hfd6sabe3o0kcafejhuz.jpg	2025-08-10 19:21:00	Strada Sporturilor, Buzău	45.1597369	26.8301146	Polycauliona candelaria	8	t	37
169	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754910331/fqqeesomgo0wmgsq7oiv.jpg	2025-08-10 20:04:00	Parcul Tineretului, Buzău	45.1627989	26.8343639	Xanthoria parietina	10	t	37
140	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754905903/sltqvvuvpcm2d4vko5pb.jpg	2025-08-10 18:46:00	Parcul Tineretului, Buzău	45.1597379	26.8300131	Xanthoria parietina	10	t	37
141	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754906321/l0pnkdoxmcjbnn0wrskt.jpg	2025-08-10 18:46:00	Strada Sporturilor, Buzău	45.15996	26.83015	Polycauliona candelaria	8	t	37
175	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754914652/jo6ebpnyn2r9l71u0kds.jpg	2025-08-09 16:33:00	Grădina Zoologică Sibiu	45.76358	24.12536	Evernia prunastri	4	t	43
173	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754911556/ldpzcn8nv9zgar5jtn1d.jpg	2025-08-09 16:32:00	Grădina Zoologică Sibiu	45.76257	24.12335	Parmelia sulcata	7	t	43
172	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754911023/lizh6upe3iw2g0bndias.jpg	2025-08-09 16:25:00	Grădina Zoologică Sibiu	45.76284	24.12305	Flavoparmelia caperata	5	t	43
174	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754914289/k0qibe42ykytnaz8hnt4.jpg	2025-08-09 16:39:00	Grădina Zoologică Sibiu	45.7632	24.12465	Parmelia sulcata	7	t	43
123	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754573258/jdu8hkqra9jjpxv6xax9.jpg	2025-08-07 16:25:00	Biserica Ortodoxă “Sfinții Apostoli Petru și Pavel”, Cluj-Napoca	46.7569605	23.5569241	Phaeophyscia orbicularis	8	t	30
178	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754922797/s4d45gpqwevvo5caucio.jpg	2025-08-11 11:00:00	Suciu de Sus	47.45719051327247	24.03623481022241	Parmelia sulcata	7	f	45
179	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754923171/at4ypkx6htfyzujkrf9q.jpg	2025-08-11 11:01:00	Suciu de Sus	47.45711	24.035451	Parmelia Sulcata	7	f	45
184	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754926571/ywbnhkginygomrigxipr.jpg	2025-08-11 14:30:00	Suciu de Sus	47.451459	24.034207	Xanthoria parietina	10	f	45
185	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754926740/qrygg7tbuzlxev60gupu.jpg	2025-08-11 12:39:00	Suciu de Sus	47.453084	24.03249	Parmelia sulcata	7	f	45
187	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754927509/o8n8ycn1qognjeizcdf0.jpg	2025-08-11 14:29:00	Suciu de Sus	47.451517	24.032877	Lepraria incana	6	f	45
189	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755002154/vulmo29p0gd49lej8brs.jpg	2025-08-10 15:23:00	Munții Cindrel, Sibiu	45.62475	23.96167	Pseudevernia furfuracea	3	t	43
195	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755003390/d6mbf8fqyuy1kqjkzkg4.jpg	2025-08-07 14:58:00	Cetatea Sighișoara	46.22005	24.79127	Flavoparmelia caperata	5	t	43
180	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754923313/acyig7zyuicvhrbcar6k.jpg	2025-08-11 10:31:00	Suciu de Sus	47.455362	24.038101	Candelaria concolor	7	t	45
190	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755002156/f6jnfdsgmwds7zwwbtlm.jpg	2025-08-10 15:23:00	Munții Cindrel, Sibiu	45.62475	23.96167	Pseudevernia furfuracea	3	f	43
191	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755002921/ckjcaqgtiywre4rgvisp.jpg	2025-08-07 15:45:00	Cetatea Sighișoara	46.21861	24.79274	Xanthoria parietina + Phaeophyscia orbicularis	10	f	43
196	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755003870/za8eyyl9ihfj7x0nwqnh.jpg	2025-08-07 18:06:00	Cetatea Sighișoara	46.22104	24.79268	Flavoparmelia caperata	5	t	43
194	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755003246/cwyfh9fngnn9tc3qqrnu.jpg	2025-08-07 17:19:00	Cetatea Sighișoara	46.21823	24.79254	Flavoparmelia caperata	5	t	43
197	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755004081/rbhnsyyhvykpshv7okqd.jpg	2025-08-07 17:07:00	Cetatea Sighișoara	46.2176	24.79025	Caloplaca citrina	9	t	43
192	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755002923/bldnkxsf737neeelklci.jpg	2025-08-07 15:45:00	Cetatea Sighișoara	46.21861	24.79274	Xanthoria parietina + Phaeophyscia orbicularis	10	t	43
193	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755003102/qnfwxozu18r0cma8c9g2.jpg	2025-08-07 16:35:00	Cetatea Sighișoara	46.21867	24.79144	Ramalina farinacea + Flavoparmelia caperata	4	t	43
200	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755006526/dbnbsfnnei6rtatjbv5e.jpg	2025-08-09 17:15:00	Cetatea Făgăraș	45.84441	24.97206	Xanthoria parietina	10	t	43
201	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755006902/doef2iefqi3wanb2s0ur.jpg	2025-08-09 16:56:00	Cetatea Făgăraș	45.84649	24.97584	Flavoparmelia caperata	5	t	43
199	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755006198/tp5mlgsxzyfmgl2iw6y2.jpg	2025-08-09 16:51:00	Cetatea Făgăraș	45.84503	24.97323	Parmelia sulcata	7	t	43
198	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755005954/frcyynbvagl0nb977nu0.jpg	2025-08-09 16:36:00	Cetatea Făgăraș	45.84414	24.97293	Hypogymnia physodes	5	t	43
204	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755086424/h5b2b8e8jbaioasnbbkd.jpg	2025-08-13 14:50:00	Parcul Central, Cluj-Napoca	46.77131	23.58124	Flavoparmelia caperata	5	t	30
208	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755090700/hrzm600yzws7okngjgxe.jpg	2025-08-13 14:30:00	Parcul Central, Cluj-Napoca	46.77108	23.58143	Candelaria concolor	7	t	26
202	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755085329/es0u3xmyl2mnwfgbzyq3.jpg	2025-08-13 14:36:00	Parcul Central, Cluj-Napoca	46.77188	23.58259	Candelaria concolor	7	t	30
206	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755090398/lmjfc0unxycvpm1vlnzf.jpg	2025-08-13 14:21:00	Parcul Central, Cluj-Napoca	46.77124	2358145	Xanthoria parietina + Phaeophyscia orbicularis	10	t	26
188	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754947625/zhkvp2aoihmdstjubi9u.jpg	2025-08-11 16:02:00	Mănăștur, Cluj-Napoca	46.75677	23.55263	Flavoparmelia caperata	5	t	30
203	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755085466/dmoug2zq5n7rrkebhr9u.jpg	2025-08-13 14:43:00	Parcul Central, Cluj-Napoca	46.77144	23.58178	Phaeophyscia orbicularis	8	t	30
207	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755090574/kdscav9qfltbrjb3xwfk.jpg	2025-08-13 14:27:00	Parcul Central, Cluj-Napoca	46.77146	23.58241	Phaeophyscia orbicularis	8	t	26
177	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754922663/clwd75lzlnnoekdgnatb.jpg	2025-08-11 11:30:00	Suciu de Sus, Maramureș	47.457768200618276	24.034710427829985	Phaeophyscia orbicularis	8	f	45
186	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754926830/inj0a0emm4gp86uosyew.jpg	2025-08-11 14:30:00	Suciu de Sus, Maramureș	47.453403	24.031847	Parmelia sulcata	7	t	45
183	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754926221/fjszze0gmkti6u63sbbp.jpg	2025-08-11 13:30:00	Suciu de Sus, Maramureș	47.456392	24.034336	Parmelia sulcata	7	t	45
181	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754923762/ash6qlmry3pw4jm0tvjz.jpg	2025-08-11 10:32:00	Suciu de Sus, Maramureș	47.455224	24.038369	Hypogymnia physodes	5	t	45
176	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754921313/p7hbhhlhkytbfjzykdll.jpg	2025-08-11 10:30:00	Suciu de Sus, Maramureș	47.45655	24.04006	Polycauliona candelaria	8	t	45
211	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755104428/fzlxziyf6sdgkphml2ge.jpg	2025-08-13 19:51:00	Parcul Central, Cluj-Napoca	46.77189	23.58331	Xanthoria parietina	10	t	30
205	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755089990/qsjezhrhnqiwk3v42dx5.jpg	2025-08-13 15:56:00	Parcul Central, Cluj-Napoca	46.77099	23.58137	Flavoparmelia caperata	5	t	30
217	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755114628/ysdysbkmychhfxfaz5hv.jpg	2025-08-13 14:25:00	Parcul Central, Cluj-Napoca	46.7718	23.58303	Xanthoria parietina + Phaeophyscia orbicularis	8	t	18
231	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755421763/lnijf0aagxwptqs5vvq4.jpg	2025-07-31 13:28:00	Pârâu Mare, Mureș	46.76074	25.00563	Evernia prunastri	4	t	43
221	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755115117/e22xqzhbejqkuo2hsvvv.jpg	2025-08-13 14:46:00	Parcul Central, Cluj-Napoca	46.77129	23.58102	Caloplaca citrina	9	t	18
220	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755114953/twfvdc7xyadu0wk5g3qz.jpg	2025-08-13 14:45:00	Parcul Central, Cluj-Napoca	46.77129	23.58102	Caloplaca citrina	9	t	18
213	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755105932/ebqqesnc9xpfk0git8xg.jpg	2025-08-13 14:23:00	Parcul Central "Simion Bărnuțiu" Cluj-Napoca	46.7712202	23.5821838	Xanthoria parietina + Flavoparmelia caperata	10	t	29
215	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755114325/v9so54r5f9okkuroyufk.jpg	2025-08-13 14:42:00	Parcul Central, Cluj-Napoca	46.7724	23.58227	Xanthoria parietina	10	t	18
230	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755421615/bse3q8hywkmdzr0zdi48.jpg	2025-07-31 12:11:00	Pârâu Mare, Mureș	46.76297	25.00422	Flavoparmelia caperata	5	t	43
210	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755090915/bel9n1xo7fjcdv83ccwa.jpg	2025-08-13 14:41:00	Parcul Central, Cluj-Napoca	46.77135	23.58164	Candelaria concolor	7	t	26
212	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755105754/glbdveeqxtrfjzxpoujn.jpg	2025-08-13 14:20:00	Parcul Central "Simion Bărnuțiu", Cluj-Napoca	46.7717908	23.5823535	Lepraria incana	6	t	29
216	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755114466/oqc7csiqv3vwkx85wajy.jpg	2025-08-13 14:24:00	Parcul Central, Cluj-Napoca	46.7718	23.58303	Caloplaca citrina	9	t	18
182	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754924142/u43hxrxobc6xmgwf6im8.jpg	2025-08-11 13:53:00	Suciu de Sus, Maramureș	47.45621	24.034132	Hypogymnia physodes	5	t	45
214	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755114324/ig0uhgomxpm763ycnrdq.jpg	2025-08-13 14:42:00	Parcul Central, Cluj-Napoca	46.7724	23.58227	Xanthoria parietina	10	t	18
222	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755115260/sds81zxcghlwfdjqwckk.jpg	2025-08-13 14:50:00	Parcul Central, Cluj-Napoca	46.77125	23.58168	Phaeophyscia orbicularis	8	t	18
209	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755090797/m4a1jy58rjr5fsqe2to1.jpg	2025-08-13 14:34:00	Parcul Central, Cluj-Napoca	46.77131	23.58184	Flavoparmelia caperata	5	t	26
219	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755114803/uj9sw0jlh1ehpaah6lly.jpg	2025-08-13 14:29:00	Parcul Central, Cluj-Napoca	46.77185	23.58309	Caloplaca citrina + Hypogymnia physodes	9	t	18
229	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755421469/tkftdykyp9yoxed0ouvq.jpg	2025-07-31 12:09:00	Pârâu Mare, Mureș	46.76056	25.0059	Flavoparmelia caperata	5	t	43
223	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755419354/fzj6wooqdswihut7m4zc.jpg	2025-08-11 14:30:00	Suciu de Sus, Maramureș	47.451459	24.034207	Xanthoria parietina	10	t	43
224	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755419462/qyeqdrnvtsz9adzcsnd4.jpg	2025-08-11 12:39:00	Suciu de Sus, Maramureș	47.453084	24.03249	Parmelia sulcata	7	t	43
225	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755419658/zvqx6miflgndtfe2piys.jpg	2025-08-11 11:30:00	Suciu de sus, Maramureș	47.4577682	24.03471042	Hypogymnia physodes	5	t	43
226	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755419767/a0fbbn2uvposdusgigev.jpg	2025-08-11 11:01:00	Suciu de Sus, Maramureș	47.45711	24.035451	Parmelia sulcata	7	t	43
227	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755419900/eeyhb9lb2jaskz6aryrp.jpg	2025-08-11 11:00:00	Suciu de Sus, Maramureș	47.45719051	24.03623481	Parmelia sulcata	7	t	43
228	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755421241/umdktpmo5dx2ediiyir6.jpg	2025-07-30 16:14:00	Pârâu Mare, Mureș	46.76061	25.00441	Xanthoria parietina	10	t	43
232	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755436465/jopz9knegzwbs2zpn2yh.jpg	2025-08-17 15:59:00	Suciu de Sus, Maramureș	47.4363206	24.0382703	Hypogymnia physodes	5	t	45
233	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755505986/jv6mh9hbuseyvuhwsibq.jpg	2025-08-17 11:58:00	Mânzălești	45.487747	26.636533	Parmelia sulcata	7	f	34
234	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755506211/pefbwqpsxmbnvhduvfsi.jpg	2025-08-17 11:57:00	Mânzălești	45.487689	26.636494	Xanthoria parietina	10	f	34
241	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755507656/lsmpoycnpmscnkyw0whc.jpg	2025-08-17 12:03:00	Mânzălești, Buzău	45.487778	26.636664	Pseudevernia furfuracea	3	t	34
283	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516807/cg6yxnd6s5mrep8f7w9a.jpg	2025-08-17 13:08:00	Lopătari, Buzău	45.48711	26.58422	Pseudevernia furfuracea	3	t	34
282	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516691/qrczxtgvu4vclwgwvbfj.jpg	2025-08-17 13:08:00	Lopătari, Buzău	45.52571	26.540414	Evernia prunastri	4	t	34
280	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516394/juopuezxf4ibv6ifdncj.jpg	2025-08-17 13:07:00	Lopătari, Buzău	45.525803	26.540839	Parmelia sulcata	7	t	34
271	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512997/pn6ebekzycwfoi849mks.jpg	2025-08-17 13:03:00	Lopătari, Buzău	45.525892	26.540814	Parmelia sulcata	7	t	34
268	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512564/llolhn1pf4yughq1uaud.jpg	2025-08-17 13:02:00	Lopătari, Buzău	45.525914	26.540664	Flavoparmelia caperata	5	t	34
266	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512232/iuhlsig6uvoufgbonm2w.jpg	2025-08-17 13:01:00	Lopătari, Buzău	45.525922	26.540561	Flavoparmelia caperata + Parmelia sulcata	5	t	34
275	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755515512/s2rifnupqbiamcwdcbas.jpg	2025-08-17 13:05:00	Lopătari, Buzău	45.525368	26.541627	Parmelia sulcata	7	t	34
261	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755511196/xen1wbck7hfv05wrm4z7.jpg	2025-08-17 12:58:00	Lopătari, Buzău	45.526825	26.539158	Chrysothrix candelaris	2	t	34
237	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755506945/sdb84phhazelvp56p18u.jpg	2025-08-17 12:00:00	Mânzălești, Buzău	45.487784	26.634982	Hypogymnia physodes	5	t	34
259	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755510886/d7q1o6a9gzd18u10onmt.jpg	2025-08-17 12:58:00	Lopătari, Buzău	45.525801	26.539357	Chrysothrix candelaris	2	t	34
242	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755507835/itnnrkv6wgr9l4bksd7k.jpg	2025-08-17 12:04:00	Mânzălești, Buzău	45.488266	26.636546	Hypogymnia physodes + Candelaria concolor	5	t	34
239	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755507264/csifs1raltcvhsmpahrx.jpg	2025-08-17 12:02:00	Mânzălești, Buzău	45.486963	26.636177	Lecanora chlarotera	8	t	34
265	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512089/uqrcxhyresh6rr1augcb.jpg	2025-08-17 13:00:00	Lopătari, Buzău	45.5261	26.5402	Lecanora chlarotera + Chrysotrix candelaris	8	t	34
238	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755507117/yhwuuax1jcg21taml77z.jpg	2025-08-17 12:01:00	Mânzălești, Buzău	45.487715	26.634475	Candelaria concolor + Lepraria incana	6	t	34
235	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755506521/vl0dsxltykkuwcvbiisc.jpg	2025-08-17 11:59:00	Mânzălești, Buzău	45.488133	26.636462	Candelaria concolor + Lepraria incana	7	t	34
243	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755507978/j9n93kwox9ilt8ddrgsu.jpg	2025-08-17 12:05:00	Mânzălești, Buzău	45.487587	26.636861	Lecanora chlarotera + Lepraria incana	6	t	34
276	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755515702/afoiktc0ffveg6uslht4.jpg	2025-08-17 13:05:00	Lopătari, Buzău	45.52864	26.540853	Flavoparmelia caperata	5	t	34
277	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755515923/lmcqz9u9cmw8jqppgf9a.jpg	2025-08-17 13:06:00	Lopătari, Buzău	45.525624	26.54005	Pseudevernia furfuracea	3	t	34
285	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755517062/zgdcsgzec2amnjjuyx7h.jpg	2025-08-17 13:09:00	Lopătari, Buzău	45.525639	26.541401	Flavoparmelia caperata	5	t	34
279	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516266/v2rvssvqxewhvgzgwzow.jpg	2025-08-17 13:06:00	Lopătari, Buzău	45.526188	26.542003	Flavoparmelia caperata	5	t	34
278	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516090/d1dco4jpelmcuazimhdt.jpg	2025-08-17 13:06:00	Lopătari, Buzău	45.525098	26.54107	Flavoparmelia caperata	5	t	34
274	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755515373/trewqzbnasz6wsbkhvbl.jpg	2025-08-17 13:04:00	Lopătari, Buzău	45.525444	26.540318	Parmelia sulcata	7	t	34
270	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512850/cfokvb279giry9ylcysj.jpg	2025-08-17 13:03:00	Lopătari, Buzău	45.525954	26.541851	Flavoparmelia caperata	5	t	34
281	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516522/xljdwg1ogwy83bwo8lhf.jpg	2025-08-17 13:08:00	Lopătari, Buzău	45.52481	26.541282	Flavoparmelia caperata	5	t	34
269	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512720/lfnbvanznegttmmvnaak.jpg	2025-08-17 13:02:00	Lopătari, Buzău	45.525654	26.540424	Flavoparmelia caperata + Phaeophyscia orbicularis	5	t	34
263	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755511760/v8oz6n2z3jv3jrpij61y.jpg	2025-08-17 13:00:00	Lopătari, Buzău	45.526097	26.54	Flavoparmelia caperata	5	t	34
258	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755510751/syavejhrtecbwvioekgv.jpg	2025-08-17 12:57:00	Lopătari, Buzău	45.526231	26.539697	Flavoparmelia caperata	5	t	34
253	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755509674/snodjus5wea0j8vfl1in.jpg	2025-08-17 12:54:00	Lopătari - Terca, Buzău	45.526494	26.538819	Ramalina farinacea	4	t	34
246	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755508525/hqclzalytoja0phhexp5.jpg	2025-08-17 12:13:00	Mânzălești, Buzău	45.488183	26.635933	Candelaria concolor + Hypogymnia physodes	7	t	34
267	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755512384/avu5hjjhgnpqeh3vqrak.jpg	2025-08-17 13:01:00	Lopătari, Buzău	45.526262	26.541358	Ramalina farinacea + Parmelia sulcata	4	t	34
247	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755508692/u1uo3b2brccvwfvtak0y.jpg	2025-08-17 12:13:00	Mânzălești, Buzău	45.488036	26.635933	Ramalina farinacea	4	t	34
307	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519659/gt1kim45crcvs2eybntk.jpg	2025-08-11 17:08:00	Parcul Marghiloman, Buzău	45.14745	26.845831	Xanthoria parietina	10	f	34
317	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755759294/ke7duy9g33ntzmfhtnig.jpg	2025-08-20 16:36:00	Parcul Tăbăcăriei, Constanța	44.2061748	28.6334519	Xanthoria parietina	10	t	22
311	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519977/xvqkbf75pooyxv5jlzja.jpg	2025-08-17 20:05:00	Faleza Brăila	45.2622408	27.9702386	Caloplaca citrina	9	t	37
315	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755624334/x0udqlwl7490blmc4j0o.jpg	2025-08-18 16:39:00	Strada Năvodari, Constanța	44.3108992	28.6156749	Xanthoria parietina	10	t	22
309	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519815/j6wcpfjwje5cjh4ko0kq.jpg	2025-08-17 20:03:00	Faleza Brăila	45.26019	27.96896	Xanthoria parietina	10	t	37
291	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518069/omxpfoneozrcbu0mmxyr.jpg	2025-08-17 13:11:00	Lopătari, Buzău	45.48886	26.58723	Phaeophyscia orbicularis	8	t	34
313	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755520112/ji3uckeljtnb4k90szyg.jpg	2025-08-17 20:07:00	Faleza Brăila	45.267	27.97683	Xanthoria parietina	10	t	37
300	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518893/tnxnermouuf9j7ranpne.jpg	2025-08-17 13:18:00	Lopătari, Buzău	45.49156	26.59411	Flavoparmelia caperata	5	t	34
314	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755624066/bjhazmxbhldttsyucfad.jpg	2025-08-18 16:23:00	Parcul “Ion Dobre” Năvodari, Constanța	44.3169902	28.6161866	Caloplaca saxicola	9	t	22
310	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519879/ivdwvass1qvyibkrf2wj.jpg	2025-08-11 16:59:00	Parcul Marghiloman, Buzău	45.146942	26.8455	Xanthoria parietina	10	t	34
260	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755511029/yng7vs3qmu5hhh67aleu.jpg	2025-08-17 12:58:00	Lopătari, Buzău	45.526822	26.539763	Flavoparmelia caperata + Chrysotrix candelaris	5	t	34
255	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755509972/kcwmdvtpmnpfnklxfqhd.jpg	2025-08-17 12:55:00	Lopătari - Terca, Buzău	45.526458	26.538875	Physcia stellaris + Flavoparmelia caperata	5	t	34
296	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518556/yrs7iahuwmmvaqb8bnn4.jpg	2025-08-16 19:51:00	Grădina Publică, Brăila	45.2752179	27.9788347	Xanthoria parietina + Phaeophyscia orbicularis	10	t	37
294	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518323/qa8imf0bvahgrh6nkbgm.jpg	2025-08-16 19:50:00	Grădina Publică, Brăila	45.2752875	27.9789081	Xanthoria parietina	10	t	37
304	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519398/jdlq9jj6ivxagc2cfqxp.jpg	2025-08-11 17:12:00	Parcul Marghiloman, Buzău	45.147858	26.844844	Xanthoria parietina + Phaeophyscia orbicularis	10	t	34
308	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519764/ectmkllqwsd67onzky6l.jpg	2025-08-11 17:04:00	Parcul Marghiloman, Buzău	45.146714	26.845178	Xanthoria parietina + Phaeophyscia orbicularis	10	t	34
312	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755520068/ralsscdrxzpghtghtp5t.jpg	2025-08-11 16:56:00	Parcul Marghiloman, Buzău	45.146539	26.845303	Calopaca citrina	9	t	34
250	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755509176/obprpgr5idh0dhd6nxw7.jpg	2025-08-17 12:14:00	Mânzălești, Buzău	45.48732	26.635765	Candelaria concolor	7	t	34
248	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755508873/sgmsbfbahrybfkitg6s8.jpg	2025-08-17 12:13:00	Mânzălești, Buzău	45.488007	26.636517	Ramalina farinacea + Xanthoria parietina	4	t	34
257	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755510629/xus1oem5qw0txphptucw.jpg	2025-08-17 12:57:00	Lopătari, Buzău	45.526495	26.540097	Chrysothrix candelaris	2	t	34
264	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755511926/bqplmnrvjukji34cvma4.jpg	2025-08-17 13:00:00	Lopătari, Buzău	45.526792	26.540487	Flavoparmelia caperata + Chrysotrix candelaris + Parmelia sulcata	5	t	34
305	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519528/frwmi7de3vgrfgoctjr0.jpg	2025-08-17 19:58:00	Faleza Brăila	45.27018	27.98097	Polycauliona candelaria	8	t	37
299	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518785/tkmhyf1deql61pv9xi24.jpg	2025-08-17 19:23:00	Bulevardul Independenței, Brăila	45.2662918	27.9667748	Xanthoria parietina	10	t	37
284	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755516929/br5dl4bv46o2r3d3q3gb.jpg	2025-08-17 13:09:00	Lopătari, Buzău	45.525416	26.539089	Parmelia sulcata	7	t	34
293	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518312/psinp1pbnm2ctwmla0i4.jpg	2025-08-17 13:13:00	Lopătari, Buzău	45.4899	26.5981	Parmelia sulcata	7	t	34
303	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519132/nmxjzv5ho56erq2zebxa.jpg	2025-08-17 19:56:00	Faleza Brăila	45.26465	27.97321	Xanthoria parietina + Phaeophyscia orbicularis	10	t	37
301	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518968/jb5b7ccwxcnwy8hr6tyh.jpg	2025-08-17 19:25:00	Bulevardul Independenței, Brăila	45.2654442	27.9674309	Xanthoria parietina	10	t	37
288	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755517628/lqwnptotyqrd4gmvxnaj.jpg	2025-08-17 13:10:00	Lopătari, Buzău	45.525053	26.539063	Flavoparmelia caperata	5	t	34
286	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755517208/eyhxzp6rafoymwarpvay.jpg	2025-08-17 13:09:00	Lopătari, Buzău	45.524944	26.540325	Parmelia sulcata	7	t	34
298	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518753/d7cw1qcci04uemcjw83a.jpg	2025-08-17 13:17:00	Lopătari, Buzău	45.526103	26.540433	Flavoparmelia caperata	5	t	34
287	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755517430/fdcx18acrm62z1tnbfcj.jpg	2025-08-17 13:09:00	Lopătari, Buzău	45.49093	26.58316	Evernia prunastri	4	t	34
290	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755517920/ytuyrwfmvejccvsctdqu.jpg	2025-08-17 13:11:00	Lopătari, Buzău	45.525478	26.541186	Parmelia sulcata	7	t	34
306	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519655/epjzou5cczn4d2trjo3z.jpg	2025-08-17 19:59:00	Faleza Brăila	45.26249	27.97114	Xanthoria parietina	10	t	37
318	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755852186/lepllh7xprnvq9raqxve.jpg	2025-08-19 18:49:00	Lacul Babadag, Tulcea	44.94247	28.81091	Xanthoria parietina	10	t	2
320	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755852902/xsyhxm94atrb1v3b9n4a.jpg	2025-08-01 12:27:00	Parcul Crâng Buzau	45.1454252	26.7966105	TBD	1	f	2
302	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755519093/elit6wmpx5v5eo4se4ka.jpg	2025-08-17 13:18:00	Lopătari, Buzău	45.48773	26.59864	Xanthoria parietina + Evernia prunastri	10	t	34
297	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518632/jvsfgdqwncshmk8zohwr.jpg	2025-08-17 13:16:00	Lopătari, Buzău	45.49206	26.5948	Flavoparmelia caperata	5	t	34
289	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755517797/zkpht0glfl5e8shte1ic.jpg	2025-08-17 13:10:00	Lopătari, Buzău	45.526421	26.540414	Flavoparmelia caperata	5	t	34
292	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518197/cu5vqctnx4mydinuujuk.jpg	2025-08-17 13:12:00	Lopătari, Buzău	45.525601	26.539751	Flavoparmelia caperata	5	t	34
295	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755518502/oc3wnbvlvsvohuit3kmo.jpg	2025-08-17 13:14:00	Lopătari, Buzău	45.48917	26.59445	Polycauliona candelaria	8	t	34
326	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755853750/qhgchmhnznkkxnjootxs.jpg	2025-08-01 12:08:00	Parcul Crâng Buzau	45.1456168	26.7936591	Tbd	1	f	2
341	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755940454/nredkhlmdfb2sqsdtlpd.jpg	2025-07-26 17:10:00	Lacul Meledic, Buzău	45.49755	26.61995	Physcia adscendens	9	t	8
324	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755853354/pse1za0jwnazzpnohx8w.jpg	2025-08-01 11:34:00	Parcul Crâng, Buzău	45.1450958	26.7933389	Phaeophyscia orbicularis	8	t	2
325	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755853426/xabl4aq5le18qlsz2z4l.jpg	2025-08-01 11:38:00	Parcul Crâng, Buzău	45.1452803	26.7928769	Phaeophyscia orbicularis	8	t	2
321	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755853039/ebo8ykeivv2untrtjylz.jpg	2025-08-01 11:56:00	Parcul Crâng, Buzău	45.1454482	26.7967051	Phaeophyscia orbicularis	8	t	2
319	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755852823/c4tj1qnsxkyhx9rpqb2e.jpg	2025-08-01 12:52:00	Parcul Crâng Buzău	45.145512	26.7965833	Xanthoria parietina + Phaeophyscia orbicularis	10	t	2
327	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755886925/gh1awhefsjbz9b05ilar.jpg	2025-07-26 16:30:00	Lacul Meledic, Buzău	45.4969331	26.6201188	Xanthoria parietina + Phaeophyscia orbicularis	8	t	8
337	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755939650/jeoe4a7yupsvmjsz2yna.jpg	2025-07-26 17:00:00	Lacul Meledic, Buzău	45.4970695	26.6206003	Polycauliona candelaria + Phaeophyscia orbicularis	8	t	8
339	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755940162/cinaxwvdxehdxmizcwz8.jpg	2025-07-26 17:05:00	Lacul Meledic, Buzău	45.49747	26.62067	Xanthoria parietina + Phaeophyscia orbicularis	10	t	8
348	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755941314/hcnw0xjnwfi3dcgfwvwg.jpg	2025-07-27 10:35:00	Lacul Meledic, Buzău	45.49642	26.62048	Lecanora conizaeoides + Xanthoria parietina	10	t	8
342	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755940527/vihvzro6kpmuzoebtsm3.jpg	2025-07-26 17:15:00	Lacul Meledic, Buzău	45.49727	26.62084	Physcia stellaris + Candelaria concolor	8	t	8
343	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755940650/wwaokiwhhkkdcz2djas9.jpg	2025-07-26 17:20:00	Lacul Meledic, Buzău	45.49661	26.62044	Lecanora conizaeoides	10	t	8
346	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755941145/rxz0dpytcckfokp1tdcb.jpg	2025-07-26 18:08:00	Lacul Meledic, Buzău	45.49733	26.62018	Physcia adscendens + Xanthoria parietina	9	t	8
344	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755941002/xa0ks9ooikwsqqzi1fjk.jpg	2025-07-26 17:40:00	Lacul Meledic, Buzău	45.49641	26.61962	Ramalina europaea + Chrysothrix candelaris	3	t	8
340	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755940221/ekpoubdz3bngfkmahqtd.jpg	2025-07-26 17:10:00	Lacul Meledic, Buzău	45.49663	26.62075	Xanthoria parietina	10	t	8
328	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755887083/edluzofrmmc36jkjgvpq.jpg	2025-07-26 16:30:00	Lacul Meledic, Buzău	45.49639	26.62006	Xanthoria parietina	10	t	8
353	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755958543/ldvjdxrca5faclje0fx3.jpg	2025-08-21 16:06:00	Mănăstirea Agapia, Neamț	47.17016	26.23529	Candelaria concolor + Hypogymnia physodes	5	t	43
354	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755958865/zcktdcx86v2ncylfts0v.jpg	2025-08-21 15:49:00	Mănăstirea Agapia, Neamț	47.17027	26.23549	Candelaria concolor + Hypogymnia physodes	5	t	43
355	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755959616/cu07vz32ycxywhixkyyp.jpg	2025-08-23 15:29:00	Sat Nicolae Bălcescu, Tulcea	44.99044	28.56582	Polycauliona candelaria	8	t	43
332	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755893053/an5uva7xbxzftvcs0yio.jpg	2025-08-20 23:51:00	Parcul Herăstrău, București	44.47397	26.077552	Flavoparmelia caperata	5	t	36
360	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755980406/cbu9mk8qzoiaoiog8tfu.jpg	2025-08-23 17:47:00	Podul Garibaldi, Cluj-Napoca	46.7674878	23.5688794	Candelaria concolor	7	t	30
359	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755980124/eehql4pllgqerqm8htj4.jpg	2025-08-23 16:52:00	Parcul Rozelor, Cluj-Napoca	46.76492	23.55202	Xanthoria parietina	10	t	30
358	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755976610/tuldcvzcfk7uyijefgba.jpg	2025-08-23 16:50:00	Parcul Rozelor, Cluj-Napoca	46.76473	23.55158	Lepraria incana	6	t	30
336	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755893621/qobed9huh9g0zjvxbrkp.jpg	2025-08-20 13:57:00	Parcul Herăstrău, București	44.475103	26.077083	Candelaria concolor	7	t	36
357	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755976141/afcsb1nz8t4xekmyxf3e.jpg	2025-08-23 16:48:00	Parcul Rozelor, Cluj-Napoca	46.76442	23.55163	Hypogymnia physodes + Xanthoria parietina	5	t	30
335	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755893445/ko0zi1v79ohfzjvplr6d.jpg	2025-08-22 00:58:00	Parcul Herăstrău, București	44.47373	26.07775	Phaeophyscia orbicularis	8	t	36
333	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755893244/bl3erljxemeuw2cjaksy.jpg	2025-08-20 23:52:00	Parcul Herăstrău, București	44.474473	26.077304	Phaeophyscia orbicularis + Xanthoria parietina	8	t	36
330	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755892256/w6vpwnjcuqtpdqofjneo.jpg	2025-08-20 13:05:00	Parcul Herăstrău, București	44.475022	26.077113	Xanthoria parietina	10	t	36
331	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755892608/dvqpc9mo2bw1atbssrsg.jpg	2025-08-20 12:48:00	Parcul Herăstrău, București	44.474731	26.077035	Parmelia sulcata	7	t	36
329	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755891977/skbjreqhgfiusbbaiuam.jpg	2025-08-20 12:40:00	Parcul Herăstrău, București	44.475762	26.077036	Xanthoria parietina + Hypogymnia physodes	10	t	36
363	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012090/fm5bfzls0vwr7jb6qszb.jpg	2025-08-01 12:07:00	Parcul Crâng Buzau	45.145971	26.7958749	TBD	1	f	2
366	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012343/ootwija5moiygsqil9es.jpg	2025-08-01 12:15:00	Parcul Crâng Buzau	45.146321	26.7965585	TBD	1	f	2
367	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012479/xk8ncwls3ommmxfqlkxs.jpg	2025-08-01 12:18:00	Parcul Crâng Buzau	45.146331	26.7965385	tbd	1	f	2
368	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012536/cpks8uc02kcy2bkbi8mt.jpg	2025-08-01 12:20:00	Parcul Crâng Buzau	45.1465404	26.7970229	tbd	1	f	2
380	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756015754/twpve092sc5j0obxn6q1.jpg	2025-08-23 14:29:00	Sat Nicolae Bălcescu, Tulcea	44.98809	28.56744	Polycauliona candelaria	8	t	43
379	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756015624/mkzuzq7oldjv55g0jrov.jpg	2025-08-23 14:16:00	Sat Nicolae Bălcescu, Tulcea	44.98985	28.56446	Polycauliona candelaria	8	t	43
378	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756015399/ptuppyfh02rpxqbdmxrf.jpg	2025-08-23 14:12:00	Comuna Nalbant, Tulcea	44.9899	28.57048	Caloplaca citrina	9	t	43
377	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756015312/m1mjzv72baqc4ublp4qv.jpg	2025-08-23 14:04:00	Comuna Nalbant, Tulcea	44.98813	28.56223	Caloplaca citrina	9	t	43
376	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756015170/byloc6f5h3pvmpwgbprl.jpg	2025-08-23 13:56:00	Comuna Nalbant, Tulcea	44.9897	28.56574	Caloplaca citrina	9	t	43
381	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756017319/uqeqcm9v4y6mh3ysnzyw.jpg	2025-08-23 11:35:00	Comuna Murighiol, Tulcea	45.02787	29.01871	Xanthoria parietina	10	t	43
390	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756021286/bqswrtnezzuv3xiurxkh.jpg	2025-08-23 12:55:00	Comuna Murighiol, Tulcea	45.0266	29.02798	Xanthoria parietina	10	t	43
373	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012829/ifihveb7n4q7hiurdq6e.jpg	2025-08-01 11:39:00	Parcul Crâng, Buzău	45.146515	26.797899	Lecanora conizaeoides	10	t	2
350	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755948903/e5eqwgpa6ynjtxzgbmnm.jpg	2025-08-01 12:06:00	Parcul Crâng, Buzău	45.1456395	26.7938354	Phaeophyscia orbicularis	8	t	2
375	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012961/ot6knmgjkzuraeaj5ojx.jpg	2025-08-01 11:36:00	Parcul Crâng, Buzău	45.146223	26.797909	Xanthoria parietina + Phaeophyscia orbicularis	10	t	2
370	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012673/jnqn99fel8xamsfnk2dt.jpg	2025-08-01 11:43:00	Parcul Crâng, Buzău	45.1465746	26.7974136	Phaeophyscia orbicularis + Lecanora conizaeoides	10	t	2
349	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755941461/pnn1mzdtocjcm8zn0n5u.jpg	2025-07-27 10:30:00	Lacul Meledic, Buzău	45.49656	26.62002	Parmelia sulcata + Candelaria concolor	7	t	8
374	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012889/zo4r2brrshsahx8sbx0c.jpg	2025-08-01 11:47:00	Parcul Crâng, Buzău	45.1464962	26.7982668	Phaeophyscia orbicularis	8	t	2
351	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755948904/vjk0ldxh2bdrj27yi33x.jpg	2025-08-01 12:06:00	Parcul Crâng, Buzău	45.1456395	26.7938354	Phaeophyscia orbicularis	8	t	2
364	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012226/pi432j1sfwxgwllepwgn.jpg	2025-08-01 12:13:00	Parcul Crâng, Buzău	45.1461472	26.7962772	Xanthoria parietina	10	f	2
365	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012280/y8s8me4atnbzh4r1pori.jpg	2025-08-01 12:11:00	Parcul Crâng, Buzău	45.1461874	26.7963768	Xanthoria parietina	10	f	2
371	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012723/ztjlmksmsl2tg6kqktgm.jpg	2025-08-01 11:45:00	Parcul Crâng, Buzău	45.146422	26.797109	Phaeophyscia orbicularis	8	t	2
369	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012590/kd7cr62gexijakcjwcbg.jpg	2025-08-01 11:37:00	Parcul Crâng, Buzău	45.146586	26.797555	Phaeophyscia orbicularis + Lecanora conizaeoides	8	t	2
388	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756020165/pgypzm2cyxs0i7xputvh.jpg	2025-08-23 12:41:00	Comuna Murighiol, Tulcea	45.02799	29.02133	Candelaria concolor	7	t	43
389	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756021044/rbwfnejzaohiekolazce.jpg	2025-08-23 12:40:00	Comuna Murighiol, Tulcea	45.0283	29.02289	Candelaria concolor	7	t	43
387	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756019870/hbhw0ixalmwtwca9fttr.jpg	2025-08-23 12:30:00	Comuna Murighiol, Tulcea	45.02809	29.01967	Candelaria concolor	7	t	43
386	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756019669/ywby2anag0ycms4ed3sn.jpg	2025-08-23 12:19:00	Comuna Murighiol, Tulcea	45.02708	29.01116	Candelaria concolor	7	t	43
385	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756019539/ujrgnvbo0tuhgkezh274.jpg	2025-08-23 12:10:00	Comuna Murighiol, Tulcea	45.02765	29.01319	Candelaria concolor	7	t	43
384	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756017735/m8xd4ui4yqq6nhbrspxa.jpg	2025-08-23 11:55:00	Comuna Murighiol, Tulcea	45.02731	29.01464	Xanthoria parietina	10	t	43
383	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756017562/keh6nsuwqpxi6opw48ju.jpg	2025-08-23 11:53:00	Comuna Murighiol, Tulcea	45.0276	29.01668	Xanthoria parietina	10	t	43
382	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756017424/xplpxotxelirexzelqqf.jpg	2025-08-23 11:41:00	Comuna Murighiol, Tulcea	45.02765	29.01738	Xanthoria parietina	10	t	43
393	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756023466/bjdyce8uruklpmklkvoq.jpg	2025-08-05 16:25:00	Koseskega Cesta, Lukovica, Slovenia	46.16577	14.68836	Caloplaca citrina + Pseudevernia furfuracea	9	t	43
392	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756023105/lgfisbkdzpu1owqqwg4o.jpg	2025-08-05 16:20:00	Koseskega Cesta, Lukovica, Slovenia	46.1656945	14.6885725	Lecanora conizaeoides	10	t	43
400	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057095/glldisufzhulavrrkqk9.jpg	2025-08-24 10:52:00	Lăpușna, Mureș	46.768027	25.237357	Usnea subfloridana	2	t	35
399	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057003/e5gw95nprhfxbzmdfe6g.jpg	2025-08-24 10:50:00	Lăpușna, Mureș	46.768534	25.234027	Evernia prunastri	4	t	35
398	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756056878/erf0ybmjojomjhrctuhz.jpg	2025-08-24 10:49:00	Lăpușna, Mureș	46.76877	25.232394	Pseudevernia furfuracea	3	t	35
397	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756056654/bz6witjtoruvyfhgtcnd.jpg	2025-08-24 10:48:00	Lăpușna, Mureș	46.7673036	25.2362777	Pseudevernia furfuracea	3	t	35
419	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756067284/u9hkox7c83yilku4dvz5.jpg	2025-08-24 11:45:00	Lăpușna, Mureș	46.767437	25.234192	Cladonia rangiferina	1	t	43
401	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057173/adkslarja1cxftuouxng.jpg	2025-08-24 10:53:00	Lăpușna, Mureș	46.767468	25.238582	Pseudevernia furfuracea	3	t	35
418	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756058412/qu5unqpdjjjf1wk94ao6.jpg	2025-08-24 11:59:00	Lăpușna, Mureș	46.767488	25.237517	Hypogymnia physodes	5	t	35
361	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755980676/bcxyxaoblc5bzbmt1i2d.jpg	2025-08-23 17:40:00	Platou Sala Sporturilor, Cluj-Napoca	46.76668	23.56445	Lepraria incana + Xanthoria parietina	6	t	30
417	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756058331/yu9jobwmq398xwbzxgwt.jpg	2025-08-24 11:52:00	Lăpușna, Mureș	46.768201	25.236402	Cladonia rangiferina	1	t	35
420	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756068754/m8xcypusevo3kycbj0ym.jpg	2025-08-20 18:41:00	Parcul Central, Cluj-Napoca	46.77187	23.58302	Melanelixia glabratula	6	t	1
416	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756058230/hwbmlpc9phedd5uzktal.jpg	2025-08-24 11:50:00	Lăpușna, Mureș	46.766886	25.23609	Cladonia rangiferina	1	t	35
406	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057410/w9ypgezkee2a8fzgxswv.jpg	2025-08-24 11:22:00	Lăpușna, Mureș	46.767305	25.2362774	Usnea subfloridana	2	t	35
415	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756058165/zhmxcu94cqbv9ciidai4.jpg	2025-08-24 11:45:00	Lăpușna, Mureș	46.767797	25.237593	Pseudevernia furfuracea	3	t	35
362	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755981189/cclkwhjtur24i7c2fame.jpg	2025-08-23 17:39:00	Platou Sala Sporturilor, Cluj-Napoca	46.766829	23.565718	Xanthoria parietina	10	t	30
414	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756058080/esoq4rarpt1pplflvjcm.jpg	2025-08-24 11:43:00	Lăpușna, Mureș	46.767606	25.235189	Pseudevernia furfuracea	3	t	35
412	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057858/qavcj7wamwvjmexrozyy.jpg	2025-08-24 11:41:00	Lăpușna, Mureș	46.767532	25.238741	Pseudevernia furfuracea	3	t	35
413	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057941/lozsezlwjda2ark909ai.jpg	2025-08-24 11:39:00	Lăpușna, Mureș	46.766709	25.238912	Pseudevernia furfuracea	3	t	35
410	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057733/eckcyukl3mwvmkk0zmzm.jpg	2025-08-24 11:33:00	Lăpușna, Mureș	46.766636	25.235672	Hypogymnia physodes	5	t	35
395	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756055911/sexfap6exeuwhzllt2ko.jpg	2025-08-09 19:03:00	Lunca Mureșului, Alba	46.42403	23.91167	Xanthoria parietina	10	t	35
245	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755508351/bdjdan3tr1yocqihdric.jpg	2025-08-17 12:10:00	Mânzălești, Buzău	45.487775	26.636069	Chrysothrix candelaris	2	t	34
391	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756022707/lqeclu0mu37ghhqqtmtq.jpg	2025-08-05 16:14:00	Koseskega Cesta, Lukovica, Slovenia	46.1656887	14.6886278	Caloplaca citrina	9	t	43
424	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756113679/lohkoatorkcm5aygvl1w.jpg	2025-08-17 12:59:00	Lopătari, Buzău	45.526192	26.538879	Physcia stellaris	8	t	43
394	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756055825/agengdaabwbrouwgsq96.jpg	2025-08-09 19:02:00	Lunca Mureșului, Alba	46.42295	23.91147	Physcia stellaris	8	t	35
396	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756056062/amdio1ftnxvbrwkh02gw.jpg	2025-08-09 19:05:00	Lunca Mureșului, Alba	46.4219222	23.9121711	Phaeophyscia orbicularis + Xanthoria parietina	8	t	35
409	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057647/fxlxmsgqwk54eh3tkele.jpg	2025-08-24 11:30:00	Lăpușna, Mureș	46.767679	25.23276	Usnea subfloridana + Pseudevernia furfuracea	2	t	35
272	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755513162/e7iz8bx0tllu1ekkl2n8.jpg	2025-08-17 13:03:00	Lopătari, Buzău	45.525399	26.539557	Pseudevernia furfuracea + Parmelia sulcata	3	t	34
408	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057539/ete6rwozqhdx6ta54twc.jpg	2025-08-24 11:27:00	Lăpușna, Mureș	46.767062	25.232733	Cladonia rangiferina	1	t	35
407	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057451/jey3kjozzcurts23blop.jpg	2025-08-24 11:19:00	Lăpușna, Mureș	46.767569	25.230684	Usnea subfloridana	2	t	35
405	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057366/a0zwxdsh58yej4ru5xnb.jpg	2025-08-24 11:13:00	Lăpușna, Mureș	46.767327	25.235372	Usnea subfloridana	2	t	35
403	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057263/wgpqxhzbmcaprdtvlgd0.jpg	2025-08-24 11:08:00	Lăpușna, Mureș	46.76815	25.235019	Usnea subfloridana	2	t	35
404	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057320/ia5zwsiiii043yim4eqf.jpg	2025-08-24 10:59:00	Lăpușna, Mureș	46.768466	25.232186	Usnea subfloridana	2	t	35
402	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756057217/iwzibyvcqi7wvh1rpzkt.jpg	2025-08-24 10:56:00	Lăpușna, Mureș	46.767267	25.231233	Usnea subfloridana	2	t	35
273	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755515216/zui9pyerhaug6tijvuum.jpg	2025-08-17 13:04:00	Lopătari, Buzău	45.525414	26.542368	Flavoparmelia caperata + Chrysotrix candelaris	5	t	34
427	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756121727/jklebfbme7x8yudnr6uu.jpg	2025-08-17 12:54:00	Lopătari - Terca, Buzău	45.525691	26.538289	Hypogymnia physodes	5	t	1
425	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756118326/esnybw8syywwolymxglu.jpg	2025-08-17 12:55:00	Lopătari - Terca, Buzău	45.525857	26.538332	Ramalina europaea	3	t	1
426	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756121569/tvpn3kclhkh6vphg2zpm.jpg	2025-08-17 13:05:00	Lopătari - Terca, Buzău	45.526811	26.538686	Ramalina europaea + Candelaria concolor	3	t	1
430	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756123352/m8fhopi1h7m7rbbxwdlw.jpg	2025-08-17 12:05:00	Mânzălești, Buzău	45.487731	26.636972	Lepraria incana + Hypogymnia physodes	6	t	1
428	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756121883/hplndlmcz15eookdrufl.jpg	2025-08-17 12:53:00	Lopătari - Terca, Buzău	45.526464	26.538697	Physcia stellaris	8	t	1
429	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756123142/bmmfdcdr2ynue319xsvk.jpg	2025-08-17 12:14:00	Mânzălești, Buzău	45.487587	26.634452	Hypogymnia physodes + Chrysothrix candelaris	5	t	1
423	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756110183/oasf8cplwvpspsh12yuc.jpg	2025-08-24 11:19:00	Lăpușna, Mureș	46.7673031	25.2362779	Platismatia glauca	4	t	35
316	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755759118/loyaxjokrfhur6ntuse5.jpg	2025-08-20 16:39:00	Parcul Tăbăcăriei, Constanța	44.2061748	28.6334519	Caloplaca saxicola	9	t	22
581	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757003858/sp0hjj2jcgtul1wavlcv.jpg	2025-09-04 18:02:00	Parcul Șipote, Suceava	47.642501	26.26814	Candelaria concolor + Hypogymnia physodes	7	t	55
323	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755853212/rywgjmymi9jcvynh55lj.jpg	2025-08-01 11:46:00	Parcul Crâng, Buzău	45.1452949	26.7942579	Phaeophyscia orbicularis	8	t	2
583	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757004383/npixpbnomil7hkrls12n.jpg	2025-09-04 18:07:00	Statuia ecvestră a lui Ștefan cel Mare, Parcul Șipote, Suceava	47.64231	26.26934	Polycauliona candelaria + Parmelia sulcata	8	t	55
372	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756012779/ujnjnul6dcbbaxtypjzr.jpg	2025-08-01 11:29:00	Parcul Crâng, Buzău	45.1465908	26.7978758	Phaeophyscia orbicularis	8	t	2
322	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755853111/rvj6ylshhbjbdxwgtj4b.jpg	2025-08-01 11:55:00	Parcul Crâng, Buzău	45.145408	26.7967533	Phaeophyscia orbicularis + Caloplaca citrina	9	t	2
352	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755949049/gvadwlroioohotxfoaov.jpg	2025-08-01 12:03:00	Parcul Crâng, Buzău	45.1459786	26.7950397	Phaeophyscia orbicularis + Physcia stellaris	8	t	2
501	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756839705/zbtg61ya1yaekg4yxtvv.jpg	2025-09-02 17:29:00	Cartier Gheorgheni, Cluj-Napoca	46.76818	23.62853	Xanthoria parietina + Hypogymnia physodes	5	f	30
502	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756839847/gsqzt1bk98ecbpfvu9es.jpg	2025-09-02 17:31:00	Cartier Gheorgheni, Cluj-Napoca	46.76913	23.62887	Hypogymnia physodes	5	f	30
240	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755507441/loe7ie41e07txcthq8su.jpg	2025-08-17 12:02:00	Mânzălești, Buzău	45.488339	26.638439	Physcia stellaris + Lepraria incana	6	t	34
584	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757004592/q5dalsg0noftt1uwhe0f.jpg	2025-09-04 18:30:00	Parcul Șipote, Suceava	47.644219	26.269437	Lepraria incana	6	t	55
464	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756636449/txp5rxanuyye544ph2ei.jpg	2025-08-22 14:52:00	Aleea Stadionului, Cluj-Napoca	46.76722	23.57223	Lepraria incana	6	t	18
582	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757004088/ki0uomqsojdivbbvf1fm.jpg	2025-09-04 18:06:00	Statuia ecvestră a lui Ștefan cel Mare, Parcul Șipote, Suceava	47.642464	26.269567	Melanelixia glabratula	6	t	55
580	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757003643/ajaftrvo0dy6igtzmiip.jpg	2025-09-04 17:57:00	Parcul Șipote, Suceava	47.642905	26.266526	Hypogymnia physodes	5	t	55
236	https://res.cloudinary.com/dkaff7r7k/image/upload/v1755506749/pc6lhjauu3btppe6rsqt.jpg	2025-08-17 11:59:00	Mânzălești, Buzău	45.487302	26.635468	Candelaria concolor + Lepraria incana	6	t	34
431	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756134255/gwlmvqnzhdpykccf7fun.jpg	2025-08-20 12:35:00	Parcul Herăstrău, București	44.472621	26.078922	Xanthoria parietina	10	f	14
432	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756134379/lecyh6xgsgoscpsavi07.jpg	2025-08-20 12:40:00	Parcul Herăstrău, București	44.472621	26.078926	Xanthoria parietina	10	f	14
503	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756841336/eeepsght8juh0cwi5tj0.jpg	2025-09-02 17:43:00	Cartier Gheorgheni, Cluj-Napoca	46.76688	23.62787	Xanthoria parietina + Hypogymnia physodes	5	f	30
504	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756841424/chgikyulmgrmwmc0bqfe.jpg	2025-09-02 17:44:00	Cartier Gheorgheni, Cluj-Napoca	46.76692	23.62781	Xanthoria parietina	10	f	30
505	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756841567/qjhktaejcxzlu2hpnnec.jpg	2025-09-02 18:45:00	Cartier Gheorgheni, Cluj-Napoca	46.7667	23.61963	Xanthoria parietina	10	f	30
506	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756841674/t0azya2hrwtmrhsv5cci.jpg	2025-09-02 18:43:00	Cartier Gheorgheni, Cluj-Napoca	46.76581	23.62004	Flavoparmelia caperata	5	f	30
507	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756841769/p7nvtqzd3okm0l0hjfj1.jpg	2025-09-02 18:42:00	Cartier Gheorgheni, Cluj-Napoca	46.76572	23.62014	Flavoparmelia caperata	5	f	30
585	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757008344/lcpvcvhele6r6te6xf8a.jpg	2025-09-04 20:18:00	Cartier Mănăștur, Cluj-Napoca	46.75321	23.54875	Lepraria incana	6	f	30
471	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647943/zw2gstd1lcfvx4ysgliy.jpg	2025-08-31 14:12:00	Ploștina, Lopătari, Buzău	45.495868	26.53944	Polycauliona candelaria	8	t	6
469	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647476/ok7fwlajwqiiup0gwpyh.jpg	2025-08-22 16:57:00	Strada George Coșbuc, Cluj-Napoca	46.76836	23.57485	Candelaria concolor + Physcia adscendens	7	t	18
466	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647134/b9upnwehhxyo9n8lntpr.jpg	2025-08-22 16:53:00	Aleea Stadionului, Cluj-Napoca	46.76743	23.57274	Caloplaca citrina	9	t	18
468	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647360/pz1fa3yc34icvbkb1meq.jpg	2025-08-22 16:55:00	Aleea Stadionului, Cluj-Napoca	46.76814	23.57446	Caloplaca citrina + Phaeophyscia orbicularis	9	t	18
467	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647254/fqgp8d2osljtuztvj6tx.jpg	2025-08-22 16:54:00	Aleea Stadionului, Cluj-Napoca	46.76743	23.57274	Candelaria concolor	7	t	18
470	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647624/qoqm8bp5rhztkqnoatpe.jpg	2025-08-22 16:59:00	Parcul Central "Simion Bărnuțiu", Cluj-Napoca	46.76888	23.57539	Hypogymnia physodes	5	t	18
465	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756647005/rbzk9actmslmewjcfohn.jpg	2025-08-22 16:53:00	Aleea Stadionului, Cluj-Napoca	46.76722	23.57223	Candelaria concolor	7	t	18
433	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756197373/grdexfbfdiqaabkdsqr0.jpg	2025-07-23 16:14:00	Seealpsee, Wasserauen, Switzerland	47.26649	9.39833	Peltigera canina	2	t	43
434	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756197675/rlqorvaw5cimlxmx9ee3.jpg	2025-07-23 16:25:00	Seealpsee, Wasserauen, Switzerland	47.26673	9.39944	Lecanora chlarotera	8	t	43
435	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756197777/org4jg14ytnxrv6ssohj.jpg	2025-07-23 16:34:00	Seealpsee, Wasserauen, Switzerland	47.26686	9.40085	Peltigera canina	2	t	43
436	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756198130/zwtzprrao17idv0waoug.jpg	2025-07-23 16:45:00	Seealpsee, Wasserauen, Switzerland	47.26627	9.40013	Cladonia fimbriata + Peltigera canina	2	t	43
437	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756198277/wbdvltu94dbi4e6wtoda.jpg	2025-07-23 16:50:00	Seealpsee, Wasserauen, Switzerland	47.26589	9.39872	Cladonia fimbriata	2	t	43
438	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756198541/h2ynu2cuvpavwhtxqgua.jpg	2025-07-23 16:55:00	Seealpsee, Wasserauen, Switzerland	47.26567	9.3965	Chrysothrix candelaris + Caloplaca citrina	2	t	43
439	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756198628/tdsomjqzf052cy95rw31.jpg	2025-07-23 17:00:00	Seealpsee, Wasserauen, Switzerland	47.26704	9.4011	Cladonia fimbriata	2	t	43
440	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756199036/iabqcnepk7lkln5asei4.jpg	2025-07-23 17:10:00	Seealpsee, Wasserauen, Switzerland	47.26652	9.40134	Lecanora muralis	8	t	43
472	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756722101/ujls19ufuq5tclkz16lm.jpg	2025-07-21 13:15:00	Parcul Herăstrău	44.473377	26.078024	Parmelia sulcata	7	f	16
473	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756722193/atb24ar6ee8sfq1cuqbn.jpg	2025-07-21 13:25:00	Parcul Herăstrău	44.472668	26.078883	Parmelia sulcata	7	f	16
508	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756845660/pjkfx3phzecc23wmwmvh.jpg	2025-09-02 18:16:00	Parcul Detunata, Cluj-Napoca	46.76494	23.62526	Candelaria concolor	7	f	30
17	https://res.cloudinary.com/dkaff7r7k/image/upload/v1753461586/dpnsjrzix2mnpqqkifwq.jpg	2025-07-01 07:33:00	Parcul Crâng, Buzău	45.14597	26.79752	Parmelia sulcata	7	t	1
59	https://res.cloudinary.com/dkaff7r7k/image/upload/v1754052919/k0w0454b4ac6snqsppya.jpg	2025-08-01 12:12:00	Buzău, Parcul Crâng	45.14638	26.800944	Xanthoria Parietina	10	t	9
561	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756910337/bijohogkd5pulxkn3rjs.jpg	2025-08-31 11:42:00	Mattenenge, Matte, Bern, Switzerland	46.948506	7.457364	Xanthoria parietina + Phaeophyscia orbicularis	8	t	34
441	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756229912/kv7c254wg1kisvpd4otj.jpg	2025-08-20 16:53:00	Parcul Rozelor, Cluj-Napoca	46.6487	23.5516	Flavoparmelia caperata	5	f	30
442	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230055/xwqrugnnvjfcycmnwvt1.jpg	2025-08-20 16:57:00	Parcul Rozelor, Cluj-Napoca	46.76492	23.55202	Xanthoria parietina	10	f	30
443	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230197/wmdskanl9yjj9lgyrk3b.jpg	2025-08-20 16:56:00	Parcul Rozelor, Cluj-Napoca	46.76486	23.55204	Xanthoria parietina	10	f	30
444	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230323/kubkpqki11zzgwkkpwpx.jpg	2025-08-20 16:55:00	Parcul Rozelor, Cluj-Napoca	46.765	23.55269	Flavoparmelia caperata	5	f	30
445	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230500/pkmf0r0ldfvytbwa5jro.jpg	2025-08-20 16:59:00	Parcul Rozelor, Cluj-Napoca	46.76503	23.55343	Flavoparmelia caperata	5	f	30
446	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230671/bkbjgmhbeco6km2ydqk2.jpg	2025-08-20 17:01:00	Parcul Rozelor, Cluj-Napoca	46.76503	23.55348	Flavoparmelia caperata	5	f	30
474	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756728964/o0b9uguzzquiw6ccbhmo.jpg	2025-07-21 13:30:00	Parcul Herăstrău	44.472621	26.07892	Xanthoria parietina	10	f	16
475	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729033/k0oo4bfqkbgktoubxjwq.jpg	2025-08-21 13:32:00	Parcul Herăstrău	44.472621	26.07892	Xanthoria parietina	10	f	16
476	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729198/xsab3reduwemb7twgmtj.jpg	2025-07-21 13:35:00	Parcul Herăstrău	44.472621	26.07892	Xanthoria parietina	10	f	16
509	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756892938/is7gx8vtqt9rcbjarlm5.jpg	2025-08-28 12:17:00	Castello Sforzesco, Milan	45.470414	9.182044	Flavoparmelia carperata	5	f	34
510	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756893399/die3nfzg4ozlk4ipkihv.jpg	2025-08-28 12:17:00	Castello Sforzesco, Milan	45.470106	9.182258	Lecanora campestris	10	f	34
511	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756893594/s3pt9skrna4nen6mykjn.jpg	2025-08-28 17:21:00	Castello Sforzesco, Milan	45.469167	9.183028	Flavoparmelia carperata	5	f	34
512	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756893829/splzztxyy3moqazecymo.jpg	2025-08-28 17:30:00	Castello Sforzesco, Milan	45.470817	9.183331	Flavoparmelia carperata	5	f	34
514	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756894482/qegdo4gbtq0j68ir6opn.jpg	2025-08-29 11:08:00	Varenna, Italy	46.014156	9.282728	Flavoparmelia carperata	5	f	34
519	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756896189/abwcuw9vkqck91yamjn5.jpg	2025-08-29 12:35:00	Como Lake, Bellagio	45.9856	9.262461	Flavoparmelia carperata	5	f	34
520	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756896487/bpdkj1hz4rzoobdzdgsa.jpg	2025-08-29 12:39:00	Parco Martiri della Libertà, Bellagio, Milan	45.984989	9.261328	Flavoparmelia carperata	5	f	34
521	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756898651/pil5fr00gsploi3kv8qp.jpg	2025-08-29 12:43:00	Piazza Mazzini, Bellagio	45.985461	9.260433	Lecanora muralis	10	f	34
522	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756898925/jp4gmo7ubewkaz6qivv9.jpg	2025-08-29 12:43:00	Piazza Mazzini, Bellagio	45.985461	9.260432	Lecanora muralis	10	f	34
523	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756899179/gpwbc2azhbiaavovsowb.jpg	2025-08-29 13:21:00	Bellagio, Italy	45.985878	9.261239	Flavoparmelia carperata	5	f	34
513	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756894073/nyu7txolt6f5ysx8diym.jpg	2025-08-28 17:31:00	Castello Sforzesco, Milan	45.471542	9.182836	Candelaria concolor	7	t	34
518	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756895983/vu04rlag2bdqdsocvyfy.jpg	2025-08-29 12:35:00	Como Lake, Bellagio, Italy	45.985594	9.262525	Candelaria concolor	7	t	34
515	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756894685/oyv2oizdk1jfqgeqz5x1.jpg	2025-08-29 11:08:00	Varenna, Italy	46.014172	9.282714	Canoparmelia crozalsiana	5	f	34
517	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756895183/nmeuq1pcxljjaykhlehc.jpg	2025-08-29 11:08:00	Varenna, Italy	46.014156	9.282722	Xanthoria parietina	10	f	34
516	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756894897/l9nxyifxs8nn90twpgus.jpg	2025-08-29 11:08:00	Varenna, Italy	46.014175	9.282714	Flavoparmelia carperata	5	f	34
477	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729350/wnfcgxvxfmgmyf4njtgc.jpg	2025-08-21 13:40:00	Parcul Herăstrău, București	44.472625	26.079205	Xanthoria parietina + Phaeophyscia orbicularis	8	t	16
553	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756908753/cyduwcwqbpeog8tdlzu3.jpg	2025-08-30 17:58:00	Bellevue, Hochschulen, Zürich, Switzerland	47.366658	8.545322	Xanthoria parietina + Phaeophyscia orbicularis	10	t	34
478	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729428/chlqk2zqnwn2dl34yfci.jpg	2025-08-21 13:45:00	Parcul Herăstrău, București	44.472625	26.079205	Xanthoria parietina + Phaeophyscia orbicularis	10	t	16
448	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230960/shah9gpvpuoq6tnplnyq.jpg	2025-08-20 17:05:00	Parcul Rozelor, Cluj-Napoca	46.76559	23.55555	Polycauliona candelaria	8	t	30
450	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756231387/neqmbsmhgrqnawor9aho.jpg	2025-08-20 17:06:00	Parcul Rozelor, Cluj-Napoca	46.76571	23.55572	Hypogymnia physodes + Xanthoria parietina	5	t	30
449	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756231048/nads4zgzngvr0utfcovi.jpg	2025-08-20 17:04:00	Parcul Rozelor, Cluj-Napoca	46.76569	23.55568	Xanthoria parietina	10	t	30
447	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756230809/fvvxiqswrdppfhdduzuc.jpg	2025-08-20 17:03:00	Parcul Rozelor, Cluj-Napoca	46.76513	23.55363	Polycauliona candelaria	8	t	30
451	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756316920/h8r2etiwwqllb1gfp4dj.jpg	2025-08-20 13:17:00	Parcul Herăstrău, București	44.4718287	26.0816446	Flavoparmelia caperata + Xanthoria parietina	8	f	27
452	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756317860/dsfvqjq1qdk0cownmscz.jpg	2025-08-20 13:44:00	Parcul Herăstrău, București	44.478266	26.078685	Xanthoria parietina + Physcia adscendens	10	f	27
524	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756899414/rk0cpfpr9epbtps3og8j.jpg	2025-08-29 13:21:00	Como Lake, Bellagio, Italy	45.985428	9.259661	Flavoparmelia caperata	5	f	34
526	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756899969/yd5upu41hhlcajvd69dq.jpg	2025-08-29 13:25:00	Como Lake, Bellagio, Italy	45.985425	9.2597	Lecanora campestris + Flavoparmelia caperata	5	f	34
527	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756900214/zuempg9p1nyez7xehwvm.jpg	2025-08-29 13:26:00	Como Lake, Bellagio, Italy	45.985428	9.259662	Lecanora conizaeoides	10	f	34
528	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756900663/elwmnouaflokazpgqrme.jpg	2025-08-29 13:27:00	Como Lake, Bellagio, Italy	45.985503	9.259686	Candelariella vitellina	7	f	34
529	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756900993/r05hw5dvzdxlrudipx69.jpg	2025-08-29 17:13:00	Via Serlas, Sankt Moritz, Grisons, Switzerland	46.498181	9.843414	Lecanora campestris + Polycauliona Candelaria	8	f	34
530	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756901410/b8h0fpo36fv3vvbcafkc.jpg	2025-08-29 17:13:00	Via Serlas, Sankt Moritz, Grisons, Switzerland	46.498161	9.843347	Lecanora campestris + Parmelia sulcata + Polycauliona Candelaria + Lecanora conizaeoides + Flavoparmelia caperata	8	f	34
531	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756901573/ndra450u4yyekrjiwzaq.jpg	2025-08-29 17:13:00	Via Serlas, Sankt Moritz, Grisons, Switzerland	4.498161	9.843347	Lecanora campestris + Parmelia sulcata + Polycauliona Candelaria + Lecanora conizaeoides + Flavoparmelia caperata	8	f	34
532	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756901734/fxrqgcjrmzi9ps9zzozp.jpg	2025-08-29 17:13:00	Via Serlas, Sankt Moritz, Grisons, Switzerland	46.498172	9.843317	Lecanora campestris + Polycauliona Candelaria	8	f	34
533	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756901925/uts27bzoc2bfmwkvublh.jpg	2025-08-29 17:15:00	Via Serlas, Sankt Moritz, Grisons, Switzerland	46.498081	9.843058	Xanthoria parietina	10	f	34
525	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756899646/awfyinshgq71gyyd1dtc.jpg	2025-08-29 13:22:00	Como Lake, Bellagio, Italy	45.985808	9.26045	Chrysothrix candelaris	2	t	34
481	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729716/zezrov9kbynhwdvk6m8i.jpg	2025-08-21 14:05:00	Parcul Herăstrău, București	44.471799	26.08159	Xanthoria parietina + Phaeophyscia orbicularis	10	t	16
480	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729539/rpvybgbo9v7v5vgtu6uv.jpg	2025-08-21 14:00:00	Parcul Herăstrău, București	44.472625	26.079205	Xanthoria parietina	10	t	16
479	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756729490/vetjrfu07yjyvrosysjg.jpg	2025-08-21 13:50:00	Parcul Herăstrău, București	44.472625	26.079205	Xanthoria parietina	10	t	16
586	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757083205/ay98gytj1iwxnb6h9miv.jpg	2025-08-03 15:50:00	Parcul ”Ion Dobre”, Năvodari	44.319056	28.609198	Phaeophyscia orbicularis	8	f	22
587	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757083510/zyzjmae9jqmkjoynjfy2.jpg	2025-08-18 16:12:00	Parcul ”Ion Dobre”, Năvodari	44.318571	28.616939	Parmelia sulcata	7	f	22
588	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757083723/qulqlhv69ae2i4czmpob.jpg	2025-08-03 19:38:00	Faleză Năvodari, Constanța	44.324356	28.637619	Caloplaca saxicola + Lecanora chlarotera	9	f	22
589	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757084166/lsrunysaww0kyvb57vtf.jpg	2025-08-03 19:17:00	Faleză Năvodari, Constanța	44.312686	28.631542	Xanthoria parientina + Physcia stellaris	9	f	22
590	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757084417/uen7tykvhyapypxu7hto.jpg	2025-09-03 11:44:00	Săliște, Sibiu	45.796173	23.895109	Lecanora chlarotera	9	f	22
591	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757084550/v8ilh5y3uxqscvj154ga.jpg	2025-09-03 14:38:00	Montana Garden, Rășinari, Sibiu	45.715277	24.075603	Lepraria incana	6	f	22
592	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757084812/melv0wv3ma0gtw2hn8cd.jpg	2025-08-30 16:57:00	Apoldu de Sus, Sibiu	45.846018	23.832063	Melanelixia glabratula + Parmelia sulcata	6	f	22
453	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756388385/aqcsjgdyp7vpkdzfstvj.jpg	2025-08-20 13:18:00	Parcul Herăstrău, București	44.472625	26.079205	Xanthoria parietina + Phaeophyscia orbicularis	8	f	14
454	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756388561/e8ixrraxuksuotjzduek.jpg	2025-08-20 13:29:00	Parcul Herăstrău, București	44.472625	26.079207	Xanthoria parietina	10	f	14
456	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756389152/kczjdznpoego4773zad0.jpg	2025-08-20 13:54:00	Parcul Herăstrău, București	44.472625	26.079203	Lecanora conizaeoides + Xanthoria parietina	10	f	14
482	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756763506/qminsq2iboyof9rgkabk.jpg	2025-08-11 16:25:00	Parcul Barcăului, Oradea	47.0616781	21.90704	Xanthoria parietina	10	t	23
536	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756904454/qfqdbimp8vndvsa9cgjj.jpg	2025-08-30 08:48:00	Rheinpark Stadion, Vaduz, Lichetenstein	47.139167	9.511281	Xanthoria parietina	10	f	34
537	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756904691/tjnkls1zojdzwus69cpb.jpg	2025-08-30 08:49:00	Rheinpark Stadion, Vaduz, Lichetenstein	47.139244	9.511103	Flavoparmelia caperata + Parmelia sulcata	6	f	34
538	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756904979/iutkemr2gfg3bjuvkeav.jpg	2025-08-30 08:58:00	Lettstrasse, Vaduz, Liechtenstein	47.140203	9.518569	Parmelia sulcata	7	f	34
540	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756905383/glsr7r72vczskoyuuxp6.jpg	2025-08-30 08:59:00	Lettstrasse, Vaduz, Liechtenstein	47.140306	9.518917	Flavoparmelia carperata	5	f	34
539	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756905157/yuz6kqgr5epzzywwb0pn.jpg	2025-08-30 08:59:00	Lettstrasse, Vaduz, Liechtenstein	47.140175	9.518728	Chrysothrix candelaris	2	t	34
534	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756903832/oiwjyzuxoud0juuxvhyd.jpg	2025-08-29 17:17:00	Via Serlas, Sankt Moritz, Grisons, Switzerland	46.498086	9.843067	Polycauliona candelaria	8	f	34
535	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756904159/p7t3pd9yrxbhwiw933md.jpg	2025-08-29 17:30:00	Ovel da la Resgia, Sankt Moritz, Grisons, Switzerland	46.4972	9.836625	Polycauliona candelaria	8	t	34
543	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756906513/ridhswn26kldbwksn8fu.jpg	2025-08-30 11:43:00	Gartenstrasse, St. Gallen - Innenstadt, Switzerland	47.422131	9.3744	Phaeophyscia orbicularis	8	t	34
544	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756906741/ptuqwrzg31esoy9ohh8s.jpg	2025-08-30 14:46:00	Belivedere, Daschen - Laufen am Rheinfall, Zürich, Switzerland	47.677064	8.614883	Polycauliona candelaria	8	t	34
551	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756908430/eq49s3bkhcezwbnejy0h.jpg	2025-08-30 16:52:00	Stadthausquai, Zürich, Switzerland	47.368756	8.541956	Xanthoria parietina + Physcia adscendens	9	t	34
555	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756909150/ng8tqhqe5hdnqu5le4uo.jpg	2025-08-30 18:11:00	Quaibrucke, Limmat, Zürich, Switzerland	47.367081	8.542992	Chrysothrix candelaris + Lecanora chlarotera	2	t	34
593	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757090244/luo0aw4vcud5r0yjcdao.jpg	2025-09-01 08:39:00	Apoldu de Sus, Sibiu	45.846065	23.831895	Caloplaca citria + Lepraria incana	8	f	22
549	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756907911/meni5v7lptb9pp4y4snm.jpg	2025-08-30 16:49:00	Hochschulen, Zürich, Switzerland	47.36365	8.544357	Lecanora muralis + Caloplaca saxicola	8	t	34
547	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756907259/hquocx8kzajr51bzai9b.jpg	2025-08-30 15:08:00	Schloss Laufen am Rheinfall, Zürich, Switzerland	47.676303	8.614875	Lecanora campestris + Caloplaca saxicola	7	t	34
554	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756908919/welr10qj8yv8z1ih6cb9.jpg	2025-08-30 17:58:00	Bellevue, Hochschulen, Zürich, Switzerland	47.366664	8.545278	Xanthoria parietina + Physcia adscendens	10	t	34
546	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756907096/be6ul7mc1msfawbcsnyg.jpg	2025-08-30 14:57:00	Rheinfall, Zürich, Switzerland	47.677742	8.614044	Ochrolechia parella	2	t	34
558	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756909742/kqsjtdifdalkysnbnotc.jpg	2025-08-31 10:16:00	Bear Park, Nydeggbrucke, Bern, Switzerland	46.948333	7.45905	Lecanora campestris + Lecanora muralis	8	t	34
545	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756906903/hclr80cok5onvdzzytpf.jpg	2025-08-30 14:57:00	Neuhausen am Rheinfall, Schaffhausen, Switzerland	47.678106	8.613836	Caloplaca saxicola + Lecanora muralis	9	t	34
559	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756909979/ppgpndduqdw5vr3uetax.jpg	2025-08-31 10:18:00	Nydeggtreppe, Matte, Bern, Switzerland	46.948464	7.457189	Caloplaca saxicola + Physcia adscendens	9	t	34
557	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756909554/l6us5syi9dwaejebq95i.jpg	2025-08-31 10:15:00	Bear Park, Nydeggbrucke, Bern, Switzerland	46.948264	7.459025	Physcia stellaris + Caloplaca saxicola	8	t	34
556	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756909377/rwakvybd0q9pisyfbisw.jpg	2025-08-31 08:09:00	Schlegeli, Adelboden, Bern, Switzerland	46.494808	7.563558	Candelariella aurella + Physcia stellaris + Caloplaca saxicola	8	t	34
552	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756908555/sg5u2qz3jff1ycdswwsy.jpg	2025-08-30 16:52:00	Stadthausquai, Zürich, Switzerland	47.368756	8.54958	Xanthoria parietina + Physcia adscendens	10	t	34
550	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756908274/ikbub0w27unrmguknl3h.jpg	2025-08-30 16:49:00	Stadthausquai, Zürich, Switzerland	47.367653	8.541869	Xanthoparmelia + Lecanora muralis	6	t	34
548	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756907689/ptoqqucjcbd8oosxrnaz.jpg	2025-08-30 16:49:00	Hochschulen, Zürich, Switzerland	47.36365	8.544356	Lecanora muralis + Phaeophyscia orbicularis	8	t	34
560	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756910157/qkbha4j3l0d0c7uqu3cy.jpg	2025-08-31 11:42:00	Nydeggtreppe, Matte, Bern, Switzerland	46.948411	7.457503	Caloplaca saxicola + Phaeophyscia orbicularis	9	t	34
542	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756906083/t3wmvynixeprvtdy65bp.jpg	2025-08-30 11:15:00	Museumstrasse, St. Gallen - St. Jakob, Switzerland	47.427067	9.379433	Parmelia sulcata + Phaeophyscia orbicularis	7	t	34
541	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756905829/qc5edispkbozibfdgfpz.jpg	2025-08-30 10:15:00	Lettstrasse, Vaduz, Liechtenstein	47.139856	9.512714	Candelaria concolor + Lecanora conizaeoides + Phaeophyscia orbicularis	10	t	34
483	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756764379/modptrqfhk67jko6rnfc.jpg	2025-08-24 15:14:00	Stâna de Vale, Budureasa, Bihor	46.6933611	22.6285472	Cladonia rangiferina	1	t	23
455	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756388767/fjyvwm9gvnmx0k2dxtut.jpg	2025-08-20 13:43:00	Parcul Herăstrău, București	44.471799	26.081591	Xanthoria parietina + Flavoparmelia caperata	10	t	14
457	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756399226/zgimx7ndn8nmuqzcbglf.jpg	2025-08-28 18:40:00	Suceava, România	47.691573	26.280177	Flavoparmelia caperata	5	t	55
601	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757091771/jezpe122iwvqtquwswwv.jpg	2025-09-03 14:40:00	Montana Garden, Rășinari, Sibiu	45.715324	24.075765	Phaeophyscia orbicularis	8	f	22
602	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757092262/xle8qx346jzgymdctizn.jpg	2025-09-03 15:56:00	Parcul "Sub Arini", Sibiu	45.77933	24.140374	Caloplaca citrina	8	f	22
564	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756911163/l8or5s0oo3psuespmduf.jpg	2025-08-31 13:23:00	Quai Edouard-Jaccoud, Vernex, Montreux, Switzerland	46.435914	6.908625	Lecanora chlarotera	8	t	34
603	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757092355/dutu5di0i8zrfmpq6wl4.jpg	2025-09-03 15:57:00	Parcul "Sub Arini", Sibiu	45.779705	24.14049	Xanthoria parientina	10	f	22
568	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756911736/uws1ojmpcdssphieizfu.jpg	2025-08-31 13:42:00	Quai de la Rouvenaz, Montreux, Vaud, Switzerland	46.429947	6.909086	Xanthoria parietina + Ramalina farinacea	10	t	34
633	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757274799/badeh4qcmw2iebkhlwuu.jpg	2025-08-30 14:09:00	Lipia, Buzău	45.13727	26.7342	Vezi tu Carla	1	f	1
604	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757092937/khv7litly3a4yucvtbky.jpg	2025-09-03 15:58:00	Parcul "Sub Arini", Sibiu	45.779779	24.140586	Xanthoria parientina + Parmelia sulcata	10	f	22
605	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093227/ec8bet8e1ceh8ds1wp7o.jpg	2025-09-03 16:02:00	Strada Argeșului, Sibiu	45.776867	24.140166	Polycauliona candelaria	8	f	22
606	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093314/txs9qrhxsfaxumujjbtd.jpg	2025-09-03 16:07:00	Calea Dumbrăvii, Sibiu	45.774282	24.141289	Caloplaca saxicola	8	f	22
567	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756911622/xa4ajeig0xkliuzuc9jb.jpg	2025-08-31 13:42:00	Quai de la Rouvenaz, Montreux, Vaud, Switzerland	46.429947	6.909086	Parmelia sulcata	7	t	34
565	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756911327/bezo2mqpukrawitoozd8.jpg	2025-08-31 13:28:00	Grand-Rue, Vernex, Montreux, Vaud, Switzerland	46.434989	6.909594	Parmelia sulcata + Lecanora conizaeoides	7	t	34
607	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093466/a5og4t9xrczijdqqvxx9.jpg	2025-09-03 17:15:00	Parcul "Sub Arini", Sibiu	45.775264	24.138036	Flavoparmelia caperata	5	f	22
563	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756910706/bdv3wg82t6uwi67phuhh.jpg	2025-08-31 13:22:00	Quai Edouard-Jaccoud, Vernex, Montreux, Switzerland	46.436078	6.908656	Phlyctis argena	6	t	34
566	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756911478/fnq5d33keoy4spomy9rn.jpg	2025-08-31 13:42:00	Quai Ami-Chessex, Montreux, Vaud, Switzerland	46.422347	6.920614	Parmelia sulcata	7	f	34
608	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093571/akcou2yx2peygqkfplum.jpg	2025-09-04 12:56:00	Galeș, Săliște, Sibiu	45.795631	23.87237	Polycauliona candelaria	8	f	22
484	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756766009/qxymapqz4unqwwoir4gn.jpg	2025-08-14 14:08:00	Băile Felix, Sânmartin, Bihor	46.9941444	21.977845	Lecanora conizaeoides	10	t	23
594	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757090359/yjurfm13ujmk5usa1pz1.jpg	2025-09-01 10:27:00	Săliște, Sibiu	45.796318	23.895478	Xanthoria parientina	10	f	22
595	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757090563/sqlu9o0weaktcqpzln2z.jpg	2025-09-03 11:03:00	Săliște, Sibiu	45.796568	23.895544	Caloplaca citrina	9	f	22
596	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757090719/ogajv6fuj7wdcuajqqx6.jpg	2025-09-05 18:19:00	Pădure Burdujeni-Sat, Suceava	47.691829	26.285563	Ramalina farinacea	4	f	55
597	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757090730/xozqsgjgicy9r0ahtser.jpg	2025-09-01 11:14:00	Apoldu de Sus, Sibiu	45.846149	23.832085	Physcia stellaris	6	f	22
598	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757091359/cyqa20qzyauifarvpofm.jpg	2025-09-03 11:00:00	Săliște, Sibiu	45.796379	23.896255	Lecanora chlarotera + Polycauliona candelaria + Candelaria concolor	8	f	22
599	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757091498/glmpt2qoasrjkrxw4u2k.jpg	2025-09-03 11:44:00	Săliște, Sibiu	45.796432	23.896471	Polycauliona candelaria	8	f	22
600	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757091675/pxrem7ujhgdx0l9htigp.jpg	2025-09-03 14:40:00	Montana Garden, Rășinari, Sibiu	45.715358	24.07576	Xanthoria parientina + Parmelia sulcata	8	f	22
609	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093702/ndj7agbp3orht5cmx9wb.jpg	2025-09-04 13:57:00	Cimitirul din Apolu de Sus	45.846742	23.832138	Polycauliona candelaria	8	f	22
610	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093908/uyfbtuolnxabws0v6ke6.jpg	2025-08-31 11:36:00	Cetatea Histria, Constanta	44.5473867	28.7734348	Xanthoria parietina	10	f	57
611	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757093918/l51tc9bfkovy3pq4ps2i.jpg	2025-08-31 11:36:00	Cetatea Histria, Constanta	44.5473867	28.7734348	Xanthoria parietina	10	f	57
612	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757094037/lczugo9v02bampnwadpt.jpg	2025-08-31 10:25:00	Cetatea Histria, Constanta	44.546879	28.771926	Xanthoria Parietina	10	f	57
613	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757094591/eimm18ibpydcdre8fkwa.jpg	2025-09-05 15:42:00	Burdujeni-Sat, Suceava	47.691889	26.280634	Candelaria concolor, Hypogymnia physodes	7	f	55
614	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757094743/lxcv1agkeohrzy6kglms.jpg	2025-09-05 18:36:00	Burdujeni-Sat, Suceava	47.691763	26220615	Evernia prunastri	4	f	55
485	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756827319/w1exjp3ixee65mpuesrq.jpg	2025-08-30 11:12:00	Nea Moudania, Greece	40.2382578	23.2900668	Polycauliona candelaria	8	t	1
617	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757144357/rckhf8v9k4i8guc7a3pe.jpg	2025-09-01 11:10:00	Apoldu de Sus, Sibiu	45.845974	23.831935	Candelariella aurella	9	f	22
618	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757144646/ildcfej5c98wud1bezyg.jpg	2025-08-30 16:58:00	Apoldu de Sus, Sibiu	45.846064	23.831969	Candelariella aurella + Physcia stellaris	7	f	22
619	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757144735/zabg2nso8dsah0gvjf1r.jpg	2025-08-30 16:58:00	Apoldu de Sus, Sibiu	45.84607	23.832009	Polycauliona candelaria + Candelariella aurella	9	f	22
572	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756912388/ppxkjsdvzdzvirjllevs.jpg	2025-09-01 16:45:00	Gornergrat, Zermatt, Wallis, Switzerland	45.983086	7.782264	Polycauliona candelaria	8	t	34
571	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756912186/d48n6l2kgvbusnuw5lh8.jpg	2025-08-31 15:21:00	Chateau de Chillon, Vaud, Switzerland	46.414356	6.927994	Polycauliona candelaria	8	t	34
620	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757144856/xtfjv1hs0ahx36ad14vn.jpg	2025-09-01 08:20:00	Apoldu de Sus, Sibiu	45.845977	23.831896	Candelariella aurella + Lepraria incana	7	f	22
569	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756911905/dxdqutkxtprjph0uazwo.jpg	2025-08-31 15:20:00	Chateau de Chillon, Vaud, Switzerland	46.414608	6.927989	Lecanora muralis	8	t	34
621	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757145055/ltqdl60njjlupv3qinhn.jpg	2025-09-01 11:09:00	Apoldu de Sus, Sibiu	45.846188	23.832023	Enchylium polycarpon	1	f	22
570	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756912041/vwvc9khj6zvsco07ls75.jpg	2025-08-31 15:20:00	Chateau de Chillon, Vaud, Switzerland	46.414458	6.928019	Lecanora chlarotera + Physcia adscendens	8	t	34
622	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757145233/w9hd5tn3g8jr6ijp9fru.jpg	2025-09-01 11:10:00	Apoldu de Sus, Sibiu	45.846101	23.831959	Enchylium polycarpon +Candelariella aurella + Physcia stellaris	7	f	22
462	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756447251/bgi77cbagsaavavdlqis.jpg	2025-08-23 17:19:00	Platou Sala Sporturilor, Cluj-Napoca	46.76703	23.5568	Xanthoria parietina + Lecanora conizaeoides + Phaeophyscia orbicularis	10	t	30
623	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757145463/gcmu7q4aujxl4cw7p2tq.jpg	2025-09-01 11:14:00	Apoldu de Sus, Sibiu	45.846045	23.831978	Enchylium polycarpon + Physcia stellaris	7	f	22
461	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756447085/i2vuzrtzpuvwa3nqxgg6.jpg	2025-08-23 17:18:00	Platou Sala Sporturilor, Cluj-Napoca	46.76707	23.55676	Caloplaca citrina	9	t	30
459	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756446629/vt0xfvks7tpvqqkejzbu.jpg	2025-08-23 17:18:00	Parcul Rozelor, Cluj-Napoca	46.7659	23.55594	Xanthoria parietina + Phaeophyscia orbicularis	8	t	30
460	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756446779/eenmz83vmyg4dg8y4ulk.jpg	2025-08-23 17:18:00	Parcul Rozelor, Cluj-Napoca	46.76707	23.55676	Xanthoria parietina + Phaeophyscia orbicularis	10	t	30
458	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756446416/halm5hiw7eo4q7iivclx.jpg	2025-08-23 17:16:00	Parcul Rozelor, Cluj-Napoca	46.76569	23.55568	Candelaria concolor + Lecanora conizaeoides	7	t	30
615	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757144080/veadqgujt6ru2dxnruiy.jpg	2025-09-01 10:27:00	Săliște, Sibiu	45.796538	23.895529	Polycauliona candelaria + Candelariella aurella	9	f	22
616	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757144237/m3jd3sl06qhfqvqk0r3v.jpg	2025-09-01 16:36:00	Săliște, Sibiu	45.796631	23.89552	Polycauliona candelaria + Candelariella aurella	9	f	22
463	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756541637/bvuyn8xbsor2ncwz7qhi.jpg	2025-08-30 11:12:00	Nea Moudania, Greece	40.2382578	23.2900668	Caloplaca citrina	9	f	30
486	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756832758/csru3ecdbdqt7giyhmch.jpg	2025-09-02 17:10:00	Cartier Gheorgheni, Cluj-Napoca	46.76803	23.62764	Xanthoria parietina	10	f	30
487	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756832916/tqhfteczkiehctfegese.jpg	2025-09-02 17:10:00	Gheorgheni, Cluj-Napoca	46.76844	23.62695	Flavoparmelia caperata	5	f	30
488	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756834448/sxgdy5vbblpwumpgrwmt.jpg	2025-09-02 17:12:00	Cartier Gheorgheni, Cluj-Napoca	46.76844	23.62695	Flavoparmelia caperata	5	f	30
489	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756834533/dyyruniuawu4miolfrkc.jpg	2025-09-02 17:15:00	Cartier Gheorgheni, Cluj-Napoca	46.76834	23.6273	Flavoparmelia caperata	6	f	30
490	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756834680/zafcp29paxvma7tpgrfj.jpg	2025-09-02 17:17:00	Cartier Gheorgheni, Cluj-Napoca	46.76828	23.62724	Flavoparmelia caperata	5	f	30
491	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756835080/onpal1dibknasrtmwxan.jpg	2025-09-02 17:18:00	Cartier Gheorgheni, Cluj-Napoca	46.76811	23.62725	Candelaria concolor	7	f	30
492	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756835276/l0bp5dbkshbq3nhjkbl6.jpg	2025-09-02 18:48:00	Cartier Gheorgheni, Cluj-Napoca	46.76804	23.61911	Candelaria concolor	7	f	30
493	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756835406/wyimudjttg5euwsttjth.jpg	2025-09-02 18:48:00	Cartier Gheorgheni, Cluj-Napoca	46.7679	23.61918	Xanthoria parietina + Flavoparmelia caperata	5	f	30
494	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756835501/yvrnepk6eamusht7aouu.jpg	2025-09-02 18:46:00	Cartier Gheorgheni, Cluj-Napoca	46.76704	23.61956	Flavoparmelia caperata	5	f	30
495	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756835634/jodxwo4a7vnk7l2szi9b.jpg	2025-09-02 17:24:00	Cartier Gheorgheni, Cluj-Napoca	46.76843	23.62734	Xanthoria parietina + Flavoparmelia caperata	5	f	30
496	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756835917/m5kjqcwjjcw4qjxnckod.jpg	2025-09-02 17:22:00	Cartier Gheorgheni, Cluj-Napoca	46.76796	23.62711	Lecanora conizaeoides	10	f	30
497	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756836057/qruwphoz3yvkga99en06.jpg	2025-09-02 17:20:00	Cartier Gheorgheni, Cluj-Napoca	46.76795	23.62721	Lecanora conizaeoides	10	f	30
498	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756836233/nzflri2zlgqqatxq14wb.jpg	2025-09-02 17:19:00	Cartier Gheorgheni, Cluj-Napoca	46.76803	23.62721	Candelaria concolor + Hypogymnia physodes	5	f	30
499	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756836376/shnifexh6eutmvfbyqkk.jpg	2025-09-02 17:19:00	Cartier Gheorgheni, Cluj-Napoca	46.76806	23.62737	Hypogymnia physodes	5	f	30
500	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756836818/utopd6axbbat908x5i4o.jpg	2025-09-02 17:28:00	Cartier Gheorgheni, Cluj-Napoca	46.76832	23.62838	Flavoparmelia caperata	5	f	30
575	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756987269/bt13donu8r7one3vwz6k.jpg	2025-09-04 13:27:00	Lunca Jariștei, Siriu, Buzău	45.47981	26.24945	Polycauliona candelaria	8	t	58
576	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756987387/e6sebm31x3tznxhfwn5q.jpg	2025-09-04 13:41:00	Lunca Jariștei, Siriu, Buzău	45.48122	26.25352	Caloplaca citrina	9	t	58
624	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757235657/iwxdikslo3suasiyt2jk.jpg	2025-08-20 13:44:00	Parcul Herăstrău, București	44.4783237	26.0786807	Xanthoria parietina + Lecanora conizaeoides + Physcia adscendens	10	f	27
625	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757236639/eupniuigdmkvlq8zbwwa.jpg	2025-08-20 13:45:00	Parcul Herăstrău, București	44.478401	26.078717	Xanthoria parietina + Flavoparmelia caperata	9	f	27
626	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757237326/xkohoz6u2mtuyylyltau.jpg	2025-08-20 13:46:00	Parcul Herăstrău, București	44.4784462	26.0787183	Xanthoria parietina + Physcia adscendens	10	f	27
627	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757237478/rjs805gqdaahgqnw0esf.jpg	2025-08-20 14:14:00	Parcul Herăstrău, București	44.481038	26.080245	Xanthoria parietina + Physcia adscendens	10	f	27
573	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756986031/rguhsqlx0m1xdtjjxwjz.jpg	2025-09-04 13:25:00	Lunca Jariștei, Siriu, Buzău	45.4793	26.25043	Flavoparmelia caperata	5	t	58
628	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757237786/x4xlpqap2zfa7pockq3e.jpg	2025-08-20 14:14:00	Parcul Herăstrău, București	44.4810547	26.0803524	Flavoparmelia caperata + Physcia adscendens + Xanthoria parietina	8	f	27
629	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757237924/f7xye8buy8vfu6a1tz9u.jpg	2025-08-20 14:22:00	Parcul Herăstrău, București	44.483198	26.083238	Xanthoria parietina + Physcia adscendens	10	f	27
577	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756987506/a58oey3hdljofsrfytqp.jpg	2025-09-04 13:32:00	Lunca Jariștei, Siriu, Buzău	45.47925	26.24833	Polycauliona candelaria	8	t	58
578	https://res.cloudinary.com/dkaff7r7k/image/upload/v1756987647/njefyrsezxpdyjg50ycj.jpg	2025-09-04 13:30:00	Lunca Jariștei, Siriu, Buzău	45.47879	26.24907	Flavoparmelia caperata	5	t	58
630	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757238832/lywqqs5rtl30sihikqje.jpg	2025-08-20 14:22:00	Parcul Herăstrău, București	44.4832719	26.0832864	Flavoparmelia caperata + Xanthoria parietina	7	f	27
631	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757238971/jhjuktktb6cklqr0sskd.jpg	2025-08-20 14:25:00	Parcul Herăstrău, București	44.483675	26.083662	Xanthoria parietina + Physcia adscendens	10	f	27
632	https://res.cloudinary.com/dkaff7r7k/image/upload/v1757239087/ryiwzqmjrul7n9wbqrel.jpg	2025-08-20 14:30:00	Parcul Herăstrău, București	44.485652	26.084529	Physcia adscendens + Xanthoria parietina	10	f	27
634	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757276547/w4lhmnhzrdlhxb9aeuuo.jpg	2025-09-07 14:04:00	Cartier Mărăști, Cluj-Napoca	46.78124	23.6085	\N	\N	f	30
635	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757333985/kmv59f3k9zxew0sy1whc.jpg	2025-09-07 12:30:00	Strada Nr.6 Codrului, Vernești, Buzău	45.214103	26.650914	Xanthoria parietina	10	f	34
636	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757334097/votnqhxkk5sjgmq3tu73.jpg	2025-09-07 12:31:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.214478	26.651178	Xanthoria parietina	10	f	34
637	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757334302/oi1partltubftvkpbx2z.jpg	2025-09-07 12:32:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.214286	26.651444	Xanthoria parietina + Parmelia sulcata	9	f	34
638	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757334413/iqotfoswml3bjt1up9hn.jpg	2025-09-07 12:34:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.213722	26.650686	Xanthoria parietina	10	f	34
639	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757334529/hbfzwmvju6ztihqvxi7d.jpg	2025-09-07 12:35:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.2137	26.649789	Xanthoria parietina	10	f	34
640	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757334699/z2aomimssxqqwxzlzhuk.jpg	2025-09-07 12:35:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.2137	26.649769	Xanthoria parietina + Parmelia sulcata	9	f	34
641	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757334894/nv8mnizmbdj0xiklcw6m.jpg	2025-09-07 12:37:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.213364	26.648853	Xanthoria parietina + Parmelia sulcata + Hypogymnia physodes	7	f	34
642	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757335008/y8wzqar8ktmfqcjtwdqi.jpg	2025-09-07 12:37:00	strada Nr. 6 Codrului, Vernești, Buzău	45.213372	26.648864	Xanthoria parietina + Parmelia sulcata	8	f	34
643	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757335169/v4ir83ki7swsyyrtlgcu.jpg	2025-09-07 12:40:00	Strada Nr. 6 Codrului, Vernești, Buzău	45.212925	26.64836	Xanthoria parietina	10	f	34
644	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757653892/dvzhkhezx7irpugz1abx.jpg	2025-08-31 11:07:00	Histria	44.5467953	28.7714379	Xanthoria parietina	10	f	57
645	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757654047/yih9dvjtasw9txkyvxsb.jpg	2025-08-31 12:13:00	Histria	44.5467753	28.7715089	Xanthoria parietina	10	f	57
646	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757654333/bfh1w08rks9dl3afjrou.jpg	2025-08-31 13:17:00	Histria	44.5480173	28.7733613	Xanthoria Parietina	10	f	57
647	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757654514/pnnyno0lc5jy8kqvu0ns.jpg	2025-08-31 14:26:00	Histria	44.5479647	28.7738103	Xanthoria Parietina	10	f	57
648	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757654641/iqlqpfjez2ncqa1hfizz.jpg	2025-08-31 10:30:00	Histria	44.5478123	28.7749619	Xanthoria Parietina	10	f	57
649	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757654858/gzbhphe9yfytmyykw1j4.jpg	2025-08-31 11:23:00	Histria	44.5472677	28.7755859	Caloplaca citrina	9	f	57
650	https://res.cloudinary.com/dr8rvsmlz/image/upload/v1757655245/bvpxfl1r6uikzftxkfie.jpg	2025-08-31 12:42:00	Histria	44.5473843	28.77342	Caloplaca citrina	9	f	57
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, username, email, password_hash, is_approved) FROM stdin;
1	admin	admin@example.com	scrypt:32768:8:1$rQxBXOTZg7oasB6B$47e635d664818bc1d3f4840935f050f4da97f64e3a25d9afa01e156144fb8598660414a62259b493f040678ff718959c22b0815608c65369a90d8e8be7b643a5	t
3	Rarestest	r@gmail.com	scrypt:32768:8:1$sQyjo9MjHKboTYDC$8e6f04e690e2ab00cb254ae86655eff1a12c2d2e977efb85fba3aa91ad3492db4019818ea6b278d40f43230f2d6de6d68a0cad1616804d31485be757b205506b	f
4	m	m@gmail.com	scrypt:32768:8:1$tWr9ni8sZYukbZ5B$ae38dc831925f1edb3c122c6267b1b73066b5e1098502f0ae46113bbd472332f9453ac26d3a11f9b133419f0bbca2b9b3d5fc433603cdbcc3dece478c328f677	f
6	Raisa Mirea	raisamirea29@gmail.com	scrypt:32768:8:1$8PFpPvxmQX6pGY6S$3c91e63b7fac147ef0aff108df6935d021434e12c53cb527ec00d8bd82c826243d9da021f956518658e80c4e53db50c189bd750fc0255feda0f7923d5f6fece1	t
5	Dărăbăneanu Luka	luka.tudor09@gmail.com	scrypt:32768:8:1$tnPYFHGzQfLoBeQ5$ca0939d445229840992adf69ecb5f15d8c9df9b792b718d88e68e311f6e12cc7b73592fcf0b9553802e01f4d25941e682a48f41ce726a824dbbeffb29c18eba3	t
7	voluntar	voluntar@gmail.com	scrypt:32768:8:1$MEfGwt2jdI2FsLFx$f47973f2b156b78b98d88ea2dbde2b3e1db020be6f07db06b3c6ef94831b23c5186ec15ca563e599065fd5277c3b34acf5412ec117185a069ca6c044309e1889	t
2	123	123@gmail.com	scrypt:32768:8:1$9eIDNLRj7fRtfK5c$6f0cfa6ef4737f42607eb1615fd52fed7f3b4b27b51e9e7ec0ee5083d8e6cb8796e6d8e642f92e78096fea7491dfd12edca5baea71cfeab9e73b95c24627e63e	t
8	Ana S	silivestruanamaria2009@gmail.com	scrypt:32768:8:1$mQu7J4fRBDCPMXv9$460e8cd5f1240d7b010fc0c5356d83911a4bb0efbde81c47e5d72430540af81acbd015dd2f2ee86c22651cf96a4f541e94ffa911e04e30bde4d9b31449647ea0	t
9	Ioana Spineci	ioanaspineci@gmail.com	scrypt:32768:8:1$veAiSvsQWkJa1TWQ$e004753c749a764a2221e47609504edc3a60d90d31ce1d0028acf7d781282609aa8c8bf651f804165c5716f1a0b46d9873475d3766740e5501f02cf9c5e7d529	t
10	sinzianapanturu	sinzianapant@gmail.com	scrypt:32768:8:1$cc6f2nXvSE6aYwMz$2a7ce8a88c11ece9259c5f72ac50a923e08a5e93d10e0a89b3e4830684472e09dcc8b7974839f56ead65581351271cf70a89de2cb8753f53ae7d483f57f7ac22	t
12	Ralucapava	ralucapavalache5@gmail.com	scrypt:32768:8:1$UvsC5M7S05sPnqwS$d0eacfd9f8c37f69705ee1a8f10f242853b649f77d727202a2651e0c6b6b473a18e02ab1ed2f7976c624d7748be48811381fd6e94281b3cbe52d0ebafb5a2481	t
15	maria rusu	mariapentrudocumente@gmail.com	scrypt:32768:8:1$LQ3UiDOgvbz0xLrR$81f8c54cefabb6430c8f9bcb551bf56b3c968a8af045eee66e2623e87b5b3be3c36e25db981268810d1aa4e5ce2775653148ba5f9c3edb7ad1b6306f2b509d5e	t
14	Eliza._.	calinovschieliza@gmail.com	scrypt:32768:8:1$zqSlqIfxycjhS0Sc$fe762b5d31268ebbd2a0e1c21ca18434b1f6f89432a13554309cd36747ba1de477f3a0dbcac583408b2637d797bd809ba75f458757870aefce7ca09195d5cd34	t
13	Silvi_Cristina	cristinaormenisan14@gmail.com	scrypt:32768:8:1$d2dAQBQ1aDViL8MZ$9170397f9a44de55f1c73e2f692436ca02ad65a12f2ff8edd3e3c57a1117b0471d33947a8e5490cfaee5a30a696dee7b525b21af934c2bcbd9e4233f1049b57e	t
11	antoniap	damianadami40@yahoo.com	scrypt:32768:8:1$iyJfdk299lUq31la$393a6ce58f97547611c7cfab657a15c37a165d0e8d72032c058430c66ab954f9d3cfd975e5eb24207258a624b892d0e2f8f96bb15f0ed8656db0ad24443a9ebd	t
16	Maya✨💖	askmayaask@gmail.com	scrypt:32768:8:1$c7rt5rpzJPRA300w$89bb0418ee46ea7e5dae0bb4eb6e1dd253702f425a844bcd6b49d63dfd822233c4ef1fd35124152bc7dbafc443eea2f8b32484d4fd1452cb165d1554e9505295	t
17	Alufi Noa🌸🌺🐞	noas20103@gmail.com	scrypt:32768:8:1$DvkAUk7BveSKYQV3$4449a8443dbfaeeabda7f67bd370047fe2d60af2894fdb1571034ad99293cca0cd5d98816064a31f5e4ac0e2454c1cff0da5f25d9d2b3846d9a0246eda9d3087	t
18	deni230	denisa.xo28@gmail.com	scrypt:32768:8:1$yvWV79fwe24Xe8M6$d4961875afb0e0f04ccc57b3aaa31f67d95dd2f00da9d347bb44684df45b9e56c95f0989df4b3ed27a9579133102f511adeb03ac11fec5d1015b041c0f35c609	t
19	Antonio P	tanumotanu09@gmail.com	scrypt:32768:8:1$XY9jJLr5CLNJamj9$1642bb958955765819441e3a26a8e7182ed714513dc9435263bcf3c34ae273cc6566ca8e5fc4c88789c9bf101081bcadc124024469169d199788b2cc44567e28	t
20	Ichim Sofia	stvbs1112@gmail.com	scrypt:32768:8:1$Anrp7bvkSJm5EjyI$80969d917eae3212d4f592e27ed8677169d783ee6dac8f762c0907c74ee68ec88e475362cd836b366ddcc746a05af82343b3ecf640ba2337a610521a81c65a60	t
23	Antonia Păcurar	antonia000maria7@gmail.com	scrypt:32768:8:1$xgWnN5w45JFZOSww$b6d58b6c29ae0c795605d822842d1bb762a0c1d599fbfe01c4b62d50a8c19f8fce8da0d35739817fe38fe7c4162c8fd5f1e1715065d24e64a2ad1576645ada5d	t
25	dianaa	diana.bucioaca24@gmail.com	scrypt:32768:8:1$weOoDRs9KeJP1Toe$56650ee947faae2c59ca6c0e00d9ab25cf2a3f80532de2fbae9a3bac1b148c4e789030f2ce16abd4642b3da2f26c7228ffbff057ca90894cc6c07386a874f4ef	t
26	Ilinca	iseleusan@gmail.com	scrypt:32768:8:1$d0Bu7GMAvIaWR72V$1f28fa33701518736b5b6efd348e1acaee19b887a4cb4f5dd92e1c2c63604bf59381f266dec868702a1d67740dff8c1dbed1c27bfb35a1b2743b3028bbb30c9e	t
27	Ioana Nen	ioannanen@gmail.com	scrypt:32768:8:1$h7WhisWVOPfk4GFG$5201f8b991219daba9f9d8ef5e9c68636a56e60b904f625a3a611bb0350d98ef23fc641b233f83fae1fcffefab6c662039b5ffe0ebab9d339094421a2c7e33d7	t
28	Huluba Camelia	hulubacamelia5@gmail.com	scrypt:32768:8:1$s7jOF27590n60bg4$3b14fc87ae4902d6a128b3660112b7f58762d20d43d538cf7a0fdcbddbe53d3a56150a8d220ff1ce8435c46cb7d6f6c0b3e3e12cc47b414d84e2132db2f02855	t
24	Stanca Alexia	ionela.rotaru88.vladu@gmail.com	scrypt:32768:8:1$cVJzIxDSmGMU7Fkb$696ae80681c19cfeb6613778d3ea749ad2f5a30d85dae68706b39a16175aaf52e347f13cbe0a4907fde9adbbad02c375b250fe9fbbe40555e436fcd914b4eb9a	t
22	crina	ardeleanu.crina26@gmail.com	scrypt:32768:8:1$PwwjFTbsUYccAzz9$a85d43e04b821f38cdbe1747cad284207f7d0c0897bf56a34ecf3b61a9021b0736c08ae19a2e941367a37edb548549835fb3750eb3fce50ed8c8b21dce2bf214	t
21	Irina	yodab0907@gmail.com	scrypt:32768:8:1$w2NKjknvBhRsd9Mf$2b9a58770f6b7a720329a0a2c786db3058d09e888daf129dc46b38e489a583f42ee2fa0f6138c79cace72fcf07e9a7710814cefd96b62062e6dbdab4382739c6	t
29	alexandra.diudea	diudea.alexandra@gmail.com	scrypt:32768:8:1$hzXwX7bcmICIVpGf$8c417c71ba87d991676a1a44cfcceeb3c8bf111024c6d639a44f752e2e747030d0f3879518177792457dfc65020bcc63ba4018e7577a895e8a9f5925cda62467	t
30	AgataVitan	agatavitan24@gmail.com	scrypt:32768:8:1$vrEu1VKN0uM3HL2k$e638b831fc9917cf1c8cbfa2a5235276b28f0424b731c5fbaf7b5f82d4c66e3499a9239520d3e9cb81aab4dcf615288b5ff401c5c5d9ecc371c3a274173b68c9	t
33	anastasia.guta	guta.anastasia@gmail.com	scrypt:32768:8:1$MPqUp89Am99htRmG$c24b740fa23a866a7e1bd2661d08844b49fc380fdbfd9e7e8dc269066b160d47a73dc0388ba6eb7db65d5a020555bf25327a6bd87e43ea1934fa495526f1bba7	t
31	DDTisntdark	ddtisntdark@gmail.com	scrypt:32768:8:1$ZqDT0NHSCsZA3eh6$33e23e448df49450a412884264c8d441414a6f1cfa5a03946a21722df751adbd5159b7a160ea0ea0f24dae4dfee2c33ee905c3ff5a55635a7f2c576bd4a15cd6	t
32	ioanacassandra	ioanacassandra09@gmail.com	scrypt:32768:8:1$XZql1hG59r7i3JeV$dba99afb538b95e7fb53fe3046e8bc44084a051ed9584adf0f2b66ed118e3bb08849a09a4cd28e4343a0ffa5bac8b0fa95eb67927ed5773340ad226078ce85c9	t
34	Balbarau Alexia	alexiabalbarau@gmail.com	scrypt:32768:8:1$0F80j2dO1X1hD7Gm$d1f963e3b87ffe5b7659550c0ab2dd5ec79e57aa897926159e65d98a600fac741641951bff0cb88ee5a7db13d37e16ed6159387d8fb2b95300715acc33483f62	t
35	Radu	Raduu.iilea@gmail.com	scrypt:32768:8:1$e80SW2XIc3ZspAvu$c28f9b5b3eec1becb55059680ea441ab5e59323ca0e261e2ac494de02d07873c1277ca63dc81832e0fb4e6999704aa4b6f9d95d93ed3af90854689d9f5c7288f	t
36	Alufi Noa	noaalufi@gmail.com	scrypt:32768:8:1$sEpGdmZGjwbPMhsn$8ac56d22f325f0ea2ae593e754889758cb7ae48c2d1228341e68670aac2b8810c6cdd456c3fbc9c65f3cd549cd1081ca0c894f92e6b90df27022c262ee07b198	t
37	Anastasia Tache	tch.anastasia.tache@gmail.com	scrypt:32768:8:1$eeiJSysUEOFqX2uG$b486e72365efbedf3aa5799f3454f9a8117a0ce0a1fbece4fb35637e9ff2bc14c011f1cdc52ff46430d96176317081ddd07315405f1049050e004b968fb33f97	t
38	Matache Monica	ioanamatache87@yahoo.com	scrypt:32768:8:1$WOS3czmoWQuRwIvh$0f734c2b7adb2a00608762a8696f5d00f07912e742cb9c3bc7c1878584f36849641089592963e693d9dd3add3717b7041750bbb8e8dcf9d267ee58217632d29c	t
39	diana1012082	dindeal.diana@gmail.com	scrypt:32768:8:1$cnLu1RU8nltAeLCH$58bf812a41e7bf2c11dd8170fedaef32e27328125d43315a64f9bb739f4363d124d4ff03849cd596325f8435ad3670f5ff689f1345dfd83ebb4e8ec440b24474	t
40	cc_maryya	cc.mariaaa14@gmail.com	scrypt:32768:8:1$UME2ONT8VSvY8Moa$7b091ce745d9198375d94560a905c8b9fd4d8194becc32e7d7a1c0019ff13c1e127ad3abc47ea3b38b9019e8141ca5937caaf4db02720b16bcb7c817a37bc226	t
41	maia.chvrs	oofoopugh@gmail.com	scrypt:32768:8:1$nBut6CaS5T10k0iW$42d602df05e65eb1604b89814b94aeac7e93c295631f42dd8a2ef1268fdfe8ed56236a55db06b48f3968022e4c96270944346955f8fd1c4fdc039afc3b3b91d9	t
42	lucanen	luka.nenciulescu@gmail.com	scrypt:32768:8:1$8JO1h8t6PBZ3iorR$c6a3c23e09344a1f6adef22db3376dc21e05dd1bf53ab4fcd8b15bf1fb4efa49049a1f5c2241ced361f2a92611d6b1e13131a0a536e9a60c84d7613ee7dbd29e	t
43	carlaa.gh	carla.ursulica@gmail.com	scrypt:32768:8:1$OxHYEaQs4K6xMLUs$bd0f3e1d13f901c5f250be9cf8d184e77eb1d8aaecc3bef7774a80891f51b7589eee7ecce8169021a70b381353d713e98b9784b380a6c42dec1fab790462cb38	t
44	Medeea Mihuta	medeea.mihuta@gmail.com	scrypt:32768:8:1$AXQvqNVgjRmJhTXB$3af70f2485c40f4eb4c8a9570d3499c8c82cdd75bba5b900cb8eb17ddc238f166105b4e8ce7c4bdb52b9493437e78f8342b531552f15d3aa306cd9c1bb8815c7	t
45	hallomary	marinaandreea1977@gmail.com	scrypt:32768:8:1$dL2AJ2XnO4z66lQr$9269f4c836d17f9e6df9fb011182513e5e0ec3be6f0317d91fad2533b4f92ad634fe18f9a0f3e32348f305ace8b14c746546d48e21d43f52e5b00b425eda98c3	t
46	edutzu	eduardaneliuc@gmail.com	scrypt:32768:8:1$zi7yHNHyrTHXsPyF$8abf55f6465da0175bf457f8cd2e05639c0d65de03f5555ebbbe6436b31b0157c73d0ce8d9641f5b199c4fe3b276f53e7bfa148868fb3d28d004e65158cd65b3	t
47	Sonia Dobre	soniadobre3@gmail.com	scrypt:32768:8:1$qbnf1RjrRxb5gWat$566c1b597c312fc1cdd06d4585a4713b07b0a17e09a8f416bf7dcc024a62ba218fc63daa348eed1a22e08fe42c6c3049be2cfb106db368f48e5533a8ceac14f0	t
48	Gabriela	gabrielaraducanu19@gmail.com	scrypt:32768:8:1$ZAF6LoZV3RAisWhi$1ed598afe3deb0da7577899697bcef3c6f29d7758ca99997679db3a327326641e8dd7f7cad1040856098ef03e2601889fcb4447c62ba3808c75cdf626ff2be3d	t
50	Radu.Marina.Andreea	marina.radu2015@gmail.com	scrypt:32768:8:1$68ha3q2L130OBZSx$1eb6bdd0e4d44ca0b24036746082cdfc64169dac50f414fd9e6c4d4a6b9895ae9081f8cd49697cce87eb1409712cc08b3fda9762141431142eef2c99ab38dac6	t
49	Alesia	alebalogh51@gmail.com	scrypt:32768:8:1$WYP7YNpETj9xS7Kv$cb3e013ecb5f61fa45da51498c332079bfb2f23cdaf5025ea8c9df84f805afeceaa21c8de399e9d06f6771eabe61cf2a7dbed7f05a5284d738664e772489355b	t
51	alexandra.chiorean	alexandrachiorean22@yahoo.com	scrypt:32768:8:1$wabjFtY7kjIKXWY4$b1d59193331b118408ea528ce9ab2b4f72acbae2a6813132d3623175b77d52c66871ad6958b3580c1e422c713be728244b1aa71b3e6efba48ae3ce2aaf5252c2	t
52	DraghiciDaniel	draghici1805@gmail.com	scrypt:32768:8:1$dUQjHsS52l3TY4pA$220e6c5e43b7d1ece909f9f3bfb9e92d40d50a6d9901f873847af449749a329161909e372e1fe6fdf9d3d72a40dbe719c187b9c72203d1d5ff37627766f0ae9f	t
55	SabrinaGiulia	msgiulia2008@yahoo.com	scrypt:32768:8:1$0sCGXu457bMxNIRn$757a025a57df8f5a65cf12124db09d83fb67604178933cc72609a8b5db16befa49ad0988e27675bfff46f7b192e4b30f13af97fb97323a322e57eff06873a018	t
54	Thenura	thenurawick@gmail.com	scrypt:32768:8:1$W0dE9gT1LvtxXvwo$7c6ae22b509afe6a566a369587ae465b65fcefe266df6be82f190179aeae39aacc8fb9fd6a6de4aac79fb5a0898848f086bceb2420d042d578fdc1abe938e65d	t
56	Ränteli	vilkau@hotmail.com	scrypt:32768:8:1$wmIF3GporZw1ExJB$d5e7acdae2c5cee15c02f96021d8a61ba60e04cd66397475a7aeb4d68d87ac887c8ec79604f8f8dc7f2acf4929f082e36a09fce1c9afe6719e6e70df18df98a2	t
58	ursleepyfriend	anca.badii@gmail.com	scrypt:32768:8:1$nboQO8bu21AnyUz7$8f641fb496a74eba86f084406e9354adbe6660d969abb976fa92e8ceee80a547f8dc0bc6f913f34abb601ca040bc911c1fb136600b91463c1d165373576f3940	t
57	maria	mariacristofor@icloud.com	scrypt:32768:8:1$ECiLMA8hT6jHkDLI$3848623614eaf38ac1e2fd5248837473396c395069d65e19efc060a28c71b949e113d5761cec1723fad83047b7dfff65c4fc50b7fe5eeb6d2ea935867c926f7f	t
53	Eliza_Calinovschi	calibeni69@yahoo.com	scrypt:32768:8:1$DsipJVrvT6NMr8Rb$5896b2629ac9e7c5420637569ed29793d7d991ebd27b5a2ed6eeb92d6229f2df78409b2f23b0c77897df0d91ccdd1be03c14b1a1cf93beb06534db45811b119d	t
59	Cristi	cristierikcris@gmail.com	scrypt:32768:8:1$UermicX6rpDrwIom$7af65b4acabf47e2f1ccca6ce6b2e5b4cad4777825d32f2bfd074115ea3cb07a99bddbeb5b66508a4b0e9bae2dcea3d6519437c6f7a9ee9db5e677d2b44a6fe5	t
60	egosumms	diannabronte@gmail.com	scrypt:32768:8:1$S4k1UAYx9qkGh351$475539d262fc47b61b32295004cacd8f04a97d22747436cebdf3bdd8d649dd6c021978443b48800c3258f1006cf10b0a5b4e0ab376b3b6604d28ddb90152ff6d	t
61	Karla	intorsurakarla@gmail.com	scrypt:32768:8:1$Aqs9vFLacUVBYSD1$a8a562e2c95f64f13fc56f8517778ddc2647d43f9c0223f50bccc228b0e73e054c88e4f60f8656a436e7bf96f4e4606dae625165c1ce0aec76277a8bc5152343	f
62	alissa	alissa.bocance@gmail.com	scrypt:32768:8:1$S7B3FW0sGrRxe6HO$ad4dd7c0398d03ab89421e8295980bbb96d824c17057f064b23731f0c4b9f270a90f9d2f742734cf44cc2e29a7bdc8b2459d0ca2080dcf50f7afecda90792121	f
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-09-07 09:19:25
20211116045059	2025-09-07 09:19:27
20211116050929	2025-09-07 09:19:29
20211116051442	2025-09-07 09:19:31
20211116212300	2025-09-07 09:19:33
20211116213355	2025-09-07 09:19:34
20211116213934	2025-09-07 09:19:36
20211116214523	2025-09-07 09:19:38
20211122062447	2025-09-07 09:19:40
20211124070109	2025-09-07 09:19:41
20211202204204	2025-09-07 09:19:43
20211202204605	2025-09-07 09:19:44
20211210212804	2025-09-07 09:19:50
20211228014915	2025-09-07 09:19:51
20220107221237	2025-09-07 09:19:53
20220228202821	2025-09-07 09:19:54
20220312004840	2025-09-07 09:19:56
20220603231003	2025-09-07 09:19:59
20220603232444	2025-09-07 09:20:00
20220615214548	2025-09-07 09:20:02
20220712093339	2025-09-07 09:20:04
20220908172859	2025-09-07 09:20:05
20220916233421	2025-09-07 09:20:07
20230119133233	2025-09-07 09:20:08
20230128025114	2025-09-07 09:20:11
20230128025212	2025-09-07 09:20:12
20230227211149	2025-09-07 09:20:14
20230228184745	2025-09-07 09:20:15
20230308225145	2025-09-07 09:20:17
20230328144023	2025-09-07 09:20:19
20231018144023	2025-09-07 09:20:21
20231204144023	2025-09-07 09:20:23
20231204144024	2025-09-07 09:20:25
20231204144025	2025-09-07 09:20:26
20240108234812	2025-09-07 09:20:28
20240109165339	2025-09-07 09:20:29
20240227174441	2025-09-07 09:20:32
20240311171622	2025-09-07 09:20:34
20240321100241	2025-09-07 09:20:38
20240401105812	2025-09-07 09:20:42
20240418121054	2025-09-07 09:20:45
20240523004032	2025-09-07 09:20:50
20240618124746	2025-09-07 09:20:52
20240801235015	2025-09-07 09:20:53
20240805133720	2025-09-07 09:20:55
20240827160934	2025-09-07 09:20:56
20240919163303	2025-09-07 09:20:59
20240919163305	2025-09-07 09:21:00
20241019105805	2025-09-07 09:21:02
20241030150047	2025-09-07 09:21:08
20241108114728	2025-09-07 09:21:10
20241121104152	2025-09-07 09:21:12
20241130184212	2025-09-07 09:21:13
20241220035512	2025-09-07 09:21:15
20241220123912	2025-09-07 09:21:17
20241224161212	2025-09-07 09:21:18
20250107150512	2025-09-07 09:21:20
20250110162412	2025-09-07 09:21:21
20250123174212	2025-09-07 09:21:23
20250128220012	2025-09-07 09:21:24
20250506224012	2025-09-07 09:21:26
20250523164012	2025-09-07 09:21:27
20250714121412	2025-09-07 09:21:29
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-09-07 09:19:22.47542
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-09-07 09:19:22.485216
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-09-07 09:19:22.491113
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-09-07 09:19:22.527564
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-09-07 09:19:22.60001
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-09-07 09:19:22.606651
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-09-07 09:19:22.613566
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-09-07 09:19:22.619316
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-09-07 09:19:22.62469
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-09-07 09:19:22.630171
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-09-07 09:19:22.635797
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-09-07 09:19:22.643952
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-09-07 09:19:22.651319
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-09-07 09:19:22.657508
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-09-07 09:19:22.66477
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-09-07 09:19:22.697518
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-09-07 09:19:22.703508
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-09-07 09:19:22.709296
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-09-07 09:19:22.717142
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-09-07 09:19:22.726591
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-09-07 09:19:22.732523
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-09-07 09:19:22.741951
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-09-07 09:19:22.782598
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-09-07 09:19:22.795831
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-09-07 09:19:22.803517
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-09-07 09:19:22.810416
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: observation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.observation_id_seq', 650, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_id_seq', 62, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_client_id_key UNIQUE (client_id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: observation observation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.observation
    ADD CONSTRAINT observation_pkey PRIMARY KEY (id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_client_id_idx ON auth.oauth_clients USING btree (client_id);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: observation observation_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.observation
    ADD CONSTRAINT observation_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: observation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.observation ENABLE ROW LEVEL SECURITY;

--
-- Name: user; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

