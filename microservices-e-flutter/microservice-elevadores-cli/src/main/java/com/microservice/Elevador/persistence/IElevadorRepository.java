package com.microservice.Elevador.persistence;

import com.microservice.Elevador.entity.Elevador;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IElevadorRepository extends CrudRepository<Elevador, Long> {
}
