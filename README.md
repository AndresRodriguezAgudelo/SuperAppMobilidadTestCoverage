# SuperApp Movilidad

Aplicación móvil desarrollada en Flutter para la gestión de servicios relacionados con la movilidad vehicular, incluyendo gestión de vehículos, alertas, multas, y más.

## Estructura del Proyecto

La aplicación está organizada siguiendo una arquitectura basada en el patrón BLoC (Business Logic Component) para la gestión del estado, con una clara separación de responsabilidades.

### Estructura de Carpetas

```
lib/
├── BLoC/               # Componentes de lógica de negocio
│   ├── alerts/         # Gestión de alertas
│   ├── auth/           # Autenticación y contexto de usuario
│   ├── callCity/       # Información de ciudades
│   ├── document_types/ # Tipos de documentos
│   ├── guides/         # Guías y tutoriales
│   ├── historial_vehicular/ # Historial de vehículos
│   ├── home/           # Lógica de la pantalla principal
│   ├── images/         # Gestión de imágenes y caché
│   ├── insurer/        # Información de aseguradoras
│   ├── multas/         # Gestión de multas
│   ├── pick_and_plate/ # Pico y placa
│   ├── profile/        # Perfil de usuario
│   ├── reset_phone/    # Restablecimiento de teléfono
│   ├── services/       # Servicios disponibles
│   ├── special_alerts/ # Alertas especiales
│   └── vehicles/       # Gestión de vehículos
├── models/             # Modelos de datos
├── screens/            # Pantallas de la aplicación
├── services/           # Servicios (API, almacenamiento, etc.)
├── usefull/            # Utilidades y helpers
│   └── json/           # Archivos JSON para datos estáticos
├── widgets/            # Componentes reutilizables de UI
│   ├── alertas/        # Widgets relacionados con alertas
│   ├── historialVehicular/ # Widgets de historial vehicular
│   ├── identidadSteps/ # Pasos para verificación de identidad
│   ├── inputs/         # Componentes de entrada de datos
│   ├── leftMenu/       # Menú lateral
│   ├── nuestrosServicios/ # Widgets de servicios
│   └── resetSteps/     # Pasos para restablecer cuenta
└── main.dart           # Punto de entrada de la aplicación
```

## Arquitectura y Lógica de la Aplicación

### Patrón BLoC

La aplicación utiliza el patrón BLoC (Business Logic Component) para separar la lógica de negocio de la interfaz de usuario. Cada componente BLoC es responsable de manejar un aspecto específico de la aplicación:

- **AuthContext**: Gestiona el estado de autenticación del usuario, almacenando información como el token, nombre, teléfono y foto de perfil.
- **ProfileBloc**: Maneja la información del perfil del usuario y las operaciones relacionadas.
- **VehiclesBloc**: Gestiona la lista de vehículos del usuario y las operaciones CRUD.
- **AlertsBloc**: Maneja las alertas y notificaciones del sistema.
- **GuidesBloc**: Gestiona las guías y tutoriales disponibles en la aplicación.
- **ImageBloc**: Maneja el caché y la carga de imágenes para optimizar el rendimiento.

### Gestión de Estado

La aplicación utiliza `Provider` como solución de gestión de estado, permitiendo que los widgets accedan a los BLoCs y reaccionen a los cambios en el estado:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthContext()),
    ChangeNotifierProvider(create: (_) => HomeBloc()),
    ChangeNotifierProvider(create: (_) => GuidesBloc()),
    ChangeNotifierProvider(create: (_) => ServicesBloc()),
    ChangeNotifierProvider(create: (_) => ImageBloc()),
    ChangeNotifierProvider(create: (_) => AlertsBloc()),
    ChangeNotifierProvider(create: (_) => VehiclesBloc()),
    ChangeNotifierProvider(create: (_) => ProfileBloc()),
  ],
  child: MaterialApp(...),
)
```

### Comunicación con el Backend

La clase `APIService` centraliza todas las comunicaciones con el backend:

- Implementa métodos para realizar peticiones HTTP (GET, POST, PUT, PATCH, DELETE).
- Maneja la autenticación mediante tokens.
- Proporciona endpoints específicos para cada funcionalidad.
- Gestiona el manejo de errores y respuestas.
- Implementa funcionalidades especiales como la carga de archivos.

### Flujo de Datos

1. **Interfaz de Usuario (Widgets/Screens)**: Captura las interacciones del usuario.
2. **BLoCs**: Procesan las acciones del usuario y actualizan el estado.
3. **Servicios**: Realizan operaciones externas como peticiones a la API.
4. **Modelos**: Representan los datos estructurados de la aplicación.
5. **Notificación**: Los BLoCs notifican a los widgets sobre cambios en el estado.
6. **Actualización de UI**: Los widgets se reconstruyen en respuesta a los cambios de estado.

### Características Principales

- **Autenticación**: Registro, inicio de sesión y recuperación de cuenta.
- **Gestión de Vehículos**: Agregar, editar y eliminar vehículos.
- **Alertas y Notificaciones**: Sistema de alertas para vencimientos y eventos importantes.
- **Historial Vehicular**: Consulta de historial, multas y accidentes.
- **Pico y Placa**: Información sobre restricciones de circulación.
- **Perfil de Usuario**: Gestión de información personal y foto de perfil.
- **Guías y Tutoriales**: Recursos informativos para los usuarios.

### Patrones de Diseño

- **Singleton**: Utilizado en servicios y BLoCs para garantizar una única instancia.
- **Observer**: Implementado a través de ChangeNotifier para notificar cambios de estado.
- **Repository**: Abstracción de la fuente de datos en los servicios.
- **Factory**: Utilizado para la creación de instancias en algunos componentes.

### Funcionamiento del HomeBloc

El `HomeBloc` es uno de los componentes centrales de la aplicación, responsable de gestionar el estado de la pantalla principal y la lista de vehículos del usuario. Su implementación sigue el patrón Singleton para garantizar una única instancia en toda la aplicación.

#### Características principales del HomeBloc:

1. **Gestión de vehículos**:
   - Almacena la lista de vehículos del usuario (`_cars`).
   - Proporciona métodos para cargar, actualizar y limpiar la lista de vehículos.
   - Implementa un sistema de paginación para cargar vehículos por lotes.

2. **Control de peticiones HTTP**:
   - Utiliza un sistema de "switch" (`_requestSwitch`) para habilitar o deshabilitar las peticiones al servidor.
   - Cuando `_requestSwitch = 1`, las peticiones están bloqueadas.
   - Cuando `_requestSwitch = 0`, las peticiones están habilitadas.
   - Métodos `enableRequests()` y `disableRequests()` para controlar este comportamiento.

3. **Gestión de guías**:
   - Almacena el número total de guías disponibles (`_totalGuides`).
   - Proporciona el método `loadTotalGuides()` para obtener esta información del servidor.

4. **Inicialización y estado**:
   - Implementa un sistema de inicialización automática al crear la instancia.
   - Mantiene banderas de estado como `_isLoading`, `_error` e `_isInitialized`.
   - Proporciona el método `initialize()` para cargar los datos iniciales.

5. **Optimización de rendimiento**:
   - Implementa un sistema de debounce para evitar múltiples llamadas al servidor.
   - El método `forceReload()` utiliza un temporizador para evitar sobrecarga de peticiones.

#### Código clave del HomeBloc:

```dart
// Control de peticiones
void enableRequests() {
  print('\n🔓 HABILITANDO PETICIONES (switch = 0)');
  _requestSwitch = 0;
  notifyListeners();
}

void disableRequests() {
  print('\n🔒 DESHABILITANDO PETICIONES (switch = 1)');
  _requestSwitch = 1;
  notifyListeners();
}

// Carga de vehículos
Future<void> getCars({int page = 1, int take = 10, bool force = false}) async {
  // Verificar el switch de peticiones
  if (_requestSwitch == 1 && !force) {
    print('\n🔒 PETICIÓN BLOQUEADA: getCars() - Switch está en $_requestSwitch');
    return;
  }
  
  // Resto de la implementación...
}
```

### Actualización de Estado de Vehículos en Add Vehicle Screen

La pantalla de añadir vehículo (`AgregarVehiculoScreen`) implementa un flujo específico para gestionar el estado de los vehículos durante el proceso de creación:

#### Flujo de actualización de estado:

1. **Inicio del proceso**:
   - Al iniciar la pantalla, se deshabilitan las peticiones automáticas mediante `homeBloc.disableRequests()`.
   - Esto evita que se realicen peticiones innecesarias mientras el usuario está en el proceso de añadir un vehículo.

   ```dart
   @override
   void initState() {
     super.initState();
     _documentTypesBloc = DocumentTypesBloc();
     
     // Deshabilitar las peticiones al iniciar el proceso de agregar vehículo
     final homeBloc = HomeBloc();
     homeBloc.disableRequests();
     print('\n🔒 PETICIONES DESHABILITADAS al iniciar agregar vehículo');
     
     // Resto de la implementación...
   }
   ```

2. **Finalización exitosa**:
   - Cuando el vehículo se crea correctamente, se habilitan nuevamente las peticiones con `homeBloc.enableRequests()`.
   - Se fuerza una actualización de la lista de vehículos con `homeBloc.getCars(force: true)`.
   - Se cargan las alertas para el nuevo vehículo a través del `AlertsBloc`.

   ```dart
   if (success) {
     try {
       // Habilitar las peticiones después de agregar el vehículo
       final homeBloc = Provider.of<HomeBloc>(context, listen: false);
       homeBloc.enableRequests();
       
       // Actualizar la lista de vehículos
       await homeBloc.getCars(force: true);
       
       // Cargar alertas para el nuevo vehículo
       if (homeBloc.cars.isNotEmpty) {
         // Buscar el vehículo recién creado
         final newVehicle = homeBloc.cars.firstWhere(
           (car) => car['licensePlate'] == _placa.toUpperCase(),
           orElse: () => homeBloc.cars.first,
         );
         
         final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
         await alertsBloc.loadAlerts(newVehicle['id']);
       }
     } catch (e) {
       // Manejo de errores...
     }
   }
   ```

3. **Manejo de errores**:
   - En caso de error durante la creación del vehículo, también se habilitan las peticiones antes de volver a la pantalla anterior.
   - Se muestra un modal con el mensaje de error correspondiente.

   ```dart
   else {
     // Habilitar las peticiones antes de volver a la pantalla anterior
     try {
       final homeBloc = Provider.of<HomeBloc>(context, listen: false);
       homeBloc.enableRequests();
     } catch (e) {
       print('Error al habilitar peticiones: $e');
     }
     
     // Mostrar modal de error...
   }
   ```

#### Beneficios de este enfoque:

- **Optimización de recursos**: Evita peticiones innecesarias durante el proceso de creación.
- **Consistencia de datos**: Garantiza que la lista de vehículos se actualice correctamente después de añadir uno nuevo.
- **Experiencia de usuario mejorada**: Proporciona retroalimentación inmediata sobre el resultado de la operación.
- **Manejo de errores robusto**: Asegura que las peticiones se habiliten nuevamente incluso en caso de error.

## Configuración del Proyecto

### Requisitos

- Flutter SDK: 3.0.0 o superior
- develop whit Flutter SDK: 3.27.1
- Dart SDK: 2.17.0 o superior

### Dependencias Principales

- **provider**: Gestión de estado
- **http**: Comunicación HTTP
- **firebase_core**: Integración con Firebase
- **image_picker**: Selección de imágenes
- **webview_flutter**: Visualización de contenido web
- **flutter_localizations**: Internacionalización

### Configuración de Entorno

La aplicación utiliza diferentes entornos (desarrollo, staging, producción) configurados en la clase `Environment`:

```dart
class Environment {
  static const String dev = 'https://back-app-equisoft-production.up.railway.app/api/sign/v1';
  static const String staging = 'https://back-app-equisoft-production.up.railway.app/api/sign/v1';
  static const String prod = 'https://back-app-equisoft-production.up.railway.app/api/sign/v1';
}
```

## Ejecución del Proyecto

1. Clonar el repositorio
2. Instalar dependencias: `flutter pub get`
3. Ejecutar la aplicación: `flutter run`

## Contribución

Para contribuir al proyecto, sigue estos pasos:

1. Crea una rama para tu funcionalidad: `git checkout -b feature/nueva-funcionalidad`
2. Realiza tus cambios y haz commit: `git commit -m 'Añadir nueva funcionalidad'`
3. Sube tus cambios: `git push origin feature/nueva-funcionalidad`
4. Crea un Pull Request
