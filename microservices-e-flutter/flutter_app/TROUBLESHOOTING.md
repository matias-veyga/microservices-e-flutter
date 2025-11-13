# Solución de Problemas - Aplicación Flutter

## Error: ERR_CONNECTION_TIMED_OUT

Este error indica que la aplicación no puede conectarse al API Gateway. Sigue estos pasos:

### 1. Verificar que el Gateway esté ejecutándose

Asegúrate de que todos los servicios estén corriendo:
1. **Eureka Server** (puerto 8761)
2. **Microservicio Clientes** (puerto 8001)
3. **Microservicio Elevadores** (puerto 8002)
4. **API Gateway** (puerto 6768)

### 2. Verificar la configuración del Gateway

El gateway debe estar configurado para escuchar en todas las interfaces. Verifica que en `microservice-gateway/src/main/resources/application.yml` tenga:

```yaml
server:
  port: 6768
  address: 0.0.0.0  # Escuchar en todas las interfaces de red
```

**Importante:** Después de cambiar esta configuración, **reinicia el gateway**.

### 3. Configurar la URL correcta en la app Flutter

Edita `lib/services/api_config.dart` y cambia la URL según tu entorno:

#### Para Emulador Android:
```dart
static const String baseUrl = 'http://10.0.2.2:6768';
```

#### Para Dispositivo Físico Android/iOS:
```dart
// Reemplaza con tu IP local (ej: 192.168.2.3)
static const String baseUrl = 'http://192.168.2.3:6768';
```

#### Para iOS Simulator:
```dart
static const String baseUrl = 'http://localhost:6768';
```

### 4. Obtener tu IP Local

#### Windows:
```bash
ipconfig
```
Busca "Dirección IPv4" (ej: 192.168.2.3)

#### Mac/Linux:
```bash
ifconfig
# o
ip addr
```
Busca la IP de tu interfaz de red (generalmente empieza con 192.168.x.x o 10.x.x.x)

### 5. Verificar conectividad

#### Desde la terminal (Windows):
```bash
curl http://192.168.2.3:6768/api/cliente/all
```

#### Desde el navegador:
Abre: `http://192.168.2.3:6768/api/cliente/all`

Si funciona en el navegador pero no en la app, el problema es la configuración de la URL en Flutter.

### 6. Verificar Firewall

Asegúrate de que el firewall de Windows no esté bloqueando el puerto 6768:

1. Abre "Firewall de Windows Defender"
2. Ve a "Configuración avanzada"
3. Verifica que el puerto 6768 esté permitido

O temporalmente desactiva el firewall para probar.

### 7. Verificar que el Gateway esté registrado en Eureka

1. Abre el navegador en: `http://localhost:8761`
2. Verifica que aparezcan los servicios:
   - msvc-gateway
   - msvc-cliente
   - msvc-elevador

### 8. Hot Restart de la App Flutter

Después de cambiar la URL en `api_config.dart`:
1. Detén la app completamente
2. Ejecuta `flutter clean` (opcional)
3. Ejecuta `flutter pub get`
4. Reinicia la app con `flutter run`

## Error: ERR_NAME_NOT_RESOLVED

Este error indica que la URL no es válida. Verifica:
- Que la URL no tenga espacios
- Que use `http://` (no `https://`)
- Que el puerto sea correcto (6768)
- Que la IP sea correcta

## Error: 404 Not Found

Si obtienes 404, el gateway está funcionando pero:
- Verifica que las rutas en el gateway estén correctas
- Verifica que los microservicios estén registrados en Eureka
- Verifica los logs del gateway para ver errores

## Error: CORS

Si obtienes errores de CORS, verifica que el archivo `CorsGatewayConfig.java` tenga:
```java
corsConfig.setAllowedOrigins(List.of("*"));
```

## Checklist de Diagnóstico

- [ ] Eureka Server ejecutándose (puerto 8761)
- [ ] Microservicio Clientes ejecutándose (puerto 8001)
- [ ] Microservicio Elevadores ejecutándose (puerto 8002)
- [ ] API Gateway ejecutándose (puerto 6768)
- [ ] Gateway configurado con `address: 0.0.0.0` en application.yml
- [ ] Gateway reiniciado después de cambiar configuración
- [ ] URL correcta en `api_config.dart` según el entorno
- [ ] App Flutter reiniciada después de cambiar URL
- [ ] Firewall no bloquea el puerto 6768
- [ ] Todos los servicios visibles en Eureka Dashboard

## Prueba Rápida

1. Abre el navegador en tu computadora
2. Ve a: `http://TU_IP:6768/api/cliente/all`
3. Si funciona, copia esa misma URL a `api_config.dart`
4. Reinicia la app Flutter

