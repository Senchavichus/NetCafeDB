CREATE TABLE IF NOT EXISTS net_cafe.session_service (
    session_service_id SERIAL PRIMARY KEY,
    session_id INT NOT NULL,
    service_id INT NOT NULL,
    CONSTRAINT fk_session FOREIGN KEY (session_id) REFERENCES net_cafe.session(session_id),
    CONSTRAINT fk_service_session FOREIGN KEY (service_id) REFERENCES net_cafe.services(service_id)
);
