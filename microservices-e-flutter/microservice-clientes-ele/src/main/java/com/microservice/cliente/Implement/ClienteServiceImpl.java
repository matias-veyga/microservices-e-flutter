package com.microservice.cliente.Implement;

import com.microservice.cliente.entities.Cliente;
import com.microservice.cliente.service.IClienteService;
import com.microservice.cliente.persistence.IClienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ClienteServiceImpl implements IClienteService {

    @Autowired
    private IClienteRepository clienteRepository;

    @Override
    public List<Cliente> findAll() {
        return (List<Cliente>) clienteRepository.findAll();
    }

    @Override
    public Cliente findById(Long id) {
        return clienteRepository.findById(id).orElseThrow(() -> new RuntimeException("Cliente no encontrado con ID: " + id));
    }

    @Override
    public Cliente save(Cliente cliente) {
        return clienteRepository.save(cliente);
    }

    @Override
    public List<Cliente> findByElevadorId(Long elevadorId) {
        return clienteRepository.findAllByElevadorId(elevadorId);
    }
    
    @Override
    public List<Cliente> findByClienteId(Long clienteId) {
        Cliente cliente = clienteRepository.findById(clienteId).orElse(null);
        return cliente != null ? List.of(cliente) : List.of();
    }
}
