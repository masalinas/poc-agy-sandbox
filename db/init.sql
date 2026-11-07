-- Demo schema and data (runs once, when the db-data volume is created)
CREATE TABLE customers (
    id      serial PRIMARY KEY,
    name    text NOT NULL,
    country text NOT NULL
);

CREATE TABLE orders (
    id          serial PRIMARY KEY,
    customer_id int NOT NULL REFERENCES customers(id),
    total       numeric(10,2) NOT NULL,
    status      text NOT NULL,
    created_at  date NOT NULL
);

INSERT INTO customers (name, country) VALUES
    ('Ana',   'Spain'),
    ('Luca',  'Italy'),
    ('Marie', 'France'),
    ('Tom',   'UK'),
    ('Sofia', 'Spain');

-- 60 deterministic orders: every 4th cancelled, every 3rd (of the rest) pending, others paid
INSERT INTO orders (customer_id, total, status, created_at)
SELECT (g % 5) + 1,
       (g * 7.5)::numeric(10,2),
       CASE WHEN g % 4 = 0 THEN 'cancelled'
            WHEN g % 3 = 0 THEN 'pending'
            ELSE 'paid' END,
       DATE '2026-01-01' + g
FROM generate_series(1, 60) AS g;

-- Least privilege: the agent can read, but not write or alter anything
CREATE ROLE agent_ro LOGIN PASSWORD 'agent_ro_pw';
GRANT CONNECT ON DATABASE shop TO agent_ro;
GRANT USAGE ON SCHEMA public TO agent_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO agent_ro;