package com.microservice.cliente.persistence;

import com.microservice.cliente.entities.Cliente;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IClienteRepository extends CrudRepository<Cliente, Long> {

    List<Cliente> findAllByElevadorId(Long elevadorId);
}
