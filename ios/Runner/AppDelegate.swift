import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  // Canal de comunicación con Flutter
  private var methodChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Registrar plugins de Flutter
    GeneratedPluginRegistrant.register(with: self)
    
    // Configurar el canal de comunicación con Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      methodChannel = FlutterMethodChannel(name: "com.tuapp/ios_notifications", binaryMessenger: controller.binaryMessenger)
      print("DEBUG_IOS: Canal de comunicación con Flutter configurado correctamente")
    } else {
      print("DEBUG_IOS: ERROR - No se pudo configurar el canal de comunicación con Flutter")
    }
    
    // Configurar Firebase Messaging
    // Verificar si Firebase ya está configurado para evitar inicialización doble
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("DEBUG_IOS: Firebase configurado manualmente en AppDelegate")
    } else {
      print("DEBUG_IOS: Firebase ya estaba configurado por Flutter")
    }
    Messaging.messaging().delegate = self
    
    // Configurar notificaciones
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Recibir token APNs
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Convertir el token a string hexadecimal
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    
    // Logs detallados para depuración
    print("DEBUG_IOS: ============================================================")
    print("DEBUG_IOS: 🔑 APNs TOKEN RECIBIDO: \(token)")
    print("DEBUG_IOS: 🔑 LONGITUD DEL TOKEN: \(token.count) caracteres")
    print("DEBUG_IOS: 🔑 TIMESTAMP: \(Date())")
    print("DEBUG_IOS: ============================================================")
    
    // Enviar el token a Flutter
    methodChannel?.invokeMethod("onReceiveAPNSToken", arguments: token, result: { result in
      if let error = result as? FlutterError {
        print("DEBUG_IOS: ❌ ERROR al enviar APNs token a Flutter: \(error.message ?? "desconocido")")
      } else {
        print("DEBUG_IOS: ✅ APNs token enviado exitosamente a Flutter")
      }
    })
    
    // Pasar el token a Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    print("DEBUG_IOS: 🔄 APNs token pasado a Firebase Messaging")
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Error al registrar para notificaciones
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("DEBUG_IOS: ❌ ERROR AL REGISTRAR PARA NOTIFICACIONES REMOTAS")
    print("DEBUG_IOS: ❌ Error: \(error)")
    print("DEBUG_IOS: ❌ Descripción: \(error.localizedDescription)")
    print("DEBUG_IOS: ❌ Timestamp: \(Date())")
  }
  
  // Recibir notificación cuando la app está en primer plano
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("DEBUG_IOS: ============================================================")
    print("DEBUG_IOS: NOTIFICACIÓN RECIBIDA EN PRIMER PLANO")
    print("DEBUG_IOS: Contenido completo: \(userInfo)")
    print("DEBUG_IOS: ============================================================")
    
    // Intentar extraer título y cuerpo para depuración
    if let aps = userInfo["aps"] as? [String: Any], 
       let alert = aps["alert"] as? [String: Any] {
        let title = alert["title"] as? String ?? "Sin título"
        let body = alert["body"] as? String ?? "Sin cuerpo"
        print("DEBUG_IOS: Título: \(title)")
        print("DEBUG_IOS: Cuerpo: \(body)")
    }
    
    // Enviar la notificación a Flutter
    print("DEBUG_IOS: Intentando enviar notificación a Flutter...")
    methodChannel?.invokeMethod("onReceiveNotification", arguments: userInfo, result: { result in
        if let error = result as? FlutterError {
            print("DEBUG_IOS: ERROR al enviar notificación a Flutter: \(error.message ?? "desconocido")")
        } else {
            print("DEBUG_IOS: Notificación enviada exitosamente a Flutter")
        }
    })
    
    // Mostrar la notificación en iOS (banner, sonido, etc.)
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .sound]])
    } else {
      completionHandler([[.alert, .sound]])
    }
  }
  
  // Manejar tap en notificación
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    
    print("DEBUG_IOS: ============================================================")
    print("DEBUG_IOS: 👆 USUARIO TOCÓ NOTIFICACIÓN")
    print("DEBUG_IOS: 📱 ID de notificación: \(response.notification.request.identifier)")
    print("DEBUG_IOS: 📱 Acción: \(response.actionIdentifier)")
    print("DEBUG_IOS: 📱 Contenido completo: \(userInfo)")
    print("DEBUG_IOS: ============================================================")
    
    // Intentar extraer título y cuerpo para depuración
    if let aps = userInfo["aps"] as? [String: Any], 
       let alert = aps["alert"] as? [String: Any] {
        let title = alert["title"] as? String ?? "Sin título"
        let body = alert["body"] as? String ?? "Sin cuerpo"
        print("DEBUG_IOS: 📱 Título: \(title)")
        print("DEBUG_IOS: 📱 Cuerpo: \(body)")
    }
    
    // Enviar evento a Flutter
    methodChannel?.invokeMethod("onNotificationTap", arguments: userInfo, result: { result in
      if let error = result as? FlutterError {
        print("DEBUG_IOS: ❌ ERROR al enviar evento de tap a Flutter: \(error.message ?? "desconocido")")
      } else {
        print("DEBUG_IOS: ✅ Evento de tap enviado exitosamente a Flutter")
      }
    })
    
    completionHandler()
  }
  
  // Delegado de Firebase Messaging
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("DEBUG_IOS: ============================================================")
    print("DEBUG_IOS: 🔑 FCM TOKEN RECIBIDO: \(fcmToken ?? "nil")")
    print("DEBUG_IOS: 🔑 TIMESTAMP: \(Date())")
    
    // Mostrar solo una parte del token por seguridad si existe
    if let token = fcmToken, !token.isEmpty {
      let start = token.prefix(8)
      let end = token.suffix(8)
      print("DEBUG_IOS: 🔑 Token preview: \(start)...\(end)")
      print("DEBUG_IOS: 🔑 Token length: \(token.count)")
      
      // Enviar el token a Flutter
      methodChannel?.invokeMethod("onToken", arguments: token, result: { result in
        if let error = result as? FlutterError {
          print("DEBUG_IOS: ❌ ERROR al enviar FCM token a Flutter: \(error.message ?? "desconocido")")
        } else {
          print("DEBUG_IOS: ✅ FCM token enviado exitosamente a Flutter")
        }
      })
    } else {
      print("DEBUG_IOS: ⚠️ FCM Token recibido es nil o vacío")
    }
    print("DEBUG_IOS: ============================================================")
  }
}