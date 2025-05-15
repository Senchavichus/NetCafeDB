CREATE TABLE IF NOT EXISTS net_cafe.computer (
    computer_id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    placement VARCHAR(100) NOT NULL
);