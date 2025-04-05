CREATE TABLE IF NOT EXISTS net_cafe.staff_service (
    staff_service_id SERIAL PRIMARY KEY,
    staff_id INT NOT NULL,
    service_id INT NOT NULL,
    CONSTRAINT fk_staff FOREIGN KEY (staff_id) REFERENCES net_cafe.staff(staff_id),
    CONSTRAINT fk_service FOREIGN KEY (service_id) REFERENCES net_cafe.services(service_id)
);