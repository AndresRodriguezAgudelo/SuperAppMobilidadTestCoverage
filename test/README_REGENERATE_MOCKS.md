# Instrucciones para regenerar los mocks

Después de actualizar la interfaz de `ImageBloc`, es necesario regenerar los mocks para evitar errores de compilación.

## Pasos para regenerar los mocks:

1. Ejecuta el siguiente comando en la terminal:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

2. Esto regenerará el archivo `mocks.mocks.dart` con las interfaces actualizadas.

## Cambios realizados en la interfaz de ImageBloc:

1. Se modificó el método `getImageUrl` para aceptar un parámetro opcional `forceRefresh`:
   ```dart
   Future<String> getImageUrl(String key, {bool forceRefresh = false});
   ```

2. Se agregó un nuevo método `invalidateCache`:
   ```dart
   void invalidateCache(String key);
   ```

Si no puedes regenerar los mocks, puedes modificar manualmente el archivo `mocks.mocks.dart` para actualizar la firma del método `getImageUrl` y agregar el método `invalidateCache`.
