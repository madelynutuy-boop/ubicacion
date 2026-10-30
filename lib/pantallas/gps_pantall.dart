import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gps/database_helper.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

class GpsPantall extends StatefulWidget {
  const GpsPantall({super.key});

  @override
  State<GpsPantall> createState() => _GpsPantallState();
}

class _GpsPantallState extends State<GpsPantall> {

  String mensaje='';
  double latitud=0;
  double longitud=0;

  //variable para caotrolar el mapa
  final MapController miMapcontroller = MapController();

  //Ubucación por defecto inicial al momneto de cargar el mapa
  LatLng ubicacionInicail= const LatLng(14.6253428, -90.5113095);
  bool tieneUbicacion=false;

//future porque se activa y despues de unos segundos o minutos obtiene los resultados

 Future<void> obtenerUbicacion()async{
bool servicioHabilitado;
LocationPermission tengoPermisos;

  //verificar si se encuentra activo el servicio de ubicación
  servicioHabilitado = await Geolocator.isLocationServiceEnabled();
  if (servicioHabilitado){
    setState(() {
      mensaje='Servicio de ubicación activado';
    });
  }else{
    setState(() {
      mensaje='Servicio de ubicación desactivado';
    });
    return;
  }
  //verificar si tengo los permisos para la ubicación
  tengoPermisos = await Geolocator.checkPermission();

  if (tengoPermisos == LocationPermission.denied){
    tengoPermisos == await Geolocator.requestPermission();
    print(tengoPermisos);
    if(tengoPermisos== LocationPermission.denied){
      setState(() {
        mensaje='Los permisos de ubucacion fueron permitidos';
      });
      return;
    }else{
      mensaje='Los mensajes de ubicacion fueron denegados';
    }
  }
  //obtener la ubicacion actual
  setState(() {
    mensaje = 'Obteniendo Ubicación Actual......';
      });
      Position posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds:15)
      )
      );
  // mostrar los datos de ubucacion geografica
 setState(() {
   latitud=posicion.latitude;
   longitud=posicion.longitude;
   //asignar la nueva ubucacion a la variable ubicacion inicial
   ubicacionInicail = LatLng(posicion.latitude, posicion.longitude);
   //controla el marcador del mapa 
   tieneUbicacion=true;
   mensaje= 'Ubicacon obtenida con exito';
 });
 miMapcontroller.move(ubicacionInicail, 16.0);
 }

 void compartirUbicacion(){
  if(!tieneUbicacion){
    setState(() {
      mensaje='Primero debes obtener una ubuicación antes de compartir';
    });
    return;
  }
  final String textoParacompartir=
  'Hola esta es mi ubicación\n'
  'desde mi App\n'
  'Latitud $latitud\n'
  'longitud $longitud\n\n'
  'Madelyn Ramos';

  SharePlus.instance.share(
    ShareParams(
      text: textoParacompartir,
      subject: 'Mi ubicación GPS',
    )
  );
 }

Future<void> guardarUbicacion(BuildContext context) async{
    //ingresamos nuestro primer registro
    Map<String, dynamic> nuevaUbicacion = {
      'longitud' : 121221.00,
      'latitud' : 231231321.00,
      'fecha' : '16-10-2026',
      'hora' : '14:54'
    };

    try {
      // Llamamos al método que acabamos de crear en el Helper
      int idReg = await DatabaseHelper.instance.insertarUbicacion(nuevaUbicacion);

      if (idReg > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Ubicación #$idReg guardada en local!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar coordenadas: $e'),
          backgroundColor: Colors.red,
        ),
      );

    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,

          title: Text('GPS Flutter'),
        ),
        body: SizedBox.expand(
          child: Column(
          children: [

            SizedBox(
              height: 150,
              width: double.infinity,
              child: FlutterMap(
                mapController: miMapcontroller,
                options: MapOptions(
                  initialCenter: ubicacionInicail,
                  initialZoom: 12.0,
                ),
                children:[
                  TileLayer(
                    urlTemplate: 'https:/tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_gps',
                  ),
                  //Capa de marcadores
                  MarkerLayer(
                    markers: [
                      if(tieneUbicacion)
                      Marker(
                        point: ubicacionInicail, 
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 45,
                        ))
                    ])
                ]),
            ),
        
        const SizedBox(height: 150,),


        Text('Presione El Botón Para\n   Obtener Ubicación', style: TextStyle(fontSize: 30),),
        SizedBox(height: 20,),

        Text('Latitud $latitud', style: TextStyle(fontSize: 20),),
        SizedBox(height: 15,),
        
        Text('Longitud $longitud',  style: TextStyle(fontSize: 20),),
        SizedBox(height: 15,),

        Text('Mensaje: $mensaje',  style: TextStyle(fontSize: 20),),
        SizedBox(height: 15,),


        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white
              ),
              onPressed: obtenerUbicacion, 
              child: Text('Obtener Ubicación')),
              
              ElevatedButton(
                onPressed: compartirUbicacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white
                ), 
                child: Icon(Icons.share_rounded)),


                 ElevatedButton(
                onPressed: () async {
                  await guardarUbicacion(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white
                ), 
                child: Icon(Icons.save)),
          ],
        ),

        const Text(
                "Historial de ubicaciones",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                          // Ejecuta la consulta de tu base de datos SQLite
                          future: DatabaseHelper.instance.obtenerUbicaciones(),
                          builder: (context, snapshot) {
                            // 1. Estado de carga inicial en disco
                            if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
                            }
                            
                            // 2. Control de errores en la base de datos
                            if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar el historial: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
                            }
                
                            // 3. Estado cuando no existen registros almacenados
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No hay ubicaciones registradas en la base de datos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
                            }
                
                            // 4. Extracción de los datos cuando la consulta es exitosa
                            final listaUbicaciones = snapshot.data!;
                
                            // Generador dinámico de Cards
                            return ListView.builder(
                shrinkWrap: true, // Obligatorio para coexistir dentro de un scroll vertical externo
                physics: const NeverScrollableScrollPhysics(), // Evita conflictos de scroll con la pantalla principal
                itemCount: listaUbicaciones.length,
                itemBuilder: (context, index) {
                  final item = listaUbicaciones[index];
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          '#${item['ubicacion_id']}',
                          style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        'Lat: ${item['latitud']} | Lon: ${item['longitud']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(item['fecha'].toString()),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(item['hora'].toString()),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.blue),
                        onPressed: () {
                          // Mueve el controlador del mapa a las coordenadas de la tarjeta seleccionada
                          miMapcontroller.move(
                            LatLng(item['latitud'], item['longitud']),
                            16.0,
                          );
                        },
                      ),
                    ),
                  );
                }
                            );
                            }
                        ),
              )

      ],
           ) )
    );
  }
}