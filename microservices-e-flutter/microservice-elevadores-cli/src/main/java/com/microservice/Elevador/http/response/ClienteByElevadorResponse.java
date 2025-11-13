package com.microservice.Elevador.http.response;

import com.microservice.Elevador.controller.sto.ClienteDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ClienteByElevadorResponse {

    private String elevadorName;
    private String elevadorMarca;
    private int elevadorCapacidad;
    private String elevadorDireccion;
    private List<ClienteDTO> clienteDTOList;
}
