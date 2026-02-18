--criar tabela cliente
CREATE TABLE tb_cliente (
  id_cliente NUMBER PRIMARY KEY,
  nome       VARCHAR2(100) NOT NULL,
  email      VARCHAR2(150) UNIQUE,
  cep        VARCHAR2(8),
  uf         VARCHAR2(2) CHECK (UF IN (
     'AC','AL','AP','AM','BA','CE','DF','ES','GO', 'MA', 'MT','MS','MG',
     'PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SE','TO' 
  )),
  ativo      NUMBER(1),
  dt_criacao TIMESTAMP DEFAULT SYSTIMESTAMP,
  dt_atualizacao TIMESTAMP
);

CREATE SEQUENCE SEQ_CLIENTE
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;



CREATE OR REPLACE TRIGGER TGR_CLIENTE_BI
BEFORE INSERT ON TB_CLIENTE
FOR EACH ROW
BEGIN
  IF :NEW.id_cliente IS NULL THEN
    SELECT seq_cliente.NEXTVAl
    INTO :NEW.id_cliente
    FROM DUAL;
  END IF;

  IF :NEW.dt_criacao IS NULL THEN    
     :NEW.dt_criacao := SYSDATE;    
  END IF;

  IF :NEW.dt_atualizacao IS NULL THEN    
     :NEW.dt_atualizacao := SYSDATE;    
  END IF;

END; 