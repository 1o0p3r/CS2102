CREATE TABLE member (
	username VARCHAR(16) PRIMARY KEY,
	password VARCHAR(16) NOT NULL,
    email VARCHAR(64) NOT NULL DEFAULT '',
    biography VARCHAR(256) NOT NULL DEFAULT '',
	is_admin INT NOT NULL DEFAULT 0 CHECK(is_admin=0 OR is_admin=1)
);

CREATE TABLE project (
	id SERIAL PRIMARY KEY CHECK(id >=0),
	title VARCHAR(256) NOT NULL,
	description VARCHAR(2048) NOT NULL DEFAULT '',
	category VARCHAR(256) NOT NULL CHECK(category='Fashion' OR category='Technology' OR category='Games' OR category='Food' OR category='Music' OR category='Photography' OR category='Handicraft' OR category='Community'),
	start_date DATE NOT NULL DEFAULT CURRENT_DATE,
	duration TIME NOT NULL DEFAULT '00:00:00'
);

CREATE TABLE advertise (
	entrepreneur VARCHAR(16) REFERENCES member(username) ON DELETE CASCADE,
	proj_id SERIAL REFERENCES project(id) ON DELETE CASCADE,
	amt_needed NUMERIC(15,2) NOT NULL DEFAULT '0.00' CHECK(amt_needed >= 0),
	amt_raised NUMERIC(15,2) NOT NULL DEFAULT '0.00' CHECK(amt_raised<=amt_needed AND amt_raised>=0),
	status INT NOT NULL DEFAULT 0 CHECK(status=0 OR status=1),
	PRIMARY KEY(proj_id)
);

CREATE TABLE invest (
	investor VARCHAR(16) REFERENCES member(username) ON DELETE CASCADE,
	proj_id SERIAL REFERENCES project(id) ON DELETE CASCADE,
	amount NUMERIC(15,2) NOT NULL DEFAULT '0.00' CHECK(amount >= 0),
	PRIMARY KEY(investor, proj_id)
);

-------------------------------Trigger when modifying email in TABLE member----------------------------------------------
CREATE OR REPLACE FUNCTION modify_email()
RETURNS TRIGGER AS $$
BEGIN
    RAISE 'Please enter a valid email address';
    RETURN NULL;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_modify_email
BEFORE INSERT OR UPDATE ON member
FOR EACH ROW
WHEN (NEW.email <> '' AND NEW.email !~ '\w+@\w+[.]\w+')
EXECUTE PROCEDURE modify_email();
---------------------------------------------------------------------------------------------------------------------

-------------------------------Trigger when inserting into TABLE Invest----------------------------------------------
CREATE OR REPLACE FUNCTION update_amt_raised_when_insert_invest()
RETURNS TRIGGER AS $$
DECLARE 
    amtNeeded NUMERIC(15,2);
    currentAmtRaised NUMERIC(15,2);
    resultingAmtRaised NUMERIC(15,2);
BEGIN
    amtNeeded = (SELECT amt_needed FROM advertise WHERE proj_id = NEW.proj_id);
    currentAmtRaised = (SELECT amt_raised FROM advertise WHERE proj_id = NEW.proj_id);
    IF currentAmtRaised + NEW.amount <= amtNeeded THEN
        UPDATE advertise SET amt_raised=NEW.amount + amt_raised WHERE NEW.proj_id = proj_id;
        RETURN NEW;
    ELSE
        RAISE 'Your investment has exceeded the amount needed. PLease reduce.';
        RETURN NULL;
    END IF;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_update_amt_raised_when_insert_invest
BEFORE INSERT ON invest 
FOR EACH ROW
EXECUTE PROCEDURE update_amt_raised_when_insert_invest();
---------------------------------------------------------------------------------------------------------------------

-------------------------------Trigger when updating amount in TABLE Invest----------------------------------------------
CREATE OR REPLACE FUNCTION update_amt_raised_when_update_invest()
RETURNS TRIGGER AS $$
DECLARE 
    amtNeeded NUMERIC(15,2);
    currentAmtRaised NUMERIC(15,2);
    resultingAmtRaised NUMERIC(15,2);
BEGIN
    amtNeeded = (SELECT amt_needed FROM advertise WHERE proj_id = NEW.proj_id);
    currentAmtRaised = (SELECT amt_raised FROM advertise WHERE proj_id = NEW.proj_id);
    resultingAmtRaised = currentAmtRaised - OLD.amount + NEW.amount;
    IF (resultingAmtRaised > amtNeeded) THEN
        RAISE 'Your investment exceed the amount needed. Please reduce.';
        RETURN NULL;
    ELSE
        UPDATE advertise SET amt_raised=(amt_raised-OLD.amount+NEW.amount) WHERE NEW.proj_id = proj_id;
        RETURN NEW;
    END IF;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_update_amt_raised_when_update_invest
BEFORE UPDATE ON invest 
FOR EACH ROW
EXECUTE PROCEDURE update_amt_raised_when_update_invest();
--------------------------------------------------------------------------------------------------------------------

-------------------------------Trigger when deleting a record in TABLE Invest----------------------------------------------
CREATE OR REPLACE FUNCTION update_amt_raised_when_delete_invest()
RETURNS TRIGGER AS $$
DECLARE 
    currentAmtRaised NUMERIC(15,2);
BEGIN
    currentAmtRaised = (SELECT a.amt_raised FROM advertise a WHERE a.proj_id = OLD.proj_id);
    UPDATE advertise SET amt_raised=(currentAmtRaised-OLD.amount) WHERE proj_id=OLD.proj_id;
    RETURN NEW;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_update_amt_raised_when_delete_invest
AFTER DELETE ON invest 
FOR EACH ROW
EXECUTE PROCEDURE update_amt_raised_when_delete_invest();
--------------------------------------------------------------------------------------------------------------------

-------------------------------Trigger when updating a record in TABLE advertise----------------------------------------------
CREATE OR REPLACE FUNCTION change_status_after_update_advertise()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status=0 THEN
        UPDATE advertise SET status=1 WHERE proj_id = NEW.proj_id;
    ELSE
        UPDATE advertise SET status=0 WHERE proj_id = NEW.proj_id;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_change_status_after_update_amtRaised
AFTER UPDATE on advertise
FOR EACH ROW
WHEN (NEW.amt_raised = OLD.amt_needed AND OLD.status=0 OR NEW.amt_raised <> OLD.amt_needed AND OLD.status=1)
EXECUTE PROCEDURE change_status_after_update_advertise();

CREATE TRIGGER trigger_change_status_after_update_amtNeeded
AFTER UPDATE on advertise
FOR EACH ROW
WHEN (NEW.amt_needed = OLD.amt_raised AND OLD.status=0 OR NEW.amt_needed <> OLD.amt_raised AND OLD.status=1)
EXECUTE PROCEDURE change_status_after_update_advertise();
--------------------------------------------------------------------------------------------------------------------

-------------------------------Trigger when deleting a record in TABLE advertise----------------------------------------------
CREATE OR REPLACE FUNCTION delete_all_investment_when_delete_advertisement()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM invest WHERE proj_id = OLD.proj_id;
	DELETE FROM project WHERE id = OLD.proj_id;
    RETURN NEW;
END; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_delete_all_investment_when_delete_advertisement
AFTER DELETE on advertise
FOR EACH ROW
EXECUTE PROCEDURE delete_all_investment_when_delete_advertisement();
--------------------------------------------------------------------------------------------------------------------
