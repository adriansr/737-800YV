
var throttleIdle = 0;
var throttleMax  = .94;
var throttleMovePerSecond = 0.10;
var throttleUpdInterval = 0.05;

var setMaxPower = func{
    setPower(throttleMax, 1.0);
}

var setIdlePower = func{
    setPower(throttleIdle, -1.0);
}

var setPower = func(target, dir) {
    e1p = "controls/engines/engine[0]/throttle";
    var curPower = getprop(e1p);
    if (dir*curPower < dir*target) {
        var timer = maketimer(throttleUpdInterval, func{
            if (getprop(e1p) != curPower) {
                return;
            }
            curPower += dir * throttleMovePerSecond * throttleUpdInterval;
            if (dir*curPower > dir*target) {
                curPower = target;
            }
            for (var i = 0; i < 2; i+=1) {
                setprop("controls/engines/engine["~i~"]/throttle", curPower);
            }
            if (dir*curPower < dir*target) {
               timer.restart(throttleUpdInterval);
            }
        });
        timer.singleShot = 1;
        timer.simulatedTime = 1;
        timer.start();
    }
}

