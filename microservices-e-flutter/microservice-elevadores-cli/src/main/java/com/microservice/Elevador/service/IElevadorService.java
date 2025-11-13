package com.microservice.Elevador.service;

import com.microservice.Elevador.entity.Elevador;
import java.util.List;

public interface IElevadorService {

    List<Elevador> findAll();
    Elevador findById(Long id);
    Elevador save(Elevador elevador);
    Elevador asignarCliente(Long elevadorId, Long clienteId);
    List<?> findClientesByElevadorId(Long elevadorId);
}
