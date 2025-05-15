CREATE TABLE IF NOT EXISTS net_cafe.computer_status (
    status_id SERIAL PRIMARY KEY,
    computer_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    date_start TIMESTAMP NOT NULL,
    date_end TIMESTAMP,
    specs TEXT,
    CONSTRAINT fk_computer FOREIGN KEY (computer_id) REFERENCES net_cafe.computer(computer_id)
);