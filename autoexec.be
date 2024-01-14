var ShutterController
log("Starting Autoexec")
load('shutter_controller.be')
log("shutter loaded")
#                topic, open_delay, close_delay
sc = ShutterController("esp/esp03/cmnd", 0, 300)
sc.set_open_timer([1, 2, 3])
sc.set_close_timer([4, 5, 6])


def display_clear()
    tasmota.cmd('DisplayText "[z]"')
    tasmota.cmd("DisplayDimmer 0")
  end
  
def display_l1(state)
  print(f"POWER3 {state}")  
  tasmota.cmd('DisplayText "[z]"')
  tasmota.cmd("DisplayDimmer 6")
  if int(state) == 1
    tasmota.cmd("displaytext [l2c1C1f2]timer")
    tasmota.set_timer(100 * 1000, display_clear, "display_clear")
  else
    tasmota.cmd("displaytext [l2c1C1f2]blocked")     
  end
end

display_l1(tasmota.get_power()[sc.timer_button])
tasmota.add_rule("POWER3#State", display_l1)