package com.microservice.Elevador.Implement;

import com.microservice.Elevador.entity.Elevador;
import com.microservice.Elevador.persistence.IElevadorRepository;
import com.microservice.Elevador.client.ClienteClient;
import com.microservice.Elevador.service.IElevadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ElevadorServiceImpl implements IElevadorService {

    @Autowired
    private IElevadorRepository elevadorRepository;
    
    @Autowired
    private ClienteClient clienteClient;

    @Override
    public List<Elevador> findAll() {
        return (List<Elevador>) elevadorRepository.findAll();
    }

    @Override
    public Elevador findById(Long id) {
        return elevadorRepository.findById(id).orElseThrow(() -> new RuntimeException("Elevador no encontrado con ID: " + id));
    }

    @Override
    public Elevador save(Elevador elevador) {
        return elevadorRepository.save(elevador);
    }
    
    @Override
    public Elevador asignarCliente(Long elevadorId, Long clienteId) {
        Elevador elevador = findById(elevadorId);
        elevador.setClienteId(clienteId);
        return elevadorRepository.save(elevador);
    }
    
    @Override
    public List<?> findClientesByElevadorId(Long elevadorId) {
        return clienteClient.findAllClienteByElevador(elevadorId);
    }
}
