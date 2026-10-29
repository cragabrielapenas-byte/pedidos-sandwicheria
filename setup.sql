-- App Pedidos Sandwichería · Panificadora Amsterdam
-- Pegar entero en Supabase > SQL Editor > New query > Run (proyecto de la app de mantenimiento)

create table if not exists sw_clientes (
  id bigint generated always as identity primary key,
  nombre text not null unique,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists sw_productos (
  id bigint generated always as identity primary key,
  nombre text not null unique,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists sw_pedidos (
  id bigint generated always as identity primary key,
  cliente_id bigint references sw_clientes(id),
  cliente text not null,                -- nombre guardado al momento del envío
  items jsonb not null,                 -- [{"producto":"BLANCO FINO","cantidad":20}, ...]
  estado text not null default 'nuevo' check (estado in ('nuevo','prep','listo')),
  visto boolean not null default false,
  fecha_envio date not null default ((now() at time zone 'America/Montevideo')::date),
  enviado_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists sw_pedidos_fecha_idx on sw_pedidos (fecha_envio);

-- Seguridad: mismo esquema que la app de mantenimiento (acceso con la anon key)
alter table sw_clientes enable row level security;
alter table sw_productos enable row level security;
alter table sw_pedidos enable row level security;
create policy "sw_clientes_anon" on sw_clientes for all to anon using (true) with check (true);
create policy "sw_productos_anon" on sw_productos for all to anon using (true) with check (true);
create policy "sw_pedidos_anon" on sw_pedidos for all to anon using (true) with check (true);

-- Tiempo real
alter publication supabase_realtime add table sw_clientes;
alter publication supabase_realtime add table sw_productos;
alter publication supabase_realtime add table sw_pedidos;

-- Datos iniciales
insert into sw_clientes (nombre) values
  ('BUENAS MIGAS'), ('CONASIR'), ('CONFITERÍA CARRERA'), ('TIENDA INGLESA (BUFFET)')
on conflict (nombre) do nothing;
insert into sw_productos (nombre) values
  ('BLANCO FINO'), ('NEGRO FINO'), ('BLANCO GRUESO')
on conflict (nombre) do nothing;
