import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/pages/deudas/deudas_page.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/widgets/sheetCard/alert_deudas.dart';
import 'package:abril_driver_app/widgets/sheetCard/body_sheet_card.dart';
import 'package:abril_driver_app/widgets/sheetCard/deudas_contenido.dart';
import 'package:abril_driver_app/widgets/sheetCard/driver_information.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BottomCardSheet extends StatelessWidget {
  final ValueNotifier<double> bottomSheetOffset;
  const BottomCardSheet({
    super.key,
    required this.bottomSheetOffset,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    return Container(
      // color: Colors.amber,
      height: 460,
      width: size.width * 1,
      child: DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.2,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                bottomSheetOffset.value = notification.extent;
                return true;
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.isDarkTheme
                          ? const Color.fromARGB(255, 30, 30, 30)
                          : Color.fromARGB(255, 82, 82, 82),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    )
                  ],
                  color: themeProvider.isDarkTheme
                      ? Color.fromRGBO(71, 71, 71, 1)
                      : page,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child:  Container(
                          color: theme,
                          width: size.width * 1,
                          height: size.height * 0.12,
                          child: DriverHeaderInformation(
                            size: size,
                            themeProvider: themeProvider,
                          ),
                        ),
                       
                      ),
                    ),
                     SliverToBoxAdapter(  
                      child: Center(
                        child:  SizedBox(
                          // color: Colors.amber,
                          width: size.width * 1,
                          height: size.height * 0.08,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: size.height * 0.055,
                                width: size.width * 0.2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                // color: Colors.green,
                                image: DecorationImage(image: NetworkImage(userDetails['profile_picture']))
                                ),
                              ),
                              Container(
                                  height: size.height * 0.055,
                                width: size.width * 0.2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                // color: Colors.green,
                                image: DecorationImage(image: NetworkImage(userDetails['foto_vehiculo']))
                                ),
                              ),
                            ],
                          )
                        ),
                       
                      ),
                    ),
                    SliverList.list(
                      children: [
                        
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.07),
                          child: const Divider(),
                        ),
                        InformacionGeneral(
                          size: size,
                          themeProvider: themeProvider,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.07),
                          child: const Divider(),
                        ),
                        BotonVerDeudas(size: size),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class BotonVerDeudas extends StatelessWidget {
  const BotonVerDeudas({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.05,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.22, vertical: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: newRedColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () {
           
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => DeudasScreen(),
              ),
            );
          },
          child: Text(
            'Ver Deudas',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
