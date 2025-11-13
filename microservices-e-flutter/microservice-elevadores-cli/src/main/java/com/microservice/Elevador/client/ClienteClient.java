package com.microservice.Elevador.client;

import com.microservice.Elevador.controller.sto.ClienteDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

// Para LAN: cambiar URL de localhost a IP del servidor
@FeignClient(name = "msvc-cliente")
public interface ClienteClient {

    @GetMapping("/api/cliente/search-by-elevador/{elevadorId}")
    List<ClienteDTO> findAllClienteByElevador(@PathVariable Long elevadorId);
}

