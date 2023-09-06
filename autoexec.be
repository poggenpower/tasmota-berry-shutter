var ShutterController
log("Starting Autoexec")
load('shutter_controller.be')
log("shutter loaded")
#                topic, open_delay, close_delay
sc = ShutterController("esp/esp03/cmnd", 0, 30)