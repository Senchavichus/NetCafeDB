-- 1. Запрет вставки или обновления строки в session, если staff_id ссылается не на менеджера.

CREATE OR REPLACE FUNCTION net_cafe.check_session_manager()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  PERFORM 1
    FROM net_cafe.staff
   WHERE staff_id = NEW.staff_id
     AND position = 'Менеджер';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Сотрудник % не является менеджером, нельзя закрепить за ним сессию', NEW.staff_id;
  END IF;
  RETURN NEW;
END;
$$;

-- Привязка BEFORE INSERT и BEFORE UPDATE

CREATE TRIGGER trg_session_manager_ins
  BEFORE INSERT ON net_cafe.session
  FOR EACH ROW EXECUTE FUNCTION net_cafe.check_session_manager();

CREATE TRIGGER trg_session_manager_upd
  BEFORE UPDATE OF staff_id ON net_cafe.session
  FOR EACH ROW EXECUTE FUNCTION net_cafe.check_session_manager();



-- 2. Автоматическое завершение действия записи в computer_status при добавлении новой для соответствующего компьютера.

CREATE OR REPLACE FUNCTION net_cafe.close_prev_computer_status()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE net_cafe.computer_status
     SET date_end = NEW.date_start
   WHERE computer_id = NEW.computer_id
     AND date_end IS NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Привязка BEFORE INSERT

CREATE TRIGGER trg_close_prev_status
  BEFORE INSERT ON net_cafe.computer_status
  FOR EACH ROW EXECUTE FUNCTION net_cafe.close_prev_computer_status();



-- 3. Контроль соответствия роли сотрудника и услуг в staff_service

CREATE OR REPLACE FUNCTION net_cafe.check_staff_service_role()
RETURNS TRIGGER AS $$
DECLARE
  v_position VARCHAR;
  v_svc      VARCHAR;
BEGIN
  SELECT position INTO v_position
    FROM net_cafe.staff
   WHERE staff_id = NEW.staff_id;

  SELECT service_name INTO v_svc
    FROM net_cafe.services
   WHERE service_id = NEW.service_id;

  IF v_position = 'Бариста' THEN
    IF NOT (v_svc LIKE 'Чипсы%' OR v_svc LIKE 'Кофе%' OR v_svc LIKE 'энергетик%' OR v_svc LIKE 'газировка%') THEN
      RAISE EXCEPTION 'Бариста % не оказывает услугу %', NEW.staff_id, v_svc;
    END IF;

  ELSIF v_position = 'Администратор' THEN
    IF v_svc NOT IN ('дополнительный контроллер к консоли','VR-шлем') THEN
      RAISE EXCEPTION 'Администратор % не оказывает услугу %', NEW.staff_id, v_svc;
    END IF;

  ELSIF v_position = 'Служба поддержки' THEN
    IF v_svc <> 'Техническая Поддержка' THEN
      RAISE EXCEPTION 'Сотрудник службы поддержки % не оказывает услугу %', NEW.staff_id, v_svc;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Привязка BEFORE INSERT и BEFORE UPDATE

CREATE TRIGGER trg_staff_service_ins
  BEFORE INSERT ON net_cafe.staff_service
  FOR EACH ROW EXECUTE FUNCTION net_cafe.check_staff_service_role();

CREATE TRIGGER trg_staff_service_upd
  BEFORE UPDATE ON net_cafe.staff_service
  FOR EACH ROW EXECUTE FUNCTION net_cafe.check_staff_service_role();


