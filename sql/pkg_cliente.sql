--criar função valida E-mail
CREATE OR REPLACE FUNCTION FN_VALIDAR_EMAIL ( p_email VARCHAR2) RETURN NUMBER
  IS 
    BEGIN
      IF p_email IS NULL THEN 
        RETURN 0; 
      END IF;

      IF REGEXP_LIKE (
        p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      ) THEN
          RETURN 1;
      ELSE
          RETURN 0;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END  FN_VALIDAR_EMAIL;

--criar função valida CEP
CREATE OR REPLACE FUNCTION FN_NORMALIZAR_CEP (p_cep VARCHAR2) RETURN NUMBER
  IS
    ls_cep VARCHAR2(8);
    BEGIN
      IF p_cep IS NULL THEN
        RETURN 0;
      END IF;

      ls_cep := REPLACE(p_cep, '-','');

      IF LENGTH(ls_cep) = 8 AND TRANSLATE(ls_cep, '0123456789',' ') IS NULL THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;

    EXCEPTION 
      WHEN OTHERS THEN
        RETURN 0;
    END FN_NORMALIZAR_CEP;

--criar procedure apagar cliente
CREATE OR REPLACE PROCEDURE PRC_DELETAR_CLIENTE(
  p_id_cliente tb_cliente.id_cliente%TYPE
)
  IS  
    BEGIN
      DELETE FROM TB_CLIENTE
      WHERE ID_CLIENTE = p_id_cliente;

      IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,'Cliente não encontrado.');
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END PRC_DELETAR_CLIENTE;

--criar procedure listar clientes
CREATE OR REPLACE PROCEDURE PRC_LISTAR_CLIENTES(
    p_nome VARCHAR2, p_email VARCHAR2, p_rc OUT SYS_REFCURSOR
) 
  IS
  BEGIN
    OPEN p_rc FOR
      SELECT  id_cliente, 
              nome, 
              email,
              cep, 
              uf,  
              dt_criacao
      FROM TB_CLIENTE 
      WHERE (p_nome IS NULL OR UPPER(nome) LIKE UPPER('%'|| p_nome || '%'))
        AND (p_email IS NULL OR UPPER(email) LIKE UPPER('%'|| p_email || '%'))
      ORDER BY NOME;     

  END PRC_LISTAR_CLIENTES;

--PKG SPEC
CREATE OR REPLACE PACKAGE PKG_CLIENTE AS
    --função validar e-mail
    FUNCTION FN_VALIDAR_EMAIL (
      p_email IN VARCHAR2
    ) RETURN NUMBER;

    --função validar CEP
    FUNCTION FN_NORMALIZAR_CEP(
      p_cep IN VARCHAR2
    ) RETURN NUMBER;

    --procedure deletar Cliente
    PROCEDURE PRC_DELETAR_CLIENTE (
      p_id_cliente  IN tb_cliente.id_cliente%TYPE
    );

    --procedure Listar Clientes
    PROCEDURE  PRC_LISTAR_CLIENTES (
      p_nome VARCHAR2, 
      p_email VARCHAR2, 
      p_rc OUT SYS_REFCURSOR
    );

    --validar
    PROCEDURE PRC_VALIDAR(
      p_nome  IN VARCHAR2,
      p_email IN VARCHAR2,
      p_cep   IN VARCHAR2,
      p_uf    IN VARCHAR2
    );

END PKG_CLIENTE;  

--PKG BODY
CREATE OR REPLACE PACKAGE BODY PKG_CLIENTE AS

    --função validar e-mail
    FUNCTION FN_VALIDAR_EMAIL ( 
      p_email VARCHAR2
      ) RETURN NUMBER
      IS 
        BEGIN
          IF p_email IS NULL THEN 
            RETURN 0; 
          END IF;

          IF REGEXP_LIKE (
            p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
          ) THEN
              RETURN 1;
          ELSE
              RETURN 0;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            RETURN 0;
        END  FN_VALIDAR_EMAIL;

    --função validar CEP
    FUNCTION FN_NORMALIZAR_CEP (
      p_cep VARCHAR2
      ) RETURN NUMBER
      IS
        ls_cep VARCHAR2(8);
        BEGIN
          IF p_cep IS NULL THEN
            RETURN 0;
          END IF;

          ls_cep := REPLACE(p_cep, '-','');

          IF LENGTH(ls_cep) = 8 AND TRANSLATE(ls_cep, '0123456789',' ') IS NULL THEN
            RETURN 1;
          ELSE
            RETURN 0;
          END IF;

        EXCEPTION 
          WHEN OTHERS THEN
            RETURN 0;
        END FN_NORMALIZAR_CEP;

    --procedure deletar Cliente
    PROCEDURE PRC_DELETAR_CLIENTE(
      p_id_cliente tb_cliente.id_cliente%TYPE
    )
    IS  
      BEGIN
        DELETE FROM TB_CLIENTE
        WHERE ID_CLIENTE = p_id_cliente;

        IF SQL%ROWCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(-20003,'Cliente não encontrado.');
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          RAISE;
      END PRC_DELETAR_CLIENTE;

    --procedure Listar Clientes
    PROCEDURE PRC_LISTAR_CLIENTES(
    p_nome VARCHAR2, 
    p_email VARCHAR2, 
    p_rc OUT SYS_REFCURSOR
    ) 
    IS
      BEGIN
        OPEN p_rc FOR
          SELECT  id_cliente, 
                  nome, 
                  email,
                  cep, 
                  uf,  
                  dt_criacao
          FROM TB_CLIENTE 
          WHERE (p_nome IS NULL OR UPPER(nome) LIKE UPPER('%'|| p_nome || '%'))
            AND (p_email IS NULL OR UPPER(email) LIKE UPPER('%'|| p_email || '%'))
          ORDER BY NOME;     

      END PRC_LISTAR_CLIENTES;

    --procedure Validar
    PROCEDURE PRC_VALIDAR(
      p_nome  IN VARCHAR2,
      p_email IN VARCHAR2,
      p_cep   IN VARCHAR2,
      p_uf    IN VARCHAR2
    )
    IS 
      BEGIN
        IF p_nome IS NULL OR TRIM(p_nome) IS NULL THEN
          RAISE_APPLICATION_ERROR(-20001,'Nome é obrigatório.');
        END IF;

        IF FN_VALIDAR_EMAIL(p_email) = 0 THEN 
          RAISE_APPLICATION_ERROR(-20001,'E-mail inválido.');
        END IF;

        IF FN_NORMALIZAR_CEP(p_cep) = 0 THEN
          RAISE_APPLICATION_ERROR(-20001,'CEP inválido.');
        END IF;

        IF UPPER(p_uf) NOT IN (
             'AC','AL','AP','AM','BA','CE','DF','ES','GO', 'MA', 'MT','MS','MG',
             'PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SE','TO' 
        )THEN
          RAISE_APPLICATION_ERROR(-20001,'UF inválido.');
        END IF;

      END PRC_VALIDAR;

END PKG_CLIENTE;
