CREATE TABLE IF NOT EXISTS net_cafe.session (
    session_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    computer_id INT NOT NULL,
    staff_id INT NOT NULL,
    time_start TIMESTAMP NOT NULL,
    time_end TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    price NUMERIC(10,2),
    CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES net_cafe.client(client_id),
    CONSTRAINT fk_computer_session FOREIGN KEY (computer_id) REFERENCES net_cafe.computer(computer_id),
    CONSTRAINT fk_staff FOREIGN KEY (staff_id) REFERENCES net_cafe.staff(staff_id)
);
