--Agregar al final de la función antes del:
--RETURN CURRVAL('movicaja_movicajaid_seq');

    --Validar matriz de riesgo e insertar en perfil transaccional

    select matrizriesgo into itipoderiesgoid from  matrizriesgo(preferenciacaja,pseriecaja);