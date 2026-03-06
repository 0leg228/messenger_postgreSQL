-- DROP SCHEMA messenger;

CREATE SCHEMA messenger AUTHORIZATION postgres;

-- DROP SEQUENCE messenger.dict_chat_id_seq;

CREATE SEQUENCE messenger.dict_chat_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE messenger.dict_group_chat_id_seq;

CREATE SEQUENCE messenger.dict_group_chat_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE messenger.logs_id_seq;

CREATE SEQUENCE messenger.logs_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE messenger.users_id_seq;

CREATE SEQUENCE messenger.users_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;-- messenger.dict_chat определение

-- Drop table

-- DROP TABLE messenger.dict_chat;

CREATE TABLE messenger.dict_chat (
	id bigserial NOT NULL,
	id_sender int4 NULL,
	login_sender varchar(50) NULL,
	nickname_sender varchar(100) NULL,
	id_accept int4 NULL,
	login_accept varchar(50) NULL,
	nickname_accept varchar(100) NULL,
	chat_content text NULL,
	date_at timestamp NULL,
	is_group bool NULL,
	CONSTRAINT dict_chat_pkey PRIMARY KEY (id)
);


-- messenger.dict_group_chat определение

-- Drop table

-- DROP TABLE messenger.dict_group_chat;

CREATE TABLE messenger.dict_group_chat (
	id bigserial NOT NULL,
	group_name varchar(200) NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP(0) NULL,
	CONSTRAINT dict_group_chat_pkey PRIMARY KEY (id)
);


-- messenger.logs определение

-- Drop table

-- DROP TABLE messenger.logs;

CREATE TABLE messenger.logs (
	id bigserial NOT NULL,
	activity text NULL,
	ddtm timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	contaiment_1 text NULL,
	contaiment_2 text NULL,
	contaiment_3 text NULL,
	warning bool DEFAULT false NULL,
	CONSTRAINT logs_pkey PRIMARY KEY (id)
);


-- messenger.users определение

-- Drop table

-- DROP TABLE messenger.users;

CREATE TABLE messenger.users (
	id bigserial NOT NULL,
	login varchar(50) NOT NULL,
	nickname varchar(100) NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT users_login_key UNIQUE (login),
	CONSTRAINT users_pkey PRIMARY KEY (id)
);


-- messenger.map_group2users определение

-- Drop table

-- DROP TABLE messenger.map_group2users;

CREATE TABLE messenger.map_group2users (
	id_group int4 NULL,
	id_users int4 NULL,
	CONSTRAINT unique_g2u UNIQUE (id_group, id_users),
	CONSTRAINT id_grop2id_users FOREIGN KEY (id_group) REFERENCES messenger.users(id),
	CONSTRAINT id_users2id_grop FOREIGN KEY (id_users) REFERENCES messenger.dict_group_chat(id)
);



-- DROP FUNCTION messenger.add_user2group(int4, int4);

CREATE OR REPLACE FUNCTION messenger.add_user2group(group_id integer, user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
		begin
			insert into messenger.map_group2users(id_group, id_users)
			values (group_id, user_id);
			raise notice 'user in group';
			insert into messenger.logs (activity, ddtm, contaiment_1,contaiment_2, warning)
			values ('user added to group', current_timestamp,group_id::text, user_id::text, false);
	return;
end;
$function$
;

-- DROP FUNCTION messenger.create_group(varchar);

CREATE OR REPLACE FUNCTION messenger.create_group(p_text character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
		begin
			insert into messenger.dict_group_chat (group_name)
			values (p_text);
			insert into messenger.logs (activity, ddtm, contaiment_1, warning)
			values ('group has created', current_timestamp,p_text::text, false);
			raise notice 'group has created';
	return;
end;
$function$
;

-- DROP FUNCTION messenger.send_message(int4, text, _int4);

CREATE OR REPLACE FUNCTION messenger.send_message(p_id integer, p_text text, d_id integer[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
	 declare 
		p_login_sender varchar(100) := (select login from messenger.users u where p_id=u.id);
		p_nickname_sender varchar(100) := (select nickname from messenger.users u where p_id=u.id);
		p_nickname_accept varchar(100) := (select nickname from messenger.users u where d_id=u.id);
		P_login_accept varchar(100) := (select login from messenger.users u where d_id=u.id);
		begin
			insert into messenger.dict_chat (id_sender,	login_sender, nickname_sender,id_accept,login_accept,nickname_accept,chat_content,date_at)
			values (p_id, p_login_sender, p_nickname_sender, d_id, p_login_accept, p_nickname_accept, p_text,CURRENT_TIMESTAMP);
			raise notice 'messange have sended';
	return;
end;
$function$
;

-- DROP FUNCTION messenger.send_message(int4, text, int4);

CREATE OR REPLACE FUNCTION messenger.send_message(p_id integer, p_text text, d_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
	 declare 
		p_login_sender varchar(100) := (select login from messenger.users u where p_id=u.id);
		p_nickname_sender varchar(100) := (select nickname from messenger.users u where p_id=u.id);
		p_nickname_accept varchar(100) := (select nickname from messenger.users u where d_id=u.id);
		P_login_accept varchar(100) := (select login from messenger.users u where d_id=u.id);
		begin
			insert into messenger.dict_chat (id_sender,	login_sender, nickname_sender,id_accept,login_accept,nickname_accept,chat_content,date_at)
			values (p_id, p_login_sender, p_nickname_sender, d_id, p_login_accept, p_nickname_accept, p_text,CURRENT_TIMESTAMP);
			raise notice 'messange have sended';
	return;
end;
$function$
;

-- DROP FUNCTION messenger.send_message(int4, text, int4, bool);

CREATE OR REPLACE FUNCTION messenger.send_message(p_id integer, p_text text, d_id integer, p_type boolean)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
	 declare 
		p_login_sender varchar(100) := (select login from messenger.users u where p_id=u.id);
		p_nickname_sender varchar(100) := (select nickname from messenger.users u where p_id=u.id);
		p_nickname_accept varchar(100) := (select nickname from messenger.users u where d_id=u.id);
		P_login_accept varchar(100) := (select login from messenger.users u where d_id=u.id);
	begin
		if p_text  ilike any (array ['%хуй%','%пизда%','%вагина%','%пенис%','%хер%','%давалка%','%блядина%']) then
			insert into messenger.logs (activity, ddtm, contaiment_1,contaiment_2,contaiment_3, warning)
			values ('you got an warning', current_timestamp, p_id::text, p_text::text, d_id::text, true);
			raise notice 'you got an warning';
		elseif p_type = false then
			insert into messenger.dict_chat (id_sender,	login_sender, nickname_sender,id_accept,login_accept,nickname_accept,chat_content,date_at, is_group)
			values (p_id, p_login_sender, p_nickname_sender, d_id, p_login_accept, p_nickname_accept, p_text,CURRENT_TIMESTAMP, false);
			raise notice 'messange have sent';
			insert into messenger.logs (activity, ddtm, contaiment_1,contaiment_2,contaiment_3, warning)
			values ('messange have sent', current_timestamp,p_id::text,p_text::text,d_id::text, false);
		elseif p_type = true then
			insert into messenger.dict_chat (id_sender,	login_sender, nickname_sender,id_accept,login_accept,nickname_accept,chat_content,date_at, is_group)
			values (p_id, p_login_sender, p_nickname_sender, d_id, p_login_accept, p_nickname_accept, p_text, CURRENT_TIMESTAMP, true);
			insert into messenger.logs (activity, ddtm, contaiment_1,contaiment_2,contaiment_3, warning)
			values ('messange have sent to group', current_timestamp,p_id::text,p_text::text,d_id::text, false);
			raise notice 'messange have sent to group';
		end if;
	return;
end;
$function$
;