import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../BLoC/profile/profile_bloc.dart';
import '../BLoC/auth/auth_context.dart';
import '../widgets/notification_card.dart';
import '../BLoC/images/image_bloc.dart';

class ProfilePhoto extends StatefulWidget {
  final String? photoUrl;
  final double size;
  final Function(File)? onImageSelected;
  final bool editable;

  const ProfilePhoto({
    super.key,
    this.photoUrl,
    this.size = 120,
    this.onImageSelected,
    this.editable = true,
  });

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (!widget.editable) return;
    
    debugPrint('Intentando abrir el selector de imágenes...');
    try {
      debugPrint('Llamando a image_picker...');
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      debugPrint('Resultado de image_picker: ${pickedFile?.path}');
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_imageFile!);
        } else {
          // Si no hay un callback externo, manejar la actualización aquí
          _uploadProfilePhoto(_imageFile!);
        }
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      // Mostrar el error al usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _uploadProfilePhoto(File imageFile) async {
    // Verificar si el widget está montado antes de continuar
    if (!mounted) return;
    
    // Obtener referencias a los servicios necesarios
    final authContext = Provider.of<AuthContext>(context, listen: false);
    final profileBloc = Provider.of<ProfileBloc>(context, listen: false);
    final userId = authContext.userId;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID del usuario')),
      );
      return;
    }
    
    // Usar un overlay simple en lugar de un diálogo
    final overlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Actualizando foto...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Insertar el overlay
    Overlay.of(context).insert(overlay);
    
    try {
      // Usar el nuevo método para enviar la imagen como FormData
      debugPrint('Enviando imagen como FormData: ${imageFile.path}');
      final success = await profileBloc.updateProfilePhotoWithFile(userId, imageFile);
      
      // Remover el overlay
      overlay.remove();
      
      // Mostrar notificación de resultado
      if (mounted) {
        NotificationCard.showNotification(
          context: context,
          isPositive: success,
          icon: success ? Icons.check_circle : Icons.error,
          text: success 
              ? 'Foto de perfil actualizada correctamente' 
              : 'No se pudo actualizar la foto de perfil',
          date: DateTime.now(),
          title: success ? 'Actualización exitosa' : 'Error',
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar la foto de perfil: $e');
      
      // Remover el overlay
      overlay.remove();
      
      // Mostrar notificación de error
      if (mounted) {
        NotificationCard.showNotification(
          context: context,
          isPositive: false,
          icon: Icons.error,
          text: 'Error al actualizar la foto de perfil',
          date: DateTime.now(),
          title: 'Error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Contenido del widget
    Widget photoContent = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFF0E5D9E),
        shape: BoxShape.circle,
      ),
      child: _imageFile != null
          ? ClipOval(
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
                width: widget.size,
                height: widget.size,
              ),
            )
          : widget.photoUrl != null
              ? ClipOval(
                  child: widget.photoUrl!.startsWith('http')
                    ? Image.network(
                        widget.photoUrl!,
                        fit: BoxFit.cover,
                        width: widget.size,
                        height: widget.size,
                        // Deshabilitar el caché para forzar la recarga de la imagen
                        cacheWidth: null,
                        cacheHeight: null,
                        // Usar un key único basado en la URL para forzar la reconstrucción cuando cambie la URL
                        key: ValueKey(widget.photoUrl),
                        // Agregar headers para evitar el caché del navegador
                        headers: const {
                          'Cache-Control': 'no-cache, no-store, must-revalidate',
                          'Pragma': 'no-cache',
                          'Expires': '0',
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('⚠️ Error cargando imagen directa: $error');
                          return Icon(
                            Icons.person,
                            color: Colors.white,
                            size: widget.size * 0.5,
                          );
                        },
                      )
                    : FutureBuilder<String>(
                        future: context.read<ImageBloc>().getImageUrl(
                          widget.photoUrl!,
                          // Forzar actualización para evitar problemas de caché
                          forceRefresh: true,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(color: Colors.white);
                          }
                          
                          if (snapshot.hasError || !snapshot.hasData) {
                            print('⚠️ Error obteniendo URL de imagen: ${snapshot.error}');
                            return Icon(
                              Icons.person,
                              color: Colors.white,
                              size: widget.size * 0.5,
                            );
                          }
                          
                          // Generar un timestamp único para esta sesión
                          final timestamp = DateTime.now().millisecondsSinceEpoch;
                          
                          // Crear una key única para forzar la reconstrucción del widget
                          final uniqueKey = ValueKey('${snapshot.data!}_$timestamp');
                          
                          // Construir la URL con un parámetro de consulta para evitar el caché
                          final imageUrl = '${snapshot.data!}?v=$timestamp';
                          print('\n🖼 CARGANDO IMAGEN CON URL: $imageUrl');
                          
                          return Image.network(
                            imageUrl,
                            key: uniqueKey,
                            fit: BoxFit.cover,
                            width: widget.size,
                            height: widget.size,
                            // Deshabilitar completamente el caché de imágenes
                            cacheWidth: null,
                            cacheHeight: null,
                            gaplessPlayback: false, // Desactivar reproducción sin interrupciones
                            // Agregar headers para evitar caché en todos los niveles
                            headers: {
                              'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
                              'Pragma': 'no-cache',
                              'Expires': '0'
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('⚠️ Error cargando imagen con ImageBloc: $error');
                              return Icon(
                                Icons.person,
                                color: Colors.white,
                                size: widget.size * 0.5,
                              );
                            },
                          );
                        },
                      ),
                )
              : Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: widget.size * 0.33,
                ),
    );
    
    // Si no es editable, devolver solo el contenido
    if (!widget.editable) {
      return photoContent;
    }
    
    // Si es editable, envolver en GestureDetector
    return GestureDetector(
      onTap: () {
        debugPrint('Widget tocado');
        _pickImage();
      },
      child: Stack(
        children: [
          photoContent,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit,
                color: Color(0xFF0E5D9E),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
