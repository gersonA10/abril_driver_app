import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:map_launcher/map_launcher.dart';

class PickUpOpenMap extends StatelessWidget {
  const PickUpOpenMap({
    super.key,
    required this.media,
  });

  final Size media;

  @override
  Widget build(BuildContext context) {
    return (driverReq['is_trip_start'] == 1)
            ? Container()
            :  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                        ),
                      ],
                      color: page,
                      borderRadius: BorderRadius.circular(media.width * 0.02),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          try {
                            final availableMaps = await MapLauncher.installedMaps;

                            final coords = Coords(
                              driverReq['pick_lat'],
                              driverReq['pick_lng'],
                            );

                            if (availableMaps.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No hay aplicaciones de mapas instaladas.')),
                              );
                              return;
                            }

                            // Si solo hay una app → abrir directamente
                            // if (availableMaps.length == 1) {
                            //   await availableMaps.first.showMarker(
                            //     coords: coords,
                            //     title: 'Punto de recogida',
                            //     description: '',
                            //   );
                            //   return;
                            // }

                            // Si hay varias apps → mostrar selección
                            // ignore: use_build_context_synchronously
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          'Abrir con...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      ...availableMaps.map((map) {
                                        return ListTile(
                                          // leading: Image(
                                          //   image: map.icon,
                                          //   height: 30,
                                          //   width: 30,
                                          // ),
                                          title: Text(map.mapName),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await map.showMarker(
                                              coords: coords,
                                              title: 'Punto de recogida',
                                              description: '',
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              },
                            );
                          } catch (e) {
                            debugPrint('Error al abrir el mapa: $e');
                          }
                        },
                        child: SizedBox(
                          height: media.width * 0.1,
                          width: media.width * 0.1,
                          child: Icon(
                            Icons.navigation_rounded,
                            color: const Color.fromARGB(255, 243, 159, 14),
                            size: media.width * 0.068,
                          ),
                        ),
                      ),
                    ),
                  );
      
  }
}
