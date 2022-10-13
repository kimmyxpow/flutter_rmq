import 'package:flutter_app_with_package/base_model.dart';
import 'package:flutter_app_with_package/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class HomeViewModel extends BaseModel {
 MqttService _mqttService = MqttService();

 var value;
 var pompa;
 var statusTanah;

 void initState() async{
   getMessage();
   setBusy(false);
 }

 void getMessage() async {
   _mqttService.subscribe('SmartWatering', getDataMessage);
 }

 void getDataMessage() async {
   _mqttService.client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
     final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
     final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
     value = int.parse(message);
     if(value < 350){
       statusTanah = 'Lembab';
       pompa = 'Off';
     } else if(value > 700){
       statusTanah = 'Kering';
       pompa = 'On';
     } else if(value >= 350 && value <= 700){
       statusTanah = 'Normal';
       pompa = 'Off';
     }
     setBusy(false);
   });
 }
}