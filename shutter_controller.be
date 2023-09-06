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

    def init(remote_shutter, open_delay, close_delay)
        self.timer_button = 2
        self.open_timers = [1 , 2]
        self.close_timers = [3 , 4]
        self.stop_buttons = [ 1, 2, 3]
        self.pos = -1
        self.remote_shutter = remote_shutter
        self.open_delay = open_delay * 1000
        self.close_delay = close_delay * 1000
        # Trigger if shutter is moving
        tasmota.add_rule("Shutter1",def (value) self.event(value) end, 1)
        # Triger for timer
        for i : self.open_timers
            tasmota.add_rule(string.format("Clock#Timer=%i", i), /-> self.timer_open())
        end
        for i : self.close_timers
            tasmota.add_rule(string.format("Clock#Timer=%i", i), /-> self.timer_close())
        end
        # Trigger for Button OFF, means stutter stop.
        for b : self.stop_buttons
            tasmota.add_rule(string.format("POWER%i#State=0", b), /-> self.stop())
        end
    end

    def stop()
        # delete timer, that remote not start moving
        log("Stop Remote shutter")
        tasmota.remove_timer("remote_delay")
        mqtt.publish(self.remote_shutter+"/ShutterStop1", "STOP")
    end

    def event(state)
        if state.find("Direction") == 0 
            self.pos = state.find("Position")
            log(string.format("New shutter position: %i", self.pos))
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
    end

    def shutter_pos(target_pos, remote_delay)
        tasmota.remove_timer("remote_delay")
        log(string.format("Shutter move to %i", target_pos))
        tasmota.cmd("ShutterPosition1 "+str(target_pos))
        tasmota.set_timer(remote_delay, /-> self.remote_shutter_pos(target_pos), "remote_delay")
    end
end

# sc = ShutterController("esp/esp03/cmnd", 0, 10)
