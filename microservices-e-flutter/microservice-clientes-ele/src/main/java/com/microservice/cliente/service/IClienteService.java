package com.microservice.cliente.service;

import com.microservice.cliente.entities.Cliente;
import java.util.List;

public interface IClienteService {

    List<Cliente> findAll();
    Cliente findById(Long id);
    Cliente save(Cliente cliente);
    List<Cliente> findByElevadorId(Long elevadorId);
    List<Cliente> findByClienteId(Long clienteId);
}
