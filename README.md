# 📱 Sensor Recorder App

Una aplicación Flutter que **lee datos en tiempo real del acelerómetro y giroscopio** del celular, permite visualizar la frecuencia de muestreo, cambiar la frecuencia de lectura, exportar los datos a CSV y reiniciar el registro.

## 🚀 Características

- ✅ Lectura en tiempo real del **acelerómetro** y **giroscopio**.
- 🎚 Cambia la **frecuencia de muestreo** entre 20 Hz, 30 Hz, 50 Hz o 60 Hz.
- 📈 Muestra valores actualizados de X, Y y Z para ambos sensores.
- ⏺ Permite **iniciar y detener grabación** de datos.
- 📂 **Exporta** los datos registrados a un archivo CSV.
- ♻️ **Reinicia** los datos con un botón.
- 🌙 Soporte para **modo oscuro y claro** (dependiendo de la configuración del sistema).

## 📦 Librerías utilizadas

- [`sensors_plus`](https://pub.dev/packages/sensors_plus) – Para acceder a sensores del dispositivo.
- [`share_plus`](https://pub.dev/packages/share_plus) – Para compartir el archivo CSV.
- `path_provider` – Para guardar archivos localmente.

## 📐 Unidades de los datos

| Sensor        | Unidad       | Descripción                            |
|---------------|--------------|----------------------------------------|
| Acelerómetro  | m/s²         | Aceleración total (incluye gravedad).  |
| Giroscopio    | rad/s        | Velocidad angular.                     |

> 📌 Si deseas leer solo la aceleración del movimiento (sin la gravedad), puedes usar `userAccelerometerEvents`.

## 📸 Interfaz de usuario

- Menú desplegable para elegir frecuencia.
- Tarjetas separadas para mostrar:
  - Acelerómetro: valores de X, Y y Z.
  - Giroscopio: valores de X, Y y Z.
- Texto con la **frecuencia usada realmente** (calculada y mostrada dinámicamente).
- Botones para:
  - Grabar/detener grabación.
  - Exportar a CSV.
  - Reiniciar datos.

## 💾 Datos exportados

- Los datos se almacenan como un archivo `.csv` que incluye:
  - Timestamp
  - Valores de acelerómetro (X, Y, Z)
  - Valores de giroscopio (X, Y, Z)
  - Frecuencia seleccionada y frecuencia real alcanzada

> Al exportar, se muestra la ruta del archivo y se abre la opción para compartirlo.

## 🔧 Cómo usar

1. Clona este repositorio.
2. Ejecuta `flutter pub get`.
3. Conecta un dispositivo físico o emulador.
4. Ejecuta la app con `flutter run`.
5. Interactúa con los sensores moviendo tu dispositivo.


---

Desarrollado con ❤️ en Flutter.
