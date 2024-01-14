import string
import mqtt

class ShutterController
    var pos
    var remote_shutter
    var open_delay
    var close_delay
    var timer_button
    var open_timers
    var close_timers
    var stop_buttons
    var last_target
    var is_moving
    var remote_timer_active

    def init(remote_shutter, open_delay, close_delay)
        self.is_moving = false
        self.remote_timer_active = false
        self.timer_button = 2
        self.open_timers = [1 , 2]
        self.close_timers = [3 , 4]
        self.stop_buttons = [ 1, 2, 3]
        self.pos = -1
        self.last_target = -1
        self.remote_shutter = remote_shutter
        self.open_delay = open_delay * 1000
        self.close_delay = close_delay * 1000
        # Trigger if shutter is moving
        tasmota.add_rule("Shutter1",def (value) self.event(value) end, 1)
        # Triger for timer
        self.set_open_timer(self.open_timers)
        self.set_close_timer(self.close_timers)
        # take over buttons
        tasmota.add_rule(string.format("Button1#Action=CLEAR", b), /-> self.stop())
        tasmota.add_rule(string.format("Button2#Action=CLEAR", b), /-> self.stop())
        # stop if timer disabled
        tasmota.add_rule("POWER3#State=0", /-> self.stop())
        # connect button with relay
        tasmota.add_rule("Button3#Action=SINGLE", /-> self.toggle_timer())
    end

    def toggle_timer()
        tasmota.set_power( self.timer_button, tasmota.get_power()[self.timer_button] != true)
        log(f"Timer enabled = {tasmota.get_power()[self.timer_button]}")
    end

    def set_open_timer(timer_list)
        for i : self.open_timers
            tasmota.remove_rule(f"Clock#Timer={i}")
        end
        self.open_timers = timer_list
        # Triger for timer
        for i : self.open_timers
            tasmota.add_rule(f"Clock#Timer={i}", /-> self.timer_open())
        end
    end

    def set_close_timer(timer_list)
        for i : self.close_timers
            tasmota.remove_rule(f"Clock#Timer={i}")
        end
        self.close_timers = timer_list
        # Triger for timer
        for i : self.close_timers
            tasmota.add_rule(f"Clock#Timer={i}", /-> self.timer_close())
        end
    end


    def stop()
        # delete timer, that remote not start moving
        log(f"Stop Remote shutter {self.remote_shutter}")
        tasmota.remove_timer("remote_delay")
        self.remote_timer_active = false
        mqtt.publish(self.remote_shutter+"/ShutterStop1", "STOP")
    end

    def event(state)
        if state.find("Direction") == 0 
            self.pos = state.find("Position")
            log(string.format("New shutter position: %i", self.pos))
        elif state.find("Target") != nil
            var target_pos = state.find("Target")
            if self.last_target != target_pos
                if self.remote_timer_active == false
                    # skip remote move, as time will do
                    self.remote_shutter_pos(target_pos)
                end
                self.last_target = target_pos
            end
        end
    end

    def timer_open()
        self.timer_func(100, self.open_delay)
    end

    def timer_close()
        self.timer_func(0, self.close_delay)
    end

    def timer_func(target_pos, remote_delay)
        # timer triggers only timer button enabled.
        if tasmota.get_power()[self.timer_button]
            self.shutter_pos(target_pos, remote_delay)
        else
            log("Time disabled, don't move.")
        end
    end

    def shutter_open()
        self.shutter_pos(100, self.open_delay)
    end

    def shutter_close()
        self.shutter_pos(0, self.close_delay)
    end

    def remote_shutter_pos(target_pos)
        log(string.format("Remote Shutter move to %i", target_pos))
        mqtt.publish(self.remote_shutter+"/ShutterPosition1", str(target_pos))
        self.remote_timer_active = false
    end

    def remote_shutter_timer(target_pos, remote_delay)
        log(f"Schedule remote move in {remote_delay} ms.")
        self.remote_timer_active = true
        tasmota.set_timer(remote_delay, def() self.remote_shutter_pos(target_pos) end, "remote_delay")
    end

    def shutter_pos(target_pos, remote_delay)
        tasmota.remove_timer("remote_delay")
        log(string.format("Shutter move to %i", target_pos))
        tasmota.cmd("ShutterPosition1 "+str(target_pos))
        self.remote_shutter_timer(target_pos, remote_delay)
    end
end

# sc = ShutterController("esp/esp03/cmnd", 0, 10)
